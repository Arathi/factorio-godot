extends Node2D


var config: Dictionary = {}


func _enter_tree():
	print("开始加载配置文件")
	load_config()


func _ready():
	print("用户资源加载器准备就绪")


func _process(delta):
	pass


func load_json(name: String):
	var path = "user://" + name
	if !FileAccess.file_exists(path):
		push_error("用户资源文件（%s）不存在" % name)
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)


func load_config():
	var name = "config.json"
	var config = load_json(name)
	if config != null:
		self.config = config
		print("配置文件加载完成")
	else:
		print("配置文件为空")
		save_config()


func save_config():
	var json = JSON.stringify(config)
	var path = "user://config.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)
	print("配置文件保存完成")

