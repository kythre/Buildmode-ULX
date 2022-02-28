if not SERVER then return end

ULib.ucl.registerAccess( "kylebuildmodesettings", ULib.ACCESS_SUPERADMIN , "Allows managing all settings related to Buildmode.", "XGUI" )
ULib.ucl.registerAccess( "kylebuildmodenoclip", ULib.ACCESS_ALL, "Allows user to use noclip in Buildmode.", "_Kyle_1" )


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
	_Kyle_Buildmode["spawnprotection"] = 0
	_Kyle_Buildmode["restrictweapons"] = 0
	_Kyle_Buildmode["restrictsents"] = 0
	_Kyle_Buildmode["restrictvehicles"] = 0
	_Kyle_Buildmode["restrictvehicleentry"] = 0
	_Kyle_Buildmode["allownoclip"] = 0
	_Kyle_Buildmode["returntospawn"] = 0
	_Kyle_Buildmode["allownpcdamage"] = 0
	_Kyle_Buildmode["npcignore"] = 0
	_Kyle_Buildmode["antipropkill"] = 0
	_Kyle_Buildmode["antipropkillpvper"] = 0
	_Kyle_Buildmode["spawnwithbuildmode"] = 1
	_Kyle_Buildmode["persistpvp"] = 0
	_Kyle_Buildmode["pvppropspawn"] = 1
	_Kyle_Buildmode["highlightbuilders"] = 0
	_Kyle_Buildmode["highlightpvpers"] = 0
	_Kyle_Buildmode["buildloadout"] = {"weapon_physgun", "gmod_tool", "gmod_camera"}
	_Kyle_Buildmode["builderentitylist"] = {}
	_Kyle_Buildmode["buildervehiclelist"] = {}
	-- 0 for whitelist, 1 for blacklist
	_Kyle_Buildmode["weaponlistmode"] = 0
	_Kyle_Buildmode["entitylistmode"] = 1
	_Kyle_Buildmode["vehiclelistmode"] = 1
	_Kyle_Buildmode["highlightbuilderscolor"]= "0,128,255"
	_Kyle_Buildmode["highlightpvperscolor"]= "255,0,0"
	_Kyle_Buildmode["builddelay"] = 0
	_Kyle_Buildmode["pvpdelay"] = 0
	_Kyle_Buildmode["highlightonlywhenlooking"] = 0
	_Kyle_Buildmode["showtextstatus"] = 1
	_Kyle_Buildmode["adminsbypassrestrictions"] = 0
	_Kyle_Buildmode["anitpropspawn"] = 0
	_Kyle_Buildmode["antiballmunch"] = 1


	--Load saved settings
	local saved = {}
	if file.Exists( "kylebuildmode.txt", "DATA" ) then
		saved = ULib.parseKeyValues(file.Read( "kylebuildmode.txt" ))
	end
		
	--Make sure all of the saved settings overwrite the default settings
	for a,b in pairs(saved) do
		_Kyle_Buildmode[a] = saved[a]
	end
	
	for a,b in pairs(_Kyle_Buildmode) do
		if type(tonumber(b)) == "number" then
			ULib.replicatedWritableCvar("kylebuildmode_"..a, "rep_kylebuildmode_"..a, b, false,true,"kylebuildmodesettings")
		end
	end
	
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
		elseif z[1]=="addvehicle" then
			table.insert(_Kyle_Buildmode["buildervehiclelist"], z[2])
		elseif z[1]=="removevehicle" then
			table.RemoveByValue( _Kyle_Buildmode["buildervehiclelist"], z[2] )
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
