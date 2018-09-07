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