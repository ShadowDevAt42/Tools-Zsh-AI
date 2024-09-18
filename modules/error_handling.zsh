#!/bin/zsh

# Description:
#   Error handling module for the application.
#   Defines error codes and provides functions to handle and log errors.
#   Facilitates consistent error management across the application.

# Error Codes
E_GENERAL=1
E_INVALID_INPUT=2
E_FILE_NOT_FOUND=3
E_PERMISSION_DENIED=4

# Function to handle errors
handle_error() {
    # Handles errors based on the provided error code and message.
    #
    # Args:
    #   error_code (int): The code representing the type of error.
    #   error_message (str): Detailed message describing the error.
    #
    # Logs the error message corresponding to the error code.
    # Additional actions like notifications or script termination can be added.

    local error_code=$1
    local error_message=$2

    log_debug_ex "Handling error with code $error_code: $error_message"

    case $error_code in
        $E_GENERAL)
            log_error "General error occurred: $error_message"
            ;;
        $E_INVALID_INPUT)
            log_error "Invalid input provided: $error_message"
            ;;
        $E_FILE_NOT_FOUND)
            log_error "File not found: $error_message"
            ;;
        $E_PERMISSION_DENIED)
            log_error "Permission denied: $error_message"
            ;;
        *)
            log_error "Unknown error (Code: $error_code): $error_message"
            ;;
    esac

    # Additional error handling actions can be implemented here.
    # For example, sending notifications or exiting the script with an error code.
}

# Function to validate input against a pattern
validate_input() {
    # Validates the input string against the provided regular expression pattern.
    #
    # Args:
    #   input (str): The input string to validate.
    #   pattern (str): The regex pattern to match the input against.
    #
    # Returns:
    #   0 if the input matches the pattern.
    #   1 if the input does not match, after handling the error.

    local input=$1
    local pattern=$2

    if [[ $input =~ $pattern ]]; then
        log_debug "Input '$input' successfully validated against pattern '$pattern'."
        return 0
    else
        handle_error $E_INVALID_INPUT "Input '$input' does not match pattern '$pattern'"
        log_error "Validation failed for input '$input' against pattern '$pattern'."
        return 1
    fi
}
