
function GetIsSuddenDeathActivated()
	local front, siege, suddendeath, gameLength = GetGameInfoEntity():GetSiegeTimes()
  return suddendeath > 0
end

local oldBuildTechData = BuildTechData
function BuildTechData()
    
    local techData = oldBuildTechData()
    
    for index,record in ipairs(techData) do 
        local currentField = record[kTechDataId]
        
        if(currentField == kTechId.CommandStation) or (currentField == kTechId.Hive) then
          
          -- patch the tech data to prevent building if sudden death
            record[kTechDataBuildRequiresMethod] = GetIsSuddenDeathActivated
            record[kTechDataBuildMethodFailedMessage] = "Can't build command structures! Sudden death is active!"
        end

    end
    
    return techData
end
    