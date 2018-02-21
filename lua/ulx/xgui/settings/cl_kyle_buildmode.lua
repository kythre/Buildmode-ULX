_Kyle_Buildmode = _Kyle_Buildmode or {}
xgui.prepareDataType( "_Kyle_Buildmode" )

local b = xlib.makepanel{ parent=xgui.null }
local ba = xlib.makecheckbox{ x=10, y=10, label="Limit weapons to Builder Loadout", parent=b, repconvar="rep_kylebuildmode_restrictweapons"}
local bb = xlib.makepanel{ x=420, y=10, w=150, h=165, parent=b}
local bba = xlib.makelistview{ x=0, y=0, w=150, h=140, parent=bb }
local bbb = xlib.makebutton{x=125, y=140, w=25, h=25,  parent=bb, label="+", disabled=true }
local bbc = xlib.maketextbox{x=0, y=140, w=125, h=25, parent=bb}
local bc = xlib.makecheckbox{ x=10, y=30, label="Respawn Player on Buildmode exit", parent=b, repconvar="rep_kylebuildmode_killonpvp"}
local bd = xlib.makecheckbox{ x=10, y=50, label="Players Spawn with Buildmode", parent=b, repconvar="rep_kylebuildmode_spawnwithbuildmode"}
local be = xlib.makelabel{ x=302, y=285, w=500, h=15, parent=b, label="For information, issues, and requests click here:" }
local bea = xlib.makebutton{x=300, y=300, w=240, h=15,  parent=b, label="https://github.com/kythre/Buildmode-ULX" }
local bf = xlib.makecheckbox{ x=10, y=70, label="Allow Noclip in Buildmode", parent=b, repconvar="rep_kylebuildmode_allownoclip"}
local bg = xlib.makecheckbox{ x=10, y=90, label="Prevent Propkill in Buildmode", parent=b, repconvar="rep_kylebuildmode_antipropkill", disabled=false}
local bg = xlib.makecheckbox{ x=10, y=110, label="Highlight Builders", parent=b, repconvar="rep_kylebuildmode_highlightbuilders"}
local bj = xlib.makecheckbox{ x=150, y=110, label="Highlight PVPers", parent=b, repconvar="rep_kylebuildmode_highlightpvpers"}
local bh = xlib.makepanel{ x=10, y=170, w=130, h=150, parent=b}
local bha = xlib.makelabel{ x=1, y=1, w=500, h=15, parent=bh, label="Builder Halo Color" }
local bhb = xlib.makecolorpicker{ x=1, y=15, parent=bh }
local bhc = xlib.makelabel{ x=10, y=150, w=500, h=15, parent=b}
local bi = xlib.makepanel{ x=150, y=170, w=130, h=150, parent=b}
local bia = xlib.makelabel{ x=1, y=1, w=500, h=15, parent=bi, label="PVPer Halo Color" }
local bib = xlib.makecolorpicker{ x=1, y=15, parent=bi }
local bj = xlib.makenumberwang {x=10, y=130, w=35, parent=b }
local bja = xlib.makelabel{ x=50, y=132, w=500, h=15, parent=b, label="Buildmode Delay" }
local bk = xlib.makenumberwang {x=150, y=130, w=35, parent=b }
local bka = xlib.makelabel{ x=190, y=132, w=500, h=15, parent=b, label="PVP Delay" }

bba:AddColumn( "Build Loadout" )

bba.OnRowSelected = function(z)
	bbb:SetText("-")
	bbb.a = false
	bbb:SetDisabled(false)
end

bbb.DoClick = function()
	if bbb.a then
		RunConsoleCommand( "kylebuildmode", "addweapon",  bbc:GetValue())
		bbc:SetValue("")
	else
		if bba:GetSelected()[1]:GetColumnText(1) then
			RunConsoleCommand("kylebuildmode", "removeweapon",  bba:GetSelected()[1]:GetColumnText(1))
		end
	end

	bbb:SetDisabled(true)
end

bbc.OnEnter = function()
	if bbc:GetValue() then
		RunConsoleCommand("kylebuildmode", "addweapon", bbc:GetValue())
		bbb:SetDisabled(true)
	end
end

bbc.OnChange = function()
	bbb:SetText("+")
	bbb.a = true
	
	if bbc:GetValue() then
		bbb:SetDisabled(false)
	else
		bbb:SetDisabled(true)
	end
end

 bj.OnValueChanged = function(y, z)
	if _Kyle_Buildmode["builddelay"] != z then
		RunConsoleCommand("kylebuildmode", "set", "builddelay", z)
	end
end

 bk.OnValueChanged = function(y, z)
	if _Kyle_Buildmode["pvpdelay"] != z then
		RunConsoleCommand("kylebuildmode", "set", "pvpdelay", z)
	end
end

bea.DoClick = function()
	gui.OpenURL( "https://github.com/kythre/Buildmode-ULX/")
end

function bhb:OnChange( z )
	z = {z["r"],z["g"],z["b"]}
	RunConsoleCommand("kylebuildmode", "set", "highlightbuilderscolor", string.sub(table.ToString(z), 2, string.len(table.ToString(z))-2))
end

function bib:OnChange( z )
	z = {z["r"],z["g"],z["b"]}
	RunConsoleCommand("kylebuildmode", "set", "highlightpvperscolor", string.sub(table.ToString(z), 2, string.len(table.ToString(z))-2))
end

net.Receive( "kylebuildmode_senddata", function()
	_Kyle_Buildmode = net.ReadTable()
	bba:Clear()
	for y,z in pairs(_Kyle_Buildmode["buildloadout"]) do
		bba:AddLine(z)
	end
	local z = string.Split( _Kyle_Buildmode["highlightbuilderscolor"],"," )
	bhb:SetColor( Color(z[1],z[2],z[3]))
	z = string.Split( _Kyle_Buildmode["highlightpvperscolor"],"," )
	bib:SetColor( Color(z[1],z[2],z[3]))
	bj:SetValue(_Kyle_Buildmode["builddelay"])
	bk:SetValue(_Kyle_Buildmode["pvpdelay"])
end )

xgui.addSettingModule( "Buildmode", b, "icon16/eye.png", "kylebuildmodesettings" )