#include "common.h"

int main() {
  struct Vec buffer = read_all("input.txt");
  if (buffer.ptr == NULL) {
    return errno;
  }

  int digits = count_digits(&buffer);
  if (digits == 0) {
    goto debuffer;
  }

  unsigned int *counts = calloc(digits, sizeof(unsigned int));
  if (counts == NULL) {
    goto debuffer;
  }

  for (size_t i = 0; i < buffer.len; i += digits + 1) {
    for (size_t j = 0; j < digits; j++) {
      if (buffer.ptr[j + i] == '1') {
        counts[j]++;
      }
    }
  }

  int threshold = (buffer.len / (digits + 1)) >> 1;
  unsigned int gamma = 0;
  unsigned int epsilon = 0;
  for (int i = 0; i < digits; i++) {
    gamma <<= 1;
    epsilon <<= 1;
    if (counts[i] > threshold) {
      gamma |= 1;
    } else {
      epsilon |= 1;
    }
  }

  printf("%d\n", gamma * epsilon);

  free(counts);
debuffer:
  free(buffer.ptr);
  return errno;
}
