-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Color, effect names and menu code changes by Matsilagi

if CLIENT then
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
		--["custom"]			= "Custom",
		["none"]			= " [ Disable Sheen ] ", -- this one doesn't have entry in the colors file, thus it won't render at all.
	}

	local EffectsList = {
		[0]		   = " [ Disable Effect ] ",
		"Fire Horns",
		"Cerebral Discharge",
		"Tornado",
		"Flames",
		"Singularity",
		"Incinerator",
		"Hypno-Beam",
		"Blush",
		"Embers",
		"Petals",
		"Waterfalls"
	}

	--PANEL CONTENTS
	local function sheenControlCL(panel)
		panel:ToolPresets("tfks_color", {
			cl_killstreak_color = "team_red",
			cl_killstreak_effect = "1",
			cl_killstreak_offset_l_right = "-1.5",
			cl_killstreak_offset_l_up = "0.0",
			cl_killstreak_offset_l_forward = "1.0",
			cl_killstreak_offset_r_right = "1.5",
			cl_killstreak_offset_r_up = "0.0",
			cl_killstreak_offset_r_forward = "1.0",
			cl_killstreak_eyepatch = "0",
		})

		local colorSelectCombo = {
			Options = {},
			CVars = {},
			Label = "Color",
			MenuButton = "0",
			Folder = "Killstreak Colors"
		}
		for k,v in pairs(colors) do
			language.Add("kssheen.color." .. k, v)
			colorSelectCombo.Options["#kssheen.color." .. k] = {
				["cl_killstreak_color"] = k
			}
			colorSelectCombo.CVars["#kssheen.color." .. k] = {
				["cl_killstreak_color"] = k
			}
		end
		panel:AddControl("ComboBox", colorSelectCombo)

		local effectSelectCombo = {
			Options = {},
			CVars = {},
			Label = "Effect",
			MenuButton = "0",
			Folder = "Killstreak Effects"
		}
		for i,j in pairs(EffectsList) do
			language.Add("kssheen.effect." .. i, j)
			effectSelectCombo.Options["#kssheen.effect." .. i] = {
				["cl_killstreak_effect"] = i
			}
			effectSelectCombo.CVars["#kssheen.effect." .. i] = {
				["cl_killstreak_effect"] = i
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
			Command = "cl_killstreak_eyepatch"
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
			Label = "HUD Killstreak Counter",
			Command = "cl_killstreak_hud"
		})

		panel:AddControl("Label", {Text = ""}) -- spacer

		panel:AddControl("CheckBox", {
			Label = "Texture Compatibility Mode",
			Command = "cl_killstreak_oldmat"
		})

		panel:AddControl("Label", {
			Text = "Enable this if sheen is not working for you."
		})

		panel:AddControl("Label", {Text = ""}) -- spacer

		panel:AddControl("CheckBox", {
			Label = "Eye Position Debug",
			Command = "cl_killstreak_eyeparticle_debug"
		})

		panel:AddControl("Label", {
			Text = "Enable this to position one (or both) eyes."
		})
	end

	hook.Add("PopulateToolMenu", "killstreak_sheen_client_menu", function()
		spawnmenu.AddToolMenuOption("Utilities", "TF2 Killstreak", "sheenControlCL", "Client Settings", "", "", sheenControlCL)
	end)
	
	local function sheenControlSV(panel)
		panel:NumSlider( "Minimum Kills (Eyes)", "sv_killstreakeyes_minkills", 1, 20, 0 )

		panel:AddControl("Label", {
			Text = "Kills required to get the Level 1 eye glow effect."
		})

		panel:AddControl("Label", {Text = ""}) -- spacer

		panel:NumSlider( "Maximum Kills (Eyes)", "sv_killstreakeyes_maxkills", 1, 20, 0 )

		panel:AddControl("Label", {
			Text = "Kills required to get the Level 2 eye glow effect."
		})
	end
	
	hook.Add("PopulateToolMenu", "killstreak_sheen_server_menu", function()
		spawnmenu.AddToolMenuOption("Utilities", "TF2 Killstreak", "sheenControlSV", "Server Settings", "", "", sheenControlSV)
	end)
end