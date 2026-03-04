## InventorySync - Inventory állapot szinkronizáció multiplayer-ben
## Item mozgatás, felszerelés, drop validáció server-oldali ellenőrzéssel
extends Node

# Utolsó szinkronizált inventory hash (változás detekció)
var _last_sync_hash: int = 0

# Pending műveletek (kliens → szerver validálásig)
var _pending_operations: Array[Dictionary] = []


func reset() -> void:
	_last_sync_hash = 0
	_pending_operations.clear()


# ══════════════════════════════════════════════
# KLIENS → SZERVER KÉRÉSEK
# ══════════════════════════════════════════════

## Item mozgatás kérés (slot → slot)
func request_move_item(from_slot: int, to_slot: int) -> void:
	if NetworkManager.is_server():
		_server_process_move(multiplayer.get_unique_id(), from_slot, to_slot)
	else:
		_rpc_request_move.rpc_id(1, from_slot, to_slot)


## Item felszerelés kérés
func request_equip_item(inventory_slot: int, equipment_slot: String) -> void:
	if NetworkManager.is_server():
		_server_process_equip(multiplayer.get_unique_id(), inventory_slot, equipment_slot)
	else:
		_rpc_request_equip.rpc_id(1, inventory_slot, equipment_slot)


## Item eldobás kérés
func request_drop_item(slot: int) -> void:
	if NetworkManager.is_server():
		_server_process_drop(multiplayer.get_unique_id(), slot)
	else:
		_rpc_request_drop.rpc_id(1, slot)


## Item használat kérés (consumable)
func request_use_item(slot: int) -> void:
	if NetworkManager.is_server():
		_server_process_use(multiplayer.get_unique_id(), slot)
	else:
		_rpc_request_use.rpc_id(1, slot)


# ══════════════════════════════════════════════
# SZERVER FELDOLGOZÁS
# ══════════════════════════════════════════════

@rpc("any_peer", "reliable")
func _rpc_request_move(from_slot: int, to_slot: int) -> void:
	if not NetworkManager.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_server_process_move(peer_id, from_slot, to_slot)


@rpc("any_peer", "reliable")
func _rpc_request_equip(inventory_slot: int, equipment_slot: String) -> void:
	if not NetworkManager.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_server_process_equip(peer_id, inventory_slot, equipment_slot)


@rpc("any_peer", "reliable")
func _rpc_request_drop(slot: int) -> void:
	if not NetworkManager.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_server_process_drop(peer_id, slot)


@rpc("any_peer", "reliable")
func _rpc_request_use(slot: int) -> void:
	if not NetworkManager.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	_server_process_use(peer_id, slot)


func _server_process_move(peer_id: int, from_slot: int, to_slot: int) -> void:
	var inv_mgr := _get_inventory_for_peer(peer_id)
	if not inv_mgr:
		return
	
	# Validáció
	if from_slot < 0 or from_slot >= inv_mgr.inventory.size():
		_rpc_operation_rejected.rpc_id(peer_id, "move", "Invalid source slot")
		return
	if to_slot < 0 or to_slot >= inv_mgr.inventory.size():
		_rpc_operation_rejected.rpc_id(peer_id, "move", "Invalid target slot")
		return
	
	# Mozgatás végrehajtása
	inv_mgr.move_item(from_slot, to_slot)
	
	# Megerősítés küldése
	_rpc_operation_confirmed.rpc_id(peer_id, "move", {"from": from_slot, "to": to_slot})


func _server_process_equip(peer_id: int, inventory_slot: int, equipment_slot: String) -> void:
	var inv_mgr := _get_inventory_for_peer(peer_id)
	if not inv_mgr:
		return
	
	if inventory_slot < 0 or inventory_slot >= inv_mgr.inventory.size():
		_rpc_operation_rejected.rpc_id(peer_id, "equip", "Invalid slot")
		return
	
	var item = inv_mgr.inventory[inventory_slot]
	if not item:
		_rpc_operation_rejected.rpc_id(peer_id, "equip", "No item in slot")
		return
	
	inv_mgr.equip_item(inventory_slot, equipment_slot)
	_rpc_operation_confirmed.rpc_id(peer_id, "equip", {"slot": inventory_slot, "equip_slot": equipment_slot})


func _server_process_drop(peer_id: int, slot: int) -> void:
	var inv_mgr := _get_inventory_for_peer(peer_id)
	if not inv_mgr:
		return
	
	if slot < 0 or slot >= inv_mgr.inventory.size():
		_rpc_operation_rejected.rpc_id(peer_id, "drop", "Invalid slot")
		return
	
	var item = inv_mgr.inventory[slot]
	if not item:
		_rpc_operation_rejected.rpc_id(peer_id, "drop", "No item")
		return
	
	# Item eltávolítása és DroppedItem spawning szerver-oldalon
	inv_mgr.remove_item_at(slot)
	_rpc_operation_confirmed.rpc_id(peer_id, "drop", {"slot": slot})


func _server_process_use(peer_id: int, slot: int) -> void:
	var inv_mgr := _get_inventory_for_peer(peer_id)
	if not inv_mgr:
		return
	
	if slot < 0 or slot >= inv_mgr.inventory.size():
		_rpc_operation_rejected.rpc_id(peer_id, "use", "Invalid slot")
		return
	
	var item = inv_mgr.inventory[slot]
	if not item or not item.base_item:
		_rpc_operation_rejected.rpc_id(peer_id, "use", "No item")
		return
	
	if item.base_item.item_type != Enums.ItemType.CONSUMABLE:
		_rpc_operation_rejected.rpc_id(peer_id, "use", "Not consumable")
		return
	
	# Player keresése és use_consumable hívás
	var player := _get_player_for_peer(peer_id)
	if player and player.has_method("use_consumable"):
		player.use_consumable(item)
	
	_rpc_operation_confirmed.rpc_id(peer_id, "use", {"slot": slot})


# ══════════════════════════════════════════════
# SZERVER → KLIENS VÁLASZOK
# ══════════════════════════════════════════════

@rpc("authority", "reliable")
func _rpc_operation_confirmed(operation: String, data: Dictionary) -> void:
	_pending_operations = _pending_operations.filter(func(op): return op.get("type") != operation)


@rpc("authority", "reliable")
func _rpc_operation_rejected(operation: String, reason: String) -> void:
	_pending_operations = _pending_operations.filter(func(op): return op.get("type") != operation)
	EventBus.show_notification.emit("Operation rejected: %s" % reason, Enums.NotificationType.WARNING if "WARNING" in Enums.NotificationType else Enums.NotificationType.LEVEL_UP)
	# Rollback: inventory újratöltés a szervertől
	request_full_sync()


## Teljes inventory szinkronizáció kérés
func request_full_sync() -> void:
	if not NetworkManager.is_server():
		_rpc_request_full_sync.rpc_id(1)


@rpc("any_peer", "reliable")
func _rpc_request_full_sync() -> void:
	if not NetworkManager.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	var inv_mgr := _get_inventory_for_peer(peer_id)
	if not inv_mgr:
		return
	var data := inv_mgr.serialize()
	_rpc_receive_full_sync.rpc_id(peer_id, data)


@rpc("authority", "reliable")
func _rpc_receive_full_sync(data: Dictionary) -> void:
	var economy = get_node_or_null("/root/EconomyManager")
	if economy and economy.inventory_manager:
		economy.inventory_manager.deserialize(data)
	EventBus.hud_update_requested.emit()


# ══════════════════════════════════════════════
# SEGÉD FÜGGVÉNYEK
# ══════════════════════════════════════════════

func _get_inventory_for_peer(peer_id: int) -> InventoryManager:
	# Solo/host esetén a lokális EconomyManager-t használjuk
	var economy = get_node_or_null("/root/EconomyManager")
	if economy and economy.inventory_manager:
		return economy.inventory_manager
	return null


func _get_player_for_peer(peer_id: int) -> Node:
	# Player keresése peer_id alapján
	var players := get_tree().get_nodes_in_group("player")
	for player in players:
		if "peer_id" in player and player.peer_id == peer_id:
			return player
	# Fallback: első player (solo mód)
	if players.size() > 0:
		return players[0]
	return null


## Változás detekció: inventory hash számítás
func server_broadcast_inventory_state() -> void:
	if not NetworkManager.is_server():
		return
	# Periodikus broadcast a hostról a klienseknek
	# Csak változás esetén küldünk
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy or not economy.inventory_manager:
		return
	var data := economy.inventory_manager.serialize()
	var new_hash := data.hash()
	if new_hash != _last_sync_hash:
		_last_sync_hash = new_hash
		# Broadcast minden kliensnek
		for peer_id in multiplayer.get_peers():
			_rpc_receive_full_sync.rpc_id(peer_id, data)
