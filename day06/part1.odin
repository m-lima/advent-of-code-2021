package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

load :: proc(file: string) -> (input: [dynamic]uint, ok: bool) {
  bytes: []u8;
  bytes, ok = os.read_entire_file(file);
  if !ok do return {}, false;

  parts := strings.split(string(bytes), ",");
  for part in parts {
    value: uint;
    value, ok = strconv.parse_uint(part);
    if !ok do return {}, false;
    append(&input, value);
  }

  return input, true;
}

to_buckets :: proc(input: []uint) -> [9]uint {
  output: [9]uint;
  for i in input {
    output[i] += 1;
  }

  return output;
}

main :: proc() {
  input, ok := load("input.txt");
  if !ok do return;

  buckets := to_buckets(input[:]);

  for day in 0..79 {
    buckets[(day + 7)%9] += buckets[day%9];
  }

  total: uint;
  for b in buckets {
    total += b;
  }
  fmt.println(total);
}
