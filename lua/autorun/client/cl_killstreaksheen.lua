-- TF2 Killstreak Weapon Sheen
-- Created by YuRaNnNzZZ
-- Colors and Eye Particles Code by Matsilagi
-- cleanup & multiplayer fixing by homonovus

--CONVARS SETUP
local cv_matmode = CreateClientConVar("cl_killstreak_oldmat", "0", true, false)
local cv_specular = GetConVar("mat_specular")
local cv_debugmodel = GetConVar("cl_killstreak_eyeparticle_debug")

CreateClientConVar("cl_killstreak_offset_l_right", "-1.50", true, true)
CreateClientConVar("cl_killstreak_offset_l_up", "0.0", true, true)
CreateClientConVar("cl_killstreak_offset_l_forward", "1.0", true, true)
CreateClientConVar("cl_killstreak_offset_r_right", "1.50", true, true)
CreateClientConVar("cl_killstreak_offset_r_up", "0.0", true, true)
CreateClientConVar("cl_killstreak_offset_r_forward", "1.0", true, true)

local glow = Material("ffgs_utils/killstreak/sheen")

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

local WeaponSheenColors = {
	["team_red"]		= Color(200, 20,  15), -- Team Shine RED
	["team_blue"]		= Color(40, 98, 200), -- Team Shine BLU
	["yellow"]			= Color(242, 172, 10), -- Deadly Daffodil
	["orange"]			= Color(255, 75,  5), -- Manndarin
	["green"]			= Color(100, 255, 10), -- Mean Green
	["ltgreen"]			= Color(40, 255, 70), -- Agonizing Emerald
	["violet"]			= Color(105, 20,  255), -- Villainous Violet
	["pink"]			= Color(255, 30,  255), -- Hot Rod
}

local ColorsLevel1 = {
	["team_red"]		= Color(255, 118, 118), -- Team Shine RED
	["team_blue"]		= Color(0, 92, 255), -- Team Shine BLU
	["yellow"]			= Color(255, 237, 138), -- Deadly Daffodil
	["orange"]			= Color(255, 111, 5), -- Manndarin
	["green"]			= Color(230, 255, 60), -- Mean Green
	["ltgreen"]			= Color(103, 255, 121), -- Agonizing Emerald
	["violet"]			= Color(105, 20,  255), -- Villainous Violet
	["pink"]			= Color(255, 120, 255), -- Hot Rod
}

local ColorsLevel2 = {
	["team_red"]		= Color(255, 35,  28), -- Team Shine RED
	["team_blue"]		= Color(134, 203, 243), -- Team Shine BLU
	["yellow"]			= Color(255, 213, 65), -- Deadly Daffodil
	["orange"]			= Color(255, 137, 31), -- Manndarin
	["green"]			= Color(193, 255, 61), -- Mean Green
	["ltgreen"]			= Color(165, 255, 193), -- Agonizing Emerald
	["violet"]			= Color(185, 145, 255), -- Villainous Violet
	["pink"]			= Color(255, 176, 217), -- Hot Rod
}

--EYE KILLSTREAKS / PARTICLE EFFECTS
hook.Add("PostPlayerDraw", "ffgs_utils_killstreak_ply", function(ply)
	local plyTable = ply:GetTable()

	--SETUP
	local leye = plyTable._TFKillstreakLEyeModel
	local reye = plyTable._TFKillstreakREyeModel

	--CREATION: MODELS
	if not (leye and leye:IsValid()) then
		leye = ClientsideModel("models/dummy.mdl")
		leye:SetParent(ply)
		leye:SetNoDraw(true)
		leye:SetModelScale(0.08, 0)
		plyTable._TFKillstreakLEyeModel = leye
	end

	if not (reye and reye:IsValid()) then
		reye = ClientsideModel("models/dummy.mdl")
		reye:SetParent(ply)
		reye:SetNoDraw(true)
		reye:SetModelScale(0.08, 0)
		plyTable._TFKillstreakREyeModel = reye
	end

	local streak = math.Clamp(ply:GetNW2Int("killstreak", 0), 0, maxstreak)
	local color = ply:IsBot() and "team_blue" or ply:GetNW2String("killstreakcolor", "")
	local effect_id = ply:IsBot() and 1 or ply:GetNW2Int("killstreakeffect", 0)
	local effect_name = string.format("killstreak_t%d_lvl%d", effect_id, streak >= 10 and 2 or 1)

	local attach_id = ply:LookupAttachment("eyes")
	local attach = attach_id > 0 and ply:GetAttachment(attach_id)

	local bSingleEye = ply:GetNW2Bool("killstreak_single_eye", false)
	
	if game.SinglePlayer() or cv_debugmodel:GetBool() then
		bSingleEye = ply == LocalPlayer() and GetConVar("cl_killstreak_eyepatch"):GetBool()
	end

	--INITIAL CHECKS AND EFFECT CONTROL
	if streak < 5 or ply:GetNoDraw() or not ply:Alive() or not attach or
		(#color == 0 or color == "none") or (effect_id > 7 or effect_id <= 0) or
		(not ColorsLevel1[color] or not ColorsLevel2[color])
		then
		leye:StopParticleEmission()
		reye:StopParticleEmission()
		return
	end

	if bSingleEye then
		leye:StopParticleEmission()
	end

	--Left Eye
	local leftEyePos = attach.Pos * 1
	local attang = attach.Ang

	local forward = attach.Ang:Forward()
	local right = attach.Ang:Right()
	local up = attach.Ang:Up()

	local offsetL = ply:GetNW2Vector("killstreak_eye_pos_l", Vector(-1.5,1,0))
	
	if game.SinglePlayer() or cv_debugmodel:GetBool() then
		local offL_dbg_r = LocalPlayer() and GetConVar("cl_killstreak_offset_l_right"):GetFloat()
		local offL_dbg_u = LocalPlayer() and GetConVar("cl_killstreak_offset_l_up"):GetFloat()
		local offL_dbg_f = LocalPlayer() and GetConVar("cl_killstreak_offset_l_forward"):GetFloat()
		offsetL = Vector(offL_dbg_r, offL_dbg_u, offL_dbg_f)
	end
	
	leftEyePos:Add(right * offsetL.x)
	leftEyePos:Add(forward * offsetL.y)
	leftEyePos:Add(up * offsetL.z)

	leye:SetRenderOrigin(leftEyePos)
	leye:SetRenderAngles(attang)

	--Right Eye
	local rightEyePos = attach.Pos * 1

	local offsetR = ply:GetNW2Vector("killstreak_eye_pos_r", Vector(1.5,1,0))
	
	if game.SinglePlayer() or cv_debugmodel:GetBool() then
		local offR_dbg_r = LocalPlayer() and GetConVar("cl_killstreak_offset_r_right"):GetFloat()
		local offR_dbg_u = LocalPlayer() and GetConVar("cl_killstreak_offset_r_up"):GetFloat()
		local offR_dbg_f = LocalPlayer() and GetConVar("cl_killstreak_offset_r_forward"):GetFloat()
		offsetR = Vector(offR_dbg_r, offR_dbg_u, offR_dbg_f)
	end
	
	rightEyePos:Add(right * offsetR.x)
	rightEyePos:Add(forward * offsetR.y)
	rightEyePos:Add(up * offsetR.z)

	reye:SetRenderOrigin(rightEyePos)
	reye:SetRenderAngles(attang)

	if cv_debugmodel:GetBool() then
		if not bSingleEye then
			leye:DrawModel()
		end
		reye:DrawModel()
	else
		leye:SetNoDraw(true)
		reye:SetNoDraw(true)
	end

	local att_l = leye:LookupAttachment("eyeglow_L")
	local att_r = reye:LookupAttachment("eyeglow_R")
	if bSingleEye then
		att_r = reye:LookupAttachment("eyeglow_C")
	end

	local pcf_l = plyTable._TFKillstreakLEyeParticle
	local pcf_r = plyTable._TFKillstreakREyeParticle

	-- stop particle if player has changed effect
	if (plyTable._TFKillStreakParticleName ~= effect_name) then
		if pcf_l and pcf_l:IsValid() then
			pcf_l:StopEmission()
		end

		if pcf_r and pcf_r:IsValid() then
			pcf_r:StopEmission()
		end
	end

	-- handle creation of particle effects

	-- update color based on streak level
	local colorTbl
	if streak >= 5 and streak < 10 then
		colorTbl = ColorsLevel1
	elseif streak >= 10 then
		colorTbl = ColorsLevel2
	end

	if not bSingleEye and not (pcf_l and pcf_l:IsValid()) then
		pcf_l = CreateParticleSystem(leye, effect_name, PATTACH_POINT_FOLLOW, att_l, leftEyePos)
		plyTable._TFKillstreakLEyeParticle = pcf_l

		if pcf_l then
			pcf_l:SetShouldDraw(false)
			pcf_l:StartEmission()
		end
	elseif bSingleEye and (pcf_l and pcf_l:IsValid()) then
		pcf_l:StopEmission()
	end

	if not (pcf_r and pcf_r:IsValid()) then
		pcf_r = CreateParticleSystem(reye, effect_name, PATTACH_POINT_FOLLOW, att_r, rightEyePos)
		plyTable._TFKillstreakREyeParticle = pcf_r
		plyTable._TFKillStreakParticleName = effect_name
		plyTable._TFKillStreakParticleColor = color

		if pcf_r then
			pcf_r:SetShouldDraw(false)
			pcf_r:StartEmission()
		end
	end

	local colorVec = colorTbl[color]:ToVector()
	if pcf_l and pcf_l:IsValid() then
		if streak == 0 then
			pcf_l:StopEmission()
		else
			pcf_l:SetControlPointOrientation(0, forward, right, up)
			pcf_l:SetControlPoint(9, colorVec)
		end
	end
	if pcf_r and pcf_r:IsValid() then
		if streak == 0 then
			pcf_r:StopEmission()
		else
			pcf_r:SetControlPointOrientation(0, forward, right, up)
			pcf_r:SetControlPoint(9, colorVec)
		end
	end
end)

-- render manually to prevent drawing in first person for localplayer
-- works in mirror on construct, as well as not having depth issues
hook.Add("PostDrawTranslucentRenderables", "ffgs_utils_killstreak_ents", function()
	for _, ply in player.Iterator() do
		if not ply:IsValid() then continue end
		if ply:GetNoDraw() or not ply:Alive() then continue end
		if ply:IsDormant() then continue end

		if ply == LocalPlayer() and not ply:ShouldDrawLocalPlayer() then continue end

		local pcf_l = ply._TFKillstreakLEyeParticle
		local pcf_r = ply._TFKillstreakREyeParticle
		local pcf2_l = ply._TFKillstreakLEyeParticle2
		local pcf2_r = ply._TFKillstreakREyeParticle2
		if pcf_l and pcf_l:IsValid() then
			pcf_l:Render()
		end
		if pcf_r and pcf_r:IsValid() then
			pcf_r:Render()
		end
		if pcf2_l and pcf2_l:IsValid() then
			pcf2_l:Render()
		end
		if pcf2_r and pcf2_r:IsValid() then
			pcf2_r:Render()
		end
	end
end)

--WEAPON/VM AND WM SHEENS
do -- matproxy
	-- localize to boost performance inside of this hot area
	-- matproxies' bind function is called multiple times per frame
	-- typically only done for entities to avoid ENT.__index's perf hit :)
	local MATERIAL = FindMetaTable("IMaterial")
	local MAT_SetVector = MATERIAL.SetVector
	local MAT_SetInt = MATERIAL.SetInt
	local MAT_GetTexture = MATERIAL.GetTexture

	local TEXTURE = FindMetaTable("ITexture")
	local TEX_GetNumAnimationFrames = TEXTURE.GetNumAnimationFrames

	local ENTITY = FindMetaTable("Entity")
	local E_GetNW2Int = ENTITY.GetNW2Int
	local E_GetNW2String = ENTITY.GetNW2String
	local E_GetOwner = ENTITY.GetOwner
	local E_IsValid = ENTITY.IsValid

	local PLAYER = FindMetaTable("Player")
	local P_IsBot = PLAYER.IsBot

	local CurTime = CurTime
	local FrameTime = FrameTime

	local baseFramerate = 25 -- default to 25 per the vmt; i leave this to you to change/manipulate
	-- you can also change this to be based on a value from the player inside of the matproxy's bind func

	local MAX_KILLS = 5
	local MAX_SHEEN_WAIT = 5
	local function GetTimeBetweenAnims(streak)
		-- set the time between sheens based on kill streak
		if streak == 0 then return MAX_SHEEN_WAIT end
		if streak >= MAX_KILLS then return 0 end

		-- as player gets more kills, time decreases
		return (1.0 - (streak / MAX_KILLS)) * MAX_SHEEN_WAIT
	end

	matproxy.Add({
		name = "KillStreakGlowColor",
		init = function(self, mat, values)
			self.ResultTo = values.resultvar
			self.AnimatedTextureVar = values.animatedtexturevar
			self.AnimatedTextureFrameVar = values.animatedtextureframenumvar
		end,
		bind = function(self, mat, ent)
			local _ent

			if ent and E_IsValid(ent) then
				if ent:IsPlayer() then -- IsPlayer doesn't actually check anything
					_ent = ent
				else
					local owner = E_GetOwner(ent)
					if E_IsValid(owner) and owner:IsPlayer() then
						_ent = owner
					end
				end
			end

			-- _ent is only set when we can find a player
			if not _ent then return end

			local streak = math.min(E_GetNW2Int(_ent, "killstreak", 0), maxstreak)
			if streak == 0 --[[or streak < minstreak]] then return end

			local colorvar = P_IsBot(_ent) and "team_blue" or E_GetNW2String(_ent, "killstreakcolor", nil)
			if not WeaponSheenColors[colorvar] then return end

			local color = WeaponSheenColors[colorvar]:ToVector()
			--local ratio = 1 --streak / maxstreak

			MAT_SetVector(mat, self.ResultTo, color)

			-- begin animated texture
			local numFrames = TEX_GetNumAnimationFrames(MAT_GetTexture(mat, self.AnimatedTextureVar))
			if numFrames <= 0 then return end

			local curtime = CurTime()
			local frametime = FrameTime()

			local startTime = _ent.NextSheenStartTime or 0
			local deltaTime = math.max(curtime - startTime, 0)
			local prevTime = math.max(deltaTime - frametime, 0)

			local frame = math.floor(baseFramerate * deltaTime) % numFrames
			local prevFrame = math.floor(baseFramerate * prevTime) % numFrames

			if prevFrame > frame then
				frame = 0
				--print("die", prevFrame, frame, streak, GetTimeBetweenAnims(streak))
				_ent.NextSheenStartTime = curtime + GetTimeBetweenAnims(streak)
			end

			--print("EEE", frame)
			--local frame = math.floor(RealTime() * baseFramerate) % TEX_GetNumAnimationFrames(MAT_GetTexture(mat, self.AnimatedTextureVar))
			MAT_SetInt(mat, self.AnimatedTextureFrameVar, frame)
		end
	})
end

local function DrawKillstreakSheen(ent, owner, override)
	if not IsValid(ent) or (ent:GetNoDraw() and not override) then return end
	if not IsValid(owner) then owner = ent:GetOwner() or ent end
	local streak = math.Clamp(owner:GetNW2Int("killstreak", 0), 0, maxstreak)
	local color = owner:IsBot() and "team_blue" or owner:GetNW2String("killstreakcolor", nil)

	if WeaponSheenColors[color] and streak > 0 and streak >= minstreak then
		render.MaterialOverride(glow)
		ent:DrawModel()
		render.MaterialOverride(nil)
	end
end

hook.Add("PostPlayerDraw", "ffgs_utils_killstreak_tp", function(ply)
	if ply.KSSheenRedraw or not ply:IsValid() then return end
	ply.KSSheenRedraw = true
	DrawKillstreakSheen(ply:GetActiveWeapon(), ply)
	ply.KSSheenRedraw = false
end)

hook.Add("PostDrawViewModel", "ffgs_utils_killstreak_fp", function(vm, ply, wep)
	if wep.VMRedraw then return end
	if wep and (wep.CW20Weapon or wep.IsFAS2Weapon) then return end -- Handled separately
	if wep and (wep.ArcCW or wep.ARC9 or wep.ArcticTacRP) then return end --No compatibility ):
	wep.VMRedraw = true
	DrawKillstreakSheen(vm, ply)
	wep.VMRedraw = false
end)

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

			if IsValid(_self.CW_VM) and WeaponSheenColors[color] and streak > 0 and streak >= minstreak then
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
