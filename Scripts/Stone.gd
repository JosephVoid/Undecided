extends RigidBody2D

var equiped

onready var mainchar = get_parent().get_node("Mainchar")

func _ready():
	pass

func drop():
	equiped = false

func equip():
	equiped = true
	set_mode(MODE_STATIC)
	global_transform.origin = mainchar.get_node("Textures/UpperParts/Torso/HeadLRhands/RH/RFA/Wrist/RHTrem").global_position
	set_collision_mask_bit(0,false)

func throw():
	equiped = false
	var d = null
	if mainchar.direction == "L":
		d = -1
	elif mainchar.direction == "R":
		d = 1
	set_mode(MODE_RIGID)
	self.apply_central_impulse(Vector2(d * 3000,-500))
	set_collision_mask_bit(0,true)


func _process(delta):
	if equiped:
		equip()


func _on_Stone_body_entered(body):
	
	if "Soldier" in body.name:
		if get_linear_velocity().x > 200 or get_linear_velocity().x < -200:
			var bp = body.position
			if bp < position:
				body.damage(10,Vector2.RIGHT)
				body.set_following_state()
			elif bp > position:
				body.damage(10,Vector2.LEFT)
				body.set_following_state()
