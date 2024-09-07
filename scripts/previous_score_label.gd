extends RichTextLabel

var default_text = "Previous Score: "
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.previous_score))
	self.text = text
