function love.load()
    -- Initialize game state
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)
    
    -- Player position
    player = {
        x = 400,
        y = 300,
        size = 30,
        speed = 200
    }
    
    -- Simple particle system
    particles = {}
    
    -- Game title
    title = "My LÖVE2D Game"
end

function love.update(dt)
    -- Move player with arrow keys
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        player.y = player.y + player.speed * dt
    end
    
    -- Keep player on screen
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    if player.x < player.size/2 then player.x = player.size/2 end
    if player.x > screenWidth - player.size/2 then player.x = screenWidth - player.size/2 end
    if player.y < player.size/2 then player.y = player.size/2 end
    if player.y > screenHeight - player.size/2 then player.y = screenHeight - player.size/2 end
    
    -- Add some floating particles
    if math.random() < 0.1 then
        table.insert(particles, {
            x = math.random(love.graphics.getWidth()),
            y = love.graphics.getHeight() + 10,
            speed = math.random(50, 150),
            size = math.random(3, 8),
            life = 1.0
        })
    end
    
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.y = p.y - p.speed * dt
        p.life = p.life - dt * 0.5
        
        if p.life <= 0 or p.y < -10 then
            table.remove(particles, i)
        end
    end
end

function love.draw()
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(title, 10, 10, 0, 2, 2)
    
    -- Draw instructions
    love.graphics.print("Use WASD or arrow keys to move", 10, 50)
    
    -- Draw particles
    for _, p in ipairs(particles) do
        love.graphics.setColor(0.8, 0.9, 1, p.life)
        love.graphics.circle("fill", p.x, p.y, p.size)
    end
    
    -- Draw player as a circle
    love.graphics.setColor(0.9, 0.3, 0.6)
    love.graphics.circle("fill", player.x, player.y, player.size)
    
    -- Draw player outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", player.x, player.y, player.size)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end