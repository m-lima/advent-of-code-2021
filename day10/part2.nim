import std/algorithm

iterator lineByLine(): string =
  let handle = open "input.txt"
  defer: close handle

  var line: string
  while readLine(handle, line):
    yield line

proc pop(stack: var seq[char]): char =
  let c = stack[high stack]
  stack.delete(high stack)
  c

iterator halfStacks(): seq[char] =
  for line in lineByLine():
    block lines:
      var stack: seq[char]
      for c in line:
        case c:
          of '(', '[', '{', '<':
            stack.add(c)
          of ')':
            let prev = stack.pop()
            if prev != '(':
              break lines
          of ']', '}', '>':
            let prev = int(stack.pop())
            if prev != int(c) - 2:
              break lines
          else:
            quit -1
      yield stack

var pointsSeq: seq[uint]
for iStack in halfStacks():
  var stack = iStack
  var points: uint = 0
  while stack.len > 0:
    let c = stack.pop()
    points *= 5
    case c:
      of '(':
        points += 1
      of '[':
        points += 2
      of '{':
        points += 3
      of '<':
        points += 4
      else:
        quit -1
  pointsSeq.add(points)

sort pointsSeq
echo pointsSeq[high(pointsSeq) shr 1]
