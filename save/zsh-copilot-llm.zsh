#!/usr/bin/env zsh

source "${0:A:h}/zsh-copilot-config.zsh"
zsh_copilot_debug "zsh-copilot-llm.zsh started, config loaded"

# Helper function to truncate long strings for logging
function truncate_log() {
    local input="$1"
    local max_length=50
    if (( ${#input} > max_length )); then
        echo "${input:0:$max_length}..."
    else
        echo "$input"
    fi
}

# Generic API call function
function call_api() {
    local provider=$1
    local url=$2
    local headers=$3
    local data=$4
    
    zsh_copilot_debug "Calling $provider API"
    local response=$(curl "$url" \
        --silent \
        --max-time 10 \
        -H "Content-Type: application/json" \
        $headers \
        -d "$data")
    
    if [[ $? -ne 0 ]]; then
        zsh_copilot_debug "Error: Failed to call $provider API"
        echo "Error: Failed to call $provider API. Please check your internet connection."
        return 1
    fi
    
    echo "$response"
}

# OpenAI API function
function call_openai_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Preparing OpenAI API call with input: $(truncate_log "$input")"

    if [[ -z "$OPENAI_API_KEY" ]]; then
        zsh_copilot_debug "Error: OPENAI_API_KEY is not set"
        echo "Error: OPENAI_API_KEY is not set."
        return 1
    fi

    local data
    data=$(jq -n \
        --arg model "${ZSH_COPILOT_CONFIG[OPENAI_MODEL]}" \
        --arg prompt "$prompt" \
        --arg input "$input" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $prompt},
                {role: "user", content: $input}
            ]
        }')

    local response=$(call_api "OpenAI" "${ZSH_COPILOT_CONFIG[OPENAI_API_URL]}/chat/completions" \
        "-H \"Authorization: Bearer $OPENAI_API_KEY\"" \
        "$data")

    local content=$(echo "$response" | jq -r '.choices[0].message.content // empty')
    zsh_copilot_debug "Extracted content from OpenAI response: $(truncate_log "$content")"
    echo "$content"
}

# Ollama API function
function call_ollama_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Preparing Ollama API call with input: $(truncate_log "$input")"

    local data
    data=$(jq -n \
        --arg model "${ZSH_COPILOT_CONFIG[OLLAMA_MODEL]}" \
        --arg prompt "$prompt" \
        --arg input "$input" \
        '{
            model: $model,
            prompt: ($prompt + "\n\nUser: " + $input + "\nPlease provide a single command suggestion, prefixed with \"=\" for a new command or \"+\" for a completion. Do not provide explanations."),
            stream: false
        }')

    local response=$(call_api "Ollama" "${ZSH_COPILOT_CONFIG[OLLAMA_URL]}/api/generate" \
        "" \
        "$data")

    local content=$(echo "$response" | jq -r '.response // empty')
    zsh_copilot_debug "Extracted content from Ollama response: $(truncate_log "$content")"
    echo "$content"
}

# Gemini API function
function call_gemini_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Preparing Google Gemini API call with input: $(truncate_log "$input")"

    if [[ -z "$GOOGLE_API_KEY" ]]; then
        zsh_copilot_debug "Error: GOOGLE_API_KEY is not set"
        echo "Error: GOOGLE_API_KEY is not set."
        return 1
    fi

    local data
    data=$(jq -n \
        --arg prompt "$prompt" \
        --arg input "$input" \
        '{
            contents: [{
                parts: [{
                    text: ($prompt + "\n\nUser: " + $input + "\nPlease provide a single command suggestion, prefixed with \"=\" for a new command or \"+\" for a completion. Do not provide explanations.")
                }]
            }]
        }')

    local api_url="${ZSH_COPILOT_CONFIG[GEMINI_API_URL]}/models/${ZSH_COPILOT_CONFIG[GEMINI_MODEL]}:generateContent?key=$GOOGLE_API_KEY"
    local response=$(call_api "Google Gemini" "$api_url" "" "$data")

    parse_gemini_response "$response"
}

# Mistral API function
function call_mistral_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Preparing Mistral API call with input: $(truncate_log "$input")"

    if [[ -z "$MISTRAL_API_KEY" ]]; then
        zsh_copilot_debug "Error: MISTRAL_API_KEY is not set"
        echo "Error: MISTRAL_API_KEY is not set."
        return 1
    fi

    local data
    data=$(jq -n \
        --arg model "${ZSH_COPILOT_CONFIG[MISTRAL_MODEL]}" \
        --arg prompt "$prompt" \
        --arg input "$input" \
        '{
            model: $model,
            messages: [
                {role: "system", content: $prompt},
                {role: "user", content: $input}
            ]
        }')

    local response=$(call_api "Mistral" "${ZSH_COPILOT_CONFIG[MISTRAL_API_URL]}/chat/completions" \
        "-H \"Authorization: Bearer $MISTRAL_API_KEY\"" \
        "$data")

    local content=$(echo "$response" | jq -r '.choices[0].message.content // empty')
    zsh_copilot_debug "Extracted content from Mistral response: $(truncate_log "$content")"
    echo "$content"
}

# Anthropic API function
function call_anthropic_api() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Preparing Anthropic API call with input: $(truncate_log "$input")"

    if [[ -z "$CLAUDE_API_KEY" ]]; then
        zsh_copilot_debug "Error: CLAUDE_API_KEY is not set"
        echo "Error: CLAUDE_API_KEY is not set."
        return 1
    fi

    local data
    data=$(jq -n \
        --arg model "${ZSH_COPILOT_CONFIG[ANTHROPIC_MODEL]}" \
        --arg prompt "$prompt" \
        --arg input "$input" \
        '{
            model: $model,
            max_tokens: 1024,
            messages: [
                {role: "user", content: ($prompt + "\n Your Search: " + $input)}
            ]
        }')

    local response=$(call_api "Anthropic" "${ZSH_COPILOT_CONFIG[ANTHROPIC_API_URL]}/messages" \
        "-H \"x-api-key: $CLAUDE_API_KEY\" -H \"anthropic-version: 2023-06-01\"" \
        "$data")

    local content=$(echo "$response" | jq -r '.content[0].text // empty')
    zsh_copilot_debug "Extracted content from Anthropic response: $(truncate_log "$content")"
    echo "$content"
}

# Gemini response parsing function
function parse_gemini_response() {
    local response=$1
    zsh_copilot_debug "Parsing Gemini response"

    if [[ -z "$response" ]]; then
        zsh_copilot_debug "Error: Empty response from Google Gemini API"
        echo "Error: Empty response from Google Gemini API"
        return 1
    fi

    local sanitized_response=$(echo "$response" | tr '\n' ' ')
    zsh_copilot_debug "Sanitized response: $(truncate_log "$sanitized_response")"

    if ! echo "$sanitized_response" | jq . > /dev/null 2>&1; then
        zsh_copilot_debug "Error: Invalid JSON response from Google Gemini API"
        echo "Error: Invalid JSON response from Google Gemini API"
        return 1
    fi

    local content=$(echo "$sanitized_response" | jq -r '.candidates[0].content.parts[0].text // empty')
    
    if [[ -z "$content" ]]; then
        zsh_copilot_debug "Error: Unable to extract content from Google Gemini response"
        echo "Error: Unable to extract content from Google Gemini response"
        return 1
    fi

    content=$(echo "$content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^=+/=/' -e 's/^+=/+/' -e 's/#.*$//')
    zsh_copilot_debug "Cleaned content from Google Gemini response: $(truncate_log "$content")"

    echo "$content"
}

# Main function to get AI suggestion
function get_ai_suggestion() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Getting AI suggestion for input: $(truncate_log "$input")"

    local response
    case "${ZSH_COPILOT_CONFIG[LLM_PROVIDER]}" in
        "openai")  response=$(call_openai_api "$input" "$prompt") ;;
        "ollama")  response=$(call_ollama_api "$input" "$prompt") ;;
        "gemini")  response=$(call_gemini_api "$input" "$prompt") ;;
        "mistral") response=$(call_mistral_api "$input" "$prompt") ;;
        "claude")  response=$(call_anthropic_api "$input" "$prompt") ;;
        *)
            zsh_copilot_debug "Error: Invalid LLM provider specified: ${ZSH_COPILOT_CONFIG[LLM_PROVIDER]}"
            echo "Error: Invalid LLM provider specified"
            return 1
            ;;
    esac

    if [[ $? -ne 0 ]]; then
        zsh_copilot_debug "Error occurred while getting AI suggestion"
        return 1
    fi

    zsh_copilot_debug "Raw AI response: $(truncate_log "$response")"
    echo "$response"
}

zsh_copilot_debug "zsh-copilot-llm.zsh loaded successfully"