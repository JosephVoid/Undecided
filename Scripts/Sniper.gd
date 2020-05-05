extends "res://Scripts/NPC.gd"

var speed = 400
var health = 100
var jump_height = 400
export(states) var state = states.IDLE
var anim_running = false
var is_char_alive = true
var dir = Vector2.RIGHT
var motion = Vector2()
var in_proximity = false
var enemy_type = "sniper"

onready var HeadHands = get_node("Textures/UpperParts/Torso/HeadLRhands")
onready var mainchar = get_parent().get_node("Mainchar")

func _ready():
	pass # Replace with function body.

func _process(delta):
	
	
	match state:
		states.IDLE:
			pass
		states.WANDERING:
			motion = wanderAround(motion,mainchar);
		states.ATTACKING:
			motion.x = 0
			aim(mainchar)
		states.DEAD:
			pass
	#######Gravity && Motion executor########
	motion.y += GRAVITY*80
	motion = move_and_slide(motion,FLOOR)
