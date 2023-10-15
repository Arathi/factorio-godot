@tool
extends Node2D


var factorio_data_path: String

@onready var loading_group: Node = get_node("loading")
@onready var logo: Sprite2D = get_node("loading/logo")
@onready var description_label: Label = get_node("loading/description")
@onready var progress_bar: ProgressBar = get_node("loading/progress_bar")
@onready var file_dialog: FileDialog = get_node("file_dialog")

func _ready():
	loading()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func loading():
	factorio_data_path = UserResourceLoader.config.get("factorio_data_path", "")
	
	if !DirAccess.dir_exists_absolute(factorio_data_path + "/core"):
		push_warning("Factorio的data目录未选择")
		file_dialog.root_subfolder = factorio_data_path
		file_dialog.show()
		return
	
	show_logo()
	
	description_label.set_text("正在加载脚本")
	FactorioDataLoader.load_script()
	
	var index = 0
	var item_amount= FactorioDataLoader.items.size()
	print("获取物品信息%d条" % item_amount)
	for item in FactorioDataLoader.items:
		description_label.set_text("正在加载物品信息（%d / %d）" % [
			index + 1,
			item_amount
		])
		
		# 缓存图片
		
		index += 1
		pass

	var recipe_amount= FactorioDataLoader.recipes.size()
	print("获取配方信息%d条" % recipe_amount)
	index = 0
	for recipe in FactorioDataLoader.recipes:
		description_label.set_text("正在加载配方信息（%d / %d）" % [
			index + 1,
			recipe_amount
		])
		
		index += 1
		pass


func show_logo():
	var logo_path = "core/graphics/background-image-logo.png"
	var logo_texture = FactorioDataLoader.load_texture(logo_path)
	if logo_texture != null:
		logo.set_texture(logo_texture)
		print("logo贴图设置完成")


func _on_file_dialog_dir_selected(dir: String):
	print("Factorio的data目录已选择：%s" % dir)
	UserResourceLoader.config["factorio_data_path"] = dir
	UserResourceLoader.save_config()
	file_dialog.hide()
	
	print("重新开始加载")
	loading()
