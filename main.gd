extends Node

@export var trunk_scene : PackedScene

var game_running : bool
var game_over : bool
var scroll : int
var score
const SCROLL_SPEED : int = 4
var screen_size : Vector2i
var ground_height : int
var trunks : Array
const TRUNK_DELAY : int = 100
const TRUNK_RANGE : int = 200

func _ready():
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$scorelabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	get_tree().call_group("trunks", "queue_free")
	trunks.clear()
	generate_trunks()
	$ponyo.reset()
	
func _input(event):
	if game_over == false:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if game_running == false:
					start_game()
				else:
					if $ponyo.flying:
						$ponyo.flap()
						check_top()

func start_game():
	game_running = true
	$ponyo.flying = true
	$ponyo.flap()
	$trunktimer.start()

func _process(_delta):
	if game_running:
		scroll += SCROLL_SPEED
		if scroll >= screen_size.x:
			scroll = 0
		$ground.position.x = -scroll
		for trunk in trunks:
			trunk.position.x -= SCROLL_SPEED

func _on_trunktimer_timeout():
	generate_trunks()
	
func generate_trunks():
	var trunk = trunk_scene.instantiate()
	trunk.position.x = screen_size.x + TRUNK_DELAY
	@warning_ignore("integer_division")
	trunk.position.y = (screen_size.y - ground_height) / 2 + randi_range(-TRUNK_RANGE, TRUNK_RANGE)
	trunk.connect("hit", Callable(self, "ponyo_hit"))
	trunk.connect("scored", Callable(self, "scored"))
	add_child(trunk)
	trunks.append(trunk)
	
func scored():
	score += 1
	$scorelabel.text = "SCORE: " + str(score)

func check_top():
	if $ponyo.position.y < 0:
		$ponyo.falling = true
		stop_game()

func stop_game():
	$trunktimer.stop()
	$GameOver.show()
	$ponyo.flying = false
	game_running = false
	game_over = true
	
func ponyo_hit():
	$ponyo.falling = true
	stop_game()

func _on_ground_hit():
	$ponyo.falling = true
	stop_game()

func _on_game_over_restart():
	new_game()
