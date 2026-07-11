extends Control


signal selected(gene)


@onready var icon = $TextureRect
@onready var label = $Label


var gene
var is_selected := false


func set_gene(new_gene):
	gene = new_gene

	if gene == null:
		label.text = "No Gene"
		return

	label.text = gene.gene_name + "\n+" + str(gene.attack_bonus)


func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("selected", gene)


func set_selected(value: bool):
	is_selected = value

	modulate = Color(1, 1, 0.5) if value else Color(1, 1, 1)
