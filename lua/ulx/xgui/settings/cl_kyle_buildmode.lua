_Kyle_Buildmode = _Kyle_Buildmode or {}
xgui.prepareDataType( "_Kyle_Buildmode" )

local b = xlib.makepanel{ parent=xgui.null }

--"Entering Buildmdode" Panel
local panel_entering = xlib.makepanel{  x=160, y=5, w=425, h=322, parent=b}
local check_buildmodespawn = xlib.makecheckbox{ x=5, y=5, label="Players Spawn with Buildmode", parent=panel_entering, repconvar="rep_kylebuildmode_spawnwithbuildmode"}
local number_buildmodedelay = xlib.makenumberwang {x=5, y=25, w=35, parent=panel_entering }
local label_buildmodedelay = xlib.makelabel{ x=number_buildmodedelay.x+40, y=number_buildmodedelay.y+2, w=500, h=15, parent=panel_entering, label="Buildmode Delay" }
number_buildmodedelay.OnValueChanged = function(y, z)
	if _Kyle_Buildmode["builddelay"] != z then
		RunConsoleCommand("kylebuildmode", "set", "builddelay", z)
	end
end

--"While IN Buildmdode" Panel
local panel_whilein = xlib.makepanel{  x=160, y=5, w=425, h=322, parent=b}
local check_builderweaponlimit = xlib.makecheckbox{ x=5, y=5, label="Limit weapons to Builder Loadout", parent=panel_whilein, repconvar="rep_kylebuildmode_restrictweapons"}
local panel_builderweapon = xlib.makepanel{ x=5, y=170, w=130, h=150, parent=panel_whilein}
local list_builderweapons = xlib.makelistview{ x=0, y=0, w=130, h=125, parent=panel_builderweapon }
local button_addremoveweapon = xlib.makebutton{x=105, y=125, w=25, h=25,  parent=panel_builderweapon, label="+", disabled=true }
local text_weaponenter = xlib.maketextbox{x=0, y=125, w=105, h=25, parent=panel_builderweapon}
list_builderweapons:AddColumn( "Build Loadout" )
list_builderweapons.OnRowSelected = function()
	button_addremoveweapon:SetText("-")
	button_addremoveweapon.a = false
	button_addremoveweapon:SetDisabled(false)
end
button_addremoveweapon.DoClick = function()
	if button_addremoveweapon.a then
		RunConsoleCommand( "kylebuildmode", "addweapon",  text_weaponenter:GetValue())
		text_weaponenter:SetValue("")
	else
		if list_builderweapons:GetSelected()[1]:GetColumnText(1) then
			RunConsoleCommand("kylebuildmode", "removeweapon",  list_builderweapons:GetSelected()[1]:GetColumnText(1))
		end
	end

	button_addremoveweapon:SetDisabled(true)
end
text_weaponenter.OnEnter = function()
	if text_weaponenter:GetValue() then
		RunConsoleCommand("kylebuildmode", "addweapon", text_weaponenter:GetValue())
		button_addremoveweapon:SetDisabled(true)
	end
end
text_weaponenter.OnChange = function()
	button_addremoveweapon:SetText("+")
	button_addremoveweapon.a = true
	
	if text_weaponenter:GetValue() then
		button_addremoveweapon:SetDisabled(false)
	else
		button_addremoveweapon:SetDisabled(true)
	end
end
local check_allownoclip = xlib.makecheckbox{ x=5, y=25, label="Allow Noclip in Buildmode", parent=panel_whilein, repconvar="rep_kylebuildmode_allownoclip"}
local check_preventpropkill = xlib.makecheckbox{ x=5, y=45, label="Prevent Propkill in Buildmode", parent=panel_whilein, repconvar="rep_kylebuildmode_antipropkill", disabled=false}
local check_highlightbuilders = xlib.makecheckbox{ x=5, y=65, label="Highlight Builders", parent=panel_whilein, repconvar="rep_kylebuildmode_highlightbuilders"}
local check_highlightpvpers = xlib.makecheckbox{ x=5, y=85, label="Highlight PVPers", parent=panel_whilein, repconvar="rep_kylebuildmode_highlightpvpers"}
local panel_builderhalo = xlib.makepanel{ x=140, y=170, w=130, h=150, parent=panel_whilein}
local label_builderhalo = xlib.makelabel{ x=1, y=1, w=500, h=15, parent=panel_builderhalo, label="Builder Halo Color" }
local color_builderhalo = xlib.makecolorpicker{ x=1, y=15, parent=panel_builderhalo }
local panel_pvphalo = xlib.makepanel{ x=275, y=170, w=130, h=150, parent=panel_whilein}
local label_pvphalo = xlib.makelabel{ x=1, y=1, w=500, h=15, parent=panel_pvphalo, label="PVPer Halo Color" }
local color_pvphalo = xlib.makecolorpicker{ x=1, y=15, parent=panel_pvphalo }
function color_builderhalo:OnChange( z )
	z = {z["r"],z["g"],z["b"]}
	RunConsoleCommand("kylebuildmode", "set", "highlightbuilderscolor", string.sub(table.ToString(z), 2, string.len(table.ToString(z))-2))
end
function color_pvphalo:OnChange( z )
	z = {z["r"],z["g"],z["b"]}
	RunConsoleCommand("kylebuildmode", "set", "highlightpvperscolor", string.sub(table.ToString(z), 2, string.len(table.ToString(z))-2))
end

--"Exiting Buildmdode" Panel
local panel_exiting = xlib.makepanel{  x=160, y=5, w=425, h=322, parent=b}
local check_buildmoderespawn = xlib.makecheckbox{ x=5, y=5, label="Respawn Player on Buildmode exit", parent=panel_exiting, repconvar="rep_kylebuildmode_killonpvp"}
local number_pvpdelay = xlib.makenumberwang {x=5, y=25, w=35, parent=panel_exiting }
local label_pvpdelay = xlib.makelabel{ x=number_pvpdelay.x+40, y=number_pvpdelay.y+2, w=500, h=15, parent=panel_exiting, label="PVP Delay" }
number_pvpdelay.OnValueChanged = function(y, z)
	if _Kyle_Buildmode["pvpdelay"] != z then
		RunConsoleCommand("kylebuildmode", "set", "pvpdelay", z)
	end
end

panels = {}
panels[1] = panel_entering
panels[2] = panel_whilein
panels[3] = panel_exiting
panels[1]:SetVisible( false)
panels[2]:SetVisible( false)
panels[3]:SetVisible( false)

local list_categories = xlib.makelistview{ x=5, y=5, w=150, h=320, parent=b }
list_categories:AddColumn( "Categories" )
list_categories.Columns[1].DoClick = function() end
list_categories:AddLine("Entering Buildmode")
list_categories:AddLine("While In Buildmode")
list_categories:AddLine("Exiting Buildmode")
list_categories.OnRowSelected = function(self, LineID)
	panels[1]:SetVisible( false)
	panels[2]:SetVisible( false)
	panels[3]:SetVisible( false)
	panels[LineID]:SetVisible( true )
end

net.Receive( "kylebuildmode_senddata", function()
	_Kyle_Buildmode = net.ReadTable()
	list_builderweapons:Clear()
	for y,z in pairs(_Kyle_Buildmode["buildloadout"]) do
		list_builderweapons:AddLine(z)
	end
	local z = string.Split( _Kyle_Buildmode["highlightbuilderscolor"],"," )
	color_builderhalo:SetColor( Color(z[1],z[2],z[3]))
	z = string.Split( _Kyle_Buildmode["highlightpvperscolor"],"," )
	color_pvphalo:SetColor( Color(z[1],z[2],z[3]))
	number_buildmodedelay:SetValue(_Kyle_Buildmode["builddelay"])
	number_pvpdelay:SetValue(_Kyle_Buildmode["pvpdelay"])
end )
xgui.addSettingModule( "Buildmode", b, "icon16/eye.png", "kylebuildmodesettings" )



-- local be = xlib.makelabel{ x=302, y=285, w=500, h=15, parent=b, label="For information, issues, and requests click here:" }
-- local bea = xlib.makebutton{x=300, y=300, w=240, h=15,  parent=b, label="https://github.com/kythre/Buildmode-ULX" }
-- bea.DoClick = function()
	-- gui.OpenURL( "https://github.com/kythre/Buildmode-ULX/")
-- end