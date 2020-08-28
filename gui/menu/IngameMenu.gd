extends Node

#

const blur_material_y = preload("res://materials/blur_gles2_y_material.tres")
const blur_material_x = preload("res://materials/blur_gles2_x_material.tres")
const empty_material = preload("res://materials/empty_material.tres")

var _is_menu_visible = false
var _viewport1
var _viewport2
var _buttons_group

func _init(viewport1, viewport2, button_group):
	_viewport1 = viewport1
	_viewport2 = viewport2
	_buttons_group = button_group

func show_menu():
	if _is_menu_visible:
		printerr("Menu is already displayed!")
	else:
		_is_menu_visible = true
		_show_blur()
		_show_buttons()

func hide_menu():
	if _is_menu_visible:
		_is_menu_visible = false
		_hide_blur()
		_hide_buttons()
	else:
		printerr("Menu is already hidden!")

func _show_buttons():
	_buttons_group.visible = true

func _hide_buttons():
	_buttons_group.visible = false

func _show_blur():
	_viewport1.set_material(blur_material_x)
	_viewport2.set_material(blur_material_y)

func _hide_blur():
	_viewport1.set_material(empty_material)
	_viewport2.set_material(empty_material)
