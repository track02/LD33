local player = {}


function player.new(level)

	local self = {}
	local rotation = 0
	local width = 10
	local height = 10
	local radius = 5
	local level_curve = level
	local level_curve_original = level
	local level_position = 0
	local x,y =  0,0
	local cx,cy = 0,0
	local move_dir = 1
	local move_speed = 0.0075
	
	local attack_distance = 0.005
	local attack_multiplier = 1
	local attack_travel_speed = 0.001
	

	local display_arc = false
	local jump_arc = level
	local jump_end = level_position + (3 * move_speed)
	local jump_arcspeed = 0.00333
	local jump_speed = 0.75
	local jumping = false
	local landed = false
	local jump_dir = 0
	local jump_cancel = false	

	--Attacks travel along the level, from player level_position to an end point
	local attacks = {}

	function self.move(direction)
		if(not jumping and not display_arc) then
			move_dir = direction
		end

		if(jumping) then
			jump_dir = direction
		end

		if(display_arc) then
			jump_cancel = true
			display_arc = false
			move_dir = direction
			
		end

	end

	function self.showJump()
	

		if(not jumping and not jump_cancel) then	
			display_arc = true
							
			--move jump landing zone while key is held down	
			jump_end = jump_end + (jump_arcspeed * move_dir)
		
			if(jump_end > 1) then
				jump_end = 1
			elseif(jump_end < 0) then
				jump_end = 0
			end

			endx,endy = level_curve:evaluate(jump_end)
			dx,dy = endx, endy		

			if(x < endx) then
				dx = (x - endx)
				dy = (y - endy)
			else
				dx = (endx - x)
				dy = (endy - y)
			end
		
			jump_arc = love.math.newBezierCurve(x,y, endx,endy -100,  endx, endy)	
		end
	end

	function self.jump()

		if(not jumping and not jump_cancel) then
	
			display_arc = false
			jumping = true				
			level_curve = jump_arc
			level_position = 0
			jump_dir = move_dir --Hold movement direction
			move_dir = 0 --Set movement direction to 0, otherwise will rotate along jump curve
		end
		if(jump_cancel) then
			display_arc = false
			jump_cancel = false
		end

		
	end	


	function self.attack()


		--Add new attack -> adjust for facing left!
		attack = {}

		attack.dir = 1		

		if(move_dir == 1 or move_dir == 0) then
			attack.dir = 1
		else
			attack.dir = -1
		end		

		attack.start_position = level_position
		attack.end_position = level_position + (attack_distance * attack.dir) 
		attack.position = level_position
		attack.speed = (attack_travel_speed * attack.dir) 


		--Check positions, ensure they don't leave level
		if(attack.end_position < 0) then
			attack.end_position = 0
		elseif(attack.end_position > 1)then
			attack.end_position = 1
		end

		table.insert(attacks, attack)		

	end

	function self.jump_attacks()

		attack_L = {}
		attack_R = {}
		
		attack_L.dir = -1
		attack_R.dir = 1

		attack_L.start_position, attack_R.start_position = level_position, level_position
		attack_L.end_position, attack_R.end_position = level_position + (attack_distance * attack_L.dir), level_position + (attack_distance * attack_R.dir)
		attack_L.position, attack_R.position = level_position, level_position
		attack_L.speed, attack_R.speed = (attack_travel_speed * attack_L.dir), (attack_travel_speed * attack_R.dir)

		--Check positions, ensure they don't leave level
		if(attack_L.end_position < 0) then
			attack_L.end_position = 0
		elseif(attack_L.end_position > 1)then
			attack_L.end_position = 1
		end


		--Check positions, ensure they don't leave level
		if(attack_R.end_position < 0) then
			attack_R.end_position = 0
		elseif(attack_R.end_position > 1)then
			attack_R.end_position = 1
		end

		table.insert(attacks,attack_L)
		table.insert(attacks,attack_R)	



	end
	

	
	function self.attack_update()

		toremove = {}

		--Move attack along
		for i = 1, #attacks, 1 do
			attacks[i].position = attacks[i].position + (attacks[i].speed)
			
	
			if((attacks[i].position >= attacks[i].end_position and attacks[i].dir== 1) or (attacks[i].position <= attacks[i].end_position and attacks[i].dir == -1)) then

				table.insert(toremove, i)
			end
			
		end
		
		for i =1, #toremove, 1 do
			table.remove(attacks, i)
		end


	end



	function self.update(dt)
		
		--Determine x,y coords on the curve at next frame

		if(jumping) then
			level_position = level_position + (dt * jump_speed)
			
			--Jump ended, return to level
			if(level_position >= 1) then
				level_position = jump_end
				level_curve = level_curve_original
				jumping = false
				landed = true
			end

		elseif(not jumping) then
			level_position = level_position + (dt * move_speed * move_dir)  
		end

		

		if(level_position > 1) then
			level_position = 1
		elseif(level_position < 0) then
			level_position = 0
		end

		new_x,new_y = level_curve:evaluate(level_position)
		--Add_next frame jump height

		--Calculate difference between current and new position
		if(x < new_x) then --Left -> Right
			dx =(x - new_x)
			dy =(y - new_y)
		else --Right -> Left
			dx = (new_x - x)
			dy = (new_y - y)
		end


		--Determine rotation required for new position
		if(move_dir ~= 0) then
			rotation = math.atan2(dy,dx)
		end
		--Update coordinates to new values
		x = new_x
		y = new_y
		cx = x + ((width/2)*move_dir)
		cy = y - (height/2)

		self.attack_update()


		if(not jumping and not display_arc) then
			jump_end = level_position + (move_speed * move_dir)
		end

		if(landed) then
			move_dir = jump_dir --Reset move_dir on landing
			landed = false
			self.jump_attacks()
		end
	end

	


	function self.draw()

		love.graphics.push()

		love.graphics.translate(x, y)
		love.graphics.rotate(rotation)
		love.graphics.translate(-x, -y)
		
		love.graphics.rectangle(
					"fill",
					x,
					y,
					width,
					height)
		
		love.graphics.setColor(204,0,204)
		love.graphics.circle("fill", (x+width/2),(y+height/2),3,10)
		love.graphics.setColor(255,255,255)
			
		love.graphics.pop()
		
		love.graphics.print("Y Position: " .. y, x, 100)
		love.graphics.print("X Position: " .. x, x, 110)
		love.graphics.print("ATTACK NO: " .. #attacks, x,150)
		love.graphics.print("JUMP END: " .. jump_end, x, 175)
		love.graphics.print("MOVE DIR: ".. move_dir ,x, 190)
--		love.graphics.circle("line", (x-width/2), (y-height/2), radius, 10)
		love.graphics.setColor(204,0,204)

		--Draw attacks
		for i=1, #attacks, 1 do
			atk_x, atk_y = level:evaluate(attacks[i].position)
			love.graphics.print("Current Position: " .. attacks[i].position .. "End Position: " .. attacks[i].end_position, x, 175)
			love.graphics.circle("fill", atk_x, atk_y, 5, 5)
		end

		love.graphics.setColor(255,255,255)

		if(display_arc) then
			love.graphics.print("PLOTTING JUMP", x, 160)
			love.graphics.line(jump_arc:render())
		end


	end

	function self.getCurvePosition()
		return level_position
	end

	function self.getAttacks()
		return attacks
	end
	
	function self.getPosition()
		return x,y
	end

	function self.getCenter()
		return (x-width/2),(y-height/2)		

	end
	
	function self.getRadius()
		return radius
	end

	self.move(0)
	return self

end

return player

