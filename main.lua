local _world = require('world')

function love.conf(t)
end

function love.load()
	

	love.window.setTitle("LD33 - Shrimpkin Stomp")
	love.keyboard.setKeyRepeat(true)
	
	world = _world.new()
	translate_x = 0
	translate_y = 0
	
	title = love.graphics.newImage("title.png")
	gameover = love.graphics.newImage("gameover.png")	
	gamestate = 0


end

function love.update(dt)
	


	if(gamestate == 1) then


		opx, opy = world.getPlayerPosition()

		world.update(dt)

		px,py = world.getPlayerPosition()

		--Translate world as player moves along
		dx = px - opx


		if(px > 200 and px < 1200) then
			translate_x = translate_x - dx	
		end
		
		if(not world.continueGame()) then
			gamestate = 2
		end

	end


end

function love.keypressed(key, isrepeat)

	if love.keyboard.isDown("right") then
		world.movePlayer(1)
	end	
	if love.keyboard.isDown("left") then
		world.movePlayer(-1)
	end

	if love.keyboard.isDown("up") then
		world.plotJumpPlayer()
	end


	if love.keyboard.isDown("down") then
		world.movePlayer(0)
	end

	if love.keyboard.isDown(" ") then
		world.attackPlayer()
	end

	
end

function love.keyreleased(key)

	if key == "up" then
		world.jumpPlayer()
	end

	if (key == "return" and (gamestate == 0 or gamestate == 2)) then
		world = _world.new()
		gamestate = 1
		translate_x = 0
	end

end

function love.mousemoved(x,y,dx,dy)
end

function love.draw()

	if(gamestate == 0) then
		love.graphics.draw(title)
	end	

	if(gamestate == 1) then
		px,py = world.getPlayerPosition()
		love.graphics.translate(translate_x, translate_y)
		world.draw()
	end

	if(gamestate == 2) then
		love.graphics.draw(gameover)
		love.graphics.print("FINAL SCORE: " .. world.getScore(), 350, 350)
	end

end
