local inc = SERVER and AddCSLuaFile or include

if ( SERVER ) then
	resource.AddFile( 'materials/frelhud/armor.png' )
	resource.AddFile( 'materials/frelhud/scar.png' )
	resource.AddFile( 'materials/frelhud/micro.png' )
	resource.AddFile( 'materials/frelhud/gun.png' )
	resource.AddFile( 'materials/frelhud/lockdown.png' )
	resource.AddFile( 'materials/frelhud/death.png' )
	resource.AddFile( 'materials/frelhud/ammo.png' )
	resource.AddFile( 'materials/frelhud/money.png' )
	resource.AddFile( 'materials/frelhud/arrested.png' )
	resource.AddFile( 'materials/frelhud/wanted.png' )
	resource.AddFile( 'materials/frelhud/hunger.png' )
end

inc( 'frelhud/config.lua' )
inc( 'frelhud/core.lua' )
