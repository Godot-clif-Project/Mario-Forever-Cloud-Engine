extends Node

var gravity: float = 20 # Global gravity

var HUD: CanvasLayer    # ref HUD
var Mario: Node2D       # ref Mario

signal TimeTick         # Called when time got lower
signal OnPlayerLoseLife # Called when Player Die
signal OnScoreChange    # Called when score get changed
signal OnLivesAdded     # Called when Live added
signal OnCoinCollected  # Called when coins collected

var lives: int = 4      # Player lives
var time: int = 999     # Time left
var score: int = 0      # Score
var coins: int = 0      # Player coins
var state: int = 0      # Player powerup state

var projectiles_count: int = 0 # Self explanable

var debug: bool = true        # Debug

var player_dead: bool = false # Player Dead?

onready var timer : Timer = Timer.new()      # Create a new timer for delay

static func get_delta(delta) -> float: # Delta by 50 FPS
  return 50 / (1 / (delta if not delta == 0 else 0.0001))

func _ready() -> void:
  if debug:
    add_child(preload('res://Objects/Core/Inspector.tscn').instance()) # Adding a debug inspector
  timer.wait_time = 1.45 # Setting delay
  add_child(timer)       # Adding a Timer

func _reset() -> void:  # Level Restert
  lives -= 1          # Player Lose life cuz he die
  player_dead = false # Player not dead anymore
  get_tree().reload_current_scene()# Rester a scene

func _physics_process(delta: float) -> void:
  if timer.time_left <= 1 && time != -1: # Wait for delaying
    _delay()         # call delay function
    timer.start()    # start timer again
  if projectiles_count < 0:
    projectiles_count = 0

func add_score(score: int) -> void:
  self.score += abs(score)
  HUD.get_node('Score').text = str(self.score)
  emit_signal('OnScoreChange')

func add_lives(lives: int) -> void:
  var scorePos = Mario.position
  scorePos.y -= 32
  var ScoreT = ScoreText.new(1, scorePos)
  Mario.get_parent().add_child(ScoreT)
  self.lives += abs(lives)
  HUD.get_node('LifeSound').play()
  HUD.get_node('Lives').text = str(self.lives)
  emit_signal('OnLivesAdded')

func add_coins(coins: int) -> void:
  self.coins += abs(coins)
  if self.coins >= 100:
    add_lives(1)
    self.coins = 0
  HUD.get_node('Coins').text = str(self.coins)
  emit_signal('OnCoinCollected')

func play_base_sound(sound: String) -> void:
  Mario.get_node('BaseSounds').get_node(sound).play()

func _ppd() -> void: # Player Powerdown
  if Mario.shield_counter > 0:
    return

  if state == 0:
    _pll()
  else:
    play_base_sound('MAIN_Pipe')
    if state > 1:
      state = 1
    else:
      state = 0
    Mario.appear_counter = 60
    Mario.shield_counter = 100

func _pll() -> void: # Player Lose Life
  if player_dead:
    return
  player_dead = true
  emit_signal('OnPlayerLoseLife')
  MusicEngine.play_music('1-music-die.it')
  Mario.dead = true

func _delay() -> void:
  if Mario == null:
    return
  if !Mario.dead:
    emit_signal('TimeTick')
    time -= 1
    if time == -1:
      _pll()
