extends CanvasLayer


@onready var color_rect = $ColorRect
var tween

func _ready():
	color_rect.color.a = 0.0  # Empezar completamente transparente

func start_fade_in():
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 1.5) # 1.5 segundos para el fade
	#var timer : Timer = Timer.new( )
	#add_child(timer)
	#timer.one_shot = true
	#timer.autostart = false
	#timer.wait_time = 1.5;
	#--timer. timeout.connect(func(): Level._load_new_level(false,false))
	#timer.start() # Cuando termine, cambia de escena

func start_fade_out():
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 1.5)  # 1.5 segundos para el fade
	var timer : Timer = Timer.new( )
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 1.5;
	timer. timeout.connect(func(): Level._load_new_level(false,false); start_fade_in())
	timer.start()

func change_scene():
	pass
	#get_tree().change_scene_to_file(next_scene_path)
