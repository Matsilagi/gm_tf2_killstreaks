-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Additional code changes by Matsilagi

local cv_color = CreateClientConVar("cl_killstreak_color", "team_red", true, true)
local cv_effect = CreateClientConVar("cl_killstreak_effect", "killstreak_t1_",true, true)
local cv_debugmodel = CreateClientConVar("cl_killstreak_eyeparticle_debug","0",true,false)
local cv_singleye = CreateClientConVar("cl_killstreak_eyepatch","0",true,false)

if CLIENT then
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

	cvars.AddChangeCallback(cv_forcetf2font:GetName(), updateFont, cv_forcetf2font:GetName())

	hook.Add("HUDPaint", "ffgs_utils_killstreak_draw", function()
		if not cv_drawhud:GetBool() or not cv_draw:GetBool() then return end

		local ply = LocalPlayer()
		if not ply:IsValid() or not ply:Alive() then return end

		local streak = ply:GetNW2Int("killstreak", 0)

		draw.SimpleTextOutlined(string.format("Streak: %s", streak), fontname, ScrW() - ScreenScale(16), ScrH() - ScreenScale(50), hudcolor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(63, 63, 0))
	end)

	return
end

hook.Add("PlayerDeath", "ffgs_utils_killstreak_playerdeath", function(victim, inflictor, attacker)
	if not victim:IsValid() or not victim:IsPlayer() or not attacker:IsValid() or not attacker:IsPlayer() then return end

	victim:SetNW2String("killstreakcolor", nil)
	victim:SetNW2Bool("killstreak_effects_created",false)
	if victim == attacker then return end
	local atkstreak = attacker:GetNW2Int("killstreak", 0) + 1
	attacker:SetNW2Int("killstreak", atkstreak)
end)

hook.Add("OnNPCKilled", "ffgs_utils_killstreak_npcdeath", function(npc, attacker, inflictor)
	if not npc:IsValid() or not attacker:IsValid() or not attacker:IsPlayer() then return end

	local atkstreak = attacker:GetNW2Int("killstreak", 0) + 1
	attacker:SetNW2Int("killstreak", atkstreak)
end)

hook.Add("PlayerSpawn", "ffgs_utils_killstreak_clear", function(ply)
	ply:SetNW2Int("killstreak", 0)
	ply:SetNW2Bool("killstreak_effects_created",false)
	ply:StopParticles()
	ply:SetNW2String("killstreakcolor", ply:GetInfo(cv_color:GetName()))
	ply:SetNW2String("killstreakeffect",ply:GetInfo(cv_effect:GetName()))
end)

concommand.Add("killstreak_applycolor", function(ply, cmd, args)
	if not ply or not ply:IsValid() then return end
	ply:SetNW2Bool("killstreak_effects_created",false)
	ply:StopParticles()
	ply:SetNW2String("killstreakcolor", ply:GetInfo(cv_color:GetName()))
	ply:SetNW2String("killstreakeffect",ply:GetInfo(cv_effect:GetName()))
end)