#include <stdio.h>
#include <stdlib.h>
#include <sys/errno.h>

struct Vec {
  unsigned char *ptr;
  size_t len;
};

struct Vec read_all(const char *file) {
  struct Vec vec = {.ptr = NULL, .len = 0};

  FILE *input = fopen("input.txt", "r");
  if (input == NULL) {
    return vec;
  }

  if (fseek(input, 0, SEEK_END)) {
    goto close;
  }

  size_t len = ftell(input);
  if (len == -1) {
    goto close;
  }

  if (fseek(input, 0, SEEK_SET)) {
    goto close;
  }

  vec.len = len;
  vec.ptr = malloc(len);
  if (vec.ptr == NULL) {
    goto close;
  }

  if (fread(vec.ptr, sizeof(unsigned char), len, input) != len) {
    free(vec.ptr);
    vec.ptr = NULL;
  }

close:
  fclose(input);
  return vec;
}

size_t count_digits(const struct Vec *buffer) {
  size_t c = 0;
  while (c < buffer->len) {
    if (buffer->ptr[c] == '\n') {
      break;
    }
    c++;
  }
  return c;
}

int main() {
  struct Vec buffer = read_all("input.txt");
  if (buffer.ptr == NULL) {
    return errno;
  }

  int digits = count_digits(&buffer);
  if (digits == 0) {
    goto debuffer;
  }

  int eol_len =
      buffer.ptr[digits + 1] == '0' || buffer.ptr[digits + 1] == '1' ? 1 : 2;

  unsigned int *counts = malloc(digits * sizeof(unsigned int));
  if (counts == NULL) {
    goto debuffer;
  }

  for (int i = 0; i < digits; i++) {
    counts[i] = 0;
  }

  for (size_t i = 0; i < buffer.len; i += digits + eol_len) {
    for (size_t j = 0; j < digits; j++) {
      if (buffer.ptr[i + j] == '1') {
        counts[j]++;
      }
    }
  }

  int threshold = (buffer.len / (digits + eol_len)) >> 1;
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
