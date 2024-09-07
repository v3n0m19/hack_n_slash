extends ProgressBar

var parent 
var max_value_amount
var min_value_amount


func _ready() -> void:
	parent = get_parent()
	max_value_amount = parent.health_max
	min_value_amount = parent.health_min
	
func _process(delta: float) -> void:
	self.value = parent.health
		
