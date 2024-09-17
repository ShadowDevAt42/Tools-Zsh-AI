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

function get_ai_suggestion() {
    local input=$1
    local prompt=$2
    zsh_copilot_debug "Getting AI suggestion for input: $input"

    local response
    if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "openai" ]]; then
        zsh_copilot_debug "Using OpenAI provider"
        response=$(call_openai_api "$input" "$prompt")
    elif [[ "$ZSH_COPILOT_LLM_PROVIDER" == "ollama" ]]; then
        zsh_copilot_debug "Using Ollama provider"
        response=$(call_ollama_api "$input" "$prompt")
    else
        zsh_copilot_debug "Error: Invalid LLM provider specified: $ZSH_COPILOT_LLM_PROVIDER"
        echo "Error: Invalid LLM provider specified"
        return 1
    fi

    # Remove comment from the response
    local cleaned_response=$(echo "$response" | sed 's/ #.*$//')
    zsh_copilot_debug "Cleaned response: $cleaned_response"

    echo "$cleaned_response"
}

zsh_copilot_debug "zsh-copilot-llm.zsh loaded successfully"