extends Node2D
class_name WorldItemDrop

var item_instance: Dictionary = {}
var _body: Polygon2D
var _label: Label

func setup(item: Dictionary) -> void:
	item_instance = item.duplicate(true)

func _ready() -> void:
	_body = Polygon2D.new()
	_body.polygon = PackedVector2Array([
		Vector2(-8, -8),
		Vector2(8, -8),
		Vector2(8, 8),
		Vector2(-8, 8),
	])
	_body.color = item_instance.get("rarity_color", Color.WHITE)
	add_child(_body)

	_label = Label.new()
	_label.position = Vector2(10, -14)
	_label.text = item_instance.get("name", "Item")
	add_child(_label)
