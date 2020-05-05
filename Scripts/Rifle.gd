extends Area2D
var stored
var equiped
var pickedup
var rot_degs = 0
var dir
var g = 800
var velocity = Vector2()
var onground = false

onready var mainchar = get_node("../Mainchar")
func drop():
	stored = false
	equiped = false
	pickedup = false
	onground = false
func _ready():
	dirSetter()
func rot_deg(var deg):
	if dir == "L":
		set_rotation_degrees(-deg)
	else:
		set_rotation_degrees(deg)
	rot_degs = deg
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
	self.position = mainchar.get_node("Textures/UpperParts/Torso/HeadLRhands/LH/LFA/Wrist/LHTrem").global_position
	self.set_rotation_degrees(0)
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
		if !stored:
			rot_deg(rot_degs)
	else:
		rot_deg(0)
	
	if !stored and !equiped and !pickedup and !onground:
		velocity.y += g * delta
		position.y += velocity.y * delta

func _on_Rifle_body_entered(body):
	if body.name == "StaticBody2D":
		onground = true
