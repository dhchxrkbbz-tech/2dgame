## LoadingScreenTips - Loading screen script
## Automatikusan beállítja a Hint labelt véletlenszerű tippre
extends CanvasLayer


func _ready() -> void:
	# Hint label szövegének frissítése véletlenszerű tippre
	var hint_label: Label = get_node_or_null("VBoxContainer/Hint")
	if hint_label:
		hint_label.text = LoadingTips.get_random_tip()


## Frissíti a tippet (meghívható pl. hosszabb töltésnél)
func refresh_tip() -> void:
	var hint_label: Label = get_node_or_null("VBoxContainer/Hint")
	if hint_label:
		hint_label.text = LoadingTips.get_random_tip()


## Progress bar frissítése (0.0 - 1.0)
func set_progress(value: float) -> void:
	var progress_bar: ProgressBar = get_node_or_null("VBoxContainer/ProgressBar")
	if progress_bar:
		progress_bar.value = value * 100.0
