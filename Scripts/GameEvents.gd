extends Node


# ================================================== 
# RUN EVENTS 
# ==================================================


signal run_started 
signal run_ended


# ================================================== 
# BATTLE EVENTS 
# ==================================================


signal battle_started(player, enemies)
signal battle_initialized(player, enemies)
signal battle_finished(result)

signal battle_won(enemy)
signal battle_lost

signal turn_changed(state)

signal move_selected(move_index)
signal move_used(attacker, move)

signal target_selected(enemy)
signal enemy_selected(enemy)

signal request_target_selection(enemies) 

signal moves_updated(player) 

signal damage_dealt(target, amount) 

signal enemy_updated(enemy) 

signal status_changed(animal, enemies)

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
signal permanent_currency_changed(amount)

# ==================================================
# GENE EVENTS
# ==================================================

signal gene_unlocked(gene)
signal gene_collection_changed
signal gene_storage_changed(used, capacity)


# ==================================================
# PERMANENT PROGRESSION EVENTS
# ==================================================


signal permanent_gene_added(gene, amount)
signal permanent_gene_removed(gene, amount)


# ================================================== 
# PLAYER EVENTS 
# ==================================================



signal hp_changed(current_hp, max_hp)
signal player_healed(amount) 
signal player_damaged(amount)
