--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

-- disable specific techs to be available before BOTH doors are opened:
-- - 'contamination' .. as it allows exploits
local ns2_SetTechNodeChanged = TechTree.SetTechNodeChanged
function TechTree:SetTechNodeChanged(node, logMsg)
    if node:GetTechId() == kTechId.Contamination then

        local front, siege, suddendeath = GetGameInfoEntity():GetSiegeTimes()
        if front > 0 and siege > 0 then
            node.available = false
            return
        end

    end
    ns2_SetTechNodeChanged(self, node, logMsg)
end
