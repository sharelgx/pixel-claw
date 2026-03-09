extends Node
## 任务板系统 - 读取并解析 TASK_BOARD.md

signal task_updated(task_id: String, task_data: Dictionary)
signal board_refreshed

var tasks: Dictionary = {}  # task_id -> task data
var last_modified: int = 0
var task_board_path: String = ""

func _ready() -> void:
	var settings = get_node("/root/GameSettings") as GameSettings
	if settings and settings.get("openclaw", "enabled", false):
		task_board_path = settings.get("openclaw", "task_board_path", "")
	
	if task_board_path != "":
		refresh_board()
		# 启动文件监听定时器
		var timer = Timer.new()
		timer.wait_time = settings.get("openclaw", "poll_interval_seconds", 10)
		timer.timeout.connect(_on_poll_timeout)
		timer.name = "PollTimer"
		add_child(timer)
		timer.start()
		print("[TaskBoard] 任务板监听已启动，路径: %s" % task_board_path)
	else:
		print("[TaskBoard] 未配置任务板路径，使用模拟数据")
		_load_mock_data()

func _on_poll_timeout() -> void:
	if task_board_path != "":
		refresh_board()

func refresh_board() -> void:
	if not FileAccess.file_exists(task_board_path):
		print("[TaskBoard] 文件不存在: %s" % task_board_path)
		return
	
	var file = FileAccess.open(task_board_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var current_modified = FileAccess.get_modified_time(task_board_path)
	if current_modified != last_modified:
		last_modified = current_modified
		_parse_tasks(content)
		board_refreshed.emit()
		print("[TaskBoard] 任务板已更新，共 %d 个任务" % tasks.size())

func _parse_tasks(markdown: String) -> void:
	tasks.clear()
	
	var lines = markdown.split("\n")
	var in_table = false
	var header_parsed = false
	
	for line in lines:
		line = line.strip_edges()
		
		# 检测表格开始（包含 | Task ID |）
		if line.contains("| Task ID |"):
			in_table = true
			header_parsed = true
			continue
		
		if in_table and line.begins_with("|---"):
			continue
		
		if in_table and line.contains("|"):
			if not header_parsed:
				continue
			
			# 解析表格行（分割 | ，跳过首尾空）
			var cells = line.split("|", false)
			if cells.size() >= 7:
				var task_id = cells[1].strip_edges()
				var title = cells[2].strip_edges()
				var owner = cells[3].strip_edges()
				var status = cells[4].strip_edges()
				var due = cells[5].strip_edges()
				var notes = cells[6].strip_edges()
				
				# 清理 title 中的 markdown 格式（如 **bold**）
				title = title.replace("**", "").replace("__", "")
				
				tasks[task_id] = {
					"id": task_id,
					"title": title,
					"owner": owner,
					"status": _normalize_status(status),
					"due": due,
					"notes": notes,
					"last_updated": Time.get_unix_time_from_system()
				}
				
				task_updated.emit(task_id, tasks[task_id])
				
				# 调试输出
				if task_id == "T-20250309-01":
					print("[TaskBoard] 关键任务加载: %s - %s (owner: %s)" % [task_id, title, owner])

func _normalize_status(status: String) -> String:
	var s = status.to_upper()
	if s.contains("TODO") or s.contains("待") or s == "":
		return "TODO"
	elif s.contains("IN_PROGRESS") or s.contains("进行") or s.contains("ING"):
		return "IN_PROGRESS"
	elif s.contains("DONE") or s.contains("完成") or s.contains("FINISH"):
		return "DONE"
	elif s.contains("BLOCKED") or s.contains("阻塞"):
		return "BLOCKED"
	else:
		return "UNKNOWN"

func get_task(task_id: String) -> Dictionary:
	if tasks.has(task_id):
		return tasks[task_id]
	return {}

func get_tasks_by_owner(owner: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for task_id in tasks:
		if tasks[task_id]["owner"] == owner:
			result.append(tasks[task_id])
	return result

func get_tasks_by_status(status: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for task_id in tasks:
		if tasks[task_id]["status"] == status:
			result.append(tasks[task_id])
	return result

func _load_mock_data() -> void:
	# 模拟数据用于演示
	tasks = {
		"T-DEMO-01": {
			"id": "T-DEMO-01",
			"title": "创建像素办公室原型",
			"owner": "jarvis-feishu",
			"status": "IN_PROGRESS",
			"due": "2026-03-10",
			"notes": "使用 Godot 引擎开发"
		},
		"T-DEMO-02": {
			"id": "T-DEMO-02",
			"title": "设计 Agent 角色像素图",
			"owner": "corali-feishu",
			"status": "IN_PROGRESS",
			"due": "2026-03-11",
			"notes": "贾维斯、克拉瑞、小远"
		},
		"T-DEMO-03": {
			"id": "T-DEMO-03",
			"title": "实现任务板同步功能",
			"owner": "jarvis-feishu",
			"status": "TODO",
			"due": "2026-03-12",
			"notes": "读取 TASK_BOARD.md"
		},
		"T-DEMO-04": {
			"id": "T-DEMO-04",
			"title": "添加时间系统和昼夜切换",
			"owner": "xiaoyuan-explore",
			"status": "DONE",
			"due": "2026-03-09",
			"notes": "已完成"
		}
	}
	print("[TaskBoard] 已加载模拟数据（%d个任务）" % tasks.size())
