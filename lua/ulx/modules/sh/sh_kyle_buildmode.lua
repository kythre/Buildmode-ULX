local function entitydata(z) 
	print("Me", z)
	print("Owner", z:GetOwner())
	print("Class", z:GetClass())
	print("Model", z:GetModel())
	print("Name", z:GetName())
	print("MoveParent", z:GetMoveParent())
	print("Creator", z:GetCreator())
	print("Parent", z:GetParent())
	print("RagdollOwner", z:GetRagdollOwner())
	print("Children")
	print("PhysicsObject", z:GetPhysicsObject())
	PrintTable(z:GetChildren())
	print("Table")
	PrintTable(z:GetTable())
	print("GetAttachments")
	PrintTable(z:GetAttachments())
	print()
end

local function _kyle_Prop_TryUnNoclip(z)	
	timer.Simple(0.5, function() 	
		--Exit if the prop stops existing or isnt noclipped or has already attempted unnoclipping for too long
		if not (z:IsValid() and z.buildnoclipped and z:GetNWInt("_kyle_unnoclip_attempt", 0) < 100) then 
			z:SetNWInt("_kyle_unnoclip_attempt", 0)
			return 
		end
		z:SetNWInt("_kyle_unnoclip_attempt", z:GetNWInt("_kyle_unnoclip_attempt", 0)+1)
		
		local d = false
		local reason = ""
		
		if z:IsVehicle() and z:GetDriver().buildmode then
			d = true 
			reason = reason .. " driver in buildmode;"
		end
		
		if z:GetVelocity():Length() > 2 then
			d = true
			reason = reason .. " entity velocity too high: ".. z:GetVelocity():Length() ..";"
		end

		if z:GetNWBool("Physgunned") then
			d = true
			reason = reason .. " entity physgunned;" 
		end
		
		if z:GetParent():GetNWBool("Physgunned") then
			d =true
			reason = reason .. " entity parent physgunned;" 
		end
		
		if IsValid(z.buildparent) and z.buildparent.buildnoclipped then 
			d = true
			reason = reason .. " buildparent noclipped;"
		end
		
		if IsValid(z.SCarOwner) and z.SCarOwner:GetNWBool("Physgunned") then 
			d = true
			reason = reason .. " scar owner physgunned;"
		end

		if false then
			d = d or z:IsVehicle() and z:GetDriver().buildmode
			d = d or z:GetVelocity():Length() > 1
			d = d or z:GetNWBool("Physgunned") 
			d = d or z:GetParent():GetNWBool("Physgunned")
			d = d or IsValid(z.buildparent) and z.buildparent.buildnoclipped
			d = d or IsValid(z.SCarOwner) and z.SCarOwner:GetNWBool("Physgunned") 
		end
		
		--enttiy interference 
		if not d then
			--Check to see if there is anything inside the props bounds
			local a,b = z:GetCollisionBounds()
			local c = ents.FindInBox(z:LocalToWorld(a), z:LocalToWorld(b))
			for aa,ab in pairs(c) do
				--if e then ignore this blocking entity
				local e = false
			
				if not ab:IsSolid() then 
					e = true
				end
			
				if z == ab	then
					e = true
				end
				
				if z == ab:GetOwner() then 
					e = true
				end
				
				if z == ab:GetParent() then 
					e = true
				end
				
				if z:GetParent() == ab then
					e = true
				end
				
				if z:IsVehicle() and ab == z:GetDriver() then
					e = true
				end
				
				if ab:GetClass() == "wac_hitdetector" then 
					e = true 
				end
				
				if ab:IsWeapon() then 
					e = true 
				end
			
				if z.Founder and z.Founder == ab.Founder then
					e = true
				end
				
				if CPPI then
					if z:CPPIGetOwner() == ab:CPPIGetOwner() and ab:GetClass() == "prop_physics" then
						e = true
					end
					
					if z:CPPIGetOwner() and z:CPPIGetOwner() == ab.Founder then
						e = true
					end
				else 
					if z.buildOwner == ab.buildOwner and ab:GetClass() == "prop_physics" then
						e = true
					end
					
					if z.buildOwner and z.buildOwner == ab.Founder then
						e = true
					end
				end
				
				--simfphys support
				if simfphys then
					--if we are a wheel of a the simfphys car that is blocking us
					if simfphys.IsCar(ab) and table.HasValue(ab.Wheels, z) then 
						e = true
					end
					
					--if we are a prop that is owned by a simfphys car
					if simfphys.IsCar(ab:GetOwner()) then
						e = true
					end
					
					--if we are a simfphys car and the blocking entity is the driver
					if simfphys.IsCar(z) and ab == z:GetDriver()then 
						e = true
					end  
			
					--if we are a simfphys car wheel and the blocking entity is a part of our car
					--if the blocking entity's parent is a simfphys car and we are a wheel from that car
					if simfphys.IsCar(ab:GetParent()) and table.HasValue(ab:GetParent().Wheels, z) then 
						e = true
					end
				end
				
				--SCars Support
				--check to see if we are the parent of the blocking prop
				if 	z == ab:GetParent().SCarOwner then
					e = true
				end
					
				--check to see if the we have any constraints on the blocking entity
				--check e to avoid any unnecessary overhead
				if not e and z.Constraints then
					for aa in pairs(z.Constraints) do
						if IsValid(z.Constraints[aa]) and z.Constraints[aa]:IsConstraint() then 
							local a, b = z.Constraints[aa]:GetConstrainedEntities()
							if ab == a or ab == b then
								e = true
								break
							end
						end
					end
				end
				
				if not e then
					d = true
					-- if ab:IsScripted() 					then d = true end
					-- if ab:IsPlayer()				 	then d = true end
					-- if ab:IsVehicle() 					then d = true end
					-- if ab:GetClass() == "prop_physics" then d = true end
				end
				
				if d then 
					reason = reason .. " entity interference;"
					--print()
					--print(z:GetNWInt("_kyle_unnoclip_attempt", 0))
					--entitydata(ab)
					--print(scar)
					--print(z:GetTable()["pSeat"][1])
					--PrintTable(ab:GetTable())
					--print(z:GetTable()["Wheels"][1]:GetModel())
					break
				end
			end	
		end
		
		--finally un noclip or try again
		if not d then
			--Recall the old attributes
			z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], z:GetNWInt("Alpha")))
			z:SetRenderMode(z:GetNWInt("RenderMode")) 
			z:SetCollisionGroup(z:GetNWInt("CollisionGroup"))
			z.buildnoclipped = false
			z.buildparent = nil
			z:SetNWInt("_kyle_unnoclip_attempt", 0)

		else
			print(z, reason)
			--entitydata(z)
			--if it fails, try again
			_kyle_Prop_TryUnNoclip(z)
		end
	end )
end

local function _kyle_Prop_Noclip_Sub(z)
	if not IsEntity(z) or z.buildnoclipped then return end
		
	--Store the old attributes (to be recalled later)
	z:SetNWInt("RenderMode", z:GetRenderMode())
	z:SetNWInt("Alpha", z:GetColor()["a"])
	z:SetNWInt("CollisionGroup", z:GetCollisionGroup())			
	
	--Set the new attributes
	z:SetCollisionGroup(COLLISION_GROUP_WORLD)
	z:SetRenderMode(1)
	z:SetColor(Color(z:GetColor()["r"], z:GetColor()["g"], z:GetColor()["b"], 200))
	z.buildnoclipped = true
	z:SetNWInt("_kyle_unnoclip_attempt", 0)
	
	--Try to un noclip asap if its not a vehicle being driven by a builder
	_kyle_Prop_TryUnNoclip(z)
end

local function _kyle_Prop_Noclip(z)
	if (not IsEntity(z)) or z.buildnoclipped then return end
	
	_kyle_Prop_Noclip_Sub(z)

	--noclip constrained props
	if z.Constraints then 	
		for aa, ab in pairs(z.Constraints) do
			if IsValid(ab) then
				local a, b = ab:GetConstrainedEntities()	
				local c
				
				--if the consraint isnt just an entity to itself
				--set c to the entity that isnt z
				if a ~= b then
					c = z==a and b or a
				end				
				
				if IsValid(z.buildparent) then
					print(z, z.buildparent, c)
				end
				
				--if we found a valid entity constrained to z
				if c and (not c:GetNWBool("Physgunned")) and (not IsValid(c.buildparent)) and not (z.buildparent == c)  then
					c.buildparent = z
					_kyle_Prop_Noclip(c) 
				end
			end
		end	
	else 
		--simfphys
		if simfphys and z:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then
			local a

			--run through all the constraints to find the car
			for aa in pairs(z.Constraints) do
				local b, c = z.Constraints[aa]:GetConstrainedEntities()
				if b ~= nil and simfphys.IsCar(b) then a = b break end
			end
			
			--noclip the car
			_kyle_Prop_Noclip_Sub(a)

			--noclip all the wheels
			for aa,ab in pairs(a.Wheels) do
				_kyle_Prop_Noclip_Sub(ab)
			end	
		end	
		
		if IsValid(z:GetParent()) then
			_kyle_Prop_Noclip(z:GetParent())
		end
	end
	
	if false then 
		--wac
		if wac then
			for aa, ab in pairs(z:GetTable()) do
				if string.match(aa, "Rotor") then
					if isentity(ab) then
						_kyle_Prop_Noclip_Sub(ab)
					end
				end
			end	
		end
	
		--SCars (scar is entowner for scar seats)
		if IsValid(z.EntOwner) then
			_kyle_Prop_Noclip(z.EntOwner)
		end	
		
		--SCars (scars wheels are placed in wheels table of scar)
		if z.Wheels then 
			for aa,ab in pairs(z.Wheels) do
				ab.buildparent = z
				_kyle_Prop_Noclip_Sub(ab)
			end
		end
	end
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
			_kyle_Prop_Noclip(z:GetVehicle())
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
			_kyle_Prop_TryUnNoclip(z:GetVehicle())
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

local function _kyle_builder_spawn_weapon(y, z)
	local restrictweapons = _Kyle_Buildmode["restrictweapons"]=="1" and y.buildmode

	if restrictweapons then 
		local restrictionmet = (_Kyle_Buildmode["weaponlistmode"]=="0") == table.HasValue(_Kyle_Buildmode["buildloadout"], z)
		local adminbypass = y:IsAdmin() and _Kyle_Buildmode["adminsbypassrestrictions"]=="1"
		return restrictionmet or adminbypass
	else
		return true
	end
end

local function _kyle_builder_spawn_entity(y, z)
	local restrictsents = _Kyle_Buildmode["restrictsents"]=="1" and y.buildmode
	
	if restrictsents then 
		local restrictionmet = (_Kyle_Buildmode["entitylistmode"]=="0") == table.HasValue(_Kyle_Buildmode["builderentitylist"], z)
		local adminbypass = y:IsAdmin() and _Kyle_Buildmode["adminsbypassrestrictions"]=="1"
		return restrictionmet or adminbypass
	else
		return true
	end 
end

hook.Add("PlayerSpawnedProp", "KylebuildmodePropKill", function(x, y, z)
	if not CPPI then 
		z.buildOwner = x
	end

	if x.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		_kyle_Prop_Noclip(z)
	end
	
	if not x.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then
		_kyle_Prop_Noclip(z)
	end
end)

hook.Add("PlayerSpawnedSENT", "KylebuildmodePropKillSENT", function(y, z)
	if not CPPI then 
		z.buildOwner = y
	end

	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		_kyle_Prop_Noclip(z)
	end
	
	if not y.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then
		_kyle_Prop_Noclip(z)
	end
end)

hook.Add("PlayerSpawnedVehicle", "KylebuildmodePropKill", function(y, z)
	if not CPPI then 
		z.buildOwner = x
	end
	
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		_kyle_Prop_Noclip(z)
	end
	
	if not y.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then
		_kyle_Prop_Noclip(z)
	end
end)

hook.Add("PlayerEnteredVehicle", "KylebuildmodePropKill", function(y, z)
	if y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then
		_kyle_Prop_Noclip(z)
	end
	
	if not y.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then
	--	_kyle_Prop_Noclip(z)
	end
end)

hook.Add("PlayerLeaveVehicle", "KylebuildmodePropKill", function(y, z)
	_kyle_Prop_TryUnNoclip(z)
end)

hook.Add("PhysgunPickup", "KylebuildmodePropKill", function(y, z)
	if not SERVER then return end
	
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", true)
		_kyle_Prop_Noclip(z)
	end
	
	if IsValid(z) and not z:IsPlayer() and not y.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then 
		z:SetNWBool("Physgunned", true)
		_kyle_Prop_Noclip(z)
	end
	
	--entitydata(z) 
end, HOOK_MONITOR_LOW )

hook.Add("PhysgunDrop", "KylebuildmodePropKill", function(y, z)
	if not SERVER then return end
	
	if IsValid(z) and (not z:IsPlayer()) and y.buildmode and _Kyle_Buildmode["antipropkill"]=="1" then 
		z:SetNWBool("Physgunned", false)
		
		--Kill the prop's velocity so it can not be thrown
		z:SetPos(z:GetPos())
	end
	
	if IsValid(z) and (not z:IsPlayer()) and not y.buildmode and _Kyle_Buildmode["antipropkillpvper"]=="1" then
		z:SetNWBool("Physgunned", false)
		
		--Kill the prop's velocity so it can not be thrown
		z:SetPos(z:GetPos())
	end
	
	if IsValid(z) and (not z:IsPlayer()) and z.buildnoclipped then	
		_kyle_Prop_TryUnNoclip(z)
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
	
	if z.buildmode == nil then z.buildmode = false end
end )

hook.Add("PlayerInitialSpawn", "kyleBuildmodePlayerInitilaSpawn", function (z) 
	z:SetNWBool("_kyle_died", true)
	z:SetNWBool("_Kyle_pvpoverride", false)
end )

hook.Add("PostPlayerDeath", "kyleBuildmodePostPlayerDeath",  function(z)
	z:SetNWBool("_kyle_died", true)
end, HOOK_HIGH )

hook.Add("PlayerGiveSWEP", "kylebuildmoderestrictswep", function(y, z)
    if not _kyle_builder_spawn_weapon(y, z) then
       	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot give yourself this weapon while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerSpawnSWEP", "kylebuildmoderestrictswep", function(y, z)
	if not _kyle_builder_spawn_weapon(y, z) then
        --some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn this weapon while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerCanPickupWeapon", "kylebuildmoderestrictswep", function(y, z)
    if not _kyle_builder_spawn_weapon(y, string.Split(string.Split(tostring(z),"][", true)[2],"]", true)[1]) then
		return false   
    end
end)

hook.Add("PlayerSpawnSENT", "kylebuildmoderestrictsent", function(y, z)
    if not _kyle_builder_spawn_entity(y, z) then
       	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn this SENT while in Buildmode.\",NOTIFY_GENERIC, 5)")
		return false
    end
end)

hook.Add("PlayerSpawnProp", "kylebuildmoderestrictpropspawn", function(y, z)
	if _Kyle_Buildmode["pvppropspawn"]=="0" and not y.buildmode and not y:IsAdmin() then
    	--some say that sendlua is lazy and wrong but idc
		y:SendLua("GAMEMODE:AddNotify(\"You cannot spawn props while in PVP.\",NOTIFY_GENERIC, 5)")
		return false
	end
end)

hook.Add("OnEntityCreated", "kylebuildmodeentitycreated", function(z)
	if z:GetClass() == "prop_combine_ball" then
		z:SetCustomCollisionCheck( true )
	end
end)

hook.Add("ShouldCollide", "kylebuildmodeShouldCollide", function(y, z)
	if y:GetClass() == "prop_combine_ball" and z:IsPlayer() then
		if y:GetOwner().buildmode or z.buildmode then 
			return false
		end
	end
end)

hook.Add("EntityTakeDamage", "kyleBuildmodeTryTakeDamage", function(y, z)
	if y.buildmode then return true end
	if y.buildnoclipped then return true end
	
	if IsValid(z:GetAttacker()) then
		if z:GetAttacker():IsPlayer() and z:GetAttacker().buildmode then 
			return true
		end

		if z:GetAttacker().Owner and z:GetAttacker().Owner.buildmode then 
			return true
		end
		
		if simfphys and simfphys.IsCar(z:GetAttacker()) and z:GetAttacker():GetDriver().buildmode or z:GetAttacker().buildnoclipped then
			return true
		end
		
		if z:GetAttacker().buildnoclipped then
			return true
		end
	end
	
	if IsValid(z:GetInflictor()) then
		if z:GetInflictor().Owner and z:GetInflictor().Owner.buildmode then 
			return true
		end
	end
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
			y=y+ScrH()*0.07414
		
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
			
			draw.TextShadow( {text=mode.."er", font="TargetID", pos={x,y}, xalign=TEXT_ALIGN_CENTER, yalign=TEXT_ALIGN_CENTER, color=team.GetColor(z:Team())}, 1 )
		end
	end
end)

local kylebuildmode = ulx.command( "_Kyle_1", "ulx build", function( calling_ply, should_revoke )
	if _Kyle_Buildmode["persistpvp"]=="1" then
		calling_ply:SetNWBool("_Kyle_pvpoverride", not should_revoke)
	end
	if not calling_ply.buildmode and not should_revoke and not calling_ply:GetNWBool("kylependingbuildchange") then
		if _Kyle_Buildmode["builddelay"]!="0" then
			local delay = tonumber(_Kyle_Buildmode["builddelay"])
			calling_ply:SendLua("GAMEMODE:AddNotify(\"Enabling Buildmode in "..delay.." seconds.\",NOTIFY_GENERIC, 5)")
			calling_ply:SetNWBool("kylependingbuildchange", true)
			ulx.fancyLogAdmin(calling_ply, "#A entering Buildmode in "..delay.." seconds.")
			timer.Simple(delay, function() 
					_kyle_Buildmode_Enable(calling_ply) 
					calling_ply:SetNWBool("kylependingbuildchange", false)
					ulx.fancyLogAdmin(calling_ply, "#A entered Buildmode")
			end)
		else
			_kyle_Buildmode_Enable(calling_ply)
			ulx.fancyLogAdmin(calling_ply, "#A entered Buildmode")
		end
	elseif calling_ply.buildmode and should_revoke and not calling_ply:GetNWBool("kylependingbuildchange") then
		if _Kyle_Buildmode["pvpdelay"]!="0" then
			local delay = tonumber(_Kyle_Buildmode["pvpdelay"])
			calling_ply:SendLua("GAMEMODE:AddNotify(\"Disabling Buildmode in "..delay.." seconds.\",NOTIFY_GENERIC, 5)")
			ulx.fancyLogAdmin(calling_ply, "#A exiting Buildmode in "..delay.." seconds.")
			calling_ply:SetNWBool("kylependingbuildchange", true)
			timer.Simple(delay, function()
				_kyle_Buildmode_Disable(calling_ply)
				calling_ply:SetNWBool("kylependingbuildchange", false)
				ulx.fancyLogAdmin(calling_ply, "#A exited Buildmode")
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
        if not z.buildmode and not should_revoke then
			_kyle_Buildmode_Enable(z)
        elseif z.buildmode and should_revoke then
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