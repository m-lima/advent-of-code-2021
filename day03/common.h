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
