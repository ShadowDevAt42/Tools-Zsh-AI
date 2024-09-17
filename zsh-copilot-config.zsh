# Configuration variables
(( ! ${+ZSH_COPILOT_KEY} )) && typeset -g ZSH_COPILOT_KEY='^z'
(( ! ${+ZSH_COPILOT_SEND_CONTEXT} )) && typeset -g ZSH_COPILOT_SEND_CONTEXT=true
(( ! ${+ZSH_COPILOT_DEBUG} )) && typeset -g ZSH_COPILOT_DEBUG=false

# LLM configuration
(( ! ${+ZSH_COPILOT_LLM_PROVIDER} )) && typeset -g ZSH_COPILOT_LLM_PROVIDER="openai"  # or "ollama"

# OpenAI configuration
(( ! ${+ZSH_COPILOT_OPENAI_API_URL} )) && typeset -g ZSH_COPILOT_OPENAI_API_URL="https://api.openai.com/v1"
(( ! ${+ZSH_COPILOT_OPENAI_MODEL} )) && typeset -g ZSH_COPILOT_OPENAI_MODEL="gpt-4o"

# Ollama configuration
(( ! ${+ZSH_COPILOT_OLLAMA_URL} )) && typeset -g ZSH_COPILOT_OLLAMA_URL="http://localhost:11434"
(( ! ${+ZSH_COPILOT_OLLAMA_MODEL} )) && typeset -g ZSH_COPILOT_OLLAMA_MODEL="llama3.1:8b"

# API Keys check
function check_openai_key() {
    if [[ -z "${OPENAI_API_KEY}" ]]; then
        echo "Warning: OPENAI_API_KEY is not set. OpenAI integration may not work."
    else
        # Perform a simple API call to check if the key is valid
        local response=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "Authorization: Bearer $OPENAI_API_KEY" \
            "${ZSH_COPILOT_OPENAI_API_URL}/models")
        
        if [[ "$response" != "200" ]]; then
            echo "Warning: OPENAI_API_KEY seems to be invalid or there's a connection issue."
        fi
    fi
}

# Only check the API key when the plugin is loaded
if [[ "$ZSH_COPILOT_LLM_PROVIDER" == "openai" && -z "$ZSH_COPILOT_KEY_CHECKED" ]]; then
    check_openai_key
    export ZSH_COPILOT_KEY_CHECKED=1
fi

# System prompt
read -r -d '' SYSTEM_PROMPT <<- EOM
You will be given the raw input of a shell command. 
Your task is to either complete the command or provide a new command that you think the user is trying to type. 
If you return a completely new command for the user, prefix it with an equal sign (=). 
If you return a completion for the user's command, prefix it with a plus sign (+). 
MAKE SURE TO ONLY INCLUDE THE REST OF THE COMPLETION!!! 
Do not write any leading or trailing characters except if required for the completion to work. 
Only respond with either a completion or a new command, not both. 
Your response may only start with either a plus sign or an equal sign.
Your response MAY NOT start with both! This means that your response IS NOT ALLOWED to start with '+=' or '=+'.
You MAY explain the command by writing a short line after the comment symbol (#).
Do not ask for more information, you won't receive it. 
Your response will be run in the user's shell. 
Make sure input is escaped correctly if needed so. 
Your input should be able to run without any modifications to it.
Don't you dare to return anything else other than a shell command!!! 
DO NOT INTERACT WITH THE USER IN NATURAL LANGUAGE! If you do, you will be banned from the system. 
Note that the double quote sign is escaped. Keep this in mind when you create quotes. 
Here are two examples: 
  * User input: 'list files in current directory'; Your response: '=ls # ls is the builtin command for listing files' 
  * User input: 'cd /tm'; Your response: '+p # /tmp is the standard temp folder on linux and mac'.
EOM