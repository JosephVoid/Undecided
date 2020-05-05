extends KinematicBody2D

const JUMP_POWER = 1000
const FLOOR = Vector2(0,-1)
const ACC = 100
const BULLET = preload("res://Scenes/Bullet.tscn")

var health = 100
var dead = false
var max_speed = 2000
var motion = Vector2()
var direction = "R"
var inipos = Vector2() #Initial postion.
var anim_running = false #Animation running state
var finite_anims = ["Throw","Pickup","Attack1","Attack2","Attack3","Sheath","Reload"] # List of the finite animations
var has_picked_up = false # If char has picked up an object
var att_count = 0 # How many times user pressed attack
var in_aim_state = false # Aim state check
var aim_degree = 0 
var inventory = [null,null] # The inventory
var weapon_equipped # The weapon the char current has
var object_in_pick_area
var stone_in_pick_area
var reloading = false
var can_shoot = true
var throw_animation_has_finished = true

onready var HeadLRhands = get_node("Textures/UpperParts/Torso/HeadLRhands") #The hands and head of char

func _ready():
	$Textures/UpperParts/Torso/HeadLRhands/Head.play("Blink") # The blink animation

func set_body_entered(var be):
	object_in_pick_area = be

func set_stone_entered(var se):
	stone_in_pick_area = se

#The throwing function
func throw_stone():
	weapon_equipped.throw()
	weapon_equipped = null

#Knock back
func knockback(var damage_direction):
	if damage_direction == Vector2.RIGHT:
		motion.x = -80000
	elif damage_direction == Vector2.LEFT:
		motion.x = 80000

# Sets the aim degree
func aimAtdeg(var dir,var interval):
	if dir == 1: #Look up to the sky....
		if aim_degree >= -20:
			aim_degree -= interval
		else:
			aim_degree = -20
		HeadLRhands.set_rotation_degrees(aim_degree)
		if weapon_equipped != null:
			weapon_equipped.rot_deg(aim_degree)
	elif dir == -1: #Look down...
		if aim_degree <= 20:
			aim_degree += interval
		else:
			aim_degree = 20
		HeadLRhands.set_rotation_degrees(aim_degree)
		if weapon_equipped != null:
			weapon_equipped.rot_deg(aim_degree)

# The jump func
func jumpWithPower(var power):
	inipos = self.position # sets intial position
	motion.y = -power*4 # Exagerrating the power..nothing else

# The the max speed the char can go.
func max_speed_setter(var ms):
	max_speed = ms

# Sets the char's hands and head to fit an anim state
func setAimState():
	$AnimationPlayer.stop()
	$Textures/UpperParts/Torso/HeadLRhands/LH.set_rotation_degrees(-90)
	$Textures/UpperParts/Torso/HeadLRhands/RH.set_rotation_degrees(-93)
	$Textures/UpperParts/Torso/HeadLRhands/LH/LFA.set_rotation_degrees(-67)
	$Textures/UpperParts/Torso/HeadLRhands/RH/RFA.set_rotation_degrees(-95)

func damage(var amount,var direction):
	knockback(direction)
	#Animation
	health -= amount
	if health <= 0:
		if !dead:
			anim_running = true
			$AnimationPlayer.play("Die")
			dead = true

# warning-ignore:unused_argument
func _physics_process(delta):
	if !dead:
		# If the char has a rifle, he is in aim state
		if weapon_equipped != null and weapon_equipped.name in "Rifle": 
			in_aim_state = true
			
		else:
			in_aim_state = false
		
		# If he is in aim state,
		if in_aim_state:
			$Blender.active = true # The anim blender will be active.
			max_speed_setter(1000) # Limits the speed.
			if !reloading:
				setAimState() # Makes char aim.
		else:
			$Blender.active = false
			max_speed_setter(2000)
		
		
		########### Flipping the character to Left  ##
		if Input.is_action_just_pressed("ui_left"): ##
			if direction == "R":                    ##
				self.apply_scale(Vector2(-1,1)) 
				direction = "L"                     ##
		##############################################
		
		########### Flipping the character to Right   ##
		elif Input.is_action_just_pressed("ui_right"):##
			if direction == "L":                      ##
				self.apply_scale(Vector2(-1,1))       ##
				direction = "R"                       ##
		################################################
		
		###############If right key is pressed###########################
		if Input.is_action_pressed("ui_left"):
			# If aiming,
			if in_aim_state:
				# Blend walk and aim
				$Blender.set("parameters/BlendTree/Blend3/blend_amount",0)
				$Blender.set("parameters/Blend2/blend_amount",0.5)
			else:
				$AnimationPlayer.play("Run")
			motion.x = max(motion.x - ACC,-max_speed) # The actual movement 
		
		###############If left key is pressed##############################
		elif Input.is_action_pressed("ui_right"):
			# If aiming,
			if in_aim_state:
				# Blend walk and aim
				$Blender.set("parameters/BlendTree/Blend3/blend_amount",0)
				$Blender.set("parameters/Blend2/blend_amount",0.5)
			else:
				$AnimationPlayer.play("Run")
			motion.x = min(motion.x + ACC,max_speed) # The actual movement    
		
		##################If nothing is pressed############################
		else:
			# If aiming,
			if in_aim_state:
				# Blend Idle and aim
				$Blender.set("parameters/BlendTree/Blend3/blend_amount",-1)
				$Blender.set("parameters/Blend2/blend_amount",0.5)
			else:
				if !anim_running:
					$AnimationPlayer.play("Idle")
			motion.x = lerp(motion.x,0,0.8) # Comes to halt smoothly
	
		################ For picking shit up ################################
		if Input.is_action_just_pressed("alt_key"):
			
			# If there is an object in the area.
			if object_in_pick_area != null:
				print(object_in_pick_area.name)
				# If that object is a sword or rifle type.
				#print(has_picked_up)
				if (object_in_pick_area.name in "Sword" or object_in_pick_area.name in "Rifle") and !has_picked_up :
					# Object has been picked up
					object_in_pick_area.pickedup = true
					# If there is a direction mismatch
					if object_in_pick_area.dir != direction:
						object_in_pick_area.on_pickup_flip() #flip on pick up
					# If iss a Sword type
					if object_in_pick_area.name in "Sword":
						inventory.insert(0,object_in_pick_area) # insert to 0 index
						inventory.remove(1) # remove the null place holder
					# If iss a Rifle type
					elif object_in_pick_area.name in "Rifle":
						inventory.insert(1,object_in_pick_area) # insert to 1 index
						inventory.remove(2) # remove the null place holder
					anim_running = true # Making space for animation
					$AnimationPlayer.play("Pickup",-1,2)
					object_in_pick_area.store() # store visually
			
			if has_picked_up and weapon_equipped.name in "Stone":
				has_picked_up = false
				anim_running = true # Make space for animation
				$AnimationPlayer.play("Throw")
				
				if throw_animation_has_finished:
					weapon_equipped = null
				
			if object_in_pick_area == null and weapon_equipped!= null:
				if !(weapon_equipped.name in "Stone"):
					weapon_equipped.drop()
					weapon_equipped = null
				has_picked_up = false
			
			if stone_in_pick_area != null:
				if stone_in_pick_area.name in "Stone" and !has_picked_up:
					anim_running = true # Making space for animation
					$AnimationPlayer.play("Pickup",-1,2)
					weapon_equipped = stone_in_pick_area
					stone_in_pick_area.equip()
					has_picked_up = true
		
		################# Selecting weapons ##############################
		if Input.is_action_just_pressed("1_key") and inventory[0] != null:
			# Equipping the sword
			if weapon_equipped == null:
				weapon_equipped = inventory[0]
				inventory[0].equip()
				has_picked_up = true
			# Switching Weapons
			elif weapon_equipped != null and not (weapon_equipped.name in "Sword") and not (weapon_equipped.name in "Stone"):
				weapon_equipped.store()
				weapon_equipped = inventory[0]
				inventory[0].equip()
				has_picked_up = true
			# Sheathing
			elif weapon_equipped.name in "Sword":
				weapon_equipped.store()
				weapon_equipped = null
				has_picked_up = false
				
		elif Input.is_action_just_pressed("2_key") and inventory[1] != null:
			# Equipping the Rifle
			if weapon_equipped == null:
				weapon_equipped = inventory[1]
				inventory[1].equip()
				setAimState()
				has_picked_up = true
				
			# Switching Weapons
			elif weapon_equipped != null and not (weapon_equipped.name in "Rifle") and not (weapon_equipped.name in "Stone"):
				weapon_equipped.store()
				weapon_equipped = inventory[1]
				inventory[1].equip()
				has_picked_up = true
			# Sheathing
			elif weapon_equipped.name in "Rifle":
				anim_running = true
				$AnimationPlayer.play("Sheath",-1,2)
				weapon_equipped.rot_deg(0)
				weapon_equipped.store()
				weapon_equipped = null
				has_picked_up = false
				HeadLRhands.set_rotation_degrees(0)
		elif Input.is_action_just_pressed("3_key"):
			if weapon_equipped.name in "Rifle" or weapon_equipped.name in "Sword":
				weapon_equipped.store()
				weapon_equipped = null
				has_picked_up = false
			
		#################For aiming#######################################
		if in_aim_state:
			# If pressed up,
			if Input.is_action_pressed("ui_up"):
				aimAtdeg(1,2) # Aim 2 deg up
			if Input.is_action_pressed("ui_down"):
				aimAtdeg(-1,2) # Aim 2 deg down
		
		#######################################
		motion = move_and_slide(motion,FLOOR)## He who causes motion.
		#######################################
		
		########################For attacking##############################
		if Input.is_action_just_pressed("a_key"):
			$Textures/UpperParts/Torso/HeadLRhands/Head.play("Angry")
		if Input.is_action_just_released("a_key"):
			$Textures/UpperParts/Torso/HeadLRhands/Head.play("Blink")
		if Input.is_action_just_pressed("a_key"):
			
			if weapon_equipped != null:
				#If the equipped item is a rifle
				if in_aim_state:
					if can_shoot:
						$AnimationPlayer.play("Reload",-1,0.8)
						reloading = false
						var bullet = BULLET.instance()
						get_parent().add_child(bullet)
						var muzzletip = $Textures/UpperParts/Torso/HeadLRhands/LH/LFA/BulletSpawn.global_position
						var to = $Textures/UpperParts/Torso/HeadLRhands/LH/LFA/BulletSpawn2.global_position
						var shotV = muzzletip.direction_to(to)
						bullet.fire(muzzletip,shotV)
						bullet.get_node("Timer").start()
						reloading = true
				else:
					if weapon_equipped.name in "Sword":
						anim_running = true # Make space for animation
						if att_count == 0: # First attack
							$AnimationPlayer.play("Attack1")
							get_node("../Sword/AnimationPlayer").play("Attack1")
							att_count += 1
							$AttackTimer.start() # Start timer for combo
						elif att_count == 1:
							$AnimationPlayer.play("Attack2")
							att_count += 1
						elif att_count == 2:
							$AnimationPlayer.play("Attack3")
							att_count = 0
		
		########################For jumping#################################
		if Input.is_action_just_pressed("ui_accept") && is_on_floor():
			jumpWithPower(JUMP_POWER)
		# When you release the jump button
		if !Input.is_action_pressed("ui_accept") && motion.y < 0:
			# Only jump 4 times the start y point
			if self.position.y < 4 * inipos.y:
				motion.y = 0
		# If going up.
		if motion.y < 0:
			if in_aim_state:
				$Blender.set("parameters/Blend2/blend_amount",0.5)
				$Blender.set("parameters/BlendTree/Blend3/blend_amount",1)
				$Blender.set("parameters/BlendTree/JumpCrouchBlender/blend_amount",0)
			else:
				$AnimationPlayer.play("Jump_up")
		# If its going down
		elif motion.y > 0:
			if in_aim_state:
				$Blender.set("parameters/Blend2/blend_amount",0.5)
				$Blender.set("parameters/BlendTree/JumpCrouchBlender/blend_amount",1)
				$Blender.set("parameters/BlendTree/Blend3/blend_amount",1)
			else:
				if $AnimationPlayer.current_animation != "Jump_down": 
					$AnimationPlayer.stop()
					$AnimationPlayer.play("Jump_down")
		
		######################################
		if !is_on_floor():                  ##
			motion.y += 100                 ##
		else:                               ##
			motion.y += 10                  ## Lord Gravity
		######################################

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in finite_anims:
		anim_running = false
	if anim_name == "Reload":
		can_shoot = true
	if anim_name == "Throw":
		throw_animation_has_finished = true
func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "Run":
		anim_running = false
	if anim_name == "Reload":
		can_shoot = false
	if anim_name == "Throw":
		throw_animation_has_finished = false
func _on_AttackTimer_timeout():
	att_count = 0

func _on_PickArea_area_entered(area):
	set_body_entered(area)

# warning-ignore:unused_argument
func _on_PickArea_area_exited(area):
	set_body_entered(null)


func _on_PickArea_body_entered(body):
	set_stone_entered(body)

# warning-ignore:unused_argument
func _on_PickArea_body_exited(body):
	set_stone_entered(null)