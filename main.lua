local _world = require('world')

function love.conf(t)
end

function love.load()

	love.keyboard.setKeyRepeat(true)
	
	world = _world.new()
	translate_x = 0
	translate_y = 0

end

function love.update(dt)
	
	opx, opy = world.getPlayerPosition()

	world.update(dt)

	px,py = world.getPlayerPosition()

	--Translate world as player moves along
	dx = px - opx


	if(px % 800 <= 400) then
	--	translate_x = translate_x - dx	
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

end

function love.mousemoved(x,y,dx,dy)
end

function love.draw()

	px,py = world.getPlayerPosition()
	love.graphics.translate(translate_x, translate_y)
	world.draw()

end
