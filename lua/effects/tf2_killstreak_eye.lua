function EFFECT:Init(data)
	self.PlyEnt = data:GetEntity()
	local streak = math.Clamp(self.PlyEnt:GetNW2Int("killstreak", 0), 0, 20)
	local colorvar = self.PlyEnt:GetNW2String("killstreakcolor", nil)
	local color1 = eye_color1[colorvar]
	local color2 = eye_color2[colorvar]
	local effectvar = self.PlyEnt:GetNW2String("killstreakeffect",nil)
	local effectname = effects[effectvar]
	
	if not IsValid(self.PlyEnt) then return end
	
	if streak >= 5 and streak <= 9 then
		local pcf = CreateParticleSystem(self.PlyEnt, effectname .. "lvl1", PATTACH_POINT_FOLLOW, 0, data:GetOrigin())
		if IsValid(pcf) and streak <= 9 and streak >= 5 then
			pcf:SetControlPoint(9,color1)
			pcf:StartEmission()
		end
	elseif streak > 9 then
	
		if IsValid(pcf) then
			pcf:StopEmissionAndDestroyImmediately()
		end
	
		local pcf2 = CreateParticleSystem(self.PlyEnt, effectname .. "lvl2", PATTACH_POINT_FOLLOW, 0, data:GetOrigin())
		if IsValid(pcf2) and streak > 9 then
			pcf:SetControlPoint(9,color2)
			pcf:StartEmission()
		end
	else
		if IsValid(pcf) then
			pcf:StopEmissionAndDestroyImmediately()
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