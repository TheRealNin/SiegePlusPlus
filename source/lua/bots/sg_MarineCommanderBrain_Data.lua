 Script.Load("lua/bots/CommonActions.lua")
Script.Load("lua/bots/BrainSenses.lua")

local kStationBuildDist = 20.0
local kPowerPointDist = 30.0
local kProtoDist = 5.0

local function CreateBuildNearStationAction( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureAction(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "CommandStation",
            kStationBuildDist )
end

local function CreateBuildNearStationActionLate( techId, className, numToBuild, weightIfNotEnough , lateTime)

    return CreateBuildStructureActionLate(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "CommandStation",
            kStationBuildDist,
            lateTime)
end
local function CreateBuildNearEachPower( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureActionForEach(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "PowerPoint",
            kPowerPointDist )
end

local function CreateBuildNearEachProto( techId, className, numToBuild, weightIfNotEnough )

    return CreateBuildStructureActionForEach(
            techId, className,
            {
            {-1.0, weightIfNotEnough},
            {numToBuild-1, weightIfNotEnough},
            {numToBuild, 0.0}
            },
            "PrototypeLab",
            kProtoDist )
end


kMarineComBrainActions =
{
    CreateBuildNearStationAction( kTechId.ArmsLab        , "ArmsLab"        , 1 , 9.1) ,
    CreateBuildNearStationAction( kTechId.PrototypeLab   , "PrototypeLab"   , 1 , 3) ,
    CreateBuildNearStationActionLate( kTechId.ArmsLab        , "ArmsLab"        , 2 , 2.0, 3) ,
    CreateBuildNearStationActionLate( kTechId.Observatory    , "Observatory"    , 1 , 2.0, 3) ,
    CreateBuildNearStationActionLate( kTechId.Armory         , "Armory"         , 1 , 3.0 , 1.5),
    CreateBuildNearStationActionLate( kTechId.PhaseGate      , "PhaseGate"      , 1 , 1, 4) ,
    CreateBuildNearStationActionLate( kTechId.RoboticsFactory, "RoboticsFactory", 1 , 0.1, 5) ,
    CreateBuildNearStationActionLate( kTechId.ARCRoboticsFactory, "ARCRoboticsFactory", 1 , 0.1, 5) ,
    CreateBuildNearStationActionLate( kTechId.InfantryPortal , "InfantryPortal" , 4 , 0.2, 4.5) ,
    
    -- todo: Fix this for maps with 2 tech points in marine start
    --CreateBuildNearStationActionLate( kTechId.CommandStation , "CommandStation" , 3 , 0.2, 5) ,
    
    
    CreateBuildNearEachPower( kTechId.Armory         , "Armory"         , 1 , 0.2 ),
    CreateBuildNearEachPower( kTechId.PhaseGate      , "PhaseGate"      , 1 , 0.3 ),
    CreateBuildNearEachPower( kTechId.PrototypeLab   , "PrototypeLab"   , 1 , 0.1 ),
    CreateBuildNearEachPower( kTechId.Observatory    , "Observatory"    , 1 , 0.1 ),

    -- Upgrades from structures
    CreateUpgradeStructureAction( kTechId.ExosuitTech           , 3.1 ) ,
    CreateUpgradeStructureAction( kTechId.AdvancedArmoryUpgrade , 3.5 ) ,
    CreateUpgradeStructureAction( kTechId.UpgradeRoboticsFactory , 1.5 ) ,
    CreateUpgradeStructureAction( kTechId.MAC , 0.5 ) ,
    CreateUpgradeStructureActionLate( kTechId.ShotgunTech           , 1.0 , nil,  4) ,
    CreateUpgradeStructureActionLate( kTechId.JetpackTech           , 2.9 , nil,  4) ,
    CreateUpgradeStructureActionLate( kTechId.MinesTech             , 0.2 , nil,  4) ,
    CreateUpgradeStructureActionLate( kTechId.HeavyMachineGunTech   , 1.1 , nil,  4) ,
    CreateUpgradeStructureActionLate( kTechId.GrenadeTech           , 0.3 , nil,  4) ,
    

    CreateUpgradeStructureAction( kTechId.PhaseTech , 2.0),

    CreateUpgradeStructureAction( kTechId.Weapons1 , 5.0 ) ,
    CreateUpgradeStructureAction( kTechId.Weapons2 , 4.0 ) ,
    CreateUpgradeStructureAction( kTechId.Weapons3 , 2.5 ) ,
    CreateUpgradeStructureAction( kTechId.Armor1   , 5.0 ) ,
    CreateUpgradeStructureAction( kTechId.Armor2   , 4.0 ) ,
    CreateUpgradeStructureAction( kTechId.Armor3   , 2.5 ) ,
    
    -- for some reason the bot can't do this. I don't know why!
    --CreateUpgradeStructureAction( kTechId.PowerSurgeTech , 0.2 ),
    --CreateUpgradeStructureAction( kTechId.CatPackTech    , 0.2 ),
    --CreateUpgradeStructureAction( kTechId.NanoShieldTech , 0.2 ),

    function(bot, brain)

        local name = "commandstation"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetTP

        -- Find a cc slot!
        targetTP = sdb:Get("techPointToTake")

        if targetTP then
            weight = 2
        end
        
        if (sdb:Get("gameMinutes") < 6) then
            weight = 0
        end

        return { name = name, weight = weight,
            perform = function(move)
                if (sdb:Get("gameMinutes") < 6) then
                    return
                end
                if doables[kTechId.CommandStation] and targetTP then
                    local sucess = brain:ExecuteTechId( com, kTechId.CommandStation, targetTP:GetOrigin(), com )
                end
            end}
    end,
    function(bot, brain)

        local weight = 0
        local team = bot:GetPlayer():GetTeam()
        local numDead = team:GetNumPlayersInQueue()
        if numDead > 1 then
            weight = 5.0
        end

        return CreateBuildNearStationAction( kTechId.InfantryPortal , "InfantryPortal" , 4 , weight )(bot, brain)
    end,
    
    function(bot, brain)

        local name = "dropjetpacks"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0
        local maxJetpacks = 10
        local team = bot:GetPlayer():GetTeam()
        
        local doables = sdb:Get("doableTechIds")
        if doables[kTechId.DropJetpack] then
            weight = 1.5
        end
        local jetpacks = GetEntitiesForTeam("Jetpack", kMarineTeamType)
        if #jetpacks > maxJetpacks then 
            weight = 0
        end
        
        
        return { name = name, weight = weight,
            perform = function(move)
                
                --if (sdb:Get("gameMinutes") < 5) then
                --    return
                --end
                local protoLabs = GetEntitiesForTeam("PrototypeLab", kMarineTeamType)
                if #protoLabs <= 0 then return end
                local proto = protoLabs[math.random(#protoLabs)]
                if not proto:GetIsBuilt() or not proto:GetIsAlive() then
                    return
                end
                
                local jetpacks = GetEntitiesForTeam("Jetpack", kMarineTeamType)
                if #jetpacks > maxJetpacks then return end
                
                local aroundPos = proto:GetOrigin()
                
                local targetPos = GetRandomSpawnForCapsule(0.4, 0.4, aroundPos, 0.01, kArmoryWeaponAttachRange * 0.5, EntityFilterAll(), nil)
                if targetPos then
                    local sucess = brain:ExecuteTechId(com, kTechId.DropJetpack, targetPos, com, proto:GetId())
                end
            end}
    end,
    
    
    function(bot, brain)

        local name = "dropmachineguns"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local weight = 0
        local maxMgs = 10
        local team = bot:GetPlayer():GetTeam()
        
        local doables = sdb:Get("doableTechIds")
        if doables[kTechId.DropHeavyMachineGun] then
            weight = 1.5
        end
        local mgs = GetEntitiesForTeam("HeavyMachineGun", kMarineTeamType)
        if #mgs > maxMgs then 
            weight = 0
        end
        
        
        return { name = name, weight = weight,
            perform = function(move)
                
                --if (sdb:Get("gameMinutes") < 5) then
                --    return
                --end
                local aas = GetEntitiesForTeam("AdvancedArmory", kMarineTeamType)
                if #aas <= 0 then return end
                local armory = aas[math.random(#aas)]
                if not armory:GetIsBuilt() or not armory:GetIsAlive() then
                    return
                end
                
                local mgs = GetEntitiesForTeam("HeavyMachineGun", kMarineTeamType)
                if #mgs > maxMgs then return end
                
                local aroundPos = armory:GetOrigin()
                
                local targetPos = GetRandomSpawnForCapsule(0.5, 0.5, aroundPos, 0.01, kArmoryWeaponAttachRange * 0.5, EntityFilterAll(), nil)
                if targetPos then
                    local sucess = brain:ExecuteTechId(com, kTechId.DropHeavyMachineGun, targetPos, com, armory:GetId())
                end
            end}
    end,

    function(bot, brain)

        local name = "extractor"
        local com = bot:GetPlayer()
        local sdb = brain:GetSenses()
        local doables = sdb:Get("doableTechIds")
        local weight = 0.0
        local targetRP

        if doables[kTechId.Extractor] and 
            (sdb:Get("gameMinutes") < 4 or (not bot.nextRTDrop or bot.nextRTDrop < Shared.GetTime())) then

            targetRP = sdb:Get("resPointToTake")

            if targetRP ~= nil then
                weight = EvalLPF( sdb:Get("numExtractors"),
                    {
                        {0, 10.0},
                        {4, 8.0},
                        {6, 5.0},
                        {8, 4.0},
                        {16,3.0},
                        })

            end
        end

        return { name = name, weight = weight,
            perform = function(move)
                if targetRP ~= nil then
                    bot.nextRTDrop =  Shared.GetTime() + 2
                    local success = brain:ExecuteTechId( com, kTechId.Extractor, targetRP:GetOrigin(), com )
                end
            end}
    end,

    function(bot, brain)

        local name = "droppacks"
        local com = bot:GetPlayer()
        local alertqueue = com:GetAlertQueue()

        --save times of having players last served to ignore spam
        bot.lastServedDropPack = bot.lastServedDropPack or {}

        local reactTechIds = {
            [kTechId.MarineAlertNeedAmmo] = kTechId.AmmoPack,
            [kTechId.MarineAlertNeedMedpack] = kTechId.MedPack
        }

        local techCheckFunction = {
            [kTechId.MarineAlertNeedAmmo] = function(target)
                local weapon = target:GetActiveWeapon()

                local ammoPercentage = 1
                if weapon and weapon:isa("ClipWeapon") then
                    local max = weapon:GetMaxAmmo()
                    if max > 0 then
                        ammoPercentage = weapon:GetAmmo() / max
                    end
                end

                return ammoPercentage
            end,
            [kTechId.MarineAlertNeedMedpack] = function(target)
                return target:GetHealthFraction() end
        }

        local weight = 0.0
        local targetPos, targetId
        local techId

        local time = Shared.GetTime()

        for i, alert in ipairs(alertqueue) do
            local aTechId = alert.techId
            local targetTechId = reactTechIds[aTechId]
            local target
            if targetTechId and time - alert.time < 0.5 then
                target = Shared.GetEntity(alert.entityId)

                local lastServerd = bot.lastServedDropPack[alert.entityId]
                local servedTime = lastServerd and lastServerd.time or time
                local servedCount = lastServerd and lastServerd.count or 0

                --reset count if last served drop pack is more than 5 secs ago
                if servedCount > 0 and time - servedTime > 5 then
                    servedCount = 0
                    bot.lastServedDropPack[alert.entityId] = nil
                end

                if target and servedCount < 3 and time - servedTime < 2 then
                    local alertPiority = EvalLPF( techCheckFunction[aTechId](target),
                    {
                        {0, 6.0},
                        {0.5, 3.0},
                        {1, 0.0},
                    })

                    if alertPiority == 0 then
                        target = nil
                    elseif alertPiority > weight then
                        techId = targetTechId
                        weight = alertPiority
                        targetPos = target:GetOrigin() --Todo Add jitter to position
                        targetId = target:GetId()
                    end
                end
            end

            if not target then
                table.remove(alertqueue, i)
            end
        end

        com:SetAlertQueue(alertqueue)

        return { name = name, weight = weight,
            perform = function(move)
                if targetId then
                    local sucess = brain:ExecuteTechId( com, techId, targetPos, com, targetId )
                    if sucess then
                        bot.lastServedDropPack[targetId] = bot.lastServedDropPack[targetId] or {}
                        local count = bot.lastServedDropPack[targetId].count or 0

                        bot.lastServedDropPack[targetId].time = Shared.GetTime()
                        bot.lastServedDropPack[targetId].count = count + 1
                    end
                end
            end}
    end,
    

    function(bot, brain)

        return { name = "idle", weight = 1e-5,
            perform = function(move)
                if brain.debug then
                    DebugPrint("idling..")
                end 
            end}
    end
}

------------------------------------------
--  Build the senses database
------------------------------------------

function CreateMarineComSenses()

    local s = BrainSenses()
    s:Initialize()

    s:Add("gameMinutes", function(db)
            return (Shared.GetTime() - GetGamerules():GetGameStartTime()) / 60.0
            end)

    s:Add("doableTechIds", function(db)
            return db.bot.brain:GetDoableTechIds( db.bot:GetPlayer() )
            end)

    s:Add("stations", function(db)
            return GetEntitiesForTeam("CommandStation", kMarineTeamType)
            end)

    s:Add("availResPoints", function(db)
            --return GetAvailableResourcePoints()
            return ResourcePointsWithPathToCC(GetAvailableResourcePoints(), db:Get("stations"))
            end)
            
    s:Add("numExtractors", function(db)
            return GetNumEntitiesOfType("ResourceTower", kMarineTeamType)
            end)

    s:Add("numInfantryPortals", function(db)
        return GetNumEntitiesOfType("InfantryPortal", kMarineTeamType)
    end)
    
    s:Add("techPointToTake", function(db)
        local tps = GetAvailableTechPoints()
            local hives = db:Get("stations")
            local dist, tp = GetMinTableEntry( tps, function(tp)
                return GetMinPathDistToEntities( tp, hives )
                end)
            return tp
            end)

    s:Add("resPointToTake", function(db)
            local rps = db:Get("availResPoints")
            local stations = db:Get("stations")
            local dist, rp = GetMinTableEntry( rps, function(rp)
                return GetMinPathDistToEntities( rp, stations )
                end)
            return rp
            end)

    return s

end
