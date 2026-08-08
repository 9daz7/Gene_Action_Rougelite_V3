extends Node


# ================================================== 
# RUN EVENTS 
# ==================================================


signal run_started 
signal run_ended


# ================================================== 
# BATTLE EVENTS 
# ==================================================


signal battle_started(enemies) 
signal battle_finished(result)

signal battle_won(enemy) 
signal battle_lost

signal turn_changed(state) 

signal move_selected(move_index) 
signal target_selected(enemy) 
signal request_target_selection(enemies) 
signal enemy_selected(enemy) 

signal moves_updated(player) 

signal move_used(attacker, move) 

signal damage_dealt(target, amount) 

signal enemy_updated(enemy) 

signal status_changed(animal, enemies)

signal battle_initialized(player, enemies)

signal battle_names_updated(player, enemies)


# ================================================== 
# ROOM EVENTS 
# ==================================================


signal room_entered(room) 
signal room_completed(room)


# ================================================== 
# ECONOMY EVENTS 
# ==================================================


signal gold_changed(amount)


# ================================================== 
# GENE EVENTS 
# ==================================================


signal gene_unlocked(gene)


# ================================================== 
# PLAYER EVENTS 
# ==================================================


signal hp_changed(current_hp, max_hp)
signal player_healed(amount) 
signal player_damaged(amount)


## ==================================================
## Run Events
## ==================================================
#
#signal run_started
#signal run_ended
#
#
## ==================================================
## Battle Events
## ==================================================
#
#signal battle_started(enemy)
#signal battle_finished(result)
#
#signal battle_won(enemy)
#signal battle_lost
#
#signal turn_changed(state)
#
#signal move_selected(move_index)
#
#signal target_selected(enemy)
#
#signal request_target_selection(enemies)
#
#signal enemy_selected(enemy)
#
#signal moves_updated(player)
#
#signal move_used(attacker, move)
#
#signal damage_dealt(target, amount)
#
#signal enemy_updated(enemy)
#
#signal status_changed(animal:AnimalBase, enemies:Array)
#
#signal battle_initialized(player, enemies)
#
#signal battle_names_updated(player, enemies)
#
## ==================================================
## Room Events
## ==================================================
#
#
#signal room_entered(room)
#signal room_completed(room)
#
#
## ==================================================
## Economy Events
## ==================================================
#
#signal gold_changed(amount)
#
#
## ==================================================
## Gene Events
## ==================================================
#
#signal gene_unlocked(gene)
#
#
## ==================================================
## Player Events
## ==================================================
#
#signal hp_changed(animal, current_hp, max_hp)
#signal player_healed(amount)
#signal player_damaged(amount)
