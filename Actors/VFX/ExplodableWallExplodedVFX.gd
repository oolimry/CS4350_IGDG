class_name ExplodableWallExplodedVFX
extends GPUParticles2D

func init(pos, params):
	self.global_position = pos
	
	
	var size = params[VfxManager.Params.SIZE]
	
	process_material = process_material.duplicate(true)
	process_material.emission_box_extents = Vector3(size.x * 0.5, size.y * 0.5, 0)
	Glogger.debug(process_material.emission_box_extents)
	self.amount = int(size.x * size.y / 400)
	
	self.one_shot = true
	self.emitting = true
