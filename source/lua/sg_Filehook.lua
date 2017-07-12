--
--	ns2siege+ Custom Game Mode
--	ZycaR (c) 2016
--

ModLoader.SetupFileHook( "lua/GameInfo.lua", "lua/sg_GameInfo.lua" , "post" )
ModLoader.SetupFileHook( "lua/NS2Gamerules.lua", "lua/sg_NS2Gamerules.lua" , "post" )

-- Truce mode untill front/siege doors are closed
ModLoader.SetupFileHook( "lua/DamageMixin.lua", "lua/sg_DamageMixin.lua" , "post" )

-- Sudden death mode disable repair of CommandStation and heal Hive
ModLoader.SetupFileHook( "lua/CommandStation.lua", "lua/sg_CommandStation.lua" , "post" )
ModLoader.SetupFileHook( "lua/CommandStructure.lua", "lua/sg_CommandStructure.lua" , "post" )

-- Special dynamicaly generated obstacles for func_doors
ModLoader.SetupFileHook( "lua/ObstacleMixin.lua", "lua/sg_ObstacleMixin.lua" , "post" )

-- Cyst placement will emit signal for all func_maid entites on map ( in range of 1000 )
ModLoader.SetupFileHook( "lua/Cyst.lua", "lua/sg_Cyst.lua" , "post" )

-- Hook custom gui elements
ModLoader.SetupFileHook( "lua/GUIWorldText.lua", "lua/sg_GUIScriptLoader.lua" , "post" )

-- tech tree changes according doors
ModLoader.SetupFileHook( "lua/Balance.lua", "lua/sg_Balance.lua" , "post" )
ModLoader.SetupFileHook( "lua/TechTree_Server.lua", "lua/sg_TechTree_Server.lua" , "post" )
