local npc = {}

function npc.new(_npctype, level, curve_position)

	local self  = {}
	local rotation = 0
	local width = 5
	local height = 5
	local level_curve = level
	local level_position = curve_position
	local x,y = 0,0
	local movetimer = 500
	local movetime = 500

	local animtimer = 5
	local animtime = 0
	local up = true

	local movedir = 1
	local flee_distance = 100
	local charge_distance = 150	
	local fire_distance = 400
	local magic_distance = 250
	local move_speed = 0.0001
	local fly_speed = 0.1
	local npctype = _npctype -- 0 Civ / 1 War / 2 Rng / 3 Clr (Try and move to inheritance structure if time allows!)
	local projectiles = {}
	local hit_player = false	
	local playhx, playhy, playrad = 0,0,0
	local projectile_timer_magic = 1000
	local projectile_timer_ranger = 650	
	local projectile_time = 0
	local magsprite = love.graphics.newImage("mproj.png")
	local rngsprite = love.graphics.newImage("rproj.png")

	local sprites = {love.graphics.newImage("civ.png"), love.graphics.newImage("war.png"), love.graphics.newImage("rng.png"), love.graphics.newImage("mag.png"), love.graphics.newImage("fly.png")}

	function self.move(increment)	

		level_position = level_position + increment
		

		if(level_position > 1 ) then
			level_position = 1
			if(npctype ~= 5) then
				movedir = movedir * -1
			end
		elseif(level_position < 0) then
			level_position = 0
			if(npctype ~= t) then
				movedir = movedir * -1
			end
		end

		new_x, new_y = level_curve:evaluate(level_position)

		if(x < new_x) then
			dx = (x - new_x)
			dy = (y - new_y)
		else
			dx = (new_x - x)
			dy = (new_y - y)
		end


		if(up) then
			animtime = animtime + 1
		else 
			animtime = animtime - 1
		end

	
		if(animtime >= animtimer) then
			up = false
			animtime = animtimer
		elseif(animtime <= 0) then
			up = true
			animtime = 0
		end
				

		rotation = math.atan2(dy,dx)
		x = new_x
		y = new_y

	end


	function self.draw()
	
		if(npctype == 3) then
			if(#projectiles ~= 0) then
				projx, projy = projectiles[1].curve:evaluate(projectiles[1].position)
				love.graphics.draw(rngsprite, projx, projy)
			end
		end


		if(npctype == 4) then
			if(#projectiles ~= 0) then
				projx, projy = projectiles[1].curve:evaluate(projectiles[1].position)
				love.graphics.draw(magsprite, projx, projy)
			end		

		end

		love.graphics.translate(0, -animtime)

		if(not self.isDead()) then
			love.graphics.draw(sprites[npctype], x, y, rotation)
		end

		love.graphics.translate(0, animtime)
		love.graphics.setColor(255,255,255)

	end
	
	--Random Movement
	local function randomMovement()
		
		movetime = movetime + 1
		self.move(movedir * move_speed)

		
		if(movetime >= movetimer) then

			if(math.random() > 0.5) then
				movedir = 1
			else
				movedir = -1
			end

			movetime = 0
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
		
		projectile_time = projectile_time + 1
	
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
		elseif(distance > flee_distance and distance <= fire_distance and #projectiles < 1 and projectile_time >= projectile_timer_ranger) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,dx/2,y - 50, cx,cy)
			projectile.position = level_position
			projectile.travel_speed = 0.005
			table.insert(projectiles,projectile)
			projectile_time = 0
		else
			randomMovement()
		end
		

	end


	local function mageAttack(px, py, cx, cy)

		projectile_time = projectile_time + 1


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
		elseif(distance > flee_distance and distance <= magic_distance and #projectiles < 1 and projectile_time >= projectile_timer_magic) then
			--Create a new projectile if isn't present
			projectile = {}
			projectile.curve = love.math.newBezierCurve(x,y,cx,cy)
			projectile.position = level_position
			projectile.travel_speed = 0.004
			table.insert(projectiles,projectile)
			projectile_time = 0
		else
			randomMovement()
		end


	end

	function self.update(px, py, cx, cy) 

		if(npctype == 1) then
			civilianFlee(px,py)
		elseif(npctype == 2) then
			warriorAttack(px,py)
		elseif(npctype == 3) then
			rangerAttack(px, py, cx, cy)
		elseif(npctype == 4) then
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
		movedir = 1
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

