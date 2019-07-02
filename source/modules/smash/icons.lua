local textures = {
	[0x00] = {
		name = "captain",
		skin = {"original", "black", "red", "white", "green", "blue"},
		team_skin = {3, 6, 5},
		series = "fzero"
	},
	[0x01] = {
		name = "donkey",
		skin = {"original", "black", "red", "blue", "green"},
		team_skin = {3, 4, 5},
		series = "donkey_kong"
	},
	[0x02] = {
		name = "fox",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x03] = {
		name = "gamewatch",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "game_and_watch"
	},
	[0x04] = {
		name = "kirby",
		skin = {"original", "yellow", "blue", "red", "green", "white"},
		team_skin = {4, 3, 5},
		series = "kirby"
	},
	[0x05] = {
		name = "koopa",
		skin = {"green", "red", "blue", "black"},
		team_skin = {2, 3, 1},
		series = "mario"
	},
	[0x06] = {
		name = "link",
		skin = {"green", "red", "blue", "black", "white"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x07] = {
		name = "luigi",
		skin = {"green", "white", "blue", "red"},
		team_skin = {4, 3, 1},
		series = "mario"
	},
	[0x08] = {
		name = "mario",
		skin = {"red", "yellow", "black", "blue", "green"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x09] = {
		name = "marth",
		skin = {"original", "red", "green", "black", "white"},
		team_skin = {2, 1, 3},
		series = "fire_emblem"
	},
	[0x10] = {
		name = "samus",
		skin = {"red", "pink", "black", "green", "blue"},
		team_skin = {1, 5, 4},
		series = "metroid"
	},
	[0x11] = {
		name = "yoshi",
		skin = {"green", "red", "blue", "yellow", "pink", "light_blue"},
		team_skin = {2, 3, 1},
		series = "yoshi"
	},
	[0x12] = {
		name = "zelda",
		skin = {"original", "red", "blue", "green", "white"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x13] = {
		name = "sheik",
		skin = {"original", "red", "blue", "green", "white"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x14] = {
		name = "falco",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "star_fox"
	},
	[0x15] = {
		name = "younglink",
		skin = {"green", "red", "blue", "black", "white"},
		team_skin = {2, 3, 1},
		series = "zelda"
	},
	[0x16] = {
		name = "mariod",
		skin = {"white", "red", "blue", "green", "black"},
		team_skin = {2, 3, 4},
		series = "mario"
	},
	[0x17] = {
		name = "roy",
		skin = {"original", "red", "blue", "green", "yellow"},
		team_skin = {2, 3, 4},
		series = "fire_emblem"
	},
	[0x18] = {
		name = "pichu",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x19] = {
		name = "ganon",
		skin = {"original", "red", "blue", "green", "purple"},
		team_skin = {2, 3, 4},
		series = "zelda"
	},
	[0x0A] = {
		name = "mewtwo",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0B] = {
		name = "ness",
		skin = {"original", "yellow", "blue", "green"},
		team_skin = {1, 3, 4},
		series = "earthbound"
	},
	[0x0C] = {
		name = "peach",
		skin = {"original", "daisy", "white", "blue", "green"},
		team_skin = {1, 4, 5},
		series = "mario"
	},
	[0x0D] = {
		name = "pikachu",
		skin = {"original", "red", "blue", "green"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x0E] = {
		name = "ice_climber",
		skin = {"original", "green", "orange", "red"},
		team_skin = {4, 1, 2},
		series = "ice_climbers"
	},
	[0x0F] = {
		name = "purin",
		skin = {"original", "red", "blue", "green", "crown"},
		team_skin = {2, 3, 4},
		series = "pokemon"
	},
	[0x21] = {
		name = "wireframe",
		series = "smash"
	},
}

local icons = {
	cache = {
		["cards"] = {},
		["heads"] = {},
		["series"] = {},
		["stocks"] = {},
	}
}

local newImage = love.graphics.newImage

function icons.init()
	for cid, info in pairs(textures) do
		icons.cache["heads"][cid] = newImage(("textures/heads/%s.png"):format(info.name))
		icons.cache["series"][cid] = newImage(("textures/series/%s.png"):format(info.series))
		
		if info.skin then
			for sid, skin in ipairs(info.skin) do
				icons.cache["stocks"][cid] = icons.cache["stocks"][cid] or {}
				icons.cache["stocks"][cid][sid-1] = newImage(("textures/stocks/%s-%s.png"):format(info.name, skin))

				icons.cache["cards"][cid] = icons.cache["cards"][cid] or {}
				icons.cache["cards"][cid] = newImage(("textures/cards/%s-%s.png"):format(info.name, skin))
			end
		end
	end
end

function icons.getPlayerStockIcon(player)
	if not player then return end
	local cache = icons.cache["stocks"][player.character]
	if not cache then return end
	return cache[player.skin]
end

return icons