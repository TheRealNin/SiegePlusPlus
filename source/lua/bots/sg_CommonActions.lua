
function CreateBuildStructureActionForEach( techId, className, numExistingToWeightLPF, buildNearClass, maxDist)

    return function(bot, brain)

        local name = "build"..EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local coms = doables[techId]

        -- find structures we can build near
        local hosts = GetEntitiesForTeam( buildNearClass, com:GetTeamNumber() )

        if coms ~= nil and #coms > 0
        and hosts ~= nil and #hosts > 0 then
            assert( coms[1] == com )

            --local existingEnts = GetEntitiesForTeam( className, com:GetTeamNumber() )
            --weight = EvalLPF( #existingEnts, numExistingToWeightLPF )
            
            for _,host in ipairs(hosts) do
                local existingEnts = GetEntitiesForTeamWithinRange( className, com:GetTeamNumber(), host:GetOrigin(), maxDist)
                weight = EvalLPF( #existingEnts, numExistingToWeightLPF )
            end
        end

        return { name = name, weight = weight,
            perform = function(move)

                -- ultra hack!
                if (sdb:Get("gameMinutes") > 5) then
                    for _,host in ipairs(hosts) do
                        if host:GetIsBuilt() and host:GetIsAlive() then
                            local existingEnts = GetEntitiesForTeamWithinRange( className, com:GetTeamNumber(), host:GetOrigin(), maxDist + 1) -- a little fudge factor
                            if existingEnts and #existingEnts < 1 then
                                local pos = GetRandomBuildPosition( techId, host:GetOrigin(), maxDist )
                                if pos ~= nil then
                                    brain:ExecuteTechId( com, techId, pos, com )
                                end
                            end
                        end
                    end
                end

            end }
    end

end


function CreateBuildStructureActionLate( techId, className, numExistingToWeightLPF, buildNearClass, maxDist , lateTime)

    return function(bot, brain)

        local name = "build"..EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local coms = doables[techId]

        -- find structures we can build near
        local hosts = GetEntitiesForTeam( buildNearClass, com:GetTeamNumber() )

        if coms ~= nil and #coms > 0
        and hosts ~= nil and #hosts > 0 then
            assert( coms[1] == com )

            -- figure out how many exist already
            local existingEnts = GetEntitiesForTeam( className, com:GetTeamNumber() )
            weight = EvalLPF( #existingEnts, numExistingToWeightLPF )
        end

        return { name = name, weight = weight,
            perform = function(move)

                -- ultra hack!
                local team = com:GetTeam()
                if (sdb:Get("gameMinutes") < lateTime and team:GetTeamResources() < 150) then return end
                
                -- Pick a random host for now
                local host = hosts[ math.random(#hosts) ]
                local pos = GetRandomBuildPosition( techId, host:GetOrigin(), maxDist )
                if pos ~= nil then
                    brain:ExecuteTechId( com, techId, pos, com )
                end

            end }
    end

end

function CreateUpgradeStructureActionLate( techId, weightIfCanDo, existingTechId, lateTime)

    return function(bot, brain)

        local name = EnumToString( kTechId, techId )
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local structures = doables[techId]

        if structures ~= nil then

            weight = weightIfCanDo

            -- but if we have the upgrade already, halve the weight
            -- TODO THIS DOES NOT WORK WTFFF
            if existingTechId ~= nil then
--                DebugPrint("Checking if %s exists..", EnumToString(kTechId, existingTechId))
                if GetTechTree(com:GetTeamNumber()):GetHasTech(existingTechId) then
                    DebugPrint("halving weight for already having %s", name)
                    weight = weight * 0.5
                end
            end

        end

        return {
            name = name, weight = weight,
            perform = function(move)

                -- ultra hack!
                local team = com:GetTeam()
                if (sdb:Get("gameMinutes") < lateTime and team:GetTeamResources() < 150) then return end
                
                if structures == nil then return end
                
                -- choose a random host
                local host = structures[ math.random(#structures) ]
                brain:ExecuteTechId( com, techId, Vector(0,0,0), host )
                
            end }
    end

end
