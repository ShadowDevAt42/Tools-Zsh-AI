#!/bin/zsh

# Source the utils file
source "../modules/utils.zsh"

# Test function for get_system_info
test_get_system_info() {
    local result=$(get_system_info)
    if [[ -z "$result" ]]; then
        echo "FAIL: get_system_info returned empty string"
        return 1
    fi
    echo "PASS: get_system_info returned: $result"
    return 0
}

# Run all tests
run_tests() {
    local failed=0
    
    if ! test_get_system_info; then
        failed=$((failed + 1))
    fi
    
    if [ $failed -eq 0 ]; then
        echo "All tests passed successfully!"
    else
        echo "$failed test(s) failed."
    fi
}

# Execute the tests
run_tests