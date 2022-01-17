surface.CreateFont( 'fh-font', { -- Font for the interface text
	font = 'Arial',
	extended = false,
	size = 22,
	weight = 800,
} )

--[[
	Main
]]--

local scrw, scrh = ScrW(), ScrH()
local ColorWhite = Color(255,255,255)
local ColorLicense = Color(218,146,104)
local mat_health = Material( 'frelhud/health-note.png' )
local mat_armor = Material( 'frelhud/panoply.png' )
local mat_micro = Material( 'frelhud/micro.png' )
local mat_gun = Material( 'frelhud/gun.png' )
local mat_lockdown = Material( 'frelhud/lockdown.png' )
local mat_death = Material( 'frelhud/death.png' )
local mat_ammo = Material( 'frelhud/ammo.png' )
local mat_arrested = Material( 'frelhud/arrested.png' )
local mat_wanted = Material( 'frelhud/wanted.png' )
local mat_hunger = Material( 'frelhud/cutlery.png' )

local function PlayerInfoText( text, pos )
	draw.RoundedBox( 6, pos.x - surface.GetTextSize( text ) * 0.5 - 4, pos.y - 14, surface.GetTextSize( text ) + 8, 28, FrelHudConfig.Colors.background )

	draw.SimpleText( text, 'fh-font', pos.x, pos.y, ColorWhite, 1, 1 )
end

local function HudDrawPlayerInfo( player )
	local pos = player:EyePos()

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	// JOB
	PlayerInfoText( player:getDarkRPVar( 'job' ), pos )

	// NICK
	pos.y = pos.y - 28 - 15

	local text = player:GetName()

	draw.RoundedBox( 6, pos.x - surface.GetTextSize( text ) * 0.5 - 4, pos.y - 14 - 4, surface.GetTextSize( text ) + 8, 28, team.GetColor( player:Team() ) )

	if ( player:getDarkRPVar( 'HasGunlicense' ) ) then
		draw.RoundedBox( 6, pos.x - surface.GetTextSize( text ) * 0.5 - 4, pos.y - 14 + 4, surface.GetTextSize( text ) + 8, 28, ColorLicense )
	end

	PlayerInfoText( text, pos )

	// ARRESTED
	if ( player:getDarkRPVar( 'Arrested' ) ) then
		pos.y = pos.y - 28 - 15

		PlayerInfoText( FrelHudConfig.Language.arrested, pos )
	end

	// WANTED

	if ( player:getDarkRPVar( 'wanted' ) ) then
		pos.y = pos.y - 28 - 15

		PlayerInfoText( FrelHudConfig.Language.wanted, pos )
	end
end

local Retreat = 0
local money_smooth, armor_smooth, hunger_smooth = 0, 0, 0

hook.Add( 'HUDPaint', 'Freline-hud', function()
	if ( not LocalPlayer():Alive() ) then
		Retreat = 0
	end

	if ( Retreat < FrelHudConfig.Indentation ) then
		Retreat = Retreat + 0.5
	elseif ( Retreat > FrelHudConfig.Indentation ) then
		Retreat = Retreat - 0.5
	end

	// CHECKS
	if ( FAdmin.ScoreBoard.Visible ) then
		return
	end

	if ( IsValid( g_ContextMenu ) ) then
		if ( g_ContextMenu:IsVisible() ) then
			return
		end
	end

	if ( IsValid( g_SpawnMenu ) ) then
		if ( g_SpawnMenu:IsVisible() ) then
			return
		end
	end

	// DEATH
	if ( not LocalPlayer():Alive() ) then
		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_death )
		surface.DrawTexturedRect( scrw * 0.5 - 64, scrh * 0.5 - 64, 128, 128 )

		return
	end

	// JOB
	surface.SetFont( 'fh-font' )

	local txt = FrelHudConfig.Language.job .. ': ' .. ( LocalPlayer():getDarkRPVar( 'job' ) or '' )

	draw.RoundedBox( 8, Retreat, scrh - Retreat - 64 - 28 - 8 - 4, surface.GetTextSize( txt ) + 12, 28, team.GetColor( LocalPlayer():Team() ) )
	draw.RoundedBox( 8, Retreat, scrh - Retreat - 64 - 28 - 8, surface.GetTextSize( txt ) + 12, 28, FrelHudConfig.Colors.background )

	draw.SimpleText( txt, 'fh-font', Retreat + 6, scrh - Retreat - 6 - 64 - 16, FrelHudConfig.Colors.text_color, 0, 1 )

	// HEALTH
	local health = math.Clamp( LocalPlayer():Health(), 0, LocalPlayer():GetMaxHealth() ) / LocalPlayer():GetMaxHealth() * 100

	money_smooth = Lerp( 8 * FrameTime(), money_smooth or 0, health or 0 )

	draw.RoundedBox( 8, Retreat + 32, scrh - 64 - Retreat + 20, 94, 28, FrelHudConfig.Colors.background )

	surface.SetDrawColor( ColorWhite )
	surface.SetMaterial( mat_health )
	surface.DrawTexturedRect( Retreat, scrh - 64 - Retreat, 64, 64 )

	draw.SimpleText( math.ceil( money_smooth ) .. '%', 'fh-font', Retreat + 64 + 36 - 6, scrh - Retreat - 32 + 2, FrelHudConfig.Colors.text_color, 1, 1 )

	// ARMOR
	if ( LocalPlayer():Armor() > 0 ) then
		draw.RoundedBox( 8, Retreat + 32 + 32 + 94 + 6 + 2, scrh - 64 - Retreat + 20, 94, 28, FrelHudConfig.Colors.background )

		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_armor )
		surface.DrawTexturedRect( Retreat + 64 + 64 + 6, scrh - 64 - Retreat, 64, 64 )

		local armor = math.Clamp( LocalPlayer():Armor(), 0, LocalPlayer():GetMaxArmor() ) / LocalPlayer():GetMaxArmor() * 100

		armor_smooth = Lerp( 8 * FrameTime(), armor_smooth or 0, armor or 0 )

		draw.SimpleText( math.ceil( armor_smooth ) .. '%', 'fh-font', Retreat + 64 + 36 + 94 + 32 + 2, scrh - Retreat - 32 + 2, FrelHudConfig.Colors.text_color, 1, 1 )
	end

	// HUNGER MODE
	if ( FrelHudConfig.HungerMode ) then
		draw.RoundedBox( 8, Retreat + 32 + 32 + 94 + 6 + 2 + ( LocalPlayer():Armor() > 0 and 64 + 94 - 26 or 0 ), scrh - 64 - Retreat + 20, 94, 28, FrelHudConfig.Colors.background )

		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_hunger )
		surface.DrawTexturedRect( Retreat + 64 + 64 + 6 + ( LocalPlayer():Armor() > 0 and 64 + 94 - 26 or 0 ), scrh - 64 - Retreat, 64, 64 )

		local hunger = math.Clamp( LocalPlayer():getDarkRPVar( 'Energy' ) or 0, 0, 100 )

		hunger_smooth = Lerp( 8 * FrameTime(), hunger_smooth or 0, hunger or 0 )

		draw.SimpleText( math.ceil( hunger_smooth ) .. '%', 'fh-font', Retreat + 64 + 36 + 94 + 32 + 2 + ( LocalPlayer():Armor() > 0 and 64 + 94 - 26 or 0 ), scrh - Retreat - 32 + 2, FrelHudConfig.Colors.text_color, 1, 1 )
	end

	// MICROPHONE
	surface.SetDrawColor( ColorWhite )

	if ( LocalPlayer():IsSpeaking() ) then
		surface.SetMaterial( mat_micro )
		surface.DrawTexturedRect( scrw * 0.5 - 32, scrh - 64 - Retreat, 64, 64 )
	end

	// LICENSE
	if ( LocalPlayer():getDarkRPVar( 'HasGunlicense' ) ) then
		surface.SetMaterial( mat_gun )
		surface.DrawTexturedRect( Retreat, scrh - 64 - Retreat - 64 - 15 - 28 - 28 - 6 - 6 - 8, 64, 64 )
	end

	// LOCKDOWN
	if ( GetGlobalBool( 'DarkRP_LockDown' ) ) then
		surface.SetMaterial( mat_lockdown )
		surface.DrawTexturedRect( scrw * 0.5 - 32, Retreat, 64, 64 )
	end

	// AMMO
	local activeWep = LocalPlayer():GetActiveWeapon()
	local wepClip = 0
	local wepAmmo = 0

	if ( IsValid( activeWep ) ) then
		wepClip = activeWep:Clip1()
		wepAmmo = LocalPlayer():GetAmmoCount( activeWep:GetPrimaryAmmoType() )
	end

	if ( wepAmmo > 0 or wepClip > 0 ) then
		local txt = wepClip .. '/' .. wepAmmo

		draw.RoundedBox( 8, scrw - Retreat - 64 - surface.GetTextSize( txt ) - Retreat - 4, scrh - Retreat - 32 - 14, surface.GetTextSize( txt ) + 8, 28, FrelHudConfig.Colors.background )

		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_ammo )
		surface.DrawTexturedRect( scrw - 64 - Retreat, scrh - 64 - Retreat, 64, 64 )
	
		draw.SimpleText( txt, 'fh-font', scrw - 64 - Retreat - surface.GetTextSize( txt ) - Retreat, scrh - Retreat - 32, FrelHudConfig.Colors.text_color, 0, 1 )
	end

	// MONEY
	local txt = FrelHudConfig.Language.wallet .. ': ' .. DarkRP.formatMoney( LocalPlayer():getDarkRPVar( 'money' ) )

	draw.RoundedBox( 8, Retreat, scrh - Retreat - 64 - 28 - 8 - 28 - 4 - 8 - 4, surface.GetTextSize( txt ) + 12, 28, team.GetColor( LocalPlayer():Team() ) )
	draw.RoundedBox( 8, Retreat, scrh - Retreat - 64 - 28 - 8 - 28 - 4 - 8, surface.GetTextSize( txt ) + 12, 28, FrelHudConfig.Colors.background )

	draw.SimpleText( txt, 'fh-font', Retreat + 6, scrh - Retreat - 6 - 64 - 16 - 28 - 8 - 4, FrelHudConfig.Colors.text_color, 0, 1 )

	// ARRESTED
	if ( LocalPlayer():getDarkRPVar( 'Arrested' ) ) then
		local txt = FrelHudConfig.Language.arrested

		draw.RoundedBox( 8, Retreat + 64 + 15 - 4, Retreat + 32 - 14, surface.GetTextSize( txt ) + 8, 28, FrelHudConfig.Colors.background )

		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_arrested )
		surface.DrawTexturedRect( Retreat, Retreat, 64, 64 )

		draw.SimpleText( txt, 'fh-font', Retreat + 64 + 15, Retreat + 32, FrelHudConfig.Colors.text_color, 0, 1 )
	end

	// WANTED
	if ( LocalPlayer():getDarkRPVar( 'wanted' ) ) then
		local txt = FrelHudConfig.Language.wanted

		draw.RoundedBox( 8, Retreat + 64 + 15 - 4, Retreat + 32 - 14 + ( LocalPlayer():getDarkRPVar( 'Arrested' ) and Retreat + 64 or 0 ), surface.GetTextSize( txt ) + 8, 28, FrelHudConfig.Colors.background )

		surface.SetDrawColor( ColorWhite )
		surface.SetMaterial( mat_wanted )
		surface.DrawTexturedRect( Retreat, Retreat + ( LocalPlayer():getDarkRPVar( 'Arrested' ) and Retreat + 64 or 0 ), 64, 64 )

		draw.SimpleText( txt, 'fh-font', Retreat + 64 + 15, Retreat + 32 + ( LocalPlayer():getDarkRPVar( 'Arrested' ) and Retreat + 64 or 0 ), FrelHudConfig.Colors.text_color, 0, 1 )
	end

	// AGENDA
	local agenda = LocalPlayer():getAgendaTable()

	if ( agenda and FrelHudConfig.Agenda ) then
		local agenda_text = LocalPlayer():getDarkRPVar( 'agenda' ) or FrelHudConfig.Language.empty
		local atext = DarkRP.textWrap( agenda_text, 'fh-font', 260 )
		local a_w, a_h = surface.GetTextSize( atext )
	  
		draw.RoundedBox( 8, scrw - 300 - Retreat, Retreat, 300, 30 + a_h + 10 + 4, FrelHudConfig.Colors.background )
		draw.RoundedBox( 8, scrw - 300 - Retreat, Retreat, 300, 30, team.GetColor( LocalPlayer():Team() ) )
		draw.RoundedBox( 0, scrw - 300 - Retreat, Retreat + 20, 300, 10, team.GetColor( LocalPlayer():Team() ) )
	  
		draw.SimpleText( agenda.Title, 'fh-font', scrw - 150 - Retreat, 15 + Retreat, ColorWhite, 1, 1 )
	
		draw.DrawText( atext, 'fh-font', scrw - 300 - Retreat + 10, Retreat + 35, ColorWhite )
	end

	// ENTITY PLAYER INFO
	local shootPos = LocalPlayer():GetShootPos()
	local aimVec = LocalPlayer():GetAimVector()

	for k, ply in pairs( player.GetAll() ) do
		if ( not IsValid( ply ) or ply == LocalPlayer() or not ply:Alive() or ply:GetNoDraw() or ply:IsDormant() ) then
			continue
		end

		local hisPos = ply:GetShootPos()

		if ( hisPos:DistToSqr( shootPos ) < 40000 ) then
			local pos = hisPos - shootPos
			local trace = util.QuickTrace( shootPos, pos, LocalPlayer() )

			if ( trace.Hit and trace.Entity != ply ) then
				if ( trace.Entity:IsPlayer() ) then
					HudDrawPlayerInfo( trace.Entity )
				end

				break
			end

			HudDrawPlayerInfo( ply )
		end
	end

	// PLAYER OWNERSHIP
	local ent = LocalPlayer():GetEyeTrace().Entity

	if ( IsValid( ent ) and ent:isKeysOwnable() and ent:GetPos():DistToSqr( LocalPlayer():GetPos() ) < 30000 ) then
		ent:drawOwnableInfo()
	end
end )

local remove_elements = {
	-- Standart
	'CHudAmmo',
	'CHudSecondaryAmmo',
	-- DarkRP
	'DarkRP_HUD',
	'DarkRP_ChatReceivers',
	'DarkRP_EntityDisplay',
	'DarkRP_Hungermod',
}

hook.Add( 'HUDShouldDraw', 'HideHudElements', function( name ) -- Here we remove the extra elements of the hud
	if ( table.HasValue( remove_elements, name ) ) then
		return false
	end
end )

--[[
	Nofity
]]--

notification = {}

NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO	= 2
NOTIFY_CLEANUP = 4
NOTIFY_HINT = 4

local Notices = {}

function notification.AddProgress( uid, text )
end

function notification.Kill( uid )
	if ( not IsValid( Notices[ uid ] ) ) then
		return
	end
	
	Notices[ uid ].StartTime = SysTime()
	Notices[ uid ].Length = 0.8
end

function notification.AddLegacy( text, type, length )
	if ( type == nil ) then
		type = 0
	end

	text = tostring( text )

	local parent

	if ( GetOverlayPanel ) then
		parent = GetOverlayPanel()
	end

	local Panel = vgui.Create( 'NoticePanel', parent )
	Panel.NotifyType = type
	Panel.StartTime = SysTime()
	Panel.Length = length
	Panel.VelX = 0
	Panel.VelY = 0
	Panel.fx = ScrW() + 200
	Panel.fy = ScrH()

	Panel:SetText( text )
	Panel:SetPos( Panel.fx, Panel.fy )
	
	table.insert( Notices, Panel )

	local color = FrelHudConfig.Colors.notify[ type ]

	MsgC( ColorWhite, '[', color, 'Notify', ColorWhite, '] ' .. text .. '\n' )

	surface.PlaySound( 'ambient/water/drip4.wav' )
end

local function UpdateNotice( i, Panel, Count )
	local x = Panel.fx
	local y = Panel.fy
	local w = Panel:GetWide() + 16
	local h = Panel:GetTall() + 16
	local ideal_y = ScrH() - ( Count - i ) * ( h - 12 ) - 15 - h
	local ideal_x = ScrW() - w - 15
	local timeleft = Panel.StartTime - ( SysTime() - Panel.Length )

	if ( timeleft < 0.2  ) then
		ideal_x = ideal_x + w * 2
	end

	local spd = FrameTime() * 15

	y = y + Panel.VelY * spd
	x = x + Panel.VelX * spd
	
	local dist = ideal_y - y

	Panel.VelY = Panel.VelY + dist * spd * 1

	if ( math.abs( dist ) < 2 && math.abs( Panel.VelY ) < 0.1 ) then
		Panel.VelY = 0
	end

	local dist = ideal_x - x

	Panel.VelX = Panel.VelX + dist * spd * 1

	if ( math.abs( dist ) < 2 && math.abs( Panel.VelX ) < 0.1 ) then
		Panel.VelX = 0
	end

	Panel.VelX = Panel.VelX * ( 0.9 - FrameTime() * 8 )
	Panel.VelY = Panel.VelY * ( 0.9 - FrameTime() * 8 )
	Panel.fx = x
	Panel.fy = y

	Panel:SetPos( Panel.fx, Panel.fy )
end

hook.Add( 'Think', 'FrelNotificationThink', function()
	for k, v in ipairs( Notices ) do
		UpdateNotice( k, v, #Notices )
	
		if ( IsValid( v ) and v:KillSelf() ) then
			table.remove( Notices, k )
		end
	end
end )

local PANEL = {}

function PANEL:Init()
	self.NotifyType = NOTIFY_GENERIC
	
	self.Label = vgui.Create( 'DLabel', self )
	self.Label:SetFont( 'fh-font' )
	self.Label:SetTextColor( ColorWhite )
	self.Label:SetPos( 5, 2 )
end

function PANEL:SetText( txt )
	self.Label:SetText( txt )

	self:SizeToContents()
end

function PANEL:SizeToContents()
	self.Label:SizeToContents()

	self:SetWidth( self.Label:GetWide() + 10 )
	self:SetHeight( 28 )
	self:InvalidateLayout()
end

function PANEL:KillSelf()
	if ( self.StartTime + self.Length < SysTime() ) then
		self:Remove()
	
		return true
	end

	return false
end

function PANEL:Paint( w, h )
	local timeleft = self.StartTime - ( SysTime() - self.Length )
	local color = FrelHudConfig.Colors.notify[ self.NotifyType ]

	draw.RoundedBox( 6, 0, 0, w, h, FrelHudConfig.Colors.background )
	draw.RoundedBox( 6, 0, 0, w * ( timeleft / self.Length ), h, color )
end

vgui.Register( 'NoticePanel', PANEL, 'DPanel' )
