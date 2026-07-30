extends Node


# ==================================================
# Run Events
# ==================================================

signal run_started
signal run_ended


# ==================================================
# Battle Events
# ==================================================

signal battle_started(enemy)
signal battle_finished(result)

signal battle_won(enemy)
signal battle_lost

signal turn_changed(state)

signal move_selected(move_index)

signal moves_updated(player)

signal move_used(attacker, move)

signal damage_dealt(target, amount)

signal enemy_updated(enemy)

signal status_changed(player, enemy)

signal battle_initialized(player, enemies)

signal battle_names_updated(player, enemy)

# ==================================================
# Room Events
# ==================================================


signal room_entered(room)
signal room_completed(room)


# ==================================================
# Economy Events
# ==================================================

signal gold_changed(amount)


# ==================================================
# Gene Events
# ==================================================

signal gene_unlocked(gene)


# ==================================================
# Player Events
# ==================================================

signal hp_changed(current_hp, max_hp)
signal player_healed(amount)
signal player_damaged(amount)
