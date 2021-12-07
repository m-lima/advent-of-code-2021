package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func load(file string) ([]int, error) {
	bytes, err := os.ReadFile(file)
	if err != nil {
		return nil, err
	}

	parts := strings.Split(string(bytes), ",")
	input := make([]int, len(parts))

	for i, part := range parts {
		num, err := strconv.ParseInt(strings.TrimSpace(part), 10, 0)
		if err != nil {
			return nil, err
		}
		input[i] = int(num)
	}

	return input, nil
}

func calculate_score(nums []int, ref int) int {
	score := 0
	for _, num := range nums {
		diff := ref - num
		if diff >= 0 {
			score += diff
		} else {
			score -= diff
		}
	}
	return score
}

func explore_ref(nums []int, score int, ref int, step int) int {
	for {
		new_score := calculate_score(nums, ref+step)
		if new_score < score {
			score = new_score
			ref += step
		} else {
			return score
		}
	}
}

func main() {
	input, err := load("input.txt")
	if err != nil {
		fmt.Fprintln(os.Stderr, "Failed to read file: {}", err)
		return
	}

	ref := 0
	for _, num := range input {
		ref += num
	}
	ref /= len(input)
	score := calculate_score(input, ref)

	score = explore_ref(input, score, ref, 1)
	score = explore_ref(input, score, ref, -1)

	fmt.Println(score)
}
