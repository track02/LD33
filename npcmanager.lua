local npcmanager = {}
local _npc = require('npc')

function npcmanager.new(level)
	
 	local self = {} 
	--Copy of the level for determining movement coords / rotation
	local level_curve = level

	--Manages complete set of NPCs
	local npcs = {}
	local npc_max = 1000 
	local deadnpc = false 
	local toremove = {}
	
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
	function self.updateNPCs(px ,py, cx, cy)

		toremove = {}		

		for i=1,#npcs,1 do
			--Determine what to do, flee, attack, heal friends
			npcs[i].update(px,py, cx, cy) 
			
			if(npcs[i].isDead()) then
				table.insert(toremove, i)
			end

		end

		for i=1,#toremove,1 do 
			deadnpc = true
			table.remove(npcs, toremove[i])
		end
	
				
	end


	--Check if an NPC has been hit by player
	function self.checkHits(attacks) 

		--Look at player attacks, see if any npc has been hit
		for a = 1, #attacks, 1 do

			--Attack start/end position
			atk_start = attacks[a].start_position
			atk_end = attacks[a].end_position


			for i=1, #npcs, 1 do

				npctype = npcs[i].getType()
				npcPosition = npcs[i].getLevelPosition()
				
				if(npctype ~= 5 
				and (npcPosition >= atk_start and npcPosition <= atk_end) 
				or (npcPosition <= atk_start and npcPosition >= atk_end)) then
					npcs[i].hit(attacks[a].dir)
				end

				--Determine if hit, react accordingly
				--npcs[i].hitcheck(centerx, centery, radius)


			end

		end


	end

	--Check if NPC projectile has hit player
	function self.checkProjHits(player_x, player_y, player_radius)
	
		hits = 0

		for i=1, #npcs, 1 do
	
			hits = hits + npcs[i].projectileHitCheck(player_x, player_y, player_radius)
		
		end
		
		return hits	
		
	end
	

	
	function self.drawNPCs()
	
		love.graphics.print("NPCS LEFT: " .. #npcs, 600,40)

		if(deadnpc) then
			love.graphics.print("NPC REMOVED!", 600, 50)
		end	
	
		for i=1, #npcs, 1 do
			npcs[i].draw()
		end		

	end	

	

 return self


end

return npcmanager






