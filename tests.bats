#!/usr/bin/env bats

# Directory paths
input_dir="tests/input"
expected_dir="tests/expected"

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

        # Compare the output with the expected output
        diff <(echo "$output") "$expected_file"
        [ "$status" -eq 0 ]
    }
done
