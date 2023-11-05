
extends Node

# Class member variables
var can_walk: bool
var can_see: bool
var can_hear: bool

# Constructor for the class
func _init(_can_walk: int, _can_see: float, _can_hear: int):
	can_walk = _can_walk
	can_see = _can_see
	can_hear = _can_hear
