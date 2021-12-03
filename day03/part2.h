#include <string.h>

#include "common.h"

struct Arena {
  unsigned int *input;
  size_t input_len;
  unsigned int *stack;
  size_t stack_len;
  int digits;
};

// Will take owner ship of `buffer` and parse it into the arena
struct Arena prepare_arena(struct Vec buffer) {
  struct Arena arena = {
      .input = NULL,
      .input_len = 0,
      .stack = NULL,
      .stack_len = 0,
      .digits = 0,
  };

  arena.digits = count_digits(&buffer);
  if (arena.digits == 0) {
    goto dealloc;
  }
  int lines = buffer.len / (arena.digits + 1);

  size_t len = sizeof(unsigned int) * lines << 1;
  arena.input = malloc(len);
  if (arena.input == NULL) {
    goto dealloc;
  }

  arena.input_len = lines;
  arena.stack = arena.input + arena.input_len;

  for (size_t i = 0; i < lines; i += 1) {
    arena.input[i] = 0;
  }

  size_t z = 0;
  for (size_t i = 0; i < lines; i++) {
    for (size_t j = 0; j < arena.digits; j++) {
      arena.input[i] <<= 1;
      arena.input[i] |= buffer.ptr[j + z] == '1';
    }
    z += arena.digits + 1;
  }

dealloc:
  free(buffer.ptr);
  return arena;
}

void initialize(struct Arena *arena) {
  memcpy(arena->stack, arena->input, arena->input_len * sizeof(unsigned int));
  arena->stack_len = arena->input_len;
}

void remove_from_stack(struct Arena *arena, size_t index) {
  arena->stack_len--;
  arena->stack[index] = arena->stack[arena->stack_len];
}
