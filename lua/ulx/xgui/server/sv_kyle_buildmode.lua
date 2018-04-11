if not SERVER then return end
if not ulx then return end
if not GAMEMODE["Name"] == "Sandbox" then return end

ULib.ucl.registerAccess( "kylebuildmodesettings", "superadmin", "Allows managing all settings related to Buildmode.", "XGUI" )

_Kyle_Buildmode = {}

util.AddNetworkString( "kylebuildmode_senddata" )

local function SaveAndSend()
	file.Write("kylebuildmode.txt", ULib.makeKeyValues(_Kyle_Buildmode))
	net.Start( "kylebuildmode_senddata", false )
	net.WriteTable( _Kyle_Buildmode )
	net.Broadcast()
end

xgui.addSVModule( "kylebuildmode_load", function()	
	xgui.addDataType( "_Kyle_Buildmode", function() end, "kylebuildmodesettings", 0, -10 )
	
	--Load defaults in to settings table
	_Kyle_Buildmode["restrictweapons"] = 0
	_Kyle_Buildmode["restrictsents"] = 0
	_Kyle_Buildmode["allownoclip"] = 0
	_Kyle_Buildmode["returntospawn"] = 0
	_Kyle_Buildmode["antipropkill"] = 0
	_Kyle_Buildmode["spawnwithbuildmode"] = 1
	_Kyle_Buildmode["persistpvp"] = 0
	_Kyle_Buildmode["pvppropspawn"] = 1
	_Kyle_Buildmode["highlightbuilders"] = 0
	_Kyle_Buildmode["highlightpvpers"] = 0
	_Kyle_Buildmode["buildloadout"] = {"weapon_physgun", "gmod_tool", "gmod_camera"}
	_Kyle_Buildmode["builderentitylist"] = {}
	-- 0 for whitelist, 1 for blacklist
	_Kyle_Buildmode["weaponlistmode"] = 0
	_Kyle_Buildmode["entitylistmode"] = 1
	_Kyle_Buildmode["highlightbuilderscolor"]= "0,128,255"
	_Kyle_Buildmode["highlightpvperscolor"]= "255,0,0"
	_Kyle_Buildmode["builddelay"] = 0
	_Kyle_Buildmode["pvpdelay"] = 0
	_Kyle_Buildmode["highlightonlywhenlooking"] = 0
	_Kyle_Buildmode["showtextstatus"] = 1
	
	--Load saved settings
	local saved = {}
	if file.Exists( "kylebuildmode.txt", "DATA" ) then
		saved = ULib.parseKeyValues( file.Read( "kylebuildmode.txt" ))
	end
		
	--Make sure all of the saved settings overwrite the default settings
	for a,b in pairs(saved) do
		_Kyle_Buildmode[a] = saved[a]
	end
	
	ULib.replicatedWritableCvar("kylebuildmode_restrictweapons",			"rep_kylebuildmode_restrictweapons",			_Kyle_Buildmode["restrictweapons"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_restrictsents",				"rep_kylebuildmode_restrictsents",				_Kyle_Buildmode["restrictsents"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_returntospawn",				"rep_kylebuildmode_returntospawn",				_Kyle_Buildmode["returntospawn"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_spawnwithbuildmode",			"rep_kylebuildmode_spawnwithbuildmode",			_Kyle_Buildmode["spawnwithbuildmode"],			false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_persistpvp",					"rep_kylebuildmode_persistpvp",					_Kyle_Buildmode["persistpvp"],					false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_allownoclip",				"rep_kylebuildmode_allownoclip",				_Kyle_Buildmode["allownoclip"],					false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_antipropkill",				"rep_kylebuildmode_antipropkill",				_Kyle_Buildmode["antipropkill"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_pvppropspawn",				"rep_kylebuildmode_pvppropspawn",				_Kyle_Buildmode["pvppropspawn"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_highlightbuilders",			"rep_kylebuildmode_highlightbuilders",			_Kyle_Buildmode["highlightbuilders"],			false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_highlightpvpers",			"rep_kylebuildmode_highlightpvpers",			_Kyle_Buildmode["highlightpvpers"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_weaponlistmode",				"rep_kylebuildmode_weaponlistmode",				_Kyle_Buildmode["weaponlistmode"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_entitylistmode",				"rep_kylebuildmode_entitylistmode",				_Kyle_Buildmode["entitylistmode"],				false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_highlightonlywhenlooking",	"rep_kylebuildmode_highlightonlywhenlooking",	_Kyle_Buildmode["highlightonlywhenlooking"],	false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_showtextstatus",				"rep_kylebuildmode_showtextstatus",				_Kyle_Buildmode["showtextstatus"],				false,true,"kylebuildmodesettings")

	SaveAndSend()
end )

hook.Add("ULibReplicatedCvarChanged", "kylebuildmodecvar",  function(v,w,x,y,z)
	local u = string.Split(v, "_")
	if(u[1]=="kylebuildmode") then
		_Kyle_Buildmode[u[2]] = z
		SaveAndSend()
	end
end)

hook.Add("PlayerInitialSpawn", "kylebuildmode_initialspawn", function(z)
	timer.Simple( 10, function() 	
		net.Start("kylebuildmode_senddata", false)
		net.WriteTable(_Kyle_Buildmode)
		net.Send(z)
		end)
end )

concommand.Add("kylebuildmode", function( x, y, z )
	if x:IsValid() and z[1]=="defaultloadout" then
		gamemode.Call("PlayerLoadout", x)
		return
	end
		
	if (x:IsValid() and x:query( "kylebuildmodesettings" )) then
		if z[1]=="addweapon" then
			table.insert(_Kyle_Buildmode["buildloadout"], z[2])
		elseif z[1]=="removeweapon" then
			table.RemoveByValue( _Kyle_Buildmode["buildloadout"], z[2] )
		elseif z[1]=="addentity" then
			table.insert(_Kyle_Buildmode["builderentitylist"], z[2])
		elseif z[1]=="removeentity" then
			table.RemoveByValue( _Kyle_Buildmode["builderentitylist"], z[2] )
		elseif z[1]=="set" then
			if z[2] then
				if z[3] then
					_Kyle_Buildmode[z[2]]=z[3]
				else
					print (_Kyle_Buildmode[z[2]])
				end
			else
				PrintTable(_Kyle_Buildmode)
				return
			end
		end
		SaveAndSend()
	end
end)
