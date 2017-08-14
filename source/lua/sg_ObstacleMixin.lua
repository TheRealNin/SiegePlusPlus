--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

kFuncDoorMapName = "ns2siege_funcdoor"

local ns2_GetPathingInfo = ObstacleMixin._GetPathingInfo
function ObstacleMixin:_GetPathingInfo()

    if self:GetMapName() ~= kFuncDoorMapName or not self._modelCoords then
        
        -- by default, the game tries to make a 1000 unit tall thing. It's stupid.
        local position = self:GetOrigin() + Vector(0, -3, 0)  
        local radius = LookupTechData(self:GetTechId(), kTechDataObstacleRadius, 1.0)
        local height = 8
        
        return position, radius, height
    end

    assert(self.GetObstaclePathingInfo)
    return self:GetObstaclePathingInfo()
end
