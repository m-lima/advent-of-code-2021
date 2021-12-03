#include "part2.h"

unsigned int calculate_parameter(struct Arena *arena, int greater_than,
                                 int bit) {
  if (arena->stack_len == 1) {
    return arena->stack[0];
  }

  int shift = arena->digits - bit - 1;

  int ones = 0;
  for (int i = 0; i < arena->stack_len; i++) {
    ones += (arena->stack[i] & (1 << shift)) >> shift;
  }

  ones <<= 1;
  int reference = (ones == arena->stack_len)
                      ? greater_than
                      : (ones > arena->stack_len) == greater_than;
  for (int i = 0; i < arena->stack_len;) {
    if ((arena->stack[i] & (1 << shift)) >> shift == reference) {
      i++;
    } else {
      remove_from_stack(arena, i);
    }
  }

  return calculate_parameter(arena, greater_than, bit + 1);
}

int main() {
  struct Vec buffer = read_all("input.txt");
  if (buffer.ptr == NULL) {
    return errno;
  }

  struct Arena arena = prepare_arena(buffer);
  if (arena.input == NULL) {
    return errno;
  }

  initialize(&arena);
  unsigned int oxygen = calculate_parameter(&arena, 1, 0);
  initialize(&arena);
  unsigned int carbon = calculate_parameter(&arena, 0, 0);

  printf("%d\n", oxygen * carbon);

  free(arena.input);
  return errno;
}
