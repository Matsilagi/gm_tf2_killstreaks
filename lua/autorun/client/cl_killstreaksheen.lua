-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Colors and Eye Particles Code by Matsilagi

--CONVARS SETUP
local cv_matmode = CreateClientConVar("cl_killstreak_oldmat", "0", true, false)
local cv_effect = GetConVar("cl_killstreak_effect")
local cv_color = GetConVar("cl_killstreak_color")
local cv_specular = GetConVar("mat_specular")
local cv_debugmodel = GetConVar("cl_killstreak_eyeparticle_debug")
local cv_singleye = GetConVar("cl_killstreak_eyepatch")
local glow = Material("ffgs_utils/killstreak/sheen")
local offset_l_right = CreateClientConVar("cl_killstreak_offset_l_right", "-1.50", true, true)
local offset_l_up = CreateClientConVar("cl_killstreak_offset_l_up", "0.0", true, true)
local offset_l_forward = CreateClientConVar("cl_killstreak_offset_l_forward", "1.0", true, true)
local offset_r_right = CreateClientConVar("cl_killstreak_offset_r_right", "1.50", true, true)
local offset_r_up = CreateClientConVar("cl_killstreak_offset_r_up", "0.0", true, true)
local offset_r_forward = CreateClientConVar("cl_killstreak_offset_r_forward", "1.0", true, true)

--MATERIAL CHECK
local function checkMaterial()
	local legacy = cv_matmode:GetBool() or not cv_specular:GetBool()
	glow = Material("ffgs_utils/killstreak/sheen" .. (legacy and "_legacy" or ""))
end
checkMaterial()

cvars.AddChangeCallback(cv_matmode:GetName(), checkMaterial, cv_matmode:GetName())
cvars.AddChangeCallback(cv_specular:GetName(), checkMaterial, cv_matmode:GetName())

--COLOR TABLE AND STREAK VALUES
local minstreak, maxstreak = 0, 20

local colors = {
	["team_red"]		= Vector(200/255, 20/255,  15/255), -- Team Shine RED
	["team_blue"]		= Vector(40/255, 98/255, 200/255), -- Team Shine BLU
	["yellow"]			= Vector(242/255, 172/255, 10/255), -- Deadly Daffodil
	["orange"]			= Vector(255/255, 75/255,  5/255), -- Manndarin
	["green"]			= Vector(100/255, 255/255, 10/255), -- Mean Green
	["ltgreen"]			= Vector(40/255, 255/255, 70/255), -- Agonizing Emerald
	["violet"]			= Vector(105/255, 20/255,  255/255), -- Villainous Violet
	["pink"]			= Vector(255/255, 30/255,  255/255), -- Hot Rod
}

local eye_color1 = {
	["team_red"]		= Vector(255/255, 118/255, 118/255), -- Team Shine RED
	["team_blue"]		= Vector(0, 92/255, 255/255), -- Team Shine BLU
	["yellow"]			= Vector(255/255, 237/255, 138/255), -- Deadly Daffodil
	["orange"]			= Vector(255/255, 111/255, 5/255), -- Manndarin
	["green"]			= Vector(230/255, 255/255, 60/255), -- Mean Green
	["ltgreen"]			= Vector(103/255, 255/255, 121/255), -- Agonizing Emerald
	["violet"]			= Vector(105/255, 20/255,  255/255), -- Villainous Violet
	["pink"]			= Vector(255/255, 120/255, 255/255), -- Hot Rod
}

local eye_color2 = {
	["team_red"]		= Vector(255/255, 35/255,  28/255), -- Team Shine RED
	["team_blue"]		= Vector(134/255, 203/255, 243/255), -- Team Shine BLU
	["yellow"]			= Vector(255/255, 213/255, 65/255), -- Deadly Daffodil
	["orange"]			= Vector(255/255, 137/255, 31/255), -- Manndarin
	["green"]			= Vector(193/255, 255/255, 61/255), -- Mean Green
	["ltgreen"]			= Vector(165/255, 255/255, 193/255), -- Agonizing Emerald
	["violet"]			= Vector(185/255, 145/255, 255/255), -- Villainous Violet
	["pink"]			= Vector(255/255, 176/255, 217/255), -- Hot Rod
}

local effects = {
	["killstreak_t1_"] = "Fire Horns",
	["killstreak_t2_"] = "Cerebral Discharge",
	["killstreak_t3_"] = "Tornado",
	["killstreak_t4_"] = "Flames",
	["killstreak_t5_"] = "Singularity",
	["killstreak_t6_"] = "Incinerator",
	["killstreak_t7_"] = "Hypno-Beam"
}

--EYE KILLSTREAKS / PARTICLE EFFECTS
local leye = ClientsideModel( "models/dummy.mdl" )
leye:SetNoDraw( true )

local reye = ClientsideModel( "models/dummy.mdl" )
reye:SetNoDraw( true )

local function DrawKillstreakParticles(ply)
	--SETUP
	local streak = math.Clamp(ply:GetNW2Int("killstreak", 0), 0, maxstreak)
	local color = ply:GetNW2String("killstreakcolor", nil)
	local effect_name = ply:GetNW2String("killstreakeffect",nil)
	local cv_offset_leye_right = GetConVar("cl_killstreak_offset_l_right")
	local cv_offset_leye_up = GetConVar("cl_killstreak_offset_l_up")
	local cv_offset_leye_forward = GetConVar("cl_killstreak_offset_l_forward")
	local offset_leye_right = cv_offset_leye_right:GetFloat()
	local offset_leye_up = cv_offset_leye_up:GetFloat()
	local offset_leye_forward = cv_offset_leye_forward:GetFloat()
	local cv_offset_reye_right = GetConVar("cl_killstreak_offset_r_right")
	local cv_offset_reye_up = GetConVar("cl_killstreak_offset_r_up")
	local cv_offset_reye_forward = GetConVar("cl_killstreak_offset_r_forward")
	local offset_reye_right = cv_offset_reye_right:GetFloat()
	local offset_reye_up = cv_offset_reye_up:GetFloat()
	local offset_reye_forward = cv_offset_reye_forward:GetFloat()
	local attach_id = ply:LookupAttachment('eyes')
	local attach = ply:GetAttachment(attach_id)
	
	--INITIAL CHECKS AND EFFECT CONTROL
	if not IsValid(ply) or ply:GetNoDraw() then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if not ply:Alive() then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if color == nil or color == "none" then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if effect_name == nil or effect_name == "none" then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if eye_color1[color] == nil then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if eye_color2[color] == nil then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if not attach_id or attach_id == nil then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if not attach or attach == nil then leye:StopParticleEmission() reye:StopParticleEmission() return end
	if cv_singleye:GetBool() then leye:StopParticleEmission() end
	
	--CREATION: MODELS
	
	--Left Eye
	local attpos = attach.Pos
	local attang = attach.Ang
	attpos = attpos + (attang:Forward() * offset_leye_forward)
	attpos = attpos + (attang:Right() * offset_leye_right)
	attpos = attpos + (attang:Up() * offset_leye_up)
	leye:SetModelScale(0.08, 0)
	leye:SetPos(attpos)
	leye:SetAngles(attang)
	leye:SetRenderOrigin(attpos)
	leye:SetRenderAngles(attang)
	leye:SetupBones()
	if cv_debugmodel:GetBool() and not cv_singleye:GetBool() then
		leye:DrawModel()
	else
		leye:SetNoDraw(true)
	end
	leye:SetRenderOrigin()
	leye:SetRenderAngles()
	
	--Right Eye
	local attpos2 = attach.Pos
	local attang2 = attach.Ang
	attpos2 = attpos2 + (attang2:Forward() * offset_reye_forward)
	attpos2 = attpos2 + (attang2:Right() * offset_reye_right)
	attpos2 = attpos2 + (attang2:Up() * offset_reye_up)
	reye:SetModelScale(0.08, 0)
	reye:SetPos(attpos2)
	reye:SetAngles(attang2)
	reye:SetRenderOrigin(attpos2)
	reye:SetRenderAngles(attang2)
	reye:SetupBones()
	if cv_debugmodel:GetBool() then
		reye:DrawModel()
	else
		reye:SetNoDraw(true)
	end
	reye:SetRenderOrigin()
	reye:SetRenderAngles()
	
	local att_l = leye:LookupAttachment("eyeglow_L")
	local att_r = reye:LookupAttachment("eyeglow_R")
	if cv_singleye:GetBool() then
		att_r = reye:LookupAttachment("eyeglow_C")
	end
	
	--CREATION AND CHECK: PARTICLE STREAKS
	if streak >= 5 and streak <= 9 then
		if not IsValid(pcf_l) and not cv_singleye:GetBool() then 
			pcf_l = CreateParticleSystem(leye, effect_name .. "lvl1", PATTACH_POINT_FOLLOW, att_l, leye:GetPos())
			pcf_l:SetControlPoint(9,eye_color1[color])
			pcf_l:StartEmission()
		end
		
		if not IsValid(pcf_r) then
			pcf_r = CreateParticleSystem(reye, effect_name .. "lvl1", PATTACH_POINT_FOLLOW, att_r, reye:GetPos())
			pcf_r:SetControlPoint(9,eye_color1[color])
			pcf_r:StartEmission()
		end
		
		if IsValid(pcf_l) and cv_singleye:GetBool() then
			pcf_l:StopEmission()
		end
	elseif streak >= 10 then
		if IsValid(pcf_l) then
			pcf_l:StopEmission()
		end
		
		if IsValid(pcf_r) then
			pcf_r:StopEmission()
		end
		
		if not IsValid(pcf2_l) and not cv_singleye:GetBool() then 
			pcf2_l = CreateParticleSystem(leye, effect_name .. "lvl2", PATTACH_POINT_FOLLOW, att_l, leye:GetPos())
			pcf2_l:SetControlPoint(9,eye_color2[color])
			pcf2_l:StartEmission()
		end
		
		if not IsValid(pcf2_r) then
			pcf2_r = CreateParticleSystem(reye, effect_name .. "lvl2", PATTACH_POINT_FOLLOW, att_r, reye:GetPos())
			pcf2_r:SetControlPoint(9,eye_color2[color])
			pcf2_r:StartEmission()
		end
		
		if IsValid(pcf2_l) and cv_singleye:GetBool() then
			pcf_l:StopEmission()
		end
	else
		if IsValid(pcf_l) or cv_singleye:GetBool() then
			pcf_l:StopEmission()
		end
		
		if IsValid(pcf_r) then
			pcf_r:StopEmission()
		end		
		
		if IsValid(pcf2_l) or cv_singleye:GetBool() then
			pcf2_l:StopEmission()
		end
		
		if IsValid(pcf2_r) then
			pcf2_r:StopEmission()
		end		
	end
	
	--ADDITIONAL CHECK: PARTICLE UPDATE
	if cv_color:GetString() != ply:GetNW2String("killstreakcolor", nil) or cv_effect:GetString() != ply:GetNW2String("killstreakeffect", nil) then
		if IsValid(pcf_l) then
			pcf_l:StopEmission()
		end
		
		if IsValid(pcf_r) then
			pcf_r:StopEmission()
		end		
		
		if IsValid(pcf2_l) or cv_singleye:GetBool() then
			pcf2_l:StopEmission()
		end
		
		if IsValid(pcf2_r) then
			pcf2_r:StopEmission()
		end
	end
end
hook.Add("PostPlayerDraw", "ffgs_utils_killstreak_ply",DrawKillstreakParticles)

--WEAPON/VM AND WM SHEENS
matproxy.Add({
	name = "KillStreakGlowColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		local _ent = ent
		if ent and ent:IsValid() and ent:GetOwner() and ent:GetOwner():IsPlayer() then
			_ent = ent:GetOwner()
		end
		if _ent and _ent:IsValid() and _ent:IsPlayer() then
			local streak = math.min(_ent:GetNW2Int("killstreak", 0), maxstreak)
			local colorvar = _ent:GetNW2String("killstreakcolor", nil)
			local color = colors[colorvar]
			local ratio = streak / maxstreak

			if colors[colorvar] and streak > 0 and streak >= minstreak then
				mat:SetVector(self.ResultTo, Vector(color.x * ratio, color.y * ratio, color.z * ratio))
			end
		end
	end
})

local function DrawKillstreakSheen(ent, owner, override)
	if not IsValid(ent) or (ent:GetNoDraw() and not override) then return end
	if not IsValid(owner) then owner = ent:GetOwner() or ent end
	local streak = math.Clamp(owner:GetNW2Int("killstreak", 0), 0, maxstreak)
	local color = owner:GetNW2String("killstreakcolor", nil)

	if colors[color] and streak > 0 and streak >= minstreak then
		render.MaterialOverride(glow)
		ent:DrawModel()
		render.MaterialOverride(nil)
	end
end

local function DrawPlayerWeaponSheen(ply)
	if ply.KSSheenRedraw or not ply:IsValid() then return end
	ply.KSSheenRedraw = true
	DrawKillstreakSheen(ply:GetActiveWeapon(), ply)
	ply.KSSheenRedraw = false
end
hook.Add("PostPlayerDraw", "ffgs_utils_killstreak_tp", DrawPlayerWeaponSheen)

local function DrawFPWeaponSheen(vm, ply, wep)
	if wep.VMRedraw then return end
	if wep and (wep.CW20Weapon or wep.IsFAS2Weapon) then return end -- Handled separately
	wep.VMRedraw = true
	DrawKillstreakSheen(vm, ply)
	wep.VMRedraw = false
end
hook.Add("PostDrawViewModel", "ffgs_utils_killstreak_fp", DrawFPWeaponSheen)

--PATCHES SECTION

-- FAS 2.0 COMPATIBILITY PATCH
if file.Exists("weapons/fas2_base/shared.lua", "LUA") then
	local cv_fas2_override = CreateClientConVar("cl_killstreak_patch_fas2", 1, true, false)

	local function PatchFAS20Draw()
		local wep = weapons.GetStored("fas2_base")
		if not wep then return end

		if not cv_fas2_override:GetBool() then
			if wep.Draw3D2DCamera_PreKS then
				wep.Draw3D2DCamera = wep.Draw3D2DCamera_PreKS
				wep.Draw3D2DCamera_PreKS = nil
			end

			return
		end

		wep.Draw3D2DCamera_PreKS = wep.Draw3D2DCamera_PreKS or wep.Draw3D2DCamera
		wep.Draw3D2DCamera = function(_self, ...)
			if IsValid(_self.Nade) and (CurTime() < _self.Nade.LifeTime) then
				_self.Nade:SetOwner(_self:GetOwner())
				DrawKillstreakSheen(_self.Nade, _self:GetOwner(), true)
			end

			if IsValid(_self.Wep) then
				_self.Wep:SetOwner(_self:GetOwner())
				DrawKillstreakSheen(_self.Wep, _self:GetOwner(), true)
			end

			if _self.Draw3D2DCamera_PreKS then
				_self.Draw3D2DCamera_PreKS(_self, ...)
			end
		end
	end

	-- PatchFAS20Draw()

	cvars.RemoveChangeCallback(cv_fas2_override:GetName(), cv_fas2_override:GetName())
	cvars.AddChangeCallback(cv_fas2_override:GetName(), PatchFAS20Draw, cv_fas2_override:GetName())

	hook.Add("InitPostEntity", "ffgs_utils_killstreak_patch_fas20", PatchFAS20Draw)
end

-- CUSTOMIZABLE WEAPONRY 2.0 COMPATIBILITY PATCH
if file.Exists("weapons/cw_base/shared.lua", "LUA") then
	local cv_cw20_override = CreateClientConVar("cl_killstreak_patch_cw20", 1, true, false)

	local function PatchCW20Draw()
		local wep = weapons.GetStored("cw_base")
		if not wep then return end

		if not cv_cw20_override:GetBool() then
			if wep.drawInteractionMenu_PreKS then
				wep.drawInteractionMenu = wep.drawInteractionMenu_PreKS
				wep.drawInteractionMenu_PreKS = nil
			end

			return
		end

		wep.drawInteractionMenu_PreKS = wep.drawInteractionMenu_PreKS or wep.drawInteractionMenu
		wep.drawInteractionMenu = function(_self, ...)
			-- second round, for sheen
			local owner = _self:GetOwner()
			local streak = math.Clamp(owner:GetNW2Int("killstreak", 0), 0, maxstreak)
			local color = owner:GetNW2String("killstreakcolor", nil)

			if IsValid(_self.CW_VM) and colors[color] and streak > 0 and streak >= minstreak then
				render.MaterialOverride(glow)

				if _self.ViewModelFlip then render.CullMode(MATERIAL_CULLMODE_CW) end
				_self.CW_VM:SetOwner(_self:GetOwner())
				_self.CW_VM:DrawModel()
				if _self.ViewModelFlip then render.CullMode(MATERIAL_CULLMODE_CCW) end
				_self:drawAttachments()

				render.MaterialOverride(nil)
			end

			if _self.drawInteractionMenu_PreKS then
				_self.drawInteractionMenu_PreKS(_self, ...)
			end
		end
	end

	-- PatchCW20Draw()

	cvars.RemoveChangeCallback(cv_cw20_override:GetName(), cv_cw20_override:GetName())
	cvars.AddChangeCallback(cv_cw20_override:GetName(), PatchCW20Draw, cv_cw20_override:GetName())

	hook.Add("InitPostEntity", "ffgs_utils_killstreak_patch_cw20", PatchCW20Draw)
end

--MWBase Compat
if file.Exists("weapons/mg_base/shared.lua", "LUA") then
	local shoulddraw = true

	local function DrawSheenMW(self, flags)
		if not shoulddraw then return end

		local wep = self:GetOwner()
		if not IsValid(wep) then return end

		local owner = wep:GetOwner()
		if not IsValid(owner) then return end

		local streak = math.Clamp(owner:GetNW2Int("killstreak", 0), 0, maxstreak)
		local color = owner:GetNW2String("killstreakcolor", nil)

		if WeaponSheenColors[color] and streak > 0 and streak >= minstreak then
			render.MaterialOverride(glow)

			self.KSSheenPlayer = owner
			self:DrawModel(flags)

			local atts = wep:GetAllAttachmentsInUse()
			for slot = #atts, 1, -1 do
				local att = atts[slot]

				if not IsValid(att.m_Model) then continue end

				if att.hideModel then
					render.SetStencilWriteMask(0xFF)
					render.SetStencilTestMask(0xFF)
					render.SetStencilReferenceValue(0)
					render.SetStencilPassOperation(STENCIL_KEEP)
					render.SetStencilZFailOperation(STENCIL_KEEP)
					render.ClearStencil()
					render.SetStencilEnable(true)
					render.SetStencilReferenceValue(MWBASE_STENCIL_REFVALUE + 2)
					render.SetStencilCompareFunction(STENCIL_NEVER)
					render.SetStencilFailOperation(STENCIL_REPLACE)

					att.hideModel:DrawModel(flags)

					render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
					render.SetStencilFailOperation(STENCIL_KEEP)
				end

				att.m_Model:DrawModel(flags)

				if att.hideModel then
					render.SetStencilEnable(false)
					render.ClearStencil()
				end
			end

			render.MaterialOverride(nil)
		end
	end

	local cv_shoulddraw = CreateClientConVar("cl_killstreak_mgbase_draw", "1", true, false)
	local function UpdateCVars()
		shoulddraw = cv_shoulddraw:GetBool()
	end
	cvars.RemoveChangeCallback(cv_shoulddraw:GetName(), cv_shoulddraw:GetName())
	cvars.AddChangeCallback(cv_shoulddraw:GetName(), UpdateCVars, cv_shoulddraw:GetName())

	hook.Add("PreRegisterSENT", "patch_mg_viewmodel", function(ENT, ClassName)
		if ClassName ~= "mg_viewmodel" then return end

		local Draw = ENT.Draw
		ENT.Draw = function(self, flags, ...)
			Draw(self, flags, ...)
			DrawSheenMW(self, flags)
		end
	end)
end
