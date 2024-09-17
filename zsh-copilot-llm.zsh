#!/usr/bin/env zsh

source "${0:A:h}/zsh-copilot-config.zsh"
zsh_copilot_debug "zsh-copilot-llm.zsh started, config loaded"

function call_openai_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Calling OpenAI API with input: $input"

    if [[ -z "$OPENAI_API_KEY" ]]; then
        zsh_copilot_debug "Error: OPENAI_API_KEY is not set"
        echo "Error: OPENAI_API_KEY is not set."
        return 1
    fi

    local data="{
        \"model\": \"$ZSH_COPILOT_OPENAI_MODEL\",
        \"messages\": [
            {
                \"role\": \"system\",
                \"content\": \"$prompt\"
            },
            {
                \"role\": \"user\",
                \"content\": \"$input\"
            }
        ]
    }"
    zsh_copilot_debug "Prepared data for OpenAI API call"

    local response=$(curl "${ZSH_COPILOT_OPENAI_API_URL}/chat/completions" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$data")
    zsh_copilot_debug "Received response from OpenAI API"

    local content=$(echo "$response" | jq -r '.choices[0].message.content')
    zsh_copilot_debug "Extracted content from OpenAI response: $content"
    echo "$content"
}

function call_ollama_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Calling Ollama API with input: $input"

    local data="{
        \"model\": \"$ZSH_COPILOT_OLLAMA_MODEL\",
        \"prompt\": \"$prompt\n\nUser: $input\nPlease provide a single command suggestion, prefixed with '=' for a new command or '+' for a completion. Do not provide explanations.\",
        \"stream\": false
    }"
    zsh_copilot_debug "Prepared data for Ollama API call"

    local response=$(curl "${ZSH_COPILOT_OLLAMA_URL}/api/generate" \
        --silent \
        -H "Content-Type: application/json" \
        -d "$data")
    zsh_copilot_debug "Received response from Ollama API"

    local content=$(echo "$response" | jq -r '.response // empty')
    zsh_copilot_debug "Extracted content from Ollama response: $content"
    echo "$content"
}

function parse_gemini_response() {
    local response=$1
    zsh_copilot_debug "Parsing Gemini response"

    if [[ -z "$response" ]]; then
        zsh_copilot_debug "Error: Empty response from Google Gemini API"
        echo "Error: Empty response from Google Gemini API"
        return 1
    fi

    # Log de la réponse brute
    zsh_copilot_debug "Raw response: $response"

    # Étape 1: Remplacer toutes les nouvelles lignes par des espaces
    local sanitized_response
    sanitized_response=$(echo "$response" | tr '\n' ' ')

    # Log de la réponse sanitisée
    zsh_copilot_debug "Sanitized response: $sanitized_response"

    # Étape 2: Valider la syntaxe JSON
    echo "$sanitized_response" | jq . > /dev/null 2>jq_validation_error.log
    if [[ $? -ne 0 ]]; then
        local validation_error
        validation_error=$(<jq_validation_error.log)
        zsh_copilot_debug "JSON Validation Error: $validation_error"
        echo "Error: Invalid JSON response from Google Gemini API"
        return 1
    fi

    # Étape 3: Extraire le champ 'text' avec jq
    local content
    content=$(echo "$sanitized_response" | jq -r '.candidates[0].content.parts[0].text // empty' 2>jq_error.log)
    local jq_exit_code=$?

    # Vérifier si jq a échoué
    if [[ $jq_exit_code -ne 0 ]]; then
        local jq_error
        jq_error=$(<jq_error.log)
        zsh_copilot_debug "jq Error: $jq_error"
        echo "Error: Failed to parse JSON with jq"
        return 1
    fi

    # Log du contenu extrait
    zsh_copilot_debug "Extracted content with jq: '$content'"

    if [[ -z "$content" ]]; then
        zsh_copilot_debug "Error: Unable to extract content from Google Gemini response"
        echo "Error: Unable to extract content from Google Gemini response"
        return 1
    fi

     # Nettoyage final du contenu
    # 1. Supprimer les espaces au début et à la fin
    # 2. Supprimer le '=+' ou '+=' du début si présent
    # 3. Supprimer tout ce qui suit '#' (y compris '#')
    content=$(echo "$content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^=+/=/' -e 's/^+=/+/' -e 's/#.*$//')

    # Log du contenu nettoyé
    zsh_copilot_debug "Cleaned content from Google Gemini response: '$content'"

    echo "$content"
}


function call_gemini_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Calling Google Gemini API with input: $input"

    if [[ -z "$GOOGLE_API_KEY" ]]; then
        zsh_copilot_debug "Error: GOOGLE_API_KEY is not set"
        echo "Error: GOOGLE_API_KEY is not set."
        return 1
    fi

    local data="{
        \"contents\": [
            {
                \"parts\": [
                    {
                        \"text\": \"$prompt\\n\\nUser: $input\\nPlease provide a single command suggestion, prefixed with '=' for a new command or '+' for a completion. Do not provide explanations.\"
                    }
                ]
            }
        ]
    }"
    zsh_copilot_debug "Prepared data for Google Gemini API call"

    local api_url="${ZSH_COPILOT_GEMINI_API_URL}/models/${ZSH_COPILOT_GEMINI_MODEL}:generateContent?key=$GOOGLE_API_KEY"
    zsh_copilot_debug "API URL: $api_url"

    local response=$(curl "$api_url" \
        --silent \
        -H "Content-Type: application/json" \
        -d "$data")
    
    zsh_copilot_debug "Raw response from Google Gemini API: $response"

    parse_gemini_response "$response"
}

function call_mistral_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Calling Mistral API with input: $input"

    if [[ -z "$MISTRAL_API_KEY" ]]; then
        zsh_copilot_debug "Error: MISTRAL_API_KEY is not set"
        echo "Error: MISTRAL_API_KEY is not set."
        return 1
    fi

    local data="{
        \"model\": \"$ZSH_COPILOT_MISTRAL_MODEL\",
        \"messages\": [
            {
                \"role\": \"system\",
                \"content\": \"$prompt\"
            },
            {
                \"role\": \"user\",
                \"content\": \"$input\"
            }
        ]
    }"
    zsh_copilot_debug "Prepared data for Mistral API call"

    local response=$(curl "${ZSH_COPILOT_MISTRAL_API_URL}/chat/completions" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $MISTRAL_API_KEY" \
        -d "$data")
    zsh_copilot_debug "Received response from Mistral API"

    local content=$(echo "$response" | jq -r '.choices[0].message.content')
    zsh_copilot_debug "Extracted content from Mistral response: $content"
    echo "$content"
}

function call_anthropic_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Calling Anthropic API with input: $input"

    if [[ -z "$CLAUDE_API_KEY" ]]; then
        zsh_copilot_debug "Error: CLAUDE_API_KEY is not set"
        echo "Error: CLAUDE_API_KEY is not set."
        return 1
    fi

    local data="{
        \"model\": \"$ZSH_COPILOT_ANTHROPIC_MODEL\",
        \"max_tokens\": 1024,
        \"messages\": [
            {
                \"role\": \"user\",
                \"content\": \"$prompt\\n Your Search: $input\"
            }
        ]
    }"
    zsh_copilot_debug "Prepared data for Anthropic API call $data"

    local response=$(curl "${ZSH_COPILOT_ANTHROPIC_API_URL}/messages" \
        --silent \
        -H "x-api-key: $CLAUDE_API_KEY" \
        -H "anthropic-version: 2023-06-01" \
        -H "Content-Type: application/json" \
        -d "$data")
    zsh_copilot_debug "Received response from Anthropic API $response"

    local content=$(echo "$response" | jq -r '.content[0].text')
    zsh_copilot_debug "Extracted content from Anthropic response: $content"
    echo "$content"
}

# Update the get_ai_suggestion function
function get_ai_suggestion() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Getting AI suggestion for input: $input"

    local response
    case "$ZSH_COPILOT_LLM_PROVIDER" in
        "openai")
            zsh_copilot_debug "Using OpenAI provider"
            response=$(call_openai_api "$input" "$prompt")
            ;;
        "ollama")
            zsh_copilot_debug "Using Ollama provider"
            response=$(call_ollama_api "$input" "$prompt")
            ;;
        "gemini")
            zsh_copilot_debug "Using Google Gemini provider"
            response=$(call_gemini_api "$input" "$prompt")
            ;;
        "mistral")
            zsh_copilot_debug "Using Mistral provider"
            response=$(call_mistral_api "$input" "$prompt")
            ;;
        "claude")
            zsh_copilot_debug "Using Anthropic provider"
            response=$(call_anthropic_api "$input" "$prompt")
            ;;
        *)
            zsh_copilot_debug "Error: Invalid LLM provider specified: $ZSH_COPILOT_LLM_PROVIDER"
            echo "Error: Invalid LLM provider specified"
            return 1
            ;;
    esac

    if [[ $? -ne 0 ]]; then
        zsh_copilot_debug "Error occurred while getting AI suggestion"
        return 1
    fi

    zsh_copilot_debug "Raw AI response: $response"

    echo "$response"
}

zsh_copilot_debug "zsh-copilot-llm.zsh loaded successfully"