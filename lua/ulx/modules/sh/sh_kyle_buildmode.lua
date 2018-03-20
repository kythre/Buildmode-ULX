local function TryUnNoCollide(z)	
	timer.Simple(0.1, function() 
		--Exit if the prop stops existing
		if not z:IsValid() then return end
		if not z:GetNWBool("_kyle_nocollide") then return end
		
		--Check to see if there is a player inside the prop
		local a,b = z:GetCollisionBounds()
		local c = ents.FindInBox(z:LocalToWorld(a), z:LocalToWorld(b))
		local d = false
		
		for aa,ab in pairs(c) do
			d = d or ab:IsPlayer() 
			d = d or ab:IsVehicle() 
			d = d or ab:GetClass() == "prop_physics"
			d = d and ab != z
		end		

		--If there isnt a player inside the prop, the prop is not being held by a physgun, and the prop is not moving, then un noclip
		if not d and not z:GetNWBool("Physgunned") and z:GetVelocity():Length() < 1 then
			--Recall the old attributes
			z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], z:GetNWInt("Alpha")))
			z:SetRenderMode(z:GetNWInt("RenderMode")) 
			z:SetCollisionGroup(z:GetNWInt("CollisionGroup"))
			z:SetNWInt("_kyle_nocollide", false)
		else
			TryUnNoCollide(z)
		end
	end )
end

local function NoCollide(z)
	--Exit if we are already un nocollided
	if z:GetNWBool("_kyle_nocollide") then return end

	--Store the old attributes (to be recalled later)
	z:SetNWInt("RenderMode", z:GetRenderMode())
	z:SetNWInt("Alpha", z:GetColor()["a"])
	z:SetNWInt("CollisionGroup", z:GetCollisionGroup())			
	
	--Set the new attributes
	z:SetCollisionGroup(COLLISION_GROUP_WORLD)
	z:SetRenderMode(1)
	z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], 200))
	z:SetNWInt("_kyle_nocollide", true)
	
	if z:IsVehicle() and z:GetDriver().buildmode then return end
	--Try to un nocollide asap
	TryUnNoCollide(z)
end

local function _kyle_Buildmode_Enable(z)
    z:SendLua("GAMEMODE:AddNotify(\"Buildmode enabled. Type !pvp to disable\",NOTIFY_GENERIC, 5)")

	if z:Alive() then
		ULib.getSpawnInfo(z)
		if _Kyle_Buildmode["restrictweapons"]=="1" then
			z:StripWeapons()
			for x,y in pairs(_Kyle_Buildmode["buildloadout"]) do 
				z:Give(y)
			end
		end
		
		if z:InVehicle() then
			NoCollide(z:GetVehicle())
		end
	end
	
	--having two buildmode variables seems redundant, however im too lazy to replace one with the other (if possible)
	z.buildmode = true
	z:SetNWBool("_Kyle_Buildmode", true)
	
	--boolean to say if buildmode was enabled because the player had just spawned
	z:SetNWBool("_Kyle_BuildmodeOnSpawn", z:GetNWBool("_kyle_died"))
end

local function _kyle_Buildmode_Disable(z)
	z:SetNWBool("_Kyle_Buildmode", false)
	z.buildmode = false
	z:SendLua("GAMEMODE:AddNotify(\"Buildmode disabled.\",NOTIFY_GENERIC, 5)")
	
	if z:Alive() then
		local pos = z:GetPos()
		
		if z:InVehicle() then
			TryUnNoCollide(z:GetVehicle())
			if _Kyle_Buildmode["returntospawn"]=="1" then
				--eject player from vehicle so they can be returned to spawn
				z:ExitVehicle()
			end
		end		
		
		if _Kyle_Buildmode["restrictweapons"]=="1" then
			--dont use spawn info that doesnt exist
			ULib.spawn( z, not z:GetNWBool("_Kyle_BuildmodeOnSpawn") ) 		
			--if there isnt any spawn info, use the default loadout
			if z:GetNWBool("_Kyle_BuildmodeOnSpawn") then z:ConCommand("kylebuildmode defaultloadout") end
		end
		
		--ULIB.spawn moves the player to spawn, this will return the player to where they where while in buildmode
		if _Kyle_Buildmode["returntospawn"]=="0" then
			z:SetPos(pos)
		end
	
		if 	z:GetNWBool("kylenocliped") then
			--called when the player had noclip while in buildmode
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
		NoCollide(z)
	end
end)

hook.Add("PlayerSpawnedVehicle", "KylebuildmodePropKill", function(y, z)
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		NoCollide(z)
	end
end)

hook.Add("PlayerEnteredVehicle", "KylebuildmodePropKill", function(y, z)
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		NoCollide(z)
	end
end)

hook.Add("PlayerLeaveVehicle", "KylebuildmodePropKill", function(y, z)
	TryUnNoCollide(z)
end)

hook.Add("PhysgunPickup", "KylebuildmodePropKill", function(y, z)
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", true)
		NoCollide(z)
	end
end, HOOK_MONITOR_LOW )

hook.Add("PhysgunDrop", "KylebuildmodePropKill", function(y, z)
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", false)
		
		--Kill the prop's momentum so it can not be thrown
		z:SetPos(z:GetPos())
	end
end)

hook.Add("PlayerNoClip", "KylebuildmodeNoclip", function(y, z)
	if _Kyle_Buildmode["allownoclip"]=="1" then
		y:SetNWBool("kylenocliped", z)
		return z == false or y.buildmode
	end
end )

hook.Add("PlayerSpawn", "kyleBuildmodePlayerSpawn",  function(z)
	--z:GetNWBool("_kyle_died") makes sure that the player is spawning after a death and not the ulib respawn
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
        y:SendLua("GAMEMODE:AddNotify(\"You cannot give yourself this weapon while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerSpawnSWEP", "kylebuildmoderestrictswep", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not _kyle_builder_spawn_weapon(z) then
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
        y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn this SENT while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("EntityTakeDamage", "kyleBuildmodeTryTakeDamage", function(y, z)
	return  y.buildmode or z:GetAttacker().buildmode
end, HOOK_HIGH)

hook.Add("PreDrawHalos", "KyleBuildmodehalos", function()
	if _Kyle_Buildmode["highlightbuilders"] then
		local w = {}
		local x = {}
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
		
		--add setting later for render mode
		z = string.Split( _Kyle_Buildmode["highlightbuilderscolor"],",")
		if _Kyle_Buildmode["highlightbuilders"]=="1" then halo.Add(w, Color(z[1],z[2],z[3]), 4, 4, 1, true) end
		
		z = string.Split( _Kyle_Buildmode["highlightpvperscolor"],",")		
		if _Kyle_Buildmode["highlightpvpers"]=="1" then halo.Add(x, Color(z[1],z[2],z[3]), 4, 4, 1, true) end
	else	
		LocalPlayer():ConCommand("kylebuildmode") 
	end
end)

local CATEGORY_NAME = "_Kyle_1"
local buildmode = ulx.command( "_Kyle_1", "ulx buildmode", function( calling_ply, target_plys, should_revoke )
    local affected_plys = {}
	for y,z in pairs(target_plys) do
		if calling_ply == z and _Kyle_Buildmode["persistpvp"]=="1" then
			z:SetNWBool("_Kyle_pvpoverride", not should_revoke)
		end
        if not z.buildmode and not should_revoke and not z:GetNWBool("kylependingbuildchange") then
			if _Kyle_Buildmode["builddelay"]!="0" then
				z:SendLua("GAMEMODE:AddNotify(\"Enabling Buildmode in "..tonumber(_Kyle_Buildmode["builddelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
				z:SetNWBool("kylependingbuildchange", true)
				timer.Simple(tonumber(_Kyle_Buildmode["builddelay"]), function() 
						_kyle_Buildmode_Enable(z) 
						z:SetNWBool("kylependingbuildchange", false)
					end)
			else
				_kyle_Buildmode_Enable(z)
			end
        elseif z.buildmode and should_revoke and not z:GetNWBool("kylependingbuildchange") then
			if _Kyle_Buildmode["pvpdelay"]!="0" then
				z:SendLua("GAMEMODE:AddNotify(\"Disabling Buildmode in "..tonumber(_Kyle_Buildmode["pvpdelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
					z:SetNWBool("kylependingbuildchange", true)
					timer.Simple(tonumber(_Kyle_Buildmode["pvpdelay"]), function()
					_kyle_Buildmode_Disable(z)
					z:SetNWBool("kylependingbuildchange", false)
						end)
			else
				_kyle_Buildmode_Disable(z)
			end
        end
        table.insert(affected_plys, z)
	end

	if should_revoke then
		ulx.fancyLogAdmin(calling_ply, "#A revoked Buildmode from #T", affected_plys)
	else
		ulx.fancyLogAdmin(calling_ply, "#A granted Buildmode upon #T", affected_plys)
	end
end, "!build" )
buildmode:addParam{type=ULib.cmds.PlayersArg, ULib.cmds.optional}
buildmode:defaultAccess(ULib.ACCESS_ALL)
buildmode:addParam{type=ULib.cmds.BoolArg, invisible=true}
buildmode:help("Grants Buildmode to target(s).")
buildmode:setOpposite("ulx pvp", {_, _, true}, "!pvp")