extends CharacterBody2D

const GRAVITY : int = 4000
const JUMP_SPEED : int = -1300

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().debut_jeu:
			pass
		else:
			$up.disabled = false
			if Input.is_action_pressed("ui_accept"):
				velocity.y += JUMP_SPEED
				$sautson.play()
			#elif Input.is_action_pressed("ui_down"):
			#	$AnimatedSprite2D.play("accroupi")
			#	$up.disabled = true
			#else:
			#	$AnimatedSprite2D.play("cours")
	#else:
	#	$AnimatedSprite2D.play("saut")
		
	move_and_slide()
	
