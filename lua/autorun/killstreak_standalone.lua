-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Additional code changes by Matsilagi

--HUD ELEMENTS / DRAWS
if CLIENT then
	--CONVARS CREATION
	CreateClientConVar("cl_killstreak_color", "team_red", true, true)
	CreateClientConVar("cl_killstreak_effect", "1",true, true)
	CreateClientConVar("cl_killstreak_eyeparticle_debug","0",true,false)
	CreateClientConVar("cl_killstreak_eyepatch","0",true,true)

	local cv_draw = CreateClientConVar("cl_killstreak_hud", "1", true, false)
	local cv_drawhud = GetConVar("cl_drawhud")

	local fontname, hudcolor

	local cv_forcetf2font = CreateClientConVar("cl_killstreak_forcetf2font", "0", true, false, "Enable only if you dont have TF2 mounted, but have its fonts installed.")

	local function updateFont()
		if IsMounted("tf") or cv_forcetf2font:GetBool() then -- no need for any edits now, mats 4HEad
			fontname = "TF2KillstreakHUD"
			hudcolor = Color(255, 255, 255)
			surface.CreateFont(fontname, {font = "TF2 Secondary", size = ScreenScale(14)})
		else
			fontname = "CloseCaption_Bold"
			hudcolor = Color(255, 255, 0)
		end
	end
	updateFont()

	cvars.AddChangeCallback("cl_killstreak_forcetf2font", updateFont, "cl_killstreak_forcetf2font")

	hook.Add("HUDPaint", "ffgs_utils_killstreak_draw", function()
		if not cv_drawhud:GetBool() or not cv_draw:GetBool() then return end

		local ply = LocalPlayer()
		if not ply:IsValid() or not ply:Alive() then return end

		local streak = ply:GetNW2Int("killstreak", 0)

		draw.SimpleTextOutlined(string.format("Streak: %s", streak), fontname, ScrW() - ScreenScale(16), ScrH() - ScreenScale(50), hudcolor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(63, 63, 0))
	end)

	return
end

--HOOKS
hook.Add("PlayerDeath", "ffgs_utils_killstreak_playerdeath", function(victim, inflictor, attacker)
	if not victim:IsValid() or not victim:IsPlayer() or not attacker:IsValid() or not attacker:IsPlayer() then return end

	victim:SetNW2String("killstreakcolor", nil)
	if victim == attacker then return end
	local atkstreak = attacker:GetNW2Int("killstreak", 0) + 1
	attacker:SetNW2Int("killstreak", atkstreak)
end)

hook.Add("OnNPCKilled", "ffgs_utils_killstreak_npcdeath", function(npc, attacker, inflictor)
	if not npc:IsValid() or not attacker:IsValid() or not attacker:IsPlayer() then return end

	local npcKills = attacker:GetNW2Int("npc_kills", 0) + 1
	attacker:SetNW2Int("npc_kills", npcKills)
	
	if npcKills % 20 == 0 then -- Only increment killstreak every 20 NPC/Nextbot kills
		local atkstreak = attacker:GetNW2Int("killstreak", 0) + 1
		attacker:SetNW2Int("killstreak", atkstreak)
	end
end)

hook.Add("PlayerSpawn", "ffgs_utils_killstreak_clear", function(ply)
	ply:SetNW2Int("killstreak", 0)
	ply:SetNW2Int("npc_kills", 0)

	if ply:IsBot() then return end
	ply:SetNW2String("killstreakcolor", ply:GetInfo("cl_killstreak_color"))
	ply:SetNW2Int("killstreakeffect", tonumber(ply:GetInfo("cl_killstreak_effect")) or 0)
	ply:SetNW2Bool("killstreak_single_eye", tobool(ply:GetInfo("cl_killstreak_eyepatch")))

	local offsetLX, offsetLY, offsetLZ = ply:GetInfo("cl_killstreak_offset_l_right"), ply:GetInfo("cl_killstreak_offset_l_forward", ply:GetInfo("cl_killstreak_offset_l_up"))
	local offsetRX, offsetRY, offsetRZ = ply:GetInfo("cl_killstreak_offset_r_right"), ply:GetInfo("cl_killstreak_offset_r_forward", ply:GetInfo("cl_killstreak_offset_r_up"))
	ply:SetNW2Vector("killstreak_eye_pos_l", Vector(offsetLX, offsetLY, offsetLZ))
	ply:SetNW2Vector("killstreak_eye_pos_r", Vector(offsetRX, offsetRY, offsetRZ))
end)

--APPLY CHANGES CONCOMMAND
concommand.Add("killstreak_applycolor", function(ply, cmd, args)
	if not ply or not ply:IsValid() then return end
	ply:SetNW2String("killstreakcolor", ply:GetInfo("cl_killstreak_color"))
	ply:SetNW2Int("killstreakeffect", tonumber(ply:GetInfo("cl_killstreak_effect")) or 0)
	ply:SetNW2Bool("killstreak_single_eye", tobool(ply:GetInfo("cl_killstreak_eyepatch")))

	local offsetLX, offsetLY, offsetLZ = ply:GetInfo("cl_killstreak_offset_l_right"), ply:GetInfo("cl_killstreak_offset_l_forward", ply:GetInfo("cl_killstreak_offset_l_up"))
	local offsetRX, offsetRY, offsetRZ = ply:GetInfo("cl_killstreak_offset_r_right"), ply:GetInfo("cl_killstreak_offset_r_forward", ply:GetInfo("cl_killstreak_offset_r_up"))
	ply:SetNW2Vector("killstreak_eye_pos_l", Vector(offsetLX, offsetLY, offsetLZ))
	ply:SetNW2Vector("killstreak_eye_pos_r", Vector(offsetRX, offsetRY, offsetRZ))
end)
