local effects = {
	["killstreak_t1_"] = "killstreak_t1_",
	["killstreak_t2_"] = "killstreak_t2_",
	["killstreak_t3_"] = "killstreak_t3_",
	["killstreak_t4_"] = "killstreak_t4_",
	["killstreak_t5_"] = "killstreak_t5_",
	["killstreak_t6_"] = "killstreak_t6_",
	["killstreak_t7_"] = "killstreak_t6_"
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

function EFFECT:Init(data)
	self.ParentEnt = data:GetEntity()
	self.Streak = self.ParentEnt:GetNW2Int("killstreak",0)
	self.Color = self.ParentEnt:GetNW2String("killstreakcolor", nil)
	self.EffectName = self.ParentEnt:GetNW2String("killstreakeffect",nil)
	self.EyeColor1 = eye_color1[self.Color]
	self.EyeColor2 = eye_color2[self.Color]
	--local streak = math.Clamp(self.Ply:GetNW2Int("killstreak", 0), 0, maxstreak)
	--local color = self.Ply:GetNW2String("killstreakcolor", nil)
	--local effect_name = self.Ply:GetNW2String("killstreakeffect",nil)
	--local eyecolor1 = eye_color1[color]
	--local eyecolor2 = eye_color2[color]
	local effectname = effects[self.EffectName]

	if not IsValid(self.ParentEnt) then print("dead") return end
	
	local pcf1 = CreateParticleSystem(self.ParentEnt, effectname .. "lvl1", PATTACH_POINT_FOLLOW, 0, data:GetOrigin())
	if IsValid(pcf1) and self.Streak <= 9 and self.Streak >= 5 then
		pcf1:SetControlPoint(9,self.EyeColor1)
		pcf1:StartEmission()
	end
	
	if self.Streak >= 5 and self.Streak <= 9 then
	elseif self.Streak > 9 then
		if IsValid(pcf1) then
			pcf1:StopEmissionAndDestroyImmediately()
		end

		local pcf2 = CreateParticleSystem(self, effectname .. "lvl2", PATTACH_POINT_FOLLOW, 0, data:GetOrigin())
		if !IsValid(pcf2) and self.Streak > 9 then
			pcf2:SetControlPoint(9,self.EyeColor2)
			pcf2:StartEmission()
		end
	else
		if IsValid(pcf1) then
			pcf1:StopEmissionAndDestroyImmediately()
		end

		if IsValid(pcf2) then
			pcf2:StopEmissionAndDestroyImmediately()
		end
	end

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end