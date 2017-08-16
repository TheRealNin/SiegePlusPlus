
function ResourcePointsWithPathToCC(list, ccs)

    local rps = {}
    for _,cc in ipairs(ccs) do
    
        local origin = cc:GetOrigin()
        
        for _,rp in ientitylist(Shared.GetEntitiesWithClassname("ResourcePoint")) do
        
            local pathPoints = PointArray()
            if pointToUse then
            
                local hasPathToPoint = Pathing.GetPathPoints(origin, rp:GetOrigin(), pathPoints)
                
                if hasPathToPoint then
                    if not rp:GetAttached() then
                        table.insert( rps, rp )
                    end
                end
            end

        end
    end

    return rps

end

function GetMinPathDistToEntities( fromEnt, toEnts )

    local minDist
    local fromPos = fromEnt:GetOrigin()

    for _,toEnt in ipairs(toEnts) do

        local path = PointArray()
        local validPath = Pathing.GetPathPoints(fromPos, toEnt:GetOrigin(), path)
        local dist = GetPointDistance(path)

        if validPath and (not minDist or dist < minDist) then
            minDist = dist
        end

    end

    return minDist

end