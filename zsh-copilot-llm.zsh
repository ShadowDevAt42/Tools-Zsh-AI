#!/usr/bin/env zsh

source "${0:A:h}/zsh-copilot-config.zsh"

function call_openai_api() {
    local input=$1
    local prompt=$2

    if [[ -z "$OPENAI_API_KEY" ]]; then
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

    local response=$(curl "${ZSH_COPILOT_OPENAI_API_URL}/chat/completions" \
        --silent \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "$data")

    echo "$response" | jq -r '.choices[0].message.content'
}

function call_ollama_api() {
    local input=$1
    local prompt=$2

    local data="{
        \"model\": \"$ZSH_COPILOT_OLLAMA_MODEL\",
        \"prompt\": \"$prompt\n\nUser: $input\nPlease provide a single command suggestion, prefixed with '=' for a new command or '+' for a completion. Do not provide explanations.\",
        \"stream\": false
    }"

    local response=$(curl "${ZSH_COPILOT_OLLAMA_URL}/api/generate" \
        --silent \
        -H "Content-Type: application/json" \
        -d "$data")

    echo "$response" | jq -r '.response // empty'
}

function get_ai_suggestion() {
    local input=$1
    local prompt=$2

    if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "openai" ]]; then
        call_openai_api "$input" "$prompt"
    elif [[ "$ZSH_COPILOT_LLM_PROVIDER" == "ollama" ]]; then
        call_ollama_api "$input" "$prompt"
    else
        echo "Error: Invalid LLM provider specified"
        return 1
    fi
}