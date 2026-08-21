@tool
extends EditorScript

const OUTPUT_PATH := "user://test.png"

func _run() -> void:
	var texture := load("res://icon.svg") as Texture2D
	if texture == null:
		push_error("[PREVIEW] Failed to load texture at res://icon.svg")
		return

	var size := Vector2i(512, 288)

	# 1. Create a Viewport RID and Canvas RID directly in the RenderingServer
	var rs := RenderingServer
	var viewport_rid := rs.viewport_create()
	var canvas_rid := rs.canvas_create()

	# Configure Viewport
	rs.viewport_set_size(viewport_rid, size.x, size.y)
	rs.viewport_set_active(viewport_rid, true)
	rs.viewport_set_transparent_background(viewport_rid, false)
	rs.viewport_attach_canvas(viewport_rid, canvas_rid)
	rs.viewport_set_update_mode(viewport_rid, RenderingServer.VIEWPORT_UPDATE_ALWAYS)

	# 2. Create a Canvas Item and draw the texture immediately
	var item_rid := rs.canvas_item_create()
	rs.canvas_item_set_parent(item_rid, canvas_rid)

	# Position the texture centered in the viewport
	var tex_size := texture.get_size()
	var draw_pos := (Vector2(size) - tex_size) / 2.0
	var rect := Rect2(draw_pos, tex_size)
	
	# Dispatch immediate 2D draw command
	rs.canvas_item_add_texture_rect(item_rid, rect, texture.get_rid())

	# 3. Synchronously render the scene
	rs.force_draw()

	# 4. Fetch the rendered texture image from the viewport RID
	var texture_rid := rs.viewport_get_texture(viewport_rid)
	var image := rs.texture_2d_get(texture_rid)

	if image != null and not image.is_empty():
		print("[PREVIEW] Captured Image size: ", image.get_size())
		print("[PREVIEW] Center pixel: ", image.get_pixel(size.x / 2, size.y / 2))

		var err := image.save_png(OUTPUT_PATH)
		print("[PREVIEW] Save error code (0 is OK): ", err)
		print("[PREVIEW] Saved to: ", ProjectSettings.globalize_path(OUTPUT_PATH))
	else:
		push_error("[PREVIEW] Failed to retrieve rendered image from Viewport.")

	# 5. Clean up allocated RIDs from the RenderingServer
	rs.free_rid(item_rid)
	rs.free_rid(canvas_rid)
	rs.free_rid(viewport_rid)
