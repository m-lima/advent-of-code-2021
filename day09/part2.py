def flood(input, output, row, col, cols, idx):
    if output[row * cols + col] == idx or input[row][col] == 9:
        return
    output[row * cols + col] = idx
    if row > 0:
        flood(input, output, row - 1, col, cols, idx)
    if row < len(input) - 1:
        flood(input, output, row + 1, col, cols, idx)
    if col > 0:
        flood(input, output, row, col - 1, cols, idx)
    if col < len(input[row]) - 1:
        flood(input, output, row, col + 1, cols, idx)

input = []
with open("input.txt") as input:
    input = [list(map(lambda c: ord(c) - ord('0'), filter(lambda c: c != '\n', row))) for row in input.readlines()]

rows = len(input)
cols = len(input[0])
lows = []
for row in range(0,rows):
    for col in range(0,cols):
        curr = input[row][col]
        if (row == 0 or curr < input[row - 1][col]) \
            and (col == 0 or curr < input[row][col - 1]) \
            and (row == rows - 1 or curr < input[row + 1][col]) \
            and (col == cols - 1 or curr < input[row][col + 1]):
                lows.append((row, col))

output = list(map(lambda x: None, range(0, rows * cols)))
for idx, low in enumerate(lows):
    flood(input, output, low[0], low[1], cols, idx)

sizes = list({i:output.count(i) for i in list(filter(lambda x: x != None, output))}.values())
sizes.sort(reverse = True)
print(sizes[0] * sizes[1] * sizes[2])
