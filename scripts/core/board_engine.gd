class_name SweetRiftBoard
extends RefCounted

## Pure Match-3 board logic. Rendering and input stay outside this class.

const EMPTY := -1

var size: int
var cells: Array[int]
var rng := RandomNumberGenerator.new()

func _init(board_size: int = 8, seed_value: int = 0) -> void:
    size = board_size
    cells.resize(size * size)
    if seed_value == 0:
        rng.randomize()
    else:
        rng.seed = seed_value

func index(row: int, column: int) -> int:
    return row * size + column

func are_adjacent(a: int, b: int) -> bool:
    return abs(a / size - b / size) + abs(a % size - b % size) == 1

func find_matches() -> Array[int]:
    var found := {}
    for row in size:
        var run := 1
        for column in range(1, size + 1):
            if column < size and cells[index(row, column)] == cells[index(row, column - 1)]:
                run += 1
            else:
                if run >= 3:
                    for offset in run:
                        found[index(row, column - 1 - offset)] = true
                run = 1
    for column in size:
        var run := 1
        for row in range(1, size + 1):
            if row < size and cells[index(row, column)] == cells[index(row - 1, column)]:
                run += 1
            else:
                if run >= 3:
                    for offset in run:
                        found[index(row - 1 - offset, column)] = true
                run = 1
    return found.keys()

func can_swap(a: int, b: int) -> bool:
    if not are_adjacent(a, b):
        return false
    cells.swap(a, b)
    var valid := not find_matches().is_empty()
    cells.swap(a, b)
    return valid
