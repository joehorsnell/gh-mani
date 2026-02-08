#!/usr/bin/env bats

# Directory paths
input_dir="fixtures/input"
expected_dir="fixtures/expected"
actual_dir="tmp/fixtures/actual"

mkdir -p "$actual_dir"

# Global variables for cleanup
CLEANUP_FILES=()
CLEANUP_DIRS=()

# Setup function to initialize cleanup arrays before each test
setup() {
    CLEANUP_FILES=()
    CLEANUP_DIRS=()
}

# Teardown function to clean up temporary files and directories
teardown() {
    for file in "${CLEANUP_FILES[@]}"; do
        if [ -f "$file" ]; then
            rm -f "$file"
        fi
    done
    for dir in "${CLEANUP_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
        fi
    done
}

# Check if [delta][1] is installed for a nicer diff output on failing specs, otherwise use diff.
# [1]: https://dandavison.github.io/delta/
if command -v delta &> /dev/null; then
    diff_cmd="delta --side-by-side"
else
    diff_cmd="diff"
fi

# Function to check if a command is available, exiting with an error message if it is not
check_dependency() {
    local command_name="$1"
    if ! command -v "$command_name" &> /dev/null; then
        echo "Error: $command_name is not installed." >&2
        exit 1
    fi
}

# Check for required dependencies
check_dependency "jq"
check_dependency "diff"

perform_test() {
    local fixture_name=$1

    local input_fixture="$input_dir/$fixture_name.json"
    local expected_fixture="$expected_dir/$fixture_name.yaml"

    # Check if the input file exists
    [ -f "$input_fixture" ]

    # Check if the expected file exists
    [ -f "$expected_fixture" ]

    # Run jq on the input file
    run jq --raw-output "$(<gh-mani.jq)" "$input_fixture"
    [ "$status" -eq 0 ]

    # Save a copy of the generated output for debugging
    echo "$output" > "${actual_dir}/${fixture_name}.yaml"

    # Compare the actual output with the expected output
    run ${diff_cmd} <(echo "$output") "$expected_fixture"
    [ "$status" -eq 0 ]
}

@test "basic processing of JSON with name and url" {
    perform_test "spring-projects"
}

@test "handling large repos with blobless clones when diskUsage is present" {
    export BLOBLESS_CLONE_SIZE_LIMIT_IN_MB=100
    perform_test "large-repos"
}

@test "integration: generate config and validate with mani" {
    check_dependency "gh"
    check_dependency "mani"

    if ! gh auth status &> /dev/null; then
        skip "gh is not authenticated"
    fi

    local org_name="${INTEGRATION_TEST_ORG:-cli}"
    local tmp_config
    local tmp_dir
    tmp_config="$(mktemp 2>/dev/null || mktemp -t gh-mani)"
    tmp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t gh-mani)"

    # Register temp files for cleanup
    CLEANUP_FILES+=("$tmp_config")
    CLEANUP_DIRS+=("$tmp_dir")

    run gh extension remove mani
    run gh extension install .
    [ "$status" -eq 0 ]

    run gh mani --limit 5 "$org_name"
    [ "$status" -eq 0 ]
    echo "$output" > "$tmp_config"

    run mani -c "$tmp_config" check
    [ "$status" -eq 0 ]

    run bash -c "cd \"$tmp_dir\" && mani -c \"$tmp_config\" sync --parallel"
    [ "$status" -eq 0 ]
}
