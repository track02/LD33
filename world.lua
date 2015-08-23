local _npcmanager = require('npcmanager')
local _player = require('player')
local world = {}


function world.new()

	local self = {}
	local level_length =10000 
	local buildings = {}
	local bezier_curve
	local control_points_no = 50 
	local control_points  = {}
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
	local player = _player.new(bezier_curve) --World contains a player
	local npcs = _npcmanager.new(bezier_curve)

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
		
		love.graphics.line(bezier_curve:render())

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

		player.draw()

		npcs.drawNPCs()

	end


	function self.update(dt)
		npcs.createNPCs()
		npcs.updateNPCs(player.getCurvePosition())
		player.update(dt)
	end

	
	function self.movePlayer(t)
		player.move(t)
	end	

	function self.jumpPlayer()
		player.jump()
	end

	return self
end	




return world 

