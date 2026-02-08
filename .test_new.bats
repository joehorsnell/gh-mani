#!/usr/bin/env bats

@test "description [input_file=$input_file,base_name=$base_name,expected_file=$expected_file]" {
  echo "# Here I am with input_file=$input_file base_name=$base_name expected_file=$expected_file" >&3
  [ -n "$input_file" ] || [ -z "$input_file" ]
}
