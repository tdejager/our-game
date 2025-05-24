function love.load()
    -- Initialize game state
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2)

    -- Spaceship position and properties
    SPACESHIP = {
        x = 400,
        y = 500,
        width = 20,
        height = 30,
        speed = 250,
        angle = 0
    }

    -- Star field particles
    STARS = {}

    -- Game title
    TITLE = "Space Explorer: Bas and Tim edition"
end

function love.update(dt)
    -- Move spaceship with arrow keys
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        SPACESHIP.x = SPACESHIP.x - SPACESHIP.speed * dt
        SPACESHIP.angle = -0.2 -- Tilt left
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        SPACESHIP.x = SPACESHIP.x + SPACESHIP.speed * dt
        SPACESHIP.angle = 0.2 -- Tilt right
    else
        SPACESHIP.angle = 0   -- Return to upright
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        SPACESHIP.y = SPACESHIP.y - SPACESHIP.speed * dt
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        SPACESHIP.y = SPACESHIP.y + SPACESHIP.speed * dt
    end

    -- Keep spaceship on screen
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if SPACESHIP.x < SPACESHIP.width / 2 then SPACESHIP.x = SPACESHIP.width / 2 end
    if SPACESHIP.x > screenWidth - SPACESHIP.width / 2 then SPACESHIP.x = screenWidth - SPACESHIP.width / 2 end
    if SPACESHIP.y < SPACESHIP.height / 2 then SPACESHIP.y = SPACESHIP.height / 2 end
    if SPACESHIP.y > screenHeight - SPACESHIP.height / 2 then SPACESHIP.y = screenHeight - SPACESHIP.height / 2 end

    -- Add twinkling stars
    if math.random() < 0.3 then
        table.insert(STARS, {
            x = math.random(love.graphics.getWidth()),
            y = -5,
            speed = math.random(30, 100),
            size = math.random(1, 3),
            brightness = math.random(),
            twinkle = math.random() * math.pi * 2
        })
    end

    -- Update stars
    for i = #STARS, 1, -1 do
        local star = STARS[i]
        star.y = star.y + star.speed * dt
        star.twinkle = star.twinkle + dt * 3
        star.brightness = 0.5 + 0.5 * math.sin(star.twinkle)

        if star.y > love.graphics.getHeight() + 10 then
            table.remove(STARS, i)
        end
    end
end

function love.draw()
    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(TITLE, 10, 10, 0, 2, 2)

    -- Draw instructions
    love.graphics.print("Use WASD or arrow keys to fly your spaceship", 10, 50)

    -- Draw stars
    for _, star in ipairs(STARS) do
        love.graphics.setColor(1, 1, 1, star.brightness)
        love.graphics.circle("fill", star.x, star.y, star.size)
    end

    -- Draw spaceship as a triangle
    love.graphics.push()
    love.graphics.translate(SPACESHIP.x, SPACESHIP.y)
    love.graphics.rotate(SPACESHIP.angle)

    -- Spaceship body (triangle pointing up)
    love.graphics.setColor(0.8, 0.8, 0.9)
    local vertices = {
        0, -SPACESHIP.height / 2,                   -- Top point
        -SPACESHIP.width / 2, SPACESHIP.height / 2, -- Bottom left
        SPACESHIP.width / 2, SPACESHIP.height / 2   -- Bottom right
    }
    love.graphics.polygon("fill", vertices)

    -- Spaceship outline
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("line", vertices)

    -- Engine glow
    love.graphics.setColor(0.2, 0.5, 1, 0.8)
    love.graphics.circle("fill", 0, SPACESHIP.height / 2 + 3, 4)

    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
