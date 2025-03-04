extends Node
#
signal added(status)
signal removed(status)

var statuses_active = {}

func add(id, status):
	statuses_active[id] = status

func remove(id):
	statuses_active.erase(id)
