import os
import math

struct Position {
	x int
	y int
}

struct Velocity {
	x int
	y int
}

struct Target {
	x0 int
	x1 int
	y0 int
	y1 int
}

enum Placement {
	before
	at
	after
}

fn (p Position) placement(t Target) Placement {
	return match true {
		p.x > t.x1 || p.y < t.y1 {
			Placement.after
		}
		p.x >= t.x0 && p.x <= t.x1 && p.y <= t.y0 && p.y >= t.y1 {
			Placement.at
		}
		else {
			Placement.before
		}
	}
}

fn load() string {
	mut input := os.open('input.txt') or { panic('Could not open input file') }
	defer {
		input.close()
	}
	{
		mut buffer := []byte{len: 128}
		bytes := input.read(mut buffer) or { panic('Could not read input file') }
		return buffer[..bytes - 1].bytestr()
	}
}

fn parse(input string) Target {
	split := input.split(' ')
	x := split[2][2..]
	x_range := x.split('..').map(it.int())
	y := split[3][2..]
	y_range := y.split('..').map(it.int())

	return Target{
		x0: if x_range[0] <= x_range[1] { x_range[0] } else { x_range[1] }
		x1: if x_range[0] <= x_range[1] { x_range[1] } else { x_range[0] }
		y0: if y_range[0] <= y_range[1] { y_range[1] } else { y_range[0] }
		y1: if y_range[0] <= y_range[1] { y_range[0] } else { y_range[1] }
	}
}

fn quad_bound(x int) int {
	return int((1 + math.sqrt(1 + 8 * x)) / 2) - 1
}

fn step(velocity Velocity, position Position) (Velocity, Position) {
	new_position := Position{
		x: position.x + velocity.x
		y: position.y + velocity.y
	}

	new_velocity := Velocity{
		x: if velocity.x > 1 { velocity.x - 1 } else { 0 }
		y: velocity.y - 1
	}

	return new_velocity, new_position
}

fn launch(mut velocity Velocity, target Target) ?int {
	mut position := Position{}
	max := max_height(velocity.y)
	mut placement := position.placement(target)
	for placement == Placement.before {
		velocity, position = step(velocity, position)
		placement = position.placement(target)
	}
	return if placement == Placement.at { max } else { none }
}

fn max_height(y int) int {
	yy := y + 1
	return (yy * yy - yy) >> 1
}

fn main() {
	target := parse(load())
	mut max := 0
	for x in quad_bound(target.x0) .. target.x1 + 1 {
		for y in 0 .. int(math.abs(target.y1)) + 1 {
			mut velocity := Velocity{x, y}
			peak := launch(mut velocity, target) or { -1 }
			if max < peak {
				max = peak
			}
		}
	}
	println('$max')
}
