local level = {}

function level.new()

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

	function self.draw()	
		
		x1,y1 = bezier_curve:evaluate(player_curve_position)

		love.graphics.line(bezier_curve:render())

		love.graphics.print(player_rotation, x1, 50)

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




return level

