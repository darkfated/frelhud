FrelHudConfig = {}

FrelHudConfig.Colors = { -- Color palette
	background = Color(51,51,51),
	text_color = Color(241,241,241),
	notify = {
		[ 0 ] = Color(255,128,51), -- Generic
		[ 1 ] = Color(225,0,0), -- Error
		[ 2 ] = Color(51,128,255), -- Undo
		[ 3 ] = Color(0,215,15), -- Cleanup
		[ 4 ] = Color(136,61,255), -- Hint
	}
}

FrelHudConfig.Indentation = 15 -- Interface indentation from the edges of the screen

FrelHudConfig.Language = {
	job = 'Job',
	wallet = 'Wallet',
	arrested = 'Arrested!',
	wanted = 'Wanted!',
	empty = 'Empty'
}

FrelHudConfig.HungerMode = true -- The hunger display mode is activated in the interface or not

FrelHudConfig.Agenda = true -- The agenda panel display mode is activated in the interface or not
