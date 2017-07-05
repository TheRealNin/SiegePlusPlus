//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

kFuncDoorMapName = "ns2siege_funcdoor"

local ns2_GetPathingInfo = ObstacleMixin._GetPathingInfo
function ObstacleMixin:_GetPathingInfo()

    if self:GetMapName() ~= kFuncDoorMapName or not self._modelCoords then
        return ns2_GetPathingInfo(self)
    end

    assert(self.GetObstaclePathingInfo)
    return self:GetObstaclePathingInfo()
end
