local player = {}


function player.new(level)

	local self = {}
	local rotation = 0
	local width = 10
	local height = 10
	local level_curve = level
	local level_position = 0
	local x,y =  0,0

	local move_dir = 1
	local move_speed = 0.001

	local jumpticks_max = 35
	local jumpticks = 0
	local jump_speed = 25
 	local jumping = false	
	local jump_y = 0
	
	local attack_distance = 0.0025
	local attack_multiplier = 1
	local attack_travel_speed = 0.0001

	--Attacks travel along the level, from player level_position to an end point
	local attacks = {}

	function self.move(direction)
		move_dir = direction		
	end

	function self.jump()
	
		if(jumpticks == 0) then
			jumping = true
			jump_y = 0 --Grab current y position
		end



	end	


	function self.attack()


		--Add new attack -> adjust for facing left!
		attack = {}
		attack.start_position = level_position
		attack.end_position = level_position + (attack_distance  ) 
		attack.position = level_position	

		table.insert(attacks, attack)		


	end

	local function attack_update()

		toremove = {}

		--Move attack along
		for i = 1, #attacks, 1 do
			attacks[i].position = attacks[i].position + attack_travel_speed
		
			if(attacks[i].position >= attacks[i].end_position or attacks[i].position < 0 or attacks[i].position > 1) then
				table.insert(toremove, i)
			end
			
		end
		
		for i =1, #toremove, 1 do
			table.remove(attacks, i)
		end


	end



	function self.update(dt)
		
		prev_jump_y = jump_y

		--Determine jump height to apply
		--Going up
		if(jumpticks < jumpticks_max and jumping) then
			jump_y = jump_y - (jump_speed * dt)
			jumpticks = jumpticks + 1

			if(jumpticks >= jumpticks_max) then
				jumping = false
			end

		--Going down
		elseif(jumpticks > 0 and not jumping) then
			jump_y = jump_y + (jump_speed * dt)
			jumpticks = jumpticks - 1
		end	
		
		--Determine x,y coords on the curve at next frame
		level_position = level_position + (dt * move_speed * move_dir)  

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
			dy =((y - prev_jump_y) - new_y)
		else --Right -> Left
			dx = (new_x - x)
			dy = (new_y - (y - prev_jump_y))
		end


		--Determine rotation required for new position
		if(move_dir ~= 0) then
			rotation = math.atan2(dy,dx)
		end
		--Update coordinates to new values
		x = new_x
		y = new_y + jump_y


		attack_update()

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
					
		love.graphics.pop()
		
		love.graphics.print("Y Position: " .. y, x, 100)
		love.graphics.print("X Position: " .. x, x, 110)
		love.graphics.print("Jump Height: " ..jump_y, x, 120)
		love.graphics.print("ATTACK NO: " .. #attacks, x,150)

		love.graphics.setColor(204,0,204)

		--Draw attacks
		for i=1, #attacks, 1 do
			atk_x, atk_y = level:evaluate(attacks[i].position)
			love.graphics.print("Current Position: " .. attacks[i].position .. "End Position: " .. attacks[i].end_position, x, 175)
			love.graphics.circle("fill", atk_x, atk_y, 5, 5)
		end

		love.graphics.setColor(255,255,255)

	end

	function self.getCurvePosition()
		return level_position
	end

	function self.getAttacks()
		return attacks
	end


	self.move(0)
	return self

end

return player

