extends Node


# ==================================================
# Run Events
# ==================================================

signal run_started
signal run_ended


# ==================================================
# Battle Events
# ==================================================

signal battle_started
signal battle_finished(enemy)
signal battle_won(enemy)
signal battle_lost


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

signal hp_changed(animal)
signal player_healed(amount)
signal player_damaged(amount)
