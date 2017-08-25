if GAMEMODE_NAME ~= "sandbox" then
	return
end

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
	xgui.addDataType( "_Kyle_Buildmode", function()  
	net.Start( "kylebuildmode_senddata", false )
	net.WriteTable( _Kyle_Buildmode )
	net.Broadcast()
	end, "kylebuildmodesettings", 0, -10 )
	
	if not file.Exists( "kylebuildmode.txt", "DATA" ) then
		--Make defaults
		_Kyle_Buildmode["restrictweapons"] = 0
		_Kyle_Buildmode["allownoclip"] = 0
		_Kyle_Buildmode["killonpvp"] = 0
		_Kyle_Buildmode["antipropkill"] = 0
		_Kyle_Buildmode["spawnwithbuildmode"] = 0
		_Kyle_Buildmode["disablepvppropspawn"] = 0
		_Kyle_Buildmode["highlightbuilders"] = 0
		_Kyle_Buildmode["highlightpvpers"] = 0
		_Kyle_Buildmode["buildloadout"] = {"weapon_physgun", "gmod_tool", "gmod_camera"}
		_Kyle_Buildmode["highlightbuilderscolor"]= "0,128,255"
		_Kyle_Buildmode["highlightpvperscolor"]= "255,0,0"
	else 
		_Kyle_Buildmode = ULib.parseKeyValues( file.Read( "kylebuildmode.txt" ) )
	end

	ULib.replicatedWritableCvar("kylebuildmode_restrictweapons",		"rep_kylebuildmode_restrictweapons",		_Kyle_Buildmode["restrictweapons"],		false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_killonpvp",				"rep_kylebuildmode_killonpvp",				_Kyle_Buildmode["killonpvp"],			false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_spawnwithbuildmode",		"rep_kylebuildmode_spawnwithbuildmode",		_Kyle_Buildmode["spawnwithbuildmode"],	false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_allownoclip",			"rep_kylebuildmode_allownoclip",			_Kyle_Buildmode["allownoclip"],			false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_antipropkill",			"rep_kylebuildmode_antipropkill",			_Kyle_Buildmode["antipropkill"],		false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_highlightbuilders",		"rep_kylebuildmode_highlightbuilders",		_Kyle_Buildmode["highlightbuilders"],	false,true,"kylebuildmodesettings")
	ULib.replicatedWritableCvar("kylebuildmode_highlightpvpers",		"rep_kylebuildmode_highlightpvpers",		_Kyle_Buildmode["highlightpvpers"],		false,true,"kylebuildmodesettings")

	SaveAndSend()
end )

hook.Add( "ULibReplicatedCvarChanged", "kylebuildmodecvar",  function(v,w,x,y,z)
	local u = string.Split(v, "_")
	if(u[1]=="kylebuildmode") then
		_Kyle_Buildmode[u[2]] = z
		SaveAndSend()
	end
end)

concommand.Add("kylebuildmode", function( x, y, z )
	if z[1]=="defaultloadout" then
		gamemode.Call("PlayerLoadout", x)
		return
	end

	if (x:query( "kylebuildmodesettings" )) then
		if z[1]=="addweapon" then
			table.insert(_Kyle_Buildmode["buildloadout"], z[2])
		elseif z[1]=="removeweapon" then
			table.RemoveByValue( _Kyle_Buildmode["buildloadout"], z[2] )
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
	else
		net.Start( "kylebuildmode_senddata", false )
		net.WriteTable(_Kyle_Buildmode)
		net.Send(z)
	end
end)
