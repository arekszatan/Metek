class_name DataBase 
extends Node

var db : SQLite

func _init():
	db = SQLite.new()
	db.path = "res://database.db"
	db.open_db()
	
func insert_data(table_name:String, data):
	return db.insert_row(table_name, data)

func select_data(table_name:String, condition:String, column:Array):
	db.select_rows(table_name, condition, column)
	return db.query_result

func update_data(table_name:String, condition:String, data):
	return db.update_rows(table_name, condition, data)

func delete_data(table_name:String, condition:String):
	return db.delete_rows(table_name, condition)

func custom_select(query:String):
	db.query(query)
	return db.query_result
