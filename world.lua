local _npcmanager = require('npcmanager')
local _player = require('player')
local world = {}


function world.new()

	local self = {}
	local level_length = 2000
	local buildings = {}
	local bezier_curve
	local control_points_no = 10 
	local control_points  = {}
	local buildingno = 8
	local buildingsprite = love.graphics.newImage("building.png")
	local score = 0

	for i = 1, control_points_no, 1 do

		if(i == 1) then
			table.insert(control_points, 0)
			table.insert(control_points, 500)
		end
		
			table.insert(control_points,i*300)
			table.insert(control_points, math.random(400,500))


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
		
		curve_point = i * 0.1		
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

	local below_polyverts = bezier_curve:render()
	table.insert(below_polyverts, level_length)
	table.insert(below_polyverts, 600)
	table.insert(below_polyverts, 0)
	table.insert(below_polyverts, 600)
	
	local above_polyverts = bezier_curve:render()
	table.insert(above_polyverts, level_length)
	table.insert(above_polyverts, 0)
	table.insert(above_polyverts, 0)
	table.insert(above_polyverts, 0)

	function self.draw()	
		
		love.graphics.line(bezier_curve:render())
		love.graphics.setColor(178,209,209)
		love.graphics.polygon("fill", above_polyverts)
		love.graphics.setColor(153, 255, 153)
		love.graphics.polygon("fill", below_polyverts)
		love.graphics.setColor(255,255,255)
		
		px,py = player.getPosition()
		love.graphics.print("Score: " .. score, 50 + px, 50)
		love.graphics.print("Life: " .. player.getHealth(), 50+px, 60)	

		for i = 1, #buildings, 1 do
			
			--Store coordinate system	
			love.graphics.push()
	
			--Rotate buildings along curve
			love.graphics.draw(buildingsprite, buildings[i].x, buildings[i].y, buildings[i].rotation)

			--Restore original coordinate system
			love.graphics.pop()

			cx,cy = player.getCenter()

		end

		player.draw()
		npcs.drawNPCs()

	end

	function self.update(dt)
		px, py = player.getPosition()
		cx,cy = player.getCenter()

		npcs.createNPCs()
		npcs.updateNPCs(px, py, cx, cy)
		player.update(dt)
		score = score + npcs.checkHits(player.getAttacks())
		health = npcs.checkProjHits(cx, cy, player.getRadius())
		player.decreaseHealth(health)

	end

	
	function self.movePlayer(t)
		player.move(t)
	end	

	function self.jumpPlayer()
		player.jump()
	end
	
	function self.attackPlayer()
		player.attack()
	end

	function self.plotJumpPlayer()
		player.showJump()
	end


	function self.getPlayerPosition()
		return player.getCenter()
	end

	function self.getScore()
		return score
	end
	
	function self.continueGame()
		if(player.getHealth() <= 0) then
			return false
		else
			return true
		end
	end
	return self
end	




return world 

