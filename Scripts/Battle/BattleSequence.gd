extends Node
class_name BattleSequence


var queue:Array = []
var running := false


func add_message(text:String):
	queue.append({
		"type":"message",
		"text":text
	})


func add_action(callable:Callable):
	queue.append({
		"type":"action",
		"callable":callable
	})


func play():
	if running:
		return

	running = true
	await run_queue()


func run_queue():

	while queue.size() > 0:

		var step = queue.pop_front()

		match step.type:

			"message":

				BattleLog.add_message(
					step.text
				)

				await get_tree().create_timer(
					1.0
				).timeout


			"action":

				step.callable.call()

				await get_tree().create_timer(
					0.3
				).timeout


	running = false
