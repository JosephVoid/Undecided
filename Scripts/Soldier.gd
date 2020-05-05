extends "res://Scripts/NPC.gd"

export var speed = 400
var health = 100
var jump_height = 400
export(states) var state = states.IDLE
var anim_running = false
var is_char_alive = true
var dir = Vector2.RIGHT
var motion = Vector2()
var in_proximity = false
var enemy_type = "soldier"

onready var mainchar = get_parent().get_node("Mainchar")
#Knock back
func knockback(var damage_direction):
	if damage_direction == Vector2.RIGHT:
		motion.x = -80000
	elif damage_direction == Vector2.LEFT:
		motion.x = 80000


func detect():
	if get_node("RayCast2DSpotter").get_collider() == mainchar && !in_proximity:
		motion = follow(motion,mainchar,self.speed,self.dir)
		if self.state != states.DEAD:
			self.state = states.FOLLOWING
	
	if in_proximity:
		self.state = states.ATTACKING
	
	if mainchar.dead == true:
		is_char_alive = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	detect()
	match state:
		states.IDLE:
			if !anim_running:
				$AnimationPlayer.play("Idle")
		states.FOLLOWING:
			if !anim_running:
				$AnimationPlayer.play("Run")
			if is_char_alive:
				motion = follow(motion,mainchar,speed,dir)
		states.ATTACKING:
			if in_proximity and is_char_alive:
				meele_attack()
			elif !in_proximity and is_char_alive:
				state = states.FOLLOWING
			elif !is_char_alive:
				state = states.IDLE
		states.WANDERING:
			$AnimationPlayer.play("Walk")
			if is_char_alive:
				motion = wanderAround(motion,mainchar)
		states.DEAD:
			motion = Vector2(0,0)
	#######Gravity && Motion executor########
	motion.y += GRAVITY*80
	motion = move_and_slide(motion,FLOOR)

func _on_HeadShot_bullet_entered(body):
	#HeadShots
	if "Bullet" in body.name:
		die()

func _on_AttackDetector_body_entered(body):
	if "Mainchar" in body.name:
		in_proximity = true
	
func _on_AttackDetector_body_exited(body):
	if "Mainchar" in body.name:
		anim_running = false
		in_proximity = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "StutterL" or anim_name == "StutterR":
		anim_running = false
	if anim_name == "Death":
		queue_free()


func _on_DamageInflictor_body_entered(body):
	if "Mainchar" in body.name:
		if self.position > body.position:
			body.damage(20,Vector2.RIGHT)
		elif self.position < body.position:
			body.damage(20,Vector2.LEFT)


func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "Death":
		set_dead_state()
