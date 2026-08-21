class_name PreviewFrameCapture
extends Node

var viewport: SubViewport
var output_path: String
var completion: Callable

func capture_after_frame(
	target_viewport: SubViewport,
	target_output_path: String,
	on_complete: Callable
) -> void:

	viewport = target_viewport
	output_path = target_output_path
	completion = on_complete
	
	RenderingServer.request_frame_drawn_callback(
		Callable(self, "_on_frame_drawn")
	)
	RenderingServer.force_draw()

func _on_frame_drawn() -> void:
	Glogger.debug("[PREVIEW-4] Frame callback received")
	var image := viewport.get_texture().get_image()
	var result := image.save_png(output_path)

	Glogger.debug("[PREVIEW-5] Image saved with result: ")
	Glogger.debug(result)
	if completion.is_valid():
		completion.call(result)
	queue_free()
