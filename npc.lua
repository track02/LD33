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
	local fly_speed = 0.05
	local npctype = _npctype -- 0 Civ / 1 War / 2 Rng / 3 Clr (Try and move to inheritance structure if time allows!)
	local projectiles = {}
	local hit_player = false	
	local playhx, playhy, playrad = 0,0,0

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
	
		if(self.isDead()) then
			love.graphics.print("Dead", 500,300)
		end

		if(npctype == 1) then
			love.graphics.setColor(255,0,0)
			love.graphics.print("WARRIOR", 400,300)
		end
		
		if(npctype == 2) then
			love.graphics.setColor(0,255,0)
			love.graphics.print("RANGER", 400,400)
			if(#projectiles ~= 0) then
				projx, projy = projectiles[1].curve:evaluate(projectiles[1].position)
				love.graphics.circle("fill", projx, projy, 3, 10)
			end
			
			love.graphics.circle("line", playhx, playhy, playrad, 10)
			
		end


		if(npctype == 3) then
			love.graphics.setColor(0,0,255)
			love.graphics.print("WIZARD", 400,300)
			if(#projectiles ~= 0) then
				projx, projy = projectiles[1].curve:evaluate(projectiles[1].position)
				love.graphics.circle("fill", projx, projy, 3, 10)
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
	local function civilianFlee(px, py)


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


	local function warriorAttack(px, py)

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
	
	local function rangerAttack(px, py, cx, cy)
	
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
		elseif(distance > flee_distance and distance <= fire_distance and #projectiles < 1) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,dx/2,y - 50, cx,cy)
			projectile.position = level_position
			projectile.travel_speed = 0.005
			table.insert(projectiles,projectile)
		else
			randomMovement()
		end
		

	end


	local function mageAttack(px, py, cx, cy)
			
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
		elseif(distance > flee_distance and distance <= magic_distance and #projectiles < 1) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,cx,cy)
			projectile.position = level_position
			projectile.travel_speed = 0.004
			table.insert(projectiles,projectile)
		else
			randomMovement()
		end


	end

	function self.update(px, py, cx, cy) 

		if(npctype == 0) then
			civilianFlee(px,py)
		elseif(npctype == 1) then
			warriorAttack(px,py)
		elseif(npctype == 2) then
			rangerAttack(px, py, cx, cy)
		elseif(npctype == 3) then
			mageAttack(px, py, cx, cy)
		elseif(npctype == 5) then
			self.move(fly_speed)
		end	


		--Update projectiles
		toremove = {}

		--Move attack
		for i=1, #projectiles, 1 do
			projectiles[i].position = projectiles[i].position + projectiles[i].travel_speed
			
			if(projectiles[i].position >= 1) then
				table.insert(toremove,i)
			end
		end

		for i=1, #toremove, 1 do
			table.remove(projectiles, i)
		end
		

	end


	function self.getLevelPosition()
		return level_position
	end

	function self.getType()
		return npctype
	end

	function self.hit(attack_dir)
		--Change type, destroyed
		npctype = 5
		
		--Generate random curve, flying off level
		level_curve = love.math.newBezierCurve(x,y, x,  y, x + (attack_dir *math.random(10,20)), y - 15)
		level_position = 0
	end
		
	function self.projectileHitCheck(plx,ply,radius)

		playhx, playhy, playrad = plx, ply, radius
		hits = 0
		toremove = {}
		
		for i=1, #projectiles, 1 do

			--Get projectile coords		
			pjx,pjy = projectiles[i].curve:evaluate(projectiles[i].position)


			--Check if fall within player hitbox - circular
			--Distance between points
			dx = math.abs(pjx - plx)
			dy = math.abs(pjy - ply)
			distance = math.sqrt((dx*dx) + (dy*dy))
			
			

			if(distance <= 5) then
				hits = hits + 1
				table.insert(toremove, i)
				hit_player = true
			end
		end

		for i=1, #toremove, 1 do		
			table.remove(projectiles, i)
		end
		

		return hits

	end

	function self.isDead()

		if(npctype == 5 and level_position >= 0.99) then
			return true
		else
			return false
		end
		
	end


	return self

end	

return npc 

