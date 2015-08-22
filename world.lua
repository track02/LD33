local world = {}

function world.new()

	local self = {}
	local level_length =10000 

	local buildings = {}
	local path = {}
	local bezier_curve
	local control_points_no = 50 
	local control_points  = {}
	local player_curve_position = 0
	local player_coords = {x = 0, y = 0}
	local player_rotation = 0
	local buildingno = 15

	for i = 1, control_points_no, 1 do

		if(i == 1) then
			table.insert(control_points, 0)
			table.insert(control_points, 500)
		end
		
			table.insert(control_points,i*200)
			table.insert(control_points,math.random(0,800))


		if (i == control_points_no)then
			table.insert(control_points, level_length)
			table.insert(control_points, 500)
		end

	end
	
	bezier_curve = love.math.newBezierCurve(control_points)


	local buildinginc = 1 / buildingno

	for i = 1, buildingno, 1 do
		
		curve_point = math.random()	
		x,y = bezier_curve:evaluate(curve_point)
		nx,ny = bezier_curve:evaluate(curve_point + 0.0001)
		dx = x - nx
		dy = y - ny
		
		

		building = {}
		building.x = x
		building.y = y
		building.width = 75
		building.height = 75
		building.rotation = math.atan2(dy,dx)		

		table.insert(buildings,building)



	end


	function self.draw()	
		
		x1,y1 = bezier_curve:evaluate(player_curve_position)

		love.graphics.line(bezier_curve:render())

		love.graphics.print(player_rotation, x1, 50)


		for i = 1, #buildings, 1 do
			
			--Store coordinate system	
			love.graphics.push()
	
			--Rotate buildings along curve
			love.graphics.translate(buildings[i].x, buildings[i].y)
			love.graphics.rotate(buildings[i].rotation)
			love.graphics.translate(-buildings[i].x, -buildings[i].y)

			love.graphics.rectangle("fill",
						buildings[i].x,
						buildings[i].y,
						buildings[i].width,
						buildings[i].height)

			--Restore original coordinate system
			love.graphics.pop()

		end


		love.graphics.push()	

		--Translate origin to player center
		love.graphics.translate(x1, y1)
		--Rotate to follow curve
		love.graphics.rotate(player_rotation)
		--Translate back
		love.graphics.translate(-x1, -y1)

		love.graphics.rectangle(
					"fill",
					x1,
					y1,
					10,
					10)		

		love.graphics.pop()


	end
	
	function self.movePlayer(t)

		cx,cy = bezier_curve:evaluate(player_curve_position)

		player_curve_position = player_curve_position + t

		nx,ny = bezier_curve:evaluate(player_curve_position)

		--Calculate rotation
		-- atan(dy/dx) to find angle between two points
		-- Better to use atan2(dy,dx), prevents 0 division + handles quadrants 

		if(t >= 0) then --Points Left - Right
			dy = (cy-ny)
			dx = (cx-nx)
		else		--Points Right - Left
			dy = (ny-cy)
			dx = (nx-cx)
		end
		player_rotation = math.atan2(dy,dx)
		


	end	



	return self
end	




return world 

