input = []
with open("input.txt") as input:
    input = [list(map(lambda c: ord(c) - ord('0'), filter(lambda c: c != '\n', row))) for row in input.readlines()]

rows = len(input)
cols = len(input[0])
sum = 0
for row in range(0,rows):
    for col in range(0,cols):
        curr = input[row][col]
        if (row == 0 or curr < input[row - 1][col]) \
            and (col == 0 or curr < input[row][col - 1]) \
            and (row == rows - 1 or curr < input[row + 1][col]) \
            and (col == cols - 1 or curr < input[row][col + 1]):
                sum += (curr + 1)
print(sum)
