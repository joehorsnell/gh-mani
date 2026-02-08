#!/usr/bin/env bats

# Directory paths
input_dir="fixtures/input"
expected_dir="fixtures/expected"
actual_dir="tmp/tests/actual"

mkdir -p "$actual_dir"

@test "wrapper" {
  final_status=0
  skip "Experimental wrapper test; skipped by default to avoid running in CI"

  # Iterate over each JSON file in the input directory
  for input_file in "$input_dir"/*.json; do
    # Get the base name of the file without the extension
    base_name=$(basename "$input_file" .json)

    # Construct the expected output file path
    expected_file="$expected_dir/$base_name.yaml"

    input_file="$input_file" base_name="$base_name" expected_file="$expected_file" run bats -t .test_new.bats

    echo "# $output" >&3
    echo "#" >&3
    final_status=$(($final_status + $status))
  done

  [ "$final_status" -eq 0 ]

  # for b in "${BACKENDS[@]}"; do
  #   for nj in "${NJOBS[@]}"; do
  #     backend="$b" njobs=$nj run bats -t test.bats

  #     echo "# $output" >&3
  #     echo "#" >&3
  #     final_status=$(($final_status + $status))
  #   done
  # done

  # [ "$final_status" -eq 0 ]
}