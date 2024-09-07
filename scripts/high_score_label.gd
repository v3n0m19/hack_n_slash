extends RichTextLabel

var default_text = "High Score:  "
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.high_score))
	self.text = text
