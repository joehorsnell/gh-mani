#!/usr/bin/env bats

# Directory paths
input_dir="tests/input"
expected_dir="tests/expected"
actual_dir="tmp/tests/actual"

mkdir -p "$actual_dir"

# Check if [delta][1] is installed for a nicer diff output on failing specs, otherwise use diff.
# [1]: https://dandavison.github.io/delta/
if command -v delta &> /dev/null; then
    diff_cmd="delta --side-by-side"
else
    diff_cmd="diff"
fi

# Function to check if a command is available, exiting with an error message if it is not
check_dependency() {
    command_name=$1
    if ! command -v "$command_name" &> /dev/null; then
        echo "Error: $command_name is not installed." >&2
        exit 1
    fi
}

# Check for required dependencies
check_dependency "jq"
check_dependency "diff"

# Iterate over each JSON file in the input directory
for input_file in "$input_dir"/*.json; do
    # Get the base name of the file without the extension
    base_name=$(basename "$input_file" .json)

    # Construct the expected output file path
    expected_file="$expected_dir/$base_name.yaml"

    # Define a test case for each file
    @test "jq processes $base_name correctly" {
        # Check if the expected file exists
        [ -f "$expected_file" ]

        # Run jq on the input file
        run jq --raw-output "$(<gh-mani.jq)" "$input_file"

        echo "$output" > "${actual_dir}/${base_name}.yaml"

        # Compare the output with the expected output
        ${diff_cmd} <(echo "$output") "$expected_file"

        [ "$status" -eq 0 ]
    }
done
