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
	world.update(dt)

end

function love.keypressed(key, isrepeat)

	if love.keyboard.isDown("right") then
		translate_x = translate_x - 10
		world.movePlayer(1)
	end

	if love.keyboard.isDown("left") then
		translate_x = translate_x  + 10
		world.movePlayer(-1)
	end

	if love.keyboard.isDown("up") then
		world.jumpPlayer()
	end


	if love.keyboard.isDown("down") then
		world.movePlayer(0)
	end
end

function love.mousemoved(x,y,dx,dy)
end

function love.draw()

	love.graphics.translate(translate_x, translate_y)
	world.draw()

end
