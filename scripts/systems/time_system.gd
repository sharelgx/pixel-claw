extends Node
## 时间系统 - 管理游戏内时间、昼夜、加速

signal time_updated(hour: int, minute: int, is_daytime: bool)
signal day_started
signal night_started
signal weekend_started

var game_time: float = 0.0  # 游戏内时间（秒），从0:00开始
var time_speed: float = 1.0  # 时间流速倍率
var is_daytime: bool = true

# 工作时间设置
var work_start_hour: int = 8
var work_end_hour: int = 18

func _ready() -> void:
	var settings = get_node("/root/GameSettings") as GameSettings
	if settings:
		work_start_hour = settings.get("time", "start_hour", 8)
		work_end_hour = settings.get("time", "end_hour", 18)
		time_speed = settings.get("time", "speed_multiplier", 1.0)
	
	# 每秒调用 _process_time
	set_physics_process(true)
	print("[TimeSystem] 时间系统已启动")

func _physics_process(delta: float) -> void:
	# game_time 以秒为单位，每现实1秒，游戏时间过去 time_speed 秒
	game_time += delta * time_speed
	
	# 转换为小时:分钟
	var total_minutes = int(game_time / 60.0)
	var hour = (total_minutes / 60) % 24
	var minute = total_minutes % 60
	
	# 检测昼夜变化
	var was_daytime = is_daytime
	is_daytime = (hour >= work_start_hour and hour < work_end_hour)
	
	if was_daytime != is_daytime:
		if is_daytime:
			day_started.emit()
		else:
			night_started.emit()
	
	time_updated.emit(hour, minute, is_daytime)

func get_time_string() -> String:
	var total_minutes = int(game_time / 60.0)
	var hour = (total_minutes / 60) % 24
	var minute = total_minutes % 60
	return "%02d:%02d" % [hour, minute]

func get_hour() -> int:
	var total_minutes = int(game_time / 60.0)
	return (total_minutes / 60) % 24

func is_working_hour() -> bool:
	var hour = get_hour()
	return hour >= work_start_hour and hour < work_end_hour

func accelerate(speed: float) -> void:
	time_speed = clamp(speed, 0.0, 10.0)
	print("[TimeSystem] 时间流速设置为 %.1fx" % time_speed)

func reset() -> void:
	game_time = 0.0
	time_speed = 1.0
