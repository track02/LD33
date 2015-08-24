local npc = {}

function npc.new(_npctype, level, curve_position)

	local self  = {}
	local rotation = 0
	local width = 5
	local height = 5
	local level_curve = level
	local level_position = curve_position
	local x,y = 0,0
	local movetime = 500
	local flee_distance = 100
	local charge_distance = 150	
	local fire_distance = 400
	local magic_distance = 250
	local move_speed = 0.0001
	local fly_speed = 0.01
	local npctype = _npctype -- 0 Civ / 1 War / 2 Rng / 3 Clr (Try and move to inheritance structure if time allows!)
	local projectiles = {}
	


	function self.move(increment)	

		level_position = level_position + increment
		
		if(level_position > 1) then
			level_position = 1
		elseif(level_position < 0) then
			level_position = 0
		end

		new_x, new_y = level_curve:evaluate(level_position)

		if(x < new_x) then
			dx = (x - new_x)
			dy = (y - new_y)
		else
			dx = (new_x - x)
			dy = (new_y - y)
		end

		rotation = math.atan2(dy,dx)
		x = new_x
		y = new_y

	end


	function self.draw()

		if(npctype == 1) then
			love.graphics.setColor(255,0,0)
			love.graphics.print("WARRIOR", 400,300)
		end
		
		if(npctype == 2) then
			love.graphics.setColor(0,255,0)
			love.graphics.print("RANGER", 400,400)
			if(#projectiles ~= 0) then
				love.graphics.line(projectiles[1].curve:render())
			end
		end


		if(npctype == 3) then
			love.graphics.setColor(0,0,255)
			love.graphics.print("WIZARD", 400,300)
			if(#projectiles ~= 0) then
				love.graphics.line(projectiles[1].curve:render())
		end



		end

		love.graphics.push()

		love.graphics.translate(x,y)
		love.graphics.rotate(rotation)
		love.graphics.translate(-x,-y)

		love.graphics.rectangle(
					"fill",
					x,
					y,
					width,
					height)

		love.graphics.pop()
		
		love.graphics.setColor(255,255,255)

	end
	
	--Random Movement
	local function randomMovement()

		if(math.random() > 0.85) then
			self.move(move_speed)
		else
			self.move(-move_speed)
		end
	end

	
	--Different behaviours civilian / warrior / ranger / cleric
	local function civilianFlee(player_curve_position)


		--Determine player position
		px,py = level_curve:evaluate(player_curve_position)


		--Determine distance from NPC
		dx = math.abs(px - x)
		dy = math.abs(py - y)
		distance = math.sqrt((dx*dx) + (dy*dy))	

		--Run from player
		if (distance <= flee_distance) then
		
			--Is player to the left
			if(px < x) then
				self.move(move_speed)
			else
				self.move(-move_speed)
			end
		else
			randomMovement()
		end

	end


	local function warriorAttack(player_curve_position)

		-- PULL THIS OUT INTO UTILITY
		--Determine player position
		px,py = level_curve:evaluate(player_curve_position)

		--Determine distance from NPC
		dx = math.abs(px - x)
		dy = math.abs(py - y)
		distance = math.sqrt((dx*dx) + (dy*dy))
		
		--Rush player
		if(distance <= charge_distance) then
	
			--player to left
			if(px < x) then
				self.move(-move_speed)
			else
				self.move(move_speed)
			end
		else
			randomMovement()
		end

	end	
	
	local function rangerAttack(player_curve_position)
	
		-- PULL THIS OUT INTO UTILITY
		--Determine player position
		px,py = level_curve:evaluate(player_curve_position)

		--Determine distance from NPC
		dx = math.abs(px - x)
		dy = math.abs(py - y)
		distance = math.sqrt((dx*dx) + (dy*dy))
		
		--Too close to ranger, flee back
		if(distance <= flee_distance) then
			--Is player to the left
			if(px < x) then
				self.move(move_speed)
			else
				self.move(-move_speed)
			end
		elseif(distance > flee_distance and distance <= fire_distance) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,dx/2, dy/2, px,py)
			table.insert(projectiles,projectile)
		else
			randomMovement()
		end
		

	end


	local function mageAttack(player_curve_position)
			
		-- PULL THIS OUT INTO UTILITY
		--Determine player position
		px,py = level_curve:evaluate(player_curve_position)

		--Determine distance from NPC
		dx = math.abs(px - x)
		dy = math.abs(py - y)
		distance = math.sqrt((dx*dx) + (dy*dy))
		
		--Too close to ranger, flee back
		if(distance <= flee_distance) then
			--Is player to the left
			if(px < x) then
				self.move(move_speed)
			else
				self.move(-move_speed)
			end
		elseif(distance > flee_distance and distance <= magic_distance) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,px,py)
			table.insert(projectiles,projectile)
		else
			randomMovement()
		end


	end

	function self.update(player_curve_position) 


		if(npctype == 0) then
			civilianFlee(player_curve_position)
		elseif(npctype == 1) then
			warriorAttack(player_curve_position)
		elseif(npctype == 2) then
			rangerAttack(player_curve_position)
		elseif(npctype == 3) then
			mageAttack(player_curve_position)
		elseif(npctype == 5) then
			self.move(fly_speed)
		end	


	end


	function self.getLevelPosition()
		return level_position
	end

	function self.getType()
		return npctype
	end

	function self.hit()
		--Change type, destroyed
		npctype = 5
		
		--Generate random curve, flying off level
		level_curve = love.math.newBezierCurve(x,y, x,  y, x+ math.random(50,100), y - 50)
		level_position = 0
	end
		



	return self

end	

return npc 

