extends Node

var object = preload("res://scene/ball.tscn")
var colldown = false

var pilier_scene = preload("res://scene/stump.tscn")
var ennemi_scene = preload("res://scene/ennemie.tscn")
var vole = preload("res://scene/vole.tscn")
var obstacle_types := [pilier_scene, ennemi_scene]
var obstacle : Array
var vole_height := [400,200]

var invincible : bool = false

const ALIEN_START_POS := Vector2i(72, 200)
const CAM_START_POS := Vector2i(577, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var hight_score : int
var speed : int
const START_SPEED : float = 3
const MAX_SPEED : int = 12
const SPEED_MODIFIER : int = 10000
var screen_size : Vector2i
var  ground_height : int
var debut_jeu : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $sol.get_node("Sprite2D").texture.get_height()
	$gameover.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	scoreVisible()
	debut_jeu = false
	get_tree().paused = false
	difficulty = 0
	
	for obs in obstacle:
		obs.queue_free()
	obstacle.clear()
	
	$alien.position = ALIEN_START_POS
	$alien.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$sol.position = Vector2i(0, 0)
	$interface.get_node("start").show()
	$gameover.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if debut_jeu:
		if Input.is_action_pressed("LMB"):
			if colldown == false:
				$Timer.start()
				colldown = true
				var shuriken
				shuriken = object.instantiate()
				shuriken.position = $alien.position
				shuriken.position.x += 80 
				add_child(shuriken)
		
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		generate_obs()
		
		$alien.position.x += speed
		$Camera2D.position.x += speed
		
		score += speed
		scoreVisible()
		
		if $Camera2D.position.x - $sol.position.x > screen_size.x * 1.5:
			$sol.position.x += screen_size.x
			
		for obs in obstacle:
			if obs.position.x < ($Camera2D.position.x) - screen_size.x:
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			debut_jeu = true
			$interface.get_node("start").hide()
			

func generate_obs():
	if obstacle.is_empty() or last_obs.position.x < score + randi_range(300,500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in  range(randi() % max_obs + 1): #permet de faire 1 a 3 foix le meme object
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 300 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_position(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = vole.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = vole_height[randi() % vole_height.size()]
				add_position(obs, obs_x, obs_y)

func add_position(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacle.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacle.erase(obs)
	
func hit_obs(body):
	if body.name == "alien":
		game_over()
	#elif body.name == "ball":
		#remove_obs(obs)
		#body.queue_free()

func scoreVisible():
	$interface.get_node("score").text = "SCORE : " +str(score / SCORE_MODIFIER)

func verifhightdcore():
	if score > hight_score:
		hight_score = score
	$interface.get_node("max").text = "HIGHT SCORE :" + str(hight_score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	verifhightdcore()
	get_tree().paused = true
	debut_jeu = false
	$gameover.show()


func _on_timer_timeout():
	colldown = false
