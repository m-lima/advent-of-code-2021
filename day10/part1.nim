iterator lineByLine(): string =
  let handle = open("input.txt")
  defer: handle.close()

  var line: string
  while readLine(handle, line):
    yield line

proc pop(stack: var seq[char]): char =
  let c = stack[high(stack)]
  stack.delete(high(stack))
  c

var stack: seq[char]
var points: uint = 0
for line in lineByLine():
  for c in line:
    case c:
      of '(', '[', '{', '<':
        stack.add(c)
      of ')':
        let prev = stack.pop()
        if prev != '(':
          points += 3
      of ']':
        let prev = stack.pop()
        if prev != '[':
          points += 57
      of '}':
        let prev = stack.pop()
        if prev != '{':
          points += 1197
      of '>':
        let prev = stack.pop()
        if prev != '<':
          points += 25137
      else:
        quit -1

echo points
