return { version = "1.1", luaversion = "5.1", orientation = "isometric", width = 15, height = 10, tilewidth = 64, tileheight = 32, properties = {}, tilesets = { { name = "set_rules", firstgid = 1, tilewidth = 64, tileheight = 32, spacing = 0, margin = 0, image = "set_rules.png", imagewidth = 128, imageheight = 128, properties = {}, tiles = {} }, { name = "tiled_cave", firstgid = 9, tilewidth = 64, tileheight = 128, spacing = 0, margin = 0, image = "tiled_cave.png", imagewidth = 1024, imageheight = 1920, properties = {}, tiles = {} }, { name = "human", firstgid = 249, tilewidth = 96, tileheight = 96, spacing = 0, margin = 0, image = "human.png", imagewidth = 864, imageheight = 768, properties = {}, tiles = {} } }, layers = { { type = "tilelayer", name = "MapBackground", x = 0, y = 0, width = 15, height = 10, visible = true, opacity = 1, properties = {}, encoding = "lua", data = { 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 16, 16, 16, 16, 16, 16, 34, 25, 25, 25, 25, 25, 25, 25, 25, 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 28, 9, 9, 9, 9, 9, 9, 9, 9, 186, 186, 186, 186, 186, 186, 28, 186, 190, 190, 190, 190, 190, 190, 195, 210, 210, 210, 210, 210, 210, 28, 210, 210, 210, 210, 210, 210, 210, 187, 210, 210, 210, 210, 210, 210, 28, 210, 210, 210, 210, 210, 210, 210, 187 } }, { type = "tilelayer", name = "MapCollision", x = 0, y = 0, width = 15, height = 10, visible = true, opacity = 1, properties = {}, encoding = "lua", data = { 7, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 7, 7, 7, 7, 7, 7, 0, 7, 7, 7, 7, 7, 7, 7, 6, 0, 0, 0, 0, 0, 6, 0, 6, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 6, 0, 6, 0, 0, 0, 0, 0, 0, 7 } }, { type = "objectgroup", name = "Event", visible = true, opacity = 1, properties = {}, objects = { { name = "Entrada 1", type = "teleport", x = 0, y = 96, width = 32, height = 32, properties = { ["hotSpot"] = "1", ["size"] = "1,1", ["toMap"] = "mapa", ["toMapHotSpot"] = "2" } }, { name = "Mapa 3", type = "teleport", x = 192, y = 0, width = 32, height = 32, properties = { ["hotSpot"] = "2", ["size"] = "1,1", ["toMap"] = "mapa3", ["toMapHotSpot"] = "1" } } } }, { type = "tilelayer", name = "MapObject", x = 0, y = 0, width = 15, height = 10, visible = true, opacity = 1, properties = {}, encoding = "lua", data = { 69, 62, 94, 62, 62, 142, 0, 142, 62, 62, 106, 62, 62, 62, 62, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 156, 0, 141, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 144, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 144, 0, 0, 0, 141, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 61, 0, 0, 146, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }, { type = "objectgroup", name = "Object", visible = true, opacity = 1, properties = {}, objects = { { name = "Player", type = "Actor", x = 128, y = 160, width = 0, height = 0, gid = 276, properties = {} } } } } }