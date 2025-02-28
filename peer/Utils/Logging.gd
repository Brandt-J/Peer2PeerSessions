extends Control

@export var font_size: int = 10
@export var max_chars_per_line: int = 40
@export var ui_log: bool = false

var _loggers: Dictionary = {}  # key: Logger name, value: Logger object
var _labels: Array[Label] = []
var _max_entries: int = 15

@onready var _vbox: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}


class Logger:
	var logger_name: String = "default"
	var level = LogLevel.INFO
	signal message_logged(msg: String)
	
	func _init(new_logger_name: String, id: int):
		logger_name = "%s on %s" % [new_logger_name, id]
		
	func debug(message: String) -> void:
		if level in [LogLevel.DEBUG]:
			_log_message("DEBUG", message)
		
	func info(message: String) -> void:
		if level in [LogLevel.DEBUG, LogLevel.INFO]:
			_log_message("INFO", message)
	
	func warning(message: String) -> void:
		if level in [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARNING]:
			_log_message("WARNING", message)
		
	func error(message: String) -> void:
		if level in [LogLevel.DEBUG, LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR]:
			_log_message("ERROR", message)
			
	func _log_message(levelString: String, message: String) -> void:
		var dt=Time.get_datetime_dict_from_system()
		var timeString: String = "%s.%s.%s, %02d:%02d:%02d " % [dt.year, dt.month, dt.day, dt.hour,dt.minute,dt.second]
		var msg: String = "%s: %s, %s, %s" % [timeString, logger_name, levelString, message]
		print(msg)
		message_logged.emit(msg)
		

func _ready() -> void:
	if ui_log:
		show()
	else:
		hide()


func get_logger(logger_name: String = "default") -> Logger:
	if not logger_name in _loggers:
		var newLogger: Logger = Logger.new(logger_name, multiplayer.get_unique_id())
		newLogger.message_logged.connect(_on_message_logged)
		_loggers[logger_name] = newLogger
	return _loggers[logger_name]


func _on_message_logged(msg: String) -> void:
	if not ui_log:
		return
		
	if len(_labels) > _max_entries:
		_labels[0].queue_free()
	
	if msg.length() > max_chars_per_line:
		var multiline_msg: String = ""
		var num_lines: int = ceil(msg.length() / max_chars_per_line)
		for i in range(num_lines):
			multiline_msg += msg.substr(i*max_chars_per_line, max_chars_per_line)
			if i < num_lines - 2:
				multiline_msg += "\n"
		
		msg = multiline_msg
	
	var new_lbl: Label = Label.new()
	new_lbl.add_theme_font_size_override("font_size", font_size)
	new_lbl.text = msg
	_labels.append(new_lbl)
	
	_vbox.add_child(new_lbl)
	new_lbl.set_owner(_vbox)
	
