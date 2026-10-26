class_name AnimatedModel extends Node3D

@export var anim_tree : AnimationTree = null
@export var skeleton : Skeleton3D = null

@export var blood_particles : GPUParticles3D = null
@export var weapon_trails_particles : GPUParticles3D = null
@export var foot_trails_particles : GPUParticles3D = null

@export var walk_dust_particles : GPUParticles3D = null
@export var physical_bone_simulator : PhysicalBoneSimulator3D = null
