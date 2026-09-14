extends Node2D

const SIZE := 8
const TYPES := ["●", "◆", "■", "★", "♥", "✦"]
const COLORS := [Color("#ff6b8a"), Color("#ffd166"), Color("#72d6ff"), Color("#b78cff"), Color("#ff8f4f"), Color("#75e6a4")]
const CELL := 78.0
const ORIGIN := Vector2(48, 300)

var board: Array[int] = []
var selected := -1
var score := 0
var moves := 25
var level := 1
var message := "Combina 3 o más piezas"
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    _new_level()
    queue_redraw()

func _new_level() -> void:
    board.clear()
    for i in SIZE * SIZE:
        board.append(_random_type())
    while _find_matches().size() > 0:
        board.clear()
        for i in SIZE * SIZE:
            board.append(_random_type())
    selected = -1
    moves = max(15, 25 - int(level / 5))
    score = 0
    message = "Nivel %d · Objetivo %d" % [level, _target()]

func _target() -> int:
    return 1000 + (level - 1) * 350

func _random_type() -> int:
    return rng.randi_range(0, TYPES.size() - 1)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(720, 1280)), Color("#100b1d"))
    draw_string(ThemeDB.fallback_font, Vector2(48, 70), "SWEET RIFT", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("#ffffff"))
    draw_string(ThemeDB.fallback_font, Vector2(50, 100), "MATCH · COMBINA · ROMPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b9a9c8"))
    _draw_stat(Vector2(48, 150), "NIVEL", str(level))
    _draw_stat(Vector2(270, 150), "PUNTOS", str(score))
    _draw_stat(Vector2(492, 150), "MOVIMIENTOS", str(moves))
    draw_string(ThemeDB.fallback_font, Vector2(48, 245), message, HORIZONTAL_ALIGNMENT_LEFT, 624, 20, Color("#f3d47b"))
    for i in SIZE * SIZE:
        var r := i / SIZE
        var c := i % SIZE
        var p := ORIGIN + Vector2(c * CELL, r * CELL)
        var bg := Color("#21152e")
        if i == selected:
            bg = Color("#5a3c75")
        draw_style_box(_box(bg, 12.0), Rect2(p, Vector2(CELL - 5, CELL - 5)))
        var label := TYPES[board[i]]
        draw_string(ThemeDB.fallback_font, p + Vector2(28, 52), label, HORIZONTAL_ALIGNMENT_CENTER, 30, 34, COLORS[board[i]])
    draw_string(ThemeDB.fallback_font, Vector2(48, 970), "Toca dos piezas adyacentes para intercambiarlas", HORIZONTAL_ALIGNMENT_LEFT, 624, 16, Color("#9d91a8"))

func _draw_stat(pos: Vector2, title: String, value: String) -> void:
    draw_style_box(_box(Color("#21172c"), 14.0), Rect2(pos, Vector2(180, 68)))
    draw_string(ThemeDB.fallback_font, pos + Vector2(14, 23), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#9d91a8"))
    draw_string(ThemeDB.fallback_font, pos + Vector2(14, 50), value, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color.WHITE)

func _box(color: Color, radius: float) -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = color
    b.corner_radius_top_left = radius
    b.corner_radius_top_right = radius
    b.corner_radius_bottom_left = radius
    b.corner_radius_bottom_right = radius
    return b

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _tap(event.position)
    elif event is InputEventMouseButton and event.pressed:
        _tap(event.position)

func _tap(pos: Vector2) -> void:
    if pos.x < ORIGIN.x or pos.y < ORIGIN.y:
        return
    var c := int((pos.x - ORIGIN.x) / CELL)
    var r := int((pos.y - ORIGIN.y) / CELL)
    if c < 0 or c >= SIZE or r < 0 or r >= SIZE or moves <= 0:
        return
    var index := r * SIZE + c
    if selected == -1:
        selected = index
        queue_redraw()
        return
    if not _adjacent(selected, index):
        selected = index
        queue_redraw()
        return
    board.swap(selected, index)
    var matches := _find_matches()
    if matches.is_empty():
        board.swap(selected, index)
        message = "Ese movimiento no crea combinación"
    else:
        moves -= 1
        _resolve(matches)
    selected = -1
    queue_redraw()

func _adjacent(a: int, b: int) -> bool:
    return abs(a / SIZE - b / SIZE) + abs(a % SIZE - b % SIZE) == 1

func _find_matches() -> Array[int]:
    var found: Array[int] = []
    for r in SIZE:
        var run := 1
        for c in range(1, SIZE + 1):
            if c < SIZE and board[r * SIZE + c] == board[r * SIZE + c - 1]:
                run += 1
            else:
                if run >= 3:
                    for k in run:
                        found.append(r * SIZE + c - 1 - k)
                run = 1
    for c in SIZE:
        var run := 1
        for r in range(1, SIZE + 1):
            if r < SIZE and board[r * SIZE + c] == board[(r - 1) * SIZE + c]:
                run += 1
            else:
                if run >= 3:
                    for k in run:
                        found.append((r - 1 - k) * SIZE + c)
                run = 1
    return found.duplicate()

func _resolve(matches: Array[int]) -> void:
    var unique := {}
    for i in matches:
        unique[i] = true
    score += unique.size() * 20
    for i in unique.keys():
        board[i] = -1
    for c in SIZE:
        var column: Array[int] = []
        for r in range(SIZE - 1, -1, -1):
            var value := board[r * SIZE + c]
            if value >= 0:
                column.append(value)
        while column.size() < SIZE:
            column.append(_random_type())
        for r in SIZE:
            board[r * SIZE + c] = column[SIZE - 1 - r]
    var chain := _find_matches()
    if not chain.is_empty():
        score += chain.size() * 20
        _resolve(chain)
    if score >= _target():
        message = "¡Nivel completado!"
    elif moves <= 0:
        message = "Sin movimientos · reinicia el nivel"
    else:
        message = "¡Buena combinación!"
