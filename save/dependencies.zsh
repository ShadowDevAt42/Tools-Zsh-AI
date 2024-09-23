#!/bin/zsh

# List of required commands
REQUIRED_COMMANDS=(
    "curl"
    "jq"
    "git"
	"nc"
)

# Function to check if a command is available
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is not installed or not in PATH"
        return 1
    fi
    return 0
}

# Check all required commands
check_dependencies() {
    local missing_deps=0
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! check_command $cmd; then
            missing_deps=$((missing_deps + 1))
        fi
    done

    if [ $missing_deps -gt 0 ]; then
        return 1
    fi
    return 0
}

# Function to get missing dependencies
get_missing_dependencies() {
    local missing=""
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            missing="$missing $cmd"
        fi
    done
    echo $missing
}
