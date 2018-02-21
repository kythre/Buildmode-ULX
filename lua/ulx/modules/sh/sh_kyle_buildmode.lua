local function _kyle_Buildmode_Enable(z)
    z:SendLua("GAMEMODE:AddNotify(\"Buildmode enabled. Type !pvp to disable\",NOTIFY_GENERIC, 5)")
	if z:Alive() then
		ULib.getSpawnInfo( z )
		if _Kyle_Buildmode["restrictweapons"]=="1" then
			z:StripWeapons()
			for x,y in pairs(_Kyle_Buildmode["buildloadout"]) do 
				z:Give(y)
			end
		end
	end
	z.buildmode = true
	z:SetNWBool("_Kyle_Buildmode",true)
	z:SetNWBool("_Kyle_BuildmodeOnSpawn", z:GetNWBool("_kyle_died"))
end

local function _kyle_Buildmode_Disable(z)
	if z:Alive() then
		local pos = z:GetPos()
		
		if _Kyle_Buildmode["killonpvp"]=="1" and z:InVehicle() then
			z:ExitVehicle()
		end
		
		if _Kyle_Buildmode["restrictweapons"]=="1" and not z:GetNWBool("_Kyle_BuildmodeOnSpawn") then
			ULib.spawn( z, true ) --Returns the player to spawn with the weapons they had before entering buildmode
		end
		
		if _Kyle_Buildmode["killonpvp"]=="1" then
			ULib.spawn( z, false)  --Returns the player to spawn
		end
		
		if _Kyle_Buildmode["restrictweapons"]=="1" and z:GetNWBool("_Kyle_BuildmodeOnSpawn") then
			z:ConCommand("kylebuildmode defaultloadout") --called when buildmode is disabled after spawning with it enabled
		end
		
		if _Kyle_Buildmode["killonpvp"]=="0" then
			z:SetPos( pos ) --Returns the player to where they where when they disabled buildmode
		end
		
		if 	z:GetNWBool("kylenocliped") then
			z:ConCommand( "noclip" ) --called when the player had noclip while in buildmode
		end
	end
	
	z.buildmode = false
	z:SendLua("GAMEMODE:AddNotify(\"Buildmode disabled.\",NOTIFY_GENERIC, 5)")
	z:SetNWBool("_Kyle_Buildmode",false)
end

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
			if ab:IsPlayer() or ab:IsVehicle() and ab != z then
				d = true
			end
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

local function NoCollide(y, z)
	z = z or false

	--Exit if we are already un nocollided
	if y:GetNWBool("_kyle_nocollide") then return end

	--Store the old attributes (to be recalled later)
	y:SetNWInt("RenderMode", y:GetRenderMode())
	y:SetNWInt("Alpha", y:GetColor()["a"])
	y:SetNWInt("CollisionGroup", y:GetCollisionGroup())			
	
	--Set the new attributes
	y:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	y:SetRenderMode(1)
	y:SetColor(Color(y:GetColor()["r"], y:GetColor()["g"], y:GetColor()["b"], 200))
	y:SetNWInt("_kyle_nocollide", true)
	
	if z then return end
	
	--Try to un nocollide asap
	TryUnNoCollide(y)
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
		NoCollide(z, true)
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
end)

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
	if (_Kyle_Buildmode["spawnwithbuildmode"]=="1" or z:GetNWBool("_Kyle_Buildmode")) and z:GetNWBool("_kyle_died") then
		_kyle_Buildmode_Enable(z)
	end
	z:SetNWBool("_kyle_died", false)
end )

hook.Add("PlayerInitialSpawn", "kyleBuildmodePlayerInitilaSpawn", function (z) 
	if _Kyle_Buildmode["spawnwithbuildmode"]=="1" then
		_kyle_Buildmode_Enable(z)
	end
end )

hook.Add("PostPlayerDeath", "kyleBuildmodePostPlayerDeath",  function(z)
	z:SetNWBool("_kyle_died", true)
end )

hook.Add("PlayerGiveSWEP", "kyleBuildmodeTrySWEPGive", function(y, z)
     if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not table.HasValue(_Kyle_Buildmode["buildloadout"], z) then
        y:SendLua("GAMEMODE:AddNotify(\"You cannot give yourself weapons while in Buildmode.\",NOTIFY_GENERIC, 5)")
	  return false
    end
end)

hook.Add("PlayerSpawnSWEP", "kyleBuildmodeTrySWEPSpawn", function(y, z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not table.HasValue(_Kyle_Buildmode["buildloadout"], z) then
        y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn weapons while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("EntityTakeDamage", "kyleBuildmodeTryTakeDamage", function(y,z)
	return  y.buildmode or z:GetAttacker().buildmode
end)

hook.Add("PlayerCanPickupWeapon", "kyleBuildmodeTrySWEPPickup", function(y,z)
    if y.buildmode and _Kyle_Buildmode["restrictweapons"]=="1" and not table.HasValue(_Kyle_Buildmode["buildloadout"], string.Split(string.Split(tostring(z),"][", true)[2],"]", true)[1]) then
        if y:GetNWBool("_kyle_buildNotify")then
			y:SetNWBool("_kyle_buildNotify", true)
            y:SendLua("GAMEMODE:AddNotify(\"You cannot pick up weapons while in Build Mode.\",NOTIFY_GENERIC, 5)") 
            timer.Create( "_kyle_NotifyBuildmode", 5, 1, function()
                y:SetNWBool("_kyle_buildNotify", false)
            end)
	   end
	   return false   
    end
end)

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
        if not z.buildmode and not should_revoke then
			if _Kyle_Buildmode["builddelay"]!="0" then
				z:SendLua("GAMEMODE:AddNotify(\"Enabling Buildmode in "..tonumber(_Kyle_Buildmode["builddelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
				timer.Simple(tonumber(_Kyle_Buildmode["builddelay"]), function() _kyle_Buildmode_Enable(z) end)
			else
				_kyle_Buildmode_Enable(z)
			end
        elseif z.buildmode and should_revoke then
			if _Kyle_Buildmode["pvpdelay"]!="0" then
				z:SendLua("GAMEMODE:AddNotify(\"Disabling Buildmode in "..tonumber(_Kyle_Buildmode["pvpdelay"]).." seconds.\",NOTIFY_GENERIC, 5)")
					timer.Simple(tonumber(_Kyle_Buildmode["pvpdelay"]), function()	_kyle_Buildmode_Disable(z)
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