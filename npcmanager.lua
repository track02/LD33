local npcmanager = {}
local _npc = require('npc')

function npcmanager.new(level)
	
 	local self = {} 
	--Copy of the level for determining movement coords / rotation
	local level_curve = level

	--Manages complete set of NPCs
	local npcs = {}
	local npc_max = 1000 
	
	function self.createNPCs()
	
		if(#npcs < npc_max) then
					
			npc_type = math.random()
			--Weight type creation to favour civillians
			
			if(npc_type <= 0.5) then
				--Create Civ
				table.insert(npcs, _npc.new(0, level_curve, math.random()))
			elseif(npc_type <= 0.8) then
				--Create Warrior
				table.insert(npcs, _npc.new(1, level_curve, math.random()))
			elseif(npc_type <= 0.9) then
				--Create Ranger
				table.insert(npcs, _npc.new(2, level_curve, math.random()))
			elseif(npc_type <= 1.0) then
				--Create Mage
				table.insert(npcs, _npc.new(3, level_curve, math.random()))
			end
		end

	end

	--Update NPCs based on player position
	function self.updateNPCs(player_curve_position)

		for i=1,#npcs,1 do
			--Determine what to do, flee, attack, heal friends
			npcs[i].update(player_curve_position) 
		end
	end


	--Check if an NPC has been hit by player
	function self.checkHits(centerx,centery, radius) 

		for i=1, #npcs, 1 do
			--Determine if hit, react accordingly
			--npcs[i].hitcheck(centerx, centery, radius)
		end

	end
	
	function self.drawNPCs()
		
		for i=1, #npcs, 1 do
			npcs[i].draw()
		end		


	end	


 return self


end

return npcmanager






