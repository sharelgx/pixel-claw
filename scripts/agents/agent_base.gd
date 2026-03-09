extends Node2D
class_name Agent

enum AgentState { IDLE, WORKING, DRINKING, MEETING, ERROR, WALKING }

@export var agent_id: String = ""
@export var agent_name: String = "Agent"
@export var display_name: String = ""
@export var agent_color: Color = Color.WHITE
@export var home_floor: int = 2
@export var home_position: Vector2 = Vector2.ZERO

var current_state: AgentState = AgentState.IDLE
var current_task: Dictionary = {}
var target_position: Vector2 = Vector2.ZERO
var movement_speed: float = 64.0  # 更快一点

func _ready() -> void:
	add_to_group("agents")
	print("[Agent:%s] %s 初始化" % [agent_id, display_name if display_name != "" else agent_name])

func _process(delta: float) -> void:
	if current_state == AgentState.WALKING:
		var direction = (target_position - position).normalized()
		if direction.length() > 0:
			position += direction * movement_speed * delta
		if position.distance_to(target_position) < 5.0:
			position = target_position
			current_state = AgentState.IDLE

func set_task(task: Dictionary) -> void:
	current_task = task
	if task.has("status"):
		match task["status"]:
			"IN_PROGRESS":
				current_state = AgentState.WORKING
			"BLOCKED":
				current_state = AgentState.ERROR
			_:
				current_state = AgentState.IDLE

func _on_task_updated(task_id: String, task_data: Dictionary) -> void:
	if task_data["owner"] == agent_id:
		set_task(task_data)
