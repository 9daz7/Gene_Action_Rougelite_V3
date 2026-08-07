extends Node


signal message_added(text)


var messages:Array[String] = []

var max_messages := 5


func add_message(text:String):

	if text.strip_edges() == "":
		return

	print("BATTLE LOG:", text)

	messages.append(text)

	if messages.size() > max_messages:
		messages.pop_front()

	message_added.emit(text)


func clear():

	messages.clear()
