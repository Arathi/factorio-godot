extends Node2D


var lua: LuaAPI
var texture_cache: Dictionary = {}


var factorio_path: String:
	get:
		return UserResourceLoader.config["factorio_data_path"]


var items = []
var recipes = []


var PACKAGES: Array[String] = [
	"res://assets/lualib/?.lua",
	"user://assets/lualib/?.lua",
	"core",
	"core/lualib",
	"base",
]


var prototypes: Array[String] = [
	"item",
	"recipe",
]

func _ready():
	lua = LuaAPI.new()
	lua.bind_libraries([
		"base", 
		"coroutine", 
		"debug", 
		"table", 
		"string", 
		"math", 
		"io", 
		"os", 
		"utf8", 
		"package",
	])
	
	print("Factorio数据加载器准备就绪")
	pass


func _process(delta):
	pass


func load_image(name: String):
	var path = "%s/%s" % [factorio_path, name]
	if !FileAccess.file_exists(path):
		push_error("图片文件（%s）不存在！" % name)
		return null
	
	var file = FileAccess.open(path, FileAccess.READ)
	var buffer = file.get_buffer(file.get_length())
	file.close()
	
	var dot_index = path.rfind(".")
	var ext_name = path.substr(dot_index)
	
	var image = Image.new()
	var error = null
	match ext_name:
		".bmp": error = image.load_bmp_from_buffer(buffer)
		".jpg": error = image.load_jpg_from_buffer(buffer)
		".png": error = image.load_png_from_buffer(buffer)
		".tga": error = image.load_tga_from_buffer(buffer)
		".webp": error = image.load_webp_from_buffer(buffer)
		_:
			push_error("文件格式无效")
			return null
	
	if error != OK:
		push_error("图片文件（%s）加载失败！" % path)
		return null
	
	return image


func load_texture(name) -> ImageTexture:
	if texture_cache.has(name):
		return texture_cache[name]
	print("贴图（%s）未缓存，正在建立缓存" % name)
	
	var image = load_image(name)
	if image == null:
		push_error("图片（%s）加载失败，无法生成贴图" % name)
		return null
	
	var texture = ImageTexture.create_from_image(image)
	texture_cache[name] = texture
	return texture


func load_script():
	var pkgs: String = ""
	for pkg in PACKAGES:
		pkgs += ";"
		if pkg.begins_with("res://"):
			pkgs += pkg
		elif pkg.begins_with("user://"):
			pkgs += pkg
		else:
			pkgs += factorio_path + "/" + pkg + "/?.lua"
	print("Lua额外包路径如下：%s" % pkgs)
	
	var script = """
		package.path = package.path .. "%s"
		
		require "dataloader"
		require "util"
		
		require("prototypes.item")
		require("prototypes.recipe")
		
		json = require("json")
		items = json.encode(data.raw["item"])
		recipes = json.encode(data.raw["recipe"])
	""" % [
		pkgs
	]
	
	var error = lua.do_string(script)
	if error is LuaError:
		push_error("脚本执行失败！错误码%d：%s" % [error.type, error.message])
		return null
	
	var items_json = lua.pull_variant("items")
	var recipes_json = lua.pull_variant("recipes")
	
	items = JSON.parse_string(items_json)
	recipes = JSON.parse_string(recipes_json)
	print("脚本加载完成")
	
	pass
