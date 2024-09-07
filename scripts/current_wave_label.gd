extends RichTextLabel

var default_text = "Current Wave: "
func _process(delta: float) -> void:
	var text = str(default_text, str(Global.current_wave))
	self.text = text
