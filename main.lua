local _level = require('world')

function love.conf(t)
end

function love.load()

	love.keyboard.setKeyRepeat(true)
	
	level = _level.new()
	translate_x = 0
	translate_y = 0

end

function love.update(dt)


end

function love.keypressed(key, isrepeat)

	if love.keyboard.isDown("right") then
		translate_x = translate_x - 10
		level.movePlayer(0.001)
	end

	if love.keyboard.isDown("left") then
		translate_x = translate_x  + 10
		level.movePlayer(-0.001)
	end

end


function love.mousemoved(x,y,dx,dy)
end

function love.draw()

	love.graphics.translate(translate_x, translate_y)
	level.draw()

end
