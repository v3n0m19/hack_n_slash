extends Node

var gameStarted:bool

var playerBody:CharacterBody2D
var playerWeaponEquip:bool
var playerAlive:bool
var playerDamageZone:Area2D
var playerDamageDealt:int
var playerHitbox :Area2D
var playerHealth: int


var batDamageZone:Area2D
var batDamageDealt:int

var frogDamageZone:Area2D
var frogDamageDealt:int

var current_wave: int
var moving_to_next_wave: bool

var high_score:int = 0
var current_score: int
var previous_score:int
