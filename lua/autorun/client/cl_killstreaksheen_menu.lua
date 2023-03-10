-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Color, effect names and menu code changes by Matsilagi

--CONVAR SETUP
local cv_color = GetConVar("cl_killstreak_color")
local cv_effect = GetConVar("cl_killstreak_effect")
local cv_matmode = GetConVar("cl_killstreak_oldmat")
local cv_streakhud = GetConVar("cl_killstreak_hud")
local cv_debugmodel = GetConVar("cl_killstreak_eyeparticle_debug")
local cv_singleye = GetConVar("cl_killstreak_eyepatch")
local cv_offset_leye_right = GetConVar("cl_killstreak_offset_l_right")
local cv_offset_leye_up = GetConVar("cl_killstreak_offset_l_up")
local cv_offset_leye_forward = GetConVar("cl_killstreak_offset_l_forward")
local cv_offset_reye_right = GetConVar("cl_killstreak_offset_r_right")
local cv_offset_reye_up = GetConVar("cl_killstreak_offset_r_up")
local cv_offset_reye_forward = GetConVar("cl_killstreak_offset_r_forward")

--OPTIONS TABLES
local colors = {
	["team_red"]		= "Team Shine RED",
	["team_blue"]		= "Team Shine BLU",
	["yellow"]			= "Deadly Daffodil",
	["orange"]			= "Manndarin",
	["green"]			= "Mean Green",
	["ltgreen"]			= "Agonizing Emerald",
	["violet"]			= "Villainous Violet",
	["pink"]			= "Hot Rod",
	["none"]			= " [ Disable Sheen ] ", -- this one doesn't have entry in the colors file, thus it won't render at all.
}

local effects = {
	["killstreak_t1_"] = "Fire Horns",
	["killstreak_t2_"] = "Cerebral Discharge",
	["killstreak_t3_"] = "Tornado",
	["killstreak_t4_"] = "Flames",
	["killstreak_t5_"] = "Singularity",
	["killstreak_t6_"] = "Incinerator",
	["killstreak_t7_"] = "Hypno-Beam",
	["none"]		   = " [ Disable Effect ] ",
}

--PANEL CONTENTS
local function sheenControl(panel)
	local colorSelectCombo = {
		Options = {},
		CVars = {},
		Label = "Killstreaker/Sheen Color",
		MenuButton = "0",
		Folder = "Killstreak Colors"
	}
	for k,v in pairs(colors) do
		language.Add("kssheen.color." .. k, v)
		colorSelectCombo.Options["#kssheen.color." .. k] = {
			[cv_color:GetName()] = k
		}
		colorSelectCombo.CVars["#kssheen.color." .. k] = {
			[cv_color:GetName()] = k
		}
	end
	panel:AddControl("ComboBox", colorSelectCombo)
	
	local effectSelectCombo = {
		Options = {},
		CVars = {},
		Label = "Killstreaker",
		MenuButton = "0",
		Folder = "Killstreak Effects"
	}
	for i,j in pairs(effects) do
		language.Add("kssheen.effect." .. i, j)
		effectSelectCombo.Options["#kssheen.effect." .. i] = {
			[cv_effect:GetName()] = i
		}
		effectSelectCombo.CVars["#kssheen.effect." .. i] = {
			[cv_effect:GetName()] = i
		}
	end
	panel:AddControl("ComboBox", effectSelectCombo)
	
	panel:NumSlider( "Offset L Right", "cl_killstreak_offset_l_right", -100.0, 100.0 )
	panel:NumSlider( "Offset L Up", "cl_killstreak_offset_l_up", -100.0, 100.0 )
	panel:NumSlider( "Offset L Forward", "cl_killstreak_offset_l_forward", -100.0, 100.0 )
	panel:NumSlider( "Offset R Right", "cl_killstreak_offset_r_right", -100.0, 100.0 )
	panel:NumSlider( "Offset R Up", "cl_killstreak_offset_r_up", -100.0, 100.0 )
	panel:NumSlider( "Offset R Forward", "cl_killstreak_offset_r_forward", -100.0, 100.0)
	
	panel:AddControl("CheckBox", {
		Label = "Disable Left Eye",
		Command = cv_singleye:GetName()
	})
	
	panel:AddControl("Label", {
		Text = "Disables the Left eye and centers the effect emission for use in single-eyed models.\n(Click 'Apply Killstreak Changes' after changing this to center the particles)"
	})
	
	panel:AddControl("Label", {Text = ""}) -- spacer

	panel:AddControl("Button", {
		Label = "Apply Killstreak Changes",
		Command = "killstreak_applycolor"
	})
	
	panel:AddControl("Label", {
		Text = "Particles will re-appear upon applying changes."
	})

	panel:AddControl("Label", {Text = ""}) -- spacer

	panel:AddControl("CheckBox", {
		Label = "HUD Streak Counter",
		Command = cv_streakhud:GetName()
	})

	panel:AddControl("Label", {Text = ""}) -- spacer

	panel:AddControl("CheckBox", {
		Label = "Texture Compatibility Mode",
		Command = cv_matmode:GetName()
	})

	panel:AddControl("Label", {
		Text = "Enable this if sheen is not working for you."
	})
	
	panel:AddControl("Label", {Text = ""}) -- spacer
	
	panel:AddControl("CheckBox", {
		Label = "Eye Position Debug",
		Command = cv_debugmodel:GetName()
	})
	
	panel:AddControl("Label", {
		Text = "Enable this to position one (or both) eyes."
	})
end

hook.Add("PopulateToolMenu", "killstreak_sheen_client_menu", function()
	spawnmenu.AddToolMenuOption("Utilities", "TF2 Killstreak", "sheenControl", "Client Settings", "", "", sheenControl)
end)