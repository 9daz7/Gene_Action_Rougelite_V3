extends AnimalBase
class_name PlayerAnimal

var current_moves:Array[String] = [
	"Attack",
	"Protect"
]

func start_battle():

	print("Player ready")
	
func choose_move(move:String):
	match move:
		
		"Attack":
			print("Player attacks")
			
		"Protect":
			print("Player protects")
			
