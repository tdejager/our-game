function math.clamp(val, lower, upper)
    assert(val and lower and upper, "not very useful error message here")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.randomf(from, to)
    assert(from and to, "not very useful error message here")
    if from > to then from, to = to, from end -- swap if boundaries supplied the wrong way
    return from + math.random() * (to - from)
end

function love.load()
    -- Initialize game state
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setLineWidth(2)

    -- Spaceship position and properties
    SPACESHIP = {
        x = 400,
        y = 500,
        width = 16,
        height = 24,
        speed = 300,
        angle = 0,
        thruster_glow = 0
    }

    -- Bullet system
    BULLETS = {}
    SHOOTING = {
        cooldown = 0,
        rate = 0.15 -- seconds between shots
    }

    -- Enemy system
    ENEMIES = {}
    ENEMY_SPAWN = {
        timer = 0,
        rate = 2.0 -- seconds between enemy spawns
    }

    -- Score
    SCORE = 0

    -- Grid properties
    GRID = {
        size = 40,
        alpha = 0.15
    }

    -- Game title
    TITLE = "Bas & Tim - Space Adventure"
end

function love.update(dt)
    local moving = false

    -- Move spaceship with arrow keys
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        SPACESHIP.x = SPACESHIP.x - SPACESHIP.speed * dt
        SPACESHIP.angle = -0.3
        moving = true
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        SPACESHIP.x = SPACESHIP.x + SPACESHIP.speed * dt
        SPACESHIP.angle = 0.3
        moving = true
    else
        SPACESHIP.angle = SPACESHIP.angle * 0.9 -- Smooth return to center
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        SPACESHIP.y = SPACESHIP.y - SPACESHIP.speed * dt
        moving = true
    end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        SPACESHIP.y = SPACESHIP.y + SPACESHIP.speed * dt
        moving = true
    end

    -- Update thruster glow
    if moving then
        SPACESHIP.thruster_glow = math.min(1, SPACESHIP.thruster_glow + dt * 8)
    else
        SPACESHIP.thruster_glow = math.max(0, SPACESHIP.thruster_glow - dt * 4)
    end

    -- Update shooting cooldown
    SHOOTING.cooldown = math.max(0, SHOOTING.cooldown - dt)

    -- Shooting
    if love.keyboard.isDown("space") and SHOOTING.cooldown <= 0 then
        table.insert(BULLETS, {
            x = SPACESHIP.x,
            y = SPACESHIP.y - SPACESHIP.height / 2,
            speed = 500,
            life = 1.0
        })
        SHOOTING.cooldown = SHOOTING.rate
    end

    -- Keep spaceship on screen
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if SPACESHIP.x < SPACESHIP.width then SPACESHIP.x = SPACESHIP.width end
    if SPACESHIP.x > screenWidth - SPACESHIP.width then SPACESHIP.x = screenWidth - SPACESHIP.width end
    if SPACESHIP.y < SPACESHIP.height then SPACESHIP.y = SPACESHIP.height end
    if SPACESHIP.y > screenHeight - SPACESHIP.height then SPACESHIP.y = screenHeight - SPACESHIP.height end

    -- Spawn enemies
    ENEMY_SPAWN.timer = ENEMY_SPAWN.timer + dt
    if ENEMY_SPAWN.timer >= ENEMY_SPAWN.rate then
        local enemyType = math.random(1, 3)
        table.insert(ENEMIES, {
            x = math.random(50, love.graphics.getWidth() - 50),
            y = -20,
            vx = math.random(-50, 50),
            vy = math.random(30, 80),
            size = math.random(12, 20),
            health = 1,
            rotation = math.random() * math.pi * 2,
            rotSpeed = math.random(-2, 2),
            type = enemyType,
            color = {
                r = math.randomf(0.8, 1),
                g = math.randomf(0.2, 0.6),
                b = math.randomf(0.2, 0.6)
            }
        })
        ENEMY_SPAWN.timer = 0
    end

    -- Update bullets
    for i = #BULLETS, 1, -1 do
        local bullet = BULLETS[i]
        bullet.y = bullet.y - bullet.speed * dt
        bullet.life = bullet.life - dt * 0.3

        if bullet.y < -10 or bullet.life <= 0 then
            table.remove(BULLETS, i)
        end
    end

    -- Update enemies
    for i = #ENEMIES, 1, -1 do
        local enemy = ENEMIES[i]
        enemy.x = enemy.x + enemy.vx * dt
        enemy.y = enemy.y + enemy.vy * dt
        enemy.rotation = enemy.rotation + enemy.rotSpeed * dt

        -- Keep enemies on screen horizontally
        if enemy.x < 0 or enemy.x > love.graphics.getWidth() then
            enemy.vx = -enemy.vx
        end

        -- Remove enemies that go off bottom
        if enemy.y > love.graphics.getHeight() + 50 then
            table.remove(ENEMIES, i)
        end
    end

    -- Check bullet-enemy collisions
    for i = #BULLETS, 1, -1 do
        local bullet = BULLETS[i]
        for j = #ENEMIES, 1, -1 do
            local enemy = ENEMIES[j]
            local dx = bullet.x - enemy.x
            local dy = bullet.y - enemy.y
            local distance = math.sqrt(dx * dx + dy * dy)

            if distance < enemy.size then
                -- Hit!
                table.remove(BULLETS, i)
                table.remove(ENEMIES, j)
                SCORE = SCORE + 100
                break
            end
        end
    end
end

function love.draw()
    -- Draw grid background
    love.graphics.setColor(0, 1, 1, GRID.alpha)
    love.graphics.setLineWidth(1)

    for x = 0, love.graphics.getWidth(), GRID.size do
        love.graphics.line(x, 0, x, love.graphics.getHeight())
    end
    for y = 0, love.graphics.getHeight(), GRID.size do
        love.graphics.line(0, y, love.graphics.getWidth(), y)
    end

    love.graphics.setLineWidth(2)

    -- Draw title with neon glow
    love.graphics.setColor(0, 1, 1, 0.3)
    love.graphics.print(TITLE, 12, 12, 0, 2, 2)
    love.graphics.setColor(0, 1, 1)
    love.graphics.print(TITLE, 10, 10, 0, 2, 2)

    -- Draw instructions with neon style
    love.graphics.setColor(1, 1, 0, 0.8)
    love.graphics.print("WASD TO NAVIGATE | SPACE TO SHOOT", 10, 50)

    -- Draw score
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("SCORE: " .. SCORE, 10, 80)

    -- Draw bullets
    for _, bullet in ipairs(BULLETS) do
        love.graphics.setColor(1, 0, 1, bullet.life) -- Magenta bullets

        -- Draw bullet as a small diamond
        love.graphics.push()
        love.graphics.translate(bullet.x, bullet.y)
        love.graphics.polygon("fill", {
            0, -4,
            2, 0,
            0, 4,
            -2, 0
        })

        -- Add glow effect
        love.graphics.setColor(1, 0, 1, bullet.life * 0.3)
        love.graphics.polygon("fill", {
            0, -6,
            3, 0,
            0, 6,
            -3, 0
        })
        love.graphics.pop()
    end

    -- Draw enemies
    for _, enemy in ipairs(ENEMIES) do
        love.graphics.setColor(enemy.color.r, enemy.color.g, enemy.color.b)

        love.graphics.push()
        love.graphics.translate(enemy.x, enemy.y)
        love.graphics.rotate(enemy.rotation)

        if enemy.type == 1 then
            -- Hostile triangle
            love.graphics.polygon("line", {
                0, -enemy.size,
                -enemy.size * 0.8, enemy.size * 0.5,
                enemy.size * 0.8, enemy.size * 0.5
            })
            -- Inner lines for detail
            love.graphics.line(0, -enemy.size * 0.5, 0, enemy.size * 0.2)
        elseif enemy.type == 2 then
            -- Hostile square
            love.graphics.rectangle("line", -enemy.size / 2, -enemy.size / 2, enemy.size, enemy.size)
            -- Cross pattern inside
            love.graphics.line(-enemy.size / 4, -enemy.size / 4, enemy.size / 4, enemy.size / 4)
            love.graphics.line(enemy.size / 4, -enemy.size / 4, -enemy.size / 4, enemy.size / 4)
        else
            -- Hostile hexagon
            local points = {}
            for i = 0, 5 do
                local angle = (i * math.pi * 2) / 6
                table.insert(points, math.cos(angle) * enemy.size)
                table.insert(points, math.sin(angle) * enemy.size)
            end
            love.graphics.polygon("line", points)
            -- Center dot
            love.graphics.circle("fill", 0, 0, 2)
        end

        love.graphics.pop()
    end

    -- Draw spaceship with geometric neon style
    love.graphics.push()
    love.graphics.translate(SPACESHIP.x, SPACESHIP.y)
    love.graphics.rotate(SPACESHIP.angle)

    -- Engine thruster effect
    if SPACESHIP.thruster_glow > 0 then
        love.graphics.setColor(0, 1, 1, SPACESHIP.thruster_glow * 0.8)
        love.graphics.polygon("line", {
            -4, SPACESHIP.height / 2,
            0, SPACESHIP.height / 2 + 8,
            4, SPACESHIP.height / 2
        })
    end

    -- Spaceship body outline (sharp geometric triangle)
    love.graphics.setColor(1, 1, 0)
    local vertices = {
        0, -SPACESHIP.height / 2,
        -SPACESHIP.width / 2, SPACESHIP.height / 2,
        SPACESHIP.width / 2, SPACESHIP.height / 2
    }
    love.graphics.polygon("line", vertices)

    -- Inner detail lines
    love.graphics.setColor(1, 1, 0, 0.6)
    love.graphics.line(0, -SPACESHIP.height / 2 + 4, 0, SPACESHIP.height / 2 - 4)
    love.graphics.line(-SPACESHIP.width / 4, 0, SPACESHIP.width / 4, 0)

    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
