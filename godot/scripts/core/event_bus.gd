## EventBus - Globális signal rendszer (Autoload singleton)
## Decoupled kommunikáció a rendszerek között
extends Node

# === Player events ===
signal player_spawned(player)
signal player_died(player)
signal player_leveled_up(player, new_level: int)
signal player_skill_unlocked(player, skill_id: String)
signal player_class_selected(player_class: Enums.PlayerClass)
signal player_stats_changed(player)

# === Combat events ===
signal damage_dealt(source, target, amount: float, damage_type: Enums.DamageType)
signal entity_killed(killer, victim)
signal status_effect_applied(target, effect_type: Enums.EffectType, duration: float)
signal status_effect_removed(target, effect_type: Enums.EffectType)
signal critical_hit(source, target, amount: float)

# === Skill events ===
signal skill_used(player, skill_id: String)
signal skill_cooldown_started(skill_id: String, duration: float)
signal skill_cooldown_finished(skill_id: String)
signal skill_tree_opened()
signal skill_tree_closed()
signal skill_point_allocated(skill_id: String, new_rank: int)

# === Loot events ===
signal item_dropped(item_data, position: Vector2)
signal item_picked_up(item_instance)
signal loot_rolled(player, items: Array)
signal item_equipped(player, item_data, slot: Enums.EquipSlot)
signal item_unequipped(player, slot: Enums.EquipSlot)
signal gold_collected(amount: int)

# === Economy events ===
signal gold_changed(player, new_amount: int)
signal item_sold(player, item_data: Dictionary, price: int)
signal item_bought(player, item_data: Dictionary, price: int)
signal currency_changed(currency_type: Enums.CurrencyType, new_amount: int)
signal dark_essence_changed(new_amount: int)
signal relic_fragments_changed(new_amount: int)

# === Inventory events ===
signal inventory_changed()
signal inventory_full()
signal stash_changed()
signal equipment_changed(slot: Enums.EquipSlot)

# === Crafting events ===
signal crafting_started(recipe_id: String)
signal crafting_completed(recipe_id: String, success: bool)
signal crafting_failed(recipe_id: String)
signal recipe_unlocked(recipe_id: String)

# === Shop events ===
signal shop_opened(shop_type: Enums.ShopType, shop_data: Dictionary)
signal shop_closed()

# === Marketplace events ===
signal marketplace_listing_created(listing_id: String)
signal marketplace_listing_sold(listing_id: String)
signal marketplace_listing_cancelled(listing_id: String)
signal marketplace_listing_expired(listing_id: String)

# === Trading events ===
signal trade_requested(from_player, to_player)
signal trade_accepted(player_a, player_b)
signal trade_completed(player_a, player_b)
signal trade_cancelled()

# === Upgrade events ===
signal enhancement_attempted(item_uuid: String, level: int, success: bool)
signal enchant_applied(item_uuid: String, enchant_type: String)
signal gem_socketed(item_uuid: String, gem_type: Enums.GemType)
signal gem_removed(item_uuid: String, socket_index: int)
signal gem_combined(result_gem_type: Enums.GemType, result_tier: Enums.GemTier)
signal gem_dropped(gem_type: Enums.GemType, gem_tier: Enums.GemTier, position: Vector2)
signal gem_picked_up(gem_instance: RefCounted)
signal socket_added_to_item(item_uuid: String, new_socket_count: int)
signal legendary_gem_effect_triggered(gem_id: String, effect_name: String)

# === Gathering events ===
signal gathering_started(node_type: Enums.GatheringNodeType)
signal gathering_completed(node_type: Enums.GatheringNodeType, yield_amount: int)
signal gathering_interrupted()

# === Profession events ===
signal profession_xp_gained(profession: Enums.ProfessionType, amount: int)
signal profession_leveled_up(profession: Enums.ProfessionType, new_level: int)

# === World events ===
signal chunk_loaded(chunk_pos: Vector2i)
signal chunk_unloaded(chunk_pos: Vector2i)
signal biome_entered(player, biome: Enums.BiomeType)
signal day_night_changed(is_night: bool)
signal weather_changed(weather: Enums.WeatherType)

# === Dungeon events ===
signal dungeon_entered(dungeon_data: Dictionary)
signal dungeon_exited()
signal room_cleared(room_index: int)
signal dungeon_floor_changed(floor_index: int)
signal dungeon_room_entered(room_index: int, room_type: int)
signal dungeon_room_sealed(room_index: int)
signal dungeon_room_unsealed(room_index: int)
signal dungeon_trap_triggered(trap_type: String, position: Vector2)
signal dungeon_puzzle_solved(puzzle_type: String, room_index: int)
signal dungeon_puzzle_failed(puzzle_type: String, room_index: int)
signal dungeon_door_state_changed(door_id: int, new_state: int)
signal dungeon_boss_room_reached(room_index: int)
signal dungeon_secret_room_found(room_index: int)
signal dungeon_fog_updated(player_tile_pos: Vector2i)
signal dungeon_chest_opened(chest_data: Dictionary)
signal dungeon_wave_started(room_index: int, wave_number: int)
signal dungeon_wave_completed(room_index: int, wave_number: int)

# === Boss events ===
signal boss_fight_started(boss_id: String)
signal boss_phase_changed(boss_id: String, phase: int)
signal boss_defeated(boss_id: String)
signal boss_enraged(boss_id: String)

# === Multiplayer events ===
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal lobby_updated(lobby_data: Dictionary)
signal multiplayer_game_starting(world_seed: int, spawn_positions: Array)
signal multiplayer_player_joined(peer_id: int, player_name: String)
signal multiplayer_player_left(peer_id: int)
signal multiplayer_session_ended()
signal chat_message_received(sender_name: String, message: String)

# === UI events ===
signal show_notification(text: String, type: Enums.NotificationType)
signal tooltip_requested(data: Dictionary)
signal tooltip_hidden()
signal screen_opened(screen_name: String)
signal screen_closed(screen_name: String)
signal hud_update_requested()

# === XP events ===
signal xp_gained(player, amount: int)
signal xp_bar_updated(current_xp: int, max_xp: int)
