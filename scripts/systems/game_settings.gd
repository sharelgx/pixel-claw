extends Node
## 游戏设置管理器 - 单例
## 负责加载和管理配置文件

var settings: Dictionary = {}

func _ready() -> void:
	load_settings()
	print("[GameSettings] 配置加载完成")

func load_settings() -> void:
	var config_path = "user://settings.json"
	
	# 尝试加载用户配置
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open(config_path, FileAccess.READ)
		settings = JSON.parse_string(file.get_as_text()) or {}
		file.close()
		print("[GameSettings] 已加载用户配置")
	else:
		# 加载默认配置
		var default_path = "res://config/settings.json"
		if ResourceLoader.exists(default_path):
			var default_file = FileAccess.open(default_path, FileAccess.READ)
			settings = JSON.parse_string(default_file.get_as_text()) or {}
			default_file.close()
			print("[GameSettings] 已加载默认配置")
		else:
			settings = get_default_settings()
			print("[GameSettings] 使用硬编码默认值")

func get_default_settings() -> Dictionary:
	return {
		"game": {
			"title": "OpenClaw Pixel Office",
			"version": "0.1.0-dev",
			"window_width": 1280,
			"window_height": 720,
			"fps_limit": 60,
			"show_fps": true
		},
		"openclaw": {
			"enabled": false,
			"task_board_path": "",
			"sync_mode": "file_watch",
			"websocket_url": "ws://localhost:8080/ws",
			"poll_interval_seconds": 10
		},
		"time": {
			"speed_multiplier": 1.0
		},
		"agents": {
			"update_interval_seconds": 2.0
		}
	}

func get(section: String, key: String, default = null):
	if settings.has(section) and settings[section].has(key):
		return settings[section][key]
	return default

func set(section: String, key: String, value) -> void:
	if not settings.has(section):
		settings[section] = {}
	settings[section][key] = value
	save_settings()

func save_settings() -> void:
	var config_path = "user://settings.json"
	var file = FileAccess.open(config_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(settings, "\t"))
	file.close()
	print("[GameSettings] 配置已保存")
