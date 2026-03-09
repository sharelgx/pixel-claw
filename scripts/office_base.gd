extends Node2D
## 办公室楼层 - 通过代码生成像素环境

@export var floor_number: int = 1

func _ready() -> void:
	_generate_office_environment()
	print("[Office] %dF 环境生成完成" % floor_number)

func _generate_office_environment() -> void:
	# 1. 地板（灰色背景）
	var floor = ColorRect.new()
	floor.name = "Floor"
	floor.rect_size = Vector2(1200, 800)
	floor.color = Color(0.85, 0.85, 0.85, 1.0)
	add_child(floor)
	
	# 2. 墙壁装饰（简单的窗户）
	var window = ColorRect.new()
	window.name = "Window"
	window.rect_position = Vector2(800, 50)
	window.rect_size = Vector2(300, 200)
	window.color = Color(0.6, 0.8, 1.0, 0.8)  # 天蓝色
	add_child(window)
	
	# 3. 办公桌（根据楼层不同）
	var desk_count = 1 + floor_number  # 每层桌子数量递增
	for i in range(desk_count):
		var desk = _create_desk(i * 250 + 100, 300)
		add_child(desk)
	
	# 4. 会议室（4F有）
	if floor_number == 4:
		var meeting_room = _create_meeting_room(900, 100)
		add_child(meeting_room)
	
	# 5. 茶水间（每层都有）
	var kitchen = _create_kitchen(100, 50)
	add_child(kitchen)

func _create_desk(x: int, y: int) -> Node2D:
	var desk = Node2D.new()
	desk.name = "Desk_%d_%d" % [x, y]
	desk.position = Vector2(x, y)
	
	# 桌面
	var table = ColorRect.new()
	table.rect_size = Vector2(120, 80)
	table.color = Color(0.6, 0.4, 0.2, 1.0)  # 木色
	desk.add_child(table)
	
	# 电脑
	var monitor = ColorRect.new()
	monitor.rect_position = Vector2(10, -40)
	monitor.rect_size = Vector2(40, 30)
	monitor.color = Color(0.2, 0.2, 0.2, 1.0)
	desk.add_child(monitor)
	
	# 键盘
	var keyboard = ColorRect.new()
	keyboard.rect_position = Vector2(20, 0)
	keyboard.rect_size = Vector2(30, 10)
	keyboard.color = Color(0.1, 0.1, 0.1, 1.0)
	desk.add_child(keyboard)
	
	return desk

func _create_meeting_room(x: int, y: int) -> Node2D:
	var room = Node2D.new()
	room.name = "MeetingRoom"
	room.position = Vector2(x, y)
	
	var table_rect = ColorRect.new()
	table_rect.rect_size = Vector2(200, 120)
	table_rect.color = Color(0.7, 0.7, 0.7, 1.0)
	room.add_child(table_rect)
	
	var label = Label.new()
	label.text = "Meeting"
	label.position = Vector2(70, 50)
	label.modulate = Color(0.5, 0.5, 0.5, 1.0)
	room.add_child(label)
	
	return room

func _create_kitchen(x: int, y: int) -> Node2D:
	var kitchen = Node2D.new()
	kitchen.name = "Kitchen"
	kitchen.position = Vector2(x, y)
	
	var counter = ColorRect.new()
	counter.rect_size = Vector2(100, 60)
	counter.color = Color(0.8, 0.8, 0.8, 1.0)
	kitchen.add_child(counter)
	
	var coffee_rect = ColorRect.new()
	coffee_rect.rect_position = Vector2(10, 10)
	coffee_rect.rect_size = Vector2(20, 15)
	coffee_rect.color = Color(0.3, 0.2, 0.1, 1.0)
	kitchen.add_child(coffee_rect)
	
	var label = Label.new()
	label.text = "☕"
	label.position = Vector2(35, 5)
	kitchen.add_child(label)
	
	return kitchen
