extends Node
## 同步管理器 - 连接 OpenClaw 与游戏

enum SyncMode { FILE_WATCH, WEBSOCKET, NONE }

var sync_mode: SyncMode = SyncMode.NONE
var task_board: TaskBoard
var time_system: TimeSystem

func _ready() -> void:
	task_board = get_node("/root/TaskBoard") as TaskBoard
	time_system = get_node("/root/TimeSystem") as TimeSystem
	
	var settings = get_node("/root/GameSettings") as GameSettings
	if settings:
		if settings.get("openclaw", "enabled", false):
			var mode_str = settings.get("openclaw", "sync_mode", "none")
			match mode_str:
				"file_watch":
					sync_mode = SyncMode.FILE_WATCH
				"websocket":
					sync_mode = SyncMode.WEBSOCKET
				_:
					sync_mode = SyncMode.NONE
			
			if sync_mode == SyncMode.WEBSOCKET:
				_connect_websocket(settings.get("openclaw", "websocket_url", ""))
	
	print("[SyncManager] 同步模式: %s" % SyncMode.keys()[sync_mode])

func _connect_websocket(url: String) -> void:
	# TODO: 实现 WebSocket 连接
	print("[SyncManager] WebSocket 功能待实现")

func dispatch_agent_activity(agent_id: String, action: String, details: String = "") -> void:
	# 从 OpenClaw 接收到活动事件，转发给对应的游戏 agent
	var agent = _find_agent_by_id(agent_id)
	if agent:
		agent.receive_activity(action, details)
		print("[SyncManager] 活动已转发: %s -> %s: %s" % [agent_id, action, details])

func _find_agent_by_id(agent_id: String) -> Node:
	# 在场景树中查找对应的 agent 节点
	var agents = get_tree().get_nodes_in_group("agents")
	for agent in agents:
		if agent.get("agent_id") == agent_id:
			return agent
	return null
