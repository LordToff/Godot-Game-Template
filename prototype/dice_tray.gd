extends Control
# Rolls now resolve immediately. Kept as a lightweight compatibility endpoint
# for existing scene/test callers; no meshes, viewport, delay or roll overlay.
signal finished
var busy := false
func _ready() -> void:
 mouse_filter = Control.MOUSE_FILTER_IGNORE
 hide()
func play(_batches: Array) -> void:
 finish()
func finish() -> void:
 busy = false
 hide()
 finished.emit()
