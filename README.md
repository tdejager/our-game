# My LÖVE2D Game

A simple 2D game built with LÖVE2D (Lua game framework).

## Description

This is a basic LÖVE2D project featuring:
- A controllable player character (pink circle)
- Floating particle effects
- Simple keyboard-based movement
- Clean, minimalist graphics

## Requirements

- LÖVE2D (managed through pixi in this project)

## How to Run

```bash
pixi run love .
```

Or if your pixi configuration uses `love2d`:

```bash
pixi run love2d .
```

## Controls

- **Movement**: WASD keys or Arrow keys
- **Quit**: ESC key

## Project Structure

- `main.lua` - Main game logic and rendering
- `conf.lua` - LÖVE2D configuration settings
- `pixi.toml` - Pixi package manager configuration

## Getting Started

The game starts with a player character in the center of the screen. Use the movement keys to navigate around while particles float upward in the background. The player is constrained to stay within the window boundaries.

This project serves as a foundation that you can extend with additional features like:
- Sprites and animations
- Sound effects and music
- Game mechanics (collision, scoring, etc.)
- Multiple levels or scenes
- Save/load functionality

## Development

To modify the game, edit `main.lua`. The basic structure follows LÖVE2D's callback system:
- `love.load()` - Initialize game state
- `love.update(dt)` - Update game logic each frame
- `love.draw()` - Render graphics each frame
- `love.keypressed(key)` - Handle keyboard input

Happy coding!