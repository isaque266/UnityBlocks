extends CharacterBody2D

func _enter_tree() -> void: #multiplayer 2
	set_multiplayer_authority(name.to_int())

const SPEED = 100.0
const JUMP_FORCE = -200.0

@onready var animation := $Animation as AnimatedSprite2D
@onready var camera := $"../../CameraFollow"

var is_jumping := false
var can_double_jump := true  # <- Adicionada para controle do pulo duplo

func _ready():
	add_to_group("players")  # Adiciona automaticamente ao grupo "players"

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority(): #multiplayer 2
		velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * 400
	move_and_slide()

	for platforms in get_slide_collision_count():
		var collision = get_slide_collision(platforms)
		if collision.get_collider().has_method("has_collided_with"):
			collision.get_collider().has_collided_with(collision, self)

	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Verifica se está no chão para resetar o pulo duplo
	if is_on_floor():
		is_jumping = false
		can_double_jump = true  # <- Reseta o pulo duplo ao tocar o chão

	# Controle de pulo e pulo duplo
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_FORCE
			is_jumping = true
		elif can_double_jump:
			velocity.y = JUMP_FORCE
			can_double_jump = false  # <- Gasta o pulo duplo
			is_jumping = true

	# Movimento horizontal + animações
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		animation.scale.x = direction
		if !is_jumping:
			animation.play("run")
		else:
			animation.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			animation.play("idle")

	move_and_slide()

func respawn():
	var respawn_point = get_tree().get_nodes_in_group("spawn")[0]
	if respawn_point:
		position = respawn_point.position
