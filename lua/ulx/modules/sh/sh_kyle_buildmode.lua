local function TryUnNoclip(z)	
	timer.Simple(0.1, function() 
		--Exit if the prop stops existing or isnt noclipped
		if not (z:IsValid() or z:GetNWBool("_kyle_noclip")) then return end
		
		--Check to see if there is anything inside the props bounds
		local a,b = z:GetCollisionBounds()
		local c = ents.FindInBox(z:LocalToWorld(a), z:LocalToWorld(b))
		local d = false
		
		for aa,ab in pairs(c) do
			d = d or ab != z and ab:IsPlayer() 
			d = d or ab != z and ab:IsVehicle() 
			d = d or ab != z and ab:GetClass() == "prop_physics"
		end		

		--If there isnt anything inside the prop, the prop is not being held by a physgun, and the prop is not moving, then un noclip
		----if there is soemthing inside the prop, then it could get stuck
		----if the prop is being held by a physgun, then it could be used to proppush
		----if the prop is moving then it could smash a player when
		if not d and not z:GetNWBool("Physgunned") and z:GetVelocity():Length() < 1 then
			--Recall the old attributes
			z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], z:GetNWInt("Alpha")))
			z:SetRenderMode(z:GetNWInt("RenderMode")) 
			z:SetCollisionGroup(z:GetNWInt("CollisionGroup"))
			z:SetNWInt("_kyle_noclip", false)
		else
			--if it fails, try again
			TryUnNoclip(z)
		end
	end )
end

local function Noclip(z)
	--Exit if we are already un noclipd
	if z:GetNWBool("_kyle_noclip") then return end

	--Store the old attributes (to be recalled later)
	z:SetNWInt("RenderMode", z:GetRenderMode())
	z:SetNWInt("Alpha", z:GetColor()["a"])
	z:SetNWInt("CollisionGroup", z:GetCollisionGroup())			
	
	--Set the new attributes
	z:SetCollisionGroup(COLLISION_GROUP_WORLD)
	z:SetRenderMode(1)
	z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], 200))
	z:SetNWInt("_kyle_noclip", true)
	
	--Try to un noclip asap if its not a vehicle being driven by a builder
	if not (z:IsVehicle() and z:GetDriver().buildmode) then TryUnNoclip(z) end
end

local function _kyle_Buildmode_Enable(z)
	if z:Alive() then
		if _Kyle_Buildmode["restrictweapons"]=="1" then
			--save the players loadout for when they exit buildmode
			ULib.getSpawnInfo(z)
			--remove their weapons
			z:StripWeapons()
			--give them whitelisted weapons
			for x,y in pairs(_Kyle_Buildmode["buildloadout"]) do 
				z:Give(y)
			end
		end
		
		--noclip their vehicle so they cant run anyone anyone over while in buildmode
		if z:InVehicle() then
			noclip(z:GetVehicle())
		end
	end

	--some say that sendlua is lazy and wrong but idc
    z:SendLua("GAMEMODE:AddNotify(\"Buildmode enabled. Type !pvp to disable\",NOTIFY_GENERIC, 5)")
	
	z.buildmode = true
	
	--second buildmode variable for halos and status text on hover
	z:SetNWBool("_Kyle_Buildmode", true)
	
	--boolean to say if buildmode was enabled because the player had just spawned
	z:SetNWBool("_Kyle_BuildmodeOnSpawn", z:GetNWBool("_kyle_died"))
end

local function _kyle_Buildmode_Disable(z)
	z.buildmode = false
	
	--second buildmode variable for halos and status text on hover
	z:SetNWBool("_Kyle_Buildmode", false)
	
	--some say that sendlua is lazy and wrong but idc
	z:SendLua("GAMEMODE:AddNotify(\"Buildmode disabled.\",NOTIFY_GENERIC, 5)")
	
	if z:Alive() then
		--save their position incase they dont need to return to spawn on exit
		local pos = z:GetPos()
		
		--if they are in a vehicle try to un noclip their vehicle and kick them out of it if they need to return to spawn
		if z:InVehicle() then
			TryUnnoclip(z:GetVehicle())
			if _Kyle_Buildmode["returntospawn"]=="1" then
				z:ExitVehicle()
			end
		end		
		
		ULib.spawn(z, not z:GetNWBool("_Kyle_BuildmodeOnSpawn"))
		
		if _Kyle_Buildmode["restrictweapons"]=="1" and z:GetNWBool("_Kyle_BuildmodeOnSpawn") then
			z:ConCommand("kylebuildmode defaultloadout")
		end		
		
		--ULIB.spawn moves the player to spawn, this will return the player to where they where while in buildmode
		if _Kyle_Buildmode["returntospawn"]=="0" then
			z:SetPos(pos)
		end

		--disable noclip if they had it in build		
		if z:GetNWBool("kylenocliped") then
			z:ConCommand( "noclip" )
		end
	end
end

local function _kyle_builder_spawn_weapon(z)
	return ((_Kyle_Buildmode["weaponlistmode"]=="0") == table.HasValue(_Kyle_Buildmode["buildloadout"], z))
end

local function _kyle_builder_spawn_entity(z)
	return ((_Kyle_Buildmode["entitylistmode"]=="0") == table.HasValue(_Kyle_Buildmode["builderentitylist"], z))
end

hook.Add("PlayerSpawnedProp", "KylebuildmodePropKill", function(x, y, z)
	if x.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		Noclip(z)
	end
end)

hook.Add("PlayerSpawnedVehicle", "KylebuildmodePropKill", function(y, z)
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		Noclip(z)
	end
end)

hook.Add("PlayerEnteredVehicle", "KylebuildmodePropKill", function(y, z)
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		Noclip(z)
	end
end)

hook.Add("PlayerLeaveVehicle", "KylebuildmodePropKill", function(y, z)
	TryUnnoclip(z)
end)

hook.Add("PhysgunPickup", "KylebuildmodePropKill", function(y, z)
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", true)
		Noclip(z)
	end
end, HOOK_MONITOR_LOW )

hook.Add("PhysgunDrop", "KylebuildmodePropKill", function(y, z)
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", false)
		
		--Kill the prop's velocity so it can not be thrown
		z:SetPos(z:GetPos())
	end
end)

hook.Add("PlayerNoClip", "KylebuildmodeNoclip", function(y, z)
	if _Kyle_Buildmode["allownoclip"]=="1" then
		--allow players to use default sandbox noclip
		y:SetNWBool("kylenocliped", z)
		return z == false or y.buildmode
	end
end )

hook.Add("PlayerSpawn", "kyleBuildmodePlayerSpawn",  function(z)
	--z:GetNWBool("_kyle_died") makes sure that the player is spawning after an actual death and not the ulib respawn function
	if ((_Kyle_Buildmode["spawnwithbuildmode"]=="1" and not z:GetNWBool("_Kyle_pvpoverride")) or z:GetNWBool("_Kyle_Buildmode")) and z:GetNWBool("_kyle_died") then
		_kyle_Buildmode_Enable(z)
	end
	z:SetNWBool("_kyle_died", false)
end )

hook.Add("PlayerInitialSpawn", "kyleBuildmodePlayerInitilaSpawn", function (z) 
	z:SetNWBool("_kyle_died", true)
	z:SetNWBool("_Kyle_pvpoverride", false)
end )

hook.Add("PostPlayerDeath", "kyleBuildmodePostPlayerDeath",  function(z)
	z:SetNWBool("_kyle_died", true)
end, HOOK_HIGH )

hook.Add("PlayerGiveSWEP", "kylebuildmoderestrictswep", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not _kyle_builder_spawn_weapon(z) then
       	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot give yourself this weapon while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerSpawnSWEP", "kylebuildmoderestrictswep", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not _kyle_builder_spawn_weapon(z) then
        --some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn this weapon while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerCanPickupWeapon", "kylebuildmoderestrictswep", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not _kyle_builder_spawn_weapon(string.Split(string.Split(tostring(z),"][", true)[2],"]", true)[1]) then
		return false   
    end
end)

hook.Add("PlayerSpawnSENT", "kylebuildmoderestrictsent", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictsents"]=="1" and not _kyle_builder_spawn_entity(z) then
       	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn this SENT while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerSpawnProp", "kylebuildmodepropspawn", function(y, z)
	if _Kyle_Buildmode["pvppropspawn"]=="0" and not y.buildmode and not y:IsAdmin() then
    	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn props while in PVP.\",NOTIFY_GENERIC, 5)")
		return false
	end
end)

hook.Add("EntityTakeDamage", "kyleBuildmodeTryTakeDamage", function(y, z)
	return  y.buildmode or z:GetAttacker().buildmode
end, HOOK_HIGH)

hook.Add("PreDrawHalos", "KyleBuildmodehalos", function()
	local w = {}
	local x = {}

	if _Kyle_Buildmode["highlightonlywhenlooking"]=="0" then
		local z = {}
		for y,z in pairs(player.GetAll()) do
			if z:Alive() then
				if z:GetNWBool("_Kyle_Buildmode") then
					table.insert(w, z)
				else
					table.insert(x, z)
				end
			end
		end
	else	
		local z = LocalPlayer():GetEyeTrace().Entity
		if z:IsPlayer() and z:Alive() then
			if z:GetNWBool("_Kyle_Buildmode") then
				table.insert(w, z)
			else
				table.insert(x, z)
			end
		end		
	end
	
	-- --add setting later for render mode
	if _Kyle_Buildmode["highlightbuilders"]=="1" then 
		z = string.Split( _Kyle_Buildmode["highlightbuilderscolor"],",")
		halo.Add(w, Color(z[1],z[2],z[3]), 4, 4, 1, true)
	end
	
	if _Kyle_Buildmode["highlightpvpers"]=="1" then 
		z = string.Split( _Kyle_Buildmode["highlightpvperscolor"],",")
		halo.Add(x, Color(z[1],z[2],z[3]), 4, 4, 1, true) 
	end	
end)

hook.Add("HUDPaint", "KyleBuildehudpaint", function()
	if _Kyle_Buildmode["showtextstatus"]=="1" then
		local z = LocalPlayer():GetEyeTrace().Entity
		if z:IsPlayer() and z:Alive() then
		
			local x,y = gui.MousePos()
			y=y+80
		
			if x==0 or y==0 then	
				x = ScrW()/2
				y = ScrH()/1.74
			end

			local col = string.Split(_Kyle_Buildmode["highlightpvperscolor"],",")	
			local mode = "PVP"
			if z:GetNWBool("_Kyle_Buildmode") then
				mode = "Build"
				col = string.Split( _Kyle_Buildmode["highlightbuilderscolor"],",")
			end
			
			draw.TextShadow( {text=mode.."er", font="ChatFont", pos={x,y}, xalign=TEXT_ALIGN_CENTER, yalign=TEXT_ALIGN_CENTER, color=team.GetColor(z:Team())}, 1 )
		end
	end
end)

local CATEGORY_NAME = "_Kyle_1"

local kylebuildmode = ulx.command( "_Kyle_1", "ulx build", function( calling_ply, should_revoke )
	if _Kyle_Buildmode["persistpvp"]=="1" then
		calling_ply:SetNWBool("_Kyle_pvpoverride", not should_revoke)
	end
	if not calling_ply.buildmode and not should_revoke and not calling_ply:GetNWBool("kylependingbuildchange") then
		if _Kyle_Buildmode["builddelay"]!="0" then
			calling_ply:SendLua("GAMEMODE:AddNotify(\"Enabling Buildmode in "..tonumber(_Kyle_Buildmode["builddelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
			calling_ply:SetNWBool("kylependingbuildchange", true)
			timer.Simple(tonumber(_Kyle_Buildmode["builddelay"]), function() 
					_kyle_Buildmode_Enable(z) 
					calling_ply:SetNWBool("kylependingbuildchange", false)
				end)
		else
			_kyle_Buildmode_Enable(calling_ply)
			ulx.fancyLogAdmin(calling_ply, "#A entered Buildmode")
		end
	elseif calling_ply.buildmode and should_revoke and not calling_ply:GetNWBool("kylependingbuildchange") then
		if _Kyle_Buildmode["pvpdelay"]!="0" then
			calling_ply:SendLua("GAMEMODE:AddNotify(\"Disabling Buildmode in "..tonumber(_Kyle_Buildmode["pvpdelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
				calling_ply:SetNWBool("kylependingbuildchange", true)
				timer.Simple(tonumber(_Kyle_Buildmode["pvpdelay"]), function()
				_kyle_Buildmode_Disable(calling_ply)
				calling_ply:SetNWBool("kylependingbuildchange", false)
					end)
		else
			_kyle_Buildmode_Disable(calling_ply)
			ulx.fancyLogAdmin(calling_ply, "#A exited Buildmode")
		end
	end
end, "!build")
kylebuildmode:defaultAccess(ULib.ACCESS_ALL)
kylebuildmode:addParam{type=ULib.cmds.BoolArg, invisible=true}
kylebuildmode:help("Grants Buildmode to self.")
kylebuildmode:setOpposite("ulx pvp", {_, true}, "!pvp")

local kylebuildmodeadmin = ulx.command("_Kyle_1", "ulx fbuild", function( calling_ply, target_plys, should_revoke)
	local affected_plys = {}
	for y,z in pairs(target_plys) do
		if calling_ply == z and _Kyle_Buildmode["persistpvp"]=="1" then
			z:SetNWBool("_Kyle_pvpoverride", not should_revoke)
		end
        if not z.buildmode and not should_revoke and not z:GetNWBool("kylependingbuildchange") then
			_kyle_Buildmode_Enable(z)
        elseif z.buildmode and should_revoke and not z:GetNWBool("kylependingbuildchange") then
			_kyle_Buildmode_Disable(z)
        end
        table.insert(affected_plys, z)
	end

	if should_revoke then
		ulx.fancyLogAdmin(calling_ply, "#A revoked Buildmode from #T", affected_plys)
	else
		ulx.fancyLogAdmin(calling_ply, "#A granted Buildmode upon #T", affected_plys)
	end
end, "!fbuild" )
kylebuildmodeadmin:addParam{type=ULib.cmds.PlayersArg}
kylebuildmodeadmin:defaultAccess(ULib.ACCESS_OPERATOR)
kylebuildmodeadmin:addParam{type=ULib.cmds.BoolArg, invisible=true}
kylebuildmodeadmin:help("Forces Buildmode on target(s).")
kylebuildmodeadmin:setOpposite("ulx fpvp", {_, _, true}, "!fpvp")