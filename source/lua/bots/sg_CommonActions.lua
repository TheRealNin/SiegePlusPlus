
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
                if (sdb:Get("gameMinutes") > 4) then
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
