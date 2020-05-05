extends Area2D

var stored
var equiped
var pickedup
var dir
var g = 800
var velocity = Vector2()
var onground = false

onready var mainchar = get_parent().get_node("Mainchar")

func _ready():
	dirSetter()

func drop():
	stored = false
	equiped = false
	pickedup = false
	onground = false

func dirSetter():
	if get_node("Head").global_position.x > get_node("Tail").global_position.x:
		dir = "R"
	elif get_node("Head").global_position.x < get_node("Tail").global_position.x:
		dir = "L"
func on_pickup_flip():
	if dir == "R":
		self.apply_scale(Vector2(-1,1))
		dir = "L"
	elif dir == "L":
		self.apply_scale(Vector2(-1,1))
		dir = "R"

func store():
	equiped = false
	self.position = mainchar.get_node("Textures/UpperParts/Torso/WeaponStore").global_position
	self.z_index = -2
	self.set_rotation_degrees(72)
	stored = true
func equip():
	stored = false
	self.position = mainchar.get_node("Textures/UpperParts/Torso/HeadLRhands/LH/LFA/Wrist").global_position
	self.set_rotation_degrees(-25)
	equiped = true

func _process(delta):
	if stored:
		store()
	elif equiped:
		equip()
	if pickedup:
		if Input.is_action_just_pressed("ui_left"):
			if dir == "R":
				self.apply_scale(Vector2(-1,1))
				dir = "L"

		elif Input.is_action_just_pressed("ui_right"):
			if dir == "L":
				self.apply_scale(Vector2(-1,1))
				dir = "R"

	
	if !stored and !equiped and !pickedup and !onground:
		velocity.y += g * delta
		position.y += velocity.y * delta
		
func _on_AnimationPlayer_animation_started(anim_name):
	#print(anim_name)
	pass


func _on_Sword_body_entered(body):
	if body.name == "StaticBody2D":
		onground = true


func _on_Area2D_body_entered(body):
	if equiped:
		if "Soldier" in body.name:
			var bp = body.position
			if bp < self.position:
				body.damage(30,Vector2.LEFT)
				body.knockback(Vector2.LEFT)
				body.set_following_state()
			elif bp > self.position:
				body.damage(30,Vector2.RIGHT)
				body.knockback(Vector2.LEFT)
				body.set_following_state()
