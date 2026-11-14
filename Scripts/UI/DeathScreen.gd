extends Control

signal return_home_requested


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS

	hide()

	$Content/Panel/ReturnHomeButton.pressed.connect(
		_on_return_home_pressed
	)


func open() -> void:

	show()


func _on_return_home_pressed() -> void:

	return_home_requested.emit()


func set_report(report: Dictionary) -> void:

	var report_label: Label = $Content/Panel/VBoxContainer/reportplaceholder

	var genes: Array = report.get("genes", [])
	var mutagens: Array = report.get("mutagens", [])

	report_label.text = (
		"Genes Used: %s\n\n" % _format_names(genes)
		+ "Mutagens Collected: %s\n\n" % _format_names(mutagens)
		+ "Enemies Defeated: %s\n\n" % str(report.get("enemies_defeated", 0))
		+ "Rooms Cleared: %s\n\n" % str(report.get("rooms_cleared", 0))
		+ "World Reached: %s" % str(report.get("world_reached", 1))
	)


func _format_names(names: Array) -> String:

	if names.is_empty():
		return "None"

	var result := ""

	for i in range(names.size()):

		if i > 0:
			result += ", "

		result += str(names[i])

	return result
