extends Node


# ==================================================
# Signals
# ==================================================

signal message_added(text)


# ==================================================
# Member Variables
# ==================================================

var messages:Array[String] = []


# ==================================================
# Public Functions
# ==================================================


func add_message(text:String):

	messages.append(text)

	print(
		"BATTLE LOG MESSAGE COUNT:",
		messages.size()
	)

	message_added.emit(text)


func clear():

	messages.clear()
