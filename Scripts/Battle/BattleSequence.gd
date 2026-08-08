extends Node
class_name BattleSequence


# ==================================================
# Variables
# ==================================================

var queue:Array = []
var running := false


# ==================================================
# Queue Management
# ==================================================


func add_message(text:String):
	queue.append(
		{
			"type":"message",
			"text":text
		}
	)


func add_action(action: Callable):
	queue.append(
	{
		"type": "action",
		"callable": action
	}
	)


# ==================================================
# Sequence Playback
# ==================================================


func play():

	if running:
		print("WARNING: Battle sequence already running")
		return

	if queue.is_empty():
		print("WARNING: Battle sequence has no actions")
		return

	running = true

	print(
		"========== BATTLE SEQUENCE START =========="
	)

	await run_queue()

	running = false

	print(
		"========== BATTLE SEQUENCE COMPLETE =========="
	)


func run_queue():

	while queue.size() > 0:

		var step = queue.pop_front()

		match step["type"]:

			# ------------------------------------------
			# Battle Log Messages
			# ------------------------------------------

			"message":

				print(
					"SEQUENCE MESSAGE:",
					step["text"]
				)

				BattleLog.add_message(
					step["text"]
				)

				await get_tree().create_timer(
					1.0
				).timeout


			# ------------------------------------------
			# Combat Actions
			# ------------------------------------------

			"action":

				var action: Callable = step["callable"]

				print(
					"SEQUENCE ACTION:",
					action
				)

				if action.is_valid():

					await action.call()

				else:

					print(
						"WARNING: Invalid battle sequence action"
					)

				await get_tree().create_timer(0.3).timeout
