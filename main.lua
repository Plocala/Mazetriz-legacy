-- ==== VARIABLES ====

-- estado global de jogo
local GameState = "menu"

-- resolução da tela
local desktopW, desktopH = love.window.getDesktopDimensions()

-- CONFIGURAÇÕES GLOBAIS
local Config = {
    gridCols            = 20,
    gridRows            = 34,
    cellSize            = nil,
    visibleCols         = nil,
    minDropInterval     = 0.1,
    dropAccel           = 0.98,
    topTouchThreshold   = 1.0,
    frameDuration       = 0.5,
    trailLifetime       = 0.3,
    turbSpeed           = 0.3,
    turbAmplitude       = 2,
    cameraBounceAmount  = nil,
    cameraReturnSpeed   = 8,
    bgScrollSpeed       = 10,
    maxOxy              = 4,
    oxyInterval         = 1,
    exitSize            = 4,
    treasureChance      = 0.25,
    slideDuration       = 0.3,
}
Config.cellSize    = math.floor((desktopH / Config.gridRows) * 0.9)
Config.visibleCols = Config.gridCols
Config.cameraBounceAmount = Config.cellSize * 0.25
Visited = {}

-- ESTADOS DE JOGO
local State = {
    gameOver       = false,
    victory        = false,
    inGameMusic    = false,
    topTouchTimer  = 0,
    dropTimer      = 0,
    lineClearTimer = 0,
    lineClearDelay = 0.3,
    dropInterval   = 0.5,
    spawnCount     = 0,
    linesToClear   = {},
    grid           = {},
    tetrominos     = {},
    current        = {},
    upcoming       = {},
}

-- MENU
Menu = {
    -- Assets
    titleSprite   = nil,
    titleScale    = 1,
    font          = nil,
    
    -- Botões
    btns = {},

    -- Fade-in/out
    fadeTimer     = 0,
    fadeDur       = 1.0,
    overlayAlpha  = 1,
    transitioning = false,
    transitionDur = 0.5,
    transitionTimer = 0,

    -- Câmera parallax
    camOffsetX    = 0,
    camOffsetY    = 0,
    camLimit      = 10,
    camSmooth     = 5,
}

-- INPUT CONTÍNUO DAS PEÇAS
local PieceInput = {
    moveTimer = 0,
    moveDelay = 0.15,
    moveHeld  = { left = false, right = false, down = false },
}
  
-- CÂMERA E TURBULÊNCIA
local Camera = {
    turbTimer   = 0,
    offsetX     = 0,
    offsetY     = 0,
    mouseOffsetX = 0,
    mouseOffsetY = 0,
    mouseLimit   = 5,
    mouseTargetX    = 0,
    mouseTargetY    = 0,
    mouseSmoothSpeed = 5,
}

-- PLAYER
local Player = {
    obj          = nil,
    spawned      = false,
    spritesheet  = nil,
    frames       = {},
    currentFrame = 1,
    frameTimer   = 0,
    scale        = 1,
    speed        = Config.cellSize * 8,
    sliding      = false,
    destCellX    = 0,
    destCellY    = 0,
    slideVelX    = 0,
    slideVelY    = 0,
    slideDirX    = 0,
    slideDirY    = 0,
    trail        = {},
}

-- Guardian
local Guardian = {
    list         = {},
    img          = nil,
    frames       = {},
    currentFrame = 1,
    frameTimer   = 0,
    frameDuration= 0.5,
    scale        = 1,
    moveInterval = 2.0,
}

-- Patrol
local Patrol = {
    list       = {},
    img        = nil,
    frames     = {},
    currentFrame = 1,
    frameTimer   = 0,
    frameDuration= 0.5,
    speedInterval= 1.0,
    shootInterval = 2.0,
}

-- Bullets
local Bullets = {
    list       = {},
    speed      = Config.cellSize * 5,
    img        = nil,
    width      = 8, height = 8,
}

-- ARMADILHAS
local Traps = {
    list    = {},
    img     = nil,
    chance  = 0.05,
}

-- OXIGÊNIO
local Oxygen = {
    current  = Config.maxOxy,
    timer    = 0,
    fullImg  = nil,
    emptyImg = nil,
}

-- Scroller
Scroller = {
    margin         = 16,
    spacing        = 8,
    maxMove        = 10,
    smoothSpeed    = 8,
    moveSmooth     = 6,
    items = {
        { baseSize = Config.cellSize * 2.5, baseAlpha = 0.75, dark = 1.0 },
        { baseSize = Config.cellSize * 2.0, baseAlpha = 0.5,  dark = 0.8 },
        { baseSize = Config.cellSize * 1.5, baseAlpha = 0.25, dark = 0.6 },
    }
}

-- FLASH
local ScreenFlash = {
    timer    = 0,
    duration = 0.3,
}

-- GRÁFICOS E FUNDO
local Graphics = {
    bgScroll   = 0,
    background = {},
}
  
-- PALETA DE CORES
local Palette = {
    border  = {0.95, 0.90, 1.00},
    wall    = {0.60, 0.40, 0.70},
    passage = {0.40, 0.20, 0.50},
    shape   = {0.70, 0.20, 0.70},
}
  
-- AUXILIARES DE DIREÇÃO E ÂNGULO
local Directions = {
    up    = {dx=0,  dy=-1},
    down  = {dx=0,  dy=1},
    left  = {dx=-1, dy=0},
    right = {dx=1,  dy=0},
}
local DirAngles = {
    up    = math.pi,
    down  = 0,
    left  = math.pi/2,
    right = -math.pi/2,
}
  
-- SONS
local Audio = {
    musicTheme    = nil,
    gameOverTheme = nil,
    victoryTheme  = nil,
    sndPlayerMove = nil,
    sndPlayerHit  = nil,
    sndRotate     = nil,
    sndLockPiece  = nil,
    sndCoin       = nil,
    sndBubble     = nil,
    sndDamage     = nil,
}

-- SALA DE SAÍDA
local ExitRoom = {
    mat         = {},
    ox          = 8,
    oy          = Config.gridRows - Config.exitSize + 1,
    forcedWalls = {
      ["0,0"]=true, ["1,0"]=true, ["2,0"]=true, ["3,0"]=true,
      ["0,3"]=true, ["1,3"]=true, ["2,3"]=true, ["3,3"]=true,
    },
    candidates  = { {0,1}, {0,2}, {3,1}, {3,2} },
}
  
-- ESTRELA (OBJETIVO)
local Star  = {
    cellX   = nil,
    cellY   = nil,
    timer   = 0,
    offsetY = 0,
    img     = nil,
    scale   = 1,
}

-- COIN (PONTUACAO)
Coin = {
    list          = {},
    sheet         = nil,
    frameW        = 16,
    frameH        = 16,
    quad          = nil,
    spawnTimer    = 0,
    spawnInterval = 5,
    maxOnMap      = Config.gridCols * Config.gridRows,
    spawnedMap    = {},
    count      = 0,
    flashTimer = 0,
    flashDur   = 0.3,
    shakeAmp   = 4,
}

-- ==== Helpers Gerais (baixo nível) ====

local function isExitCell(x, y)
    local i = x - ExitRoom.ox
    local j = y - ExitRoom.oy
    return i >= 0 and i < Config.exitSize and j >= 0 and j < Config.exitSize, i, j
end

local function getCell(x, y)
    local inExit, i, j = isExitCell(x, y)
    if inExit then
        return { wall = ExitRoom.mat[i][j].wall, corridor = not ExitRoom.mat[i][j].wall, }
    end
    return State.grid[x] and State.grid[x][y] or nil
end

local function isNeighbor(blocks, x, y) for _, b in ipairs(blocks) do if b[1] == x and b[2] == y then return true end end return false end
local function isWallCell(x, y) local c = getCell(x, y) return c and c.wall end
local function isPassageCell(x, y) local c = getCell(x, y) return c and c.corridor end
local function isInVacuumCell() return not isPassageCell(Player.obj.cellX, Player.obj.cellY) end
local function worldToCell(px, py) return math.floor(px / Config.cellSize) + 1, math.floor(py / Config.cellSize) + 1 end
local function isInCorridor(rx, ry) for _, c in ipairs(State.current.corridor) do if c[1] == rx and c[2] == ry then return true end end return false end
local function isVacuumCell(x,y) local c = getCell(x,y) return c == nil end

local function drawMiniTetromino(blocks, bx, by, size)
    local cell = size / 4 * 0.8
    local off  = (size - cell*4)/2
    local col = Palette.shape
    love.graphics.setColor(col[1], col[2], col[3], alpha)
    for _, b in ipairs(blocks) do
        local px = bx + off + (b[1])*cell
        local py = by + off + (b[2])*cell
        love.graphics.rectangle("fill", px, py, cell, cell)
    end
end

local function clearLineOfSight(x1, y1, x2, y2)
    if x1 ~= x2 and y1 ~= y2 then return false end 
    local dx = (x2 > x1) and 1 or (x2 < x1) and -1 or 0
    local dy = (y2 > y1) and 1 or (y2 < y1) and -1 or 0
    local cx, cy = x1, y1
    while not (cx == x2 and cy == y2) do
        cx, cy = cx + dx, cy + dy
        local c = getCell(cx, cy)
        if c and c.wall then
            return false
        end
    end
    return true
end

-- ==== Salas Roguelike ====

local roomTemplates = {
    I = { {1,0},{1,1},{1,2},{1,3} },
    O = { {1,1},{2,1},{1,2},{2,2} },
    T = { {1,1},{0,2},{1,2},{2,2} },
    S = { {1,1},{2,1},{0,2},{1,2} },
    Z = { {0,1},{1,1},{1,2},{2,2} },
    J = { {0,1},{0,2},{1,2},{2,2} },
    L = { {2,1},{0,2},{1,2},{2,2} },
}
  
local function templateBounds(shape)
    local minX, maxX = 999, -999
    local minY, maxY = 999, -999
    for _,cell in ipairs(shape) do
        minX = math.min(minX, cell[1])
        maxX = math.max(maxX, cell[1])
        minY = math.min(minY, cell[2])
        maxY = math.max(maxY, cell[2])
    end
    return maxX-minX+1, maxY-minY+1, minX, minY
end

local function overlapsExitRoom(x0,y0,W,H)
    local ex0, ey0 = ExitRoom.ox, ExitRoom.oy
    local ex1, ey1 = ex0+Config.exitSize-1, ey0+Config.exitSize-1
    return not (x0+W-1 < ex0 or x0 > ex1 or y0+H-1 < ey0 or y0 > ey1)
end
  
local rooms = {}
local function overlapsOtherRooms(x0,y0,W,H)
    for _,r in ipairs(rooms) do
        if not (x0+W-1 < r.x or x0 > r.x+r.w-1 or y0+H-1 < r.y or y0 > r.y+r.h-1) then return true end
    end
    return false
end

local function carveRoom(shape, x0, y0, sw, sh, minX, minY)
    local W, H = sw + 2, sh + 2

    for dx = 0, W - 1 do
      for dy = 0, H - 1 do
        local gx, gy = x0 + dx, y0 + dy
        if dx == 0 or dx == W - 1 or dy == 0 or dy == H - 1 then
          State.grid[gx][gy] = { wall = true, corridor = false }
        else
          State.grid[gx][gy] = false
        end
      end
    end

    for _, cell in ipairs(shape) do
      local sx = (cell[1] - minX) + 1
      local sy = (cell[2] - minY) + 1
      local bx, by = x0 + sx, y0 + sy
      State.grid[bx][by] = { wall = false, corridor = true }
    end

    local holeProb = 0.15
    for dx = 0, W - 1 do
      for dy = 0, H - 1 do
        local gx, gy = x0 + dx, y0 + dy
        local c = State.grid[gx][gy]
        if c and c.wall and love.math.random() < holeProb then
          State.grid[gx][gy] = false
        end
      end
    end

    table.insert(rooms, { x = x0, y = y0, w = W, h = H })
end

local function carveTreasureRoom(shape, x0, y0, sw, sh, minX, minY)
    local W, H = sw+2, sh+2
    local room = { x=x0, y=y0, w=W, h=H, isTreasure=true, lockHits=0, lockRequired=10, chestCollected=false }

    for dx=0,W-1 do for dy=0,H-1 do
        local gx, gy = x0+dx, y0+dy
        local border = (dx==0 or dx==W-1 or dy==0 or dy==H-1)
        State.grid[gx][gy] = { wall=border, corridor=not border }
    end end

    for _,cell in ipairs(shape) do
        local sx, sy = cell[1]-minX+1, cell[2]-minY+1
        local gx, gy = x0+sx, y0+sy
        State.grid[gx][gy] = { wall=false, corridor=true }
    end

    local sides = {
      {side="top",    x=x0+math.floor(W/2), y=y0},
      {side="bottom", x=x0+math.floor(W/2), y=y0+H-1},
      {side="left",   x=x0,                 y=y0+math.floor(H/2)},
      {side="right",  x=x0+W-1,             y=y0+math.floor(H/2)},
    }
    local lock = sides[love.math.random(#sides)]
    room.treasureLock = {
      cellX = lock.x,
      cellY = lock.y,
      dir   = ({ top="down", bottom="up", left="right", right="left" })[lock.side]
    }
    State.grid[lock.x][lock.y] = { wall=true, corridor=false }

    local chestCands = {}
    for dx=1,W-2 do
        for dy=1,H-2 do
            local gx, gy = x0+dx, y0+dy
            if isPassageCell(gx, gy) then
                table.insert(chestCands, {gx,gy})
            end
        end 
    end

    if #chestCands > 0 then
        local pick = chestCands[love.math.random(#chestCands)]
        room.treasureChest = { cellX=pick[1], cellY=pick[2], dir=room.treasureLock.dir }
        State.grid[pick[1]][pick[2]] = { wall=false, corridor=true }
    end

    table.insert(rooms, room)
    local roomId = #rooms

    if room.treasureChest and love.math.random() < 0.30 then
      for i=#chestCands,1,-1 do
            if chestCands[i][1]==room.treasureChest.cellX
            and chestCands[i][2]==room.treasureChest.cellY then
            table.remove(chestCands, i)
            break
            end
        end
        if #chestCands > 0 then
            local gpick = chestCands[love.math.random(#chestCands)]
            if isPassageCell(gpick[1], gpick[2]) then
                local g = {
                    roomId       = roomId,
                    cellX        = gpick[1],
                    cellY        = gpick[2],
                    px           = (gpick[1]-1)*Config.cellSize,
                    py           = (gpick[2]-1)*Config.cellSize,
                    sliding      = false,
                    destCellX    = nil,
                    destCellY    = nil,
                    slideVelX    = 0,
                    slideVelY    = 0,
                    img          = Guardian.img,
                    frames       = Guardian.frames,
                    frameDuration= Guardian.frameDuration,
                    currentFrame = 1,
                    frameTimer   = 0,
                    scale        = Guardian.scale,
                    moveInterval = Guardian.moveInterval,
                    timer        = 0,
                    dir          = "down",
                    angle        = DirAngles.down,
                }
                table.insert(Guardian.list, g)
            end
        end
    end
end

local function placeRandomRooms()
    rooms = {}
    local count = love.math.random(1,3)
    for i = 1, count do
        local isTreasure = love.math.random() < Config.treasureChance
        local key = ({"I","O","T","S","Z","J","L"})[love.math.random(7)]
        local shape = roomTemplates[key]
        local sw, sh, minX, minY = templateBounds(shape)
        local W, H = sw+2, sh+2
    
        for attempt = 1, 50 do
            local x0 = love.math.random(1, Config.visibleCols-W+1)
            local y0 = love.math.random(math.floor(Config.gridRows*0.4), Config.gridRows-H+1)
            if not overlapsExitRoom(x0,y0,W,H)
            and not overlapsOtherRooms(x0,y0,W,H) then
            if isTreasure then
                carveTreasureRoom(shape, x0,y0, sw,sh, minX,minY)
            else
                carveRoom(shape, x0,y0, sw,sh, minX,minY)
            end
            break
            end
        end
    end
end

-- ==== Helper Rooms ====

local function isBlockedCell(x, y)
    for _, room in ipairs(rooms) do
        if room.isTreasure
        and room.treasureChest.cellX == x
        and room.treasureChest.cellY == y
        and not room.chestCollected
        then
            return true
        end
    end
    local c = getCell(x, y)
    return c and (c.wall or c.corridor)
end

-- ==== Pathfinding & Transformações de Blocos ====

local function findExternalEdges(blocks)
    local edges = {}
    for _, b in ipairs(blocks) do
        for dir, delta in pairs(Directions) do
            local nx, ny = b[1] + delta.dx, b[2] + delta.dy
            if not isNeighbor(blocks, nx, ny) then
                table.insert(edges, { x = b[1], y = b[2], dir = dir })
            end
        end
    end
    return edges
end
  
local function chooseTwo(edges)
    local i1 = love.math.random(#edges)
    local i2 = i1
    while i2 == i1 do
        i2 = love.math.random(#edges)
    end
    return edges[i1], edges[i2]
end
  
local function buildGraph(blocks)
    local g = {}
    for _, a in ipairs(blocks) do
        local key = a[1] .. "," .. a[2]
        g[key] = {}
        for _, b in ipairs(blocks) do
            if math.abs(a[1] - b[1]) + math.abs(a[2] - b[2]) == 1 then
                table.insert(g[key], b[1] .. "," .. b[2])
            end
        end
    end
    return g
end
  
local function bfs(graph, start, goal)
    local queue = { { start } }
    local vis = { [start] = true }
    while #queue > 0 do
        local path = table.remove(queue, 1)
        local node = path[#path]
        if node == goal then return path end
        for _, nbr in ipairs(graph[node] or {}) do
            if not vis[nbr] then
                vis[nbr] = true
                local newPath = { unpack(path) }
                table.insert(newPath, nbr)
                table.insert(queue, newPath)
            end
        end
    end
    return {}
end
  
local function rotate(blocks)
    local o = {}
    for _, b in ipairs(blocks) do
      local x, y     = b[1] - 1.5, b[2] - 1.5
      local rx, ry   = -y, x
      table.insert(o, {
        math.floor(rx + 1.5 + 0.5),
        math.floor(ry + 1.5 + 0.5)
      })
    end
    return o
end
  
local dirRotation = { up = "right", right = "down", down = "left", left = "up", }

local function rotateCoord(x, y) local tmp = rotate({ { x, y } }) return tmp[1][1], tmp[1][2] end

-- spawn Patrol
local function spawnPatrol(n)
    for i = 1, n do
        local x,y
        repeat
            x = love.math.random(1, Config.visibleCols)
            y = love.math.random(1, Config.gridRows)
        until isVacuumCell(x,y)  -- precisa de um helper: retorne true se não for corridor nem wall
        table.insert(Patrol.list, {
            cellX = x, cellY = y,
            dir   = (love.math.random() < 0.5) and "horizontal" or "vertical",
            sign  = 1,   -- 1 ou -1 para avançar ou voltar
            timer = 0,
            shootTimer  = 0,
        })
    end
end

-- ==== Colisão e Área de Saída ====

local function clearExitArea()
    for i = 0, Config.exitSize - 1 do
      for j = 0, Config.exitSize - 1 do
        local gx = ExitRoom.ox + i
        local gy = ExitRoom.oy + j
        State.grid[gx][gy] = nil
      end
    end
end  

local function checkCollision(p, dX, dY, newBlocks)
    local blocks = newBlocks or p.blocks
    for _, b in ipairs(blocks) do
        local cx = p.x + dX + b[1]
        local cy = p.y + dY + b[2]
        if cx < 1 or cx > Config.visibleCols
        or cy < 1 or cy > Config.gridRows then
            return true
        end
        if isBlockedCell(cx, cy) then
            return true
        end
    end
    return false
end

-- ==== Objetivo (Estrela) ====

local function spawnStar()
    Star.cellX = love.math.random(1, Config.visibleCols)
    Star.cellY = love.math.random(2, 6)
end

-- ==== Coin (pontos) ====

function Coin.cellHasCoin(x, y) for _, c in ipairs(Coin.list) do if c.cellX == x and c.cellY == y then return true end end return false end

local function spawnCoin()
    local candidates = {}
    for x = 1, Config.visibleCols do
        for y = 1, Config.gridRows do
            if isPassageCell(x, y) and not Visited[x][y] and not Coin.cellHasCoin(x, y) and not Coin.spawnedMap[x][y] then
                local hasWallNeighbor = false
                for _, d in pairs(Directions) do
                    local nx, ny = x + d.dx, y + d.dy
                    if isWallCell(nx, ny) then
                        hasWallNeighbor = true
                        break
                    end
                end
                if hasWallNeighbor then table.insert(candidates, {x, y}) end
            end
        end
    end

    if #candidates > 0 then
        local pick = candidates[love.math.random(#candidates)]
        table.insert(Coin.list, { cellX = pick[1], cellY = pick[2], })
        Coin.spawnedMap[pick[1]][pick[2]] = true
    end
end


function Coin.initVisitedAndCoins()
    for x = 1, Config.visibleCols do
        Visited[x] = {}
        Coin.spawnedMap[x] = {}
        for y = 1, Config.gridRows do
            Visited[x][y] = false
            Coin.spawnedMap[x][y] = false
        end
    end
    Coin.list = {}
end

-- ==== Inicialização & Reset ====

function initTetrominos()
    State.tetrominos = {
        I = { {0,1}, {1,1}, {2,1}, {3,1} },
        O = { {1,1}, {2,1}, {1,2}, {2,2} },
        T = { {1,1}, {0,2}, {1,2}, {2,2} },
        S = { {1,1}, {2,1}, {0,2}, {1,2} },
        Z = { {0,1}, {1,1}, {1,2}, {2,2} },
        J = { {0,1}, {0,2}, {1,2}, {2,2} },
        L = { {2,1}, {0,2}, {1,2}, {2,2} },
    }
end

local function initExitMatrix()
    local pick     = ExitRoom.candidates[love.math.random(#ExitRoom.candidates)]
    local pickKey  = pick[1] .. "," .. pick[2]

    for i = 0, Config.exitSize - 1 do
        ExitRoom.mat[i] = {}
        for j = 0, Config.exitSize - 1 do
            local key = i .. "," .. j
            local wall

            if ExitRoom.forcedWalls[key] then
                wall = true
            elseif i >= 1 and i <= Config.exitSize - 2 and j >= 1 and j <= Config.exitSize - 2 then
                wall = false
            elseif key == pickKey then
                wall = false
            else
                wall = true
            end

            ExitRoom.mat[i][j] = { wall = wall }
        end
    end
end

local function injectExitIntoGrid()
    for i = 0, Config.exitSize - 1 do
        for j = 0, Config.exitSize - 1 do
            local gx = ExitRoom.ox + i
            local gy = ExitRoom.oy + j
            State.grid[gx][gy] = { wall = ExitRoom.mat[i][j].wall, corridor = not ExitRoom.mat[i][j].wall, }
        end
    end
end

-- ==== Mecânicas de Tetrominos ====

local function spawnTetromino()
    local shape = table.remove(State.upcoming, 1)
    local blocks = State.tetrominos[shape]
  
    local shapes = {}
    for k in pairs(State.tetrominos) do table.insert(shapes, k) end
    table.insert(State.upcoming, shapes[love.math.random(#shapes)])
  
    local e1, e2   = chooseTwo(findExternalEdges(blocks))
    local rawPath  = bfs(buildGraph(blocks), e1.x..","..e1.y, e2.x..","..e2.y)
    local corridor = {}
    for _, s in ipairs(rawPath) do
        local cx, cy = s:match("(%d+),(%d+)") 
        table.insert(corridor,{tonumber(cx), tonumber(cy)})
    end

    local minB, maxB = blocks[1][1], blocks[1][1]
    for _, b in ipairs(blocks) do
    if b[1] < minB then minB = b[1] end
    if b[1] > maxB then maxB = b[1] end
    end

    -- calcula limites
    local minX   = 2 - minB
    local maxX   = (Config.visibleCols - 1) - maxB
    local spawnX = love.math.random(minX, maxX)

    State.current = {
      shape    = shape,
      blocks   = blocks,
      corridor = corridor,
      p1       = e1,
      p2       = e2,
      x        = spawnX,
      y        = -1,
    }
    State.dropTimer = 0
end  

local function detectFullRows()
    local rows = {}
    for y = 1, Config.gridRows do
        local full = true
        for x = 1, Config.visibleCols do
            if not isWallCell(x, y) then
                full = false; break
            end
        end
        if full then table.insert(rows, y) end
    end
    return rows
end

local function clearMarkedRows()
    table.sort(State.linesToClear, function(a, b) return a > b end)
    for _, y in ipairs(State.linesToClear) do
        for yy = y, 2, -1 do
            for x = 1, Config.visibleCols do
                State.grid[x][yy] = State.grid[x][yy - 1]
            end
        end
        for x = 1, Config.visibleCols do
            State.grid[x][1] = false
        end
    end
    State.linesToClear = {}
end

local function lockPiece()
    for _, block in ipairs(State.current.blocks) do
        local gx = State.current.x + block[1]
        local gy = State.current.y + block[2]
        if gx >= 1 and gx <= Config.visibleCols and gy >= 1 and gy <= Config.gridRows then
            local inC = false
            for _, coord in ipairs(State.current.corridor) do
                if coord[1] == block[1] and coord[2] == block[2] then
                    inC = true; break
                end
            end
            State.grid[gx][gy] = { wall = not inC, corridor = inC, }
            love.audio.play(Audio.sndLockPiece:clone())
        end
    end
    spawnTetromino()
end

-- ==== Sala de Saída & Jogador ====

local function drawExitMatrix()
    for i = 0, Config.exitSize - 1 do
        for j = 0, Config.exitSize - 1 do
            local cell = ExitRoom.mat[i][j]
            local gx   = ExitRoom.ox + i
            local gy   = ExitRoom.oy + j

            local col = cell.wall and Palette.wall or Palette.passage
            love.graphics.setColor( unpack(col) )
            love.graphics.rectangle( "fill", (gx - 1) * Config.cellSize, (gy - 1) * Config.cellSize, Config.cellSize, Config.cellSize )
        end
    end
end

local function trySpawnExitPlayer()
    if Player.spawned then return end

    Player.obj     = {}
    Player.spawned = true

    local opts = {}
    local innerMin = 1
    local innerMax = Config.exitSize - 2
    local center   = math.floor(Config.exitSize / 2)
    for i = innerMin, innerMax do
        for j = innerMin, innerMax do
            if not (i == center and j == center) then
                table.insert(opts, { i, j })
            end
        end
    end

    local pick = opts[love.math.random(#opts)]
    local i, j = pick[1], pick[2]

    local obj = Player.obj
    obj.cellX = ExitRoom.ox + i
    obj.cellY = ExitRoom.oy + j

    local dir
    local upY    = obj.cellY - 1
    local downY  = obj.cellY + 1
    local leftX  = obj.cellX - 1
    local rightX = obj.cellX + 1

    if     isWallCell(obj.cellX, downY)  then dir = "down"
    elseif isWallCell(obj.cellX, upY)    then dir = "up"
    elseif isWallCell(rightX, obj.cellY) then dir = "right"
    elseif isWallCell(leftX, obj.cellY)  then dir = "left"
    else
        dir = (love.math.random() < 0.5) and "up" or "down"
    end

    obj.dir   = dir
    obj.angle = DirAngles[dir]

    local delta = Directions[dir]
    obj.px = (obj.cellX - 1) * Config.cellSize + delta.dx * (Config.cellSize / 2)
    obj.py = (obj.cellY - 1) * Config.cellSize + (delta.dy == -1 and -Config.cellSize or 0)
    obj.collided = true
end

local function startPlayerSlide(dx, dy)
    if not isWallCell(Player.obj.cellX + dx, Player.obj.cellY + dy) then
        love.audio.play(Audio.sndPlayerMove:clone())
    end

    local cx, cy = Player.obj.cellX, Player.obj.cellY
    local nx, ny = cx, cy
    while
      nx + dx >= 1 and nx + dx <= Config.visibleCols
      and ny + dy >= 1 and ny + dy <= Config.gridRows
      and not isWallCell(nx + dx, ny + dy)
    do
      nx = nx + dx; ny = ny + dy
    end

    Player.slideDirX = dx
    Player.slideDirY = dy

    Player.obj.px = (cx - 1) * Config.cellSize + dx * (Config.cellSize/2)
    Player.obj.py = (cy - 1) * Config.cellSize + (dy == -1 and -Config.cellSize or 0)

    Player.destCellX = nx
    Player.destCellY = ny

    Player.slideVelX = dx * Player.speed
    Player.slideVelY = dy * Player.speed

    Camera.offsetX = -dx * Config.cameraBounceAmount
    Camera.offsetY = -dy * Config.cameraBounceAmount

    Player.sliding = true
    Player.nextMove = nil

    Player.obj.dir   = (dx~=0 and (dx>0 and "right" or "left")) or (dy>0 and "down" or "up")
    Player.obj.angle = DirAngles[Player.obj.dir]

    if nx == cx and ny == cy then
        love.audio.play(Audio.sndPlayerHit:clone())
    end
end

target = resetGame
do
    function resetGame()
        if Audio.gameOverTheme:isPlaying() then
            Audio.gameOverTheme:stop()
        end
        if Audio.victoryTheme:isPlaying() then
            Audio.victoryTheme:stop()
        end
        if not State.inGameMusic then
            love.audio.play(Audio.musicTheme)
            Audio.musicTheme:setVolume(0.5)
            State.inGameMusic = true
        end

        State.gameOver      = false
        State.victory       = false
        State.topTouchTimer = 0

        clearExitArea()
        Coin.initVisitedAndCoins()

        for x = 1, Config.visibleCols do
            for y = 1, Config.gridRows do
                State.grid[x][y] = false
            end
        end
        
        Guardian.list = {}
        placeRandomRooms()

        State.linesToClear   = {}
        State.lineClearTimer = 0
        State.dropTimer      = 0

        Player.spawned      = false
        Player.obj          = nil
        Player.sliding      = false
        PieceInput.moveHeld = { left = false, right = false, down = false }

        for x = 1, Config.visibleCols do
            Visited[x] = {}
            for y = 1, Config.gridRows do
            Visited[x][y] = false
            end
        end
        Coin.list = {}
        Coin.count = 0

        Oxygen.current = Config.maxOxy
        Oxygen.timer   = 0

        -- define volume padrão para todos os SFX em 20%
        for key, src in pairs(Audio) do
            if src and src.setVolume then
                if not key:find("Theme") then
                    src:setVolume(0.2)
                end
            end
        end

        -- limpa armadilhas
        Traps.list = {}
        for x = 1, Config.visibleCols do
            for y = 1, Config.gridRows do
                if isPassageCell(x, y) and love.math.random() < Traps.chance then
                    table.insert(Traps.list, { cellX = x, cellY = y })
                end
            end
        end

        Patrol.list = {}
        spawnPatrol(3)

        spawnTetromino()
        initExitMatrix()
        spawnStar()
    end
end

function proceedToNextLevel()
    Dungeon.level = Dungeon.level + 1
    Config.maxOxy       = math.max(1, Config.maxOxy - 1)
    Traps.chance        = math.min(0.2, Traps.chance + 0.01)
    Patrol.speedInterval= math.max(0.2, Patrol.speedInterval * 0.9)
    spawnPatrol(Dungeon.level + 2)
    resetGame()
end  

-- ==== Condições de Fim de Jogo ====

local function triggerGameOver()
    State.gameOver = true
    if State.inGameMusic then
        Audio.musicTheme:stop()
        State.inGameMusic = false
    end
    love.audio.play(Audio.gameOverTheme)
    Audio.gameOverTheme:setVolume(0.5)
end

local function triggerVictory()
    State.victory = true
    if State.inGameMusic then
        Audio.musicTheme:stop()
        State.inGameMusic = false
    end
    love.audio.play(Audio.victoryTheme)
    Audio.victoryTheme:setVolume(0.5)
end

-- ==== Helpers de Renderização ====

local function drawEdge(x, y, dir)
    local px = (x - 1) * Config.cellSize
    local py = (y - 1) * Config.cellSize
    love.graphics.setColor(unpack(Palette.border))
    if dir == "up" then
        love.graphics.line(px, py, px + Config.cellSize, py)
    elseif dir == "down" then
        love.graphics.line(px, py + Config.cellSize, px + Config.cellSize, py + Config.cellSize)
    elseif dir == "left" then
        love.graphics.line(px, py, px, py + Config.cellSize)
    elseif dir == "right" then
        love.graphics.line(px + Config.cellSize, py, px + Config.cellSize, py + Config.cellSize)
    end
end

local function drawScaled(img, x, y) love.graphics.draw( img, x, y, 0, Config.cellSize / img:getHeight(), Config.cellSize / img:getWidth() ) end

-- ==== Callbacks Principais do LÖVE ====

function love.load()
    -- configura janela
    love.window.setMode(
      Config.visibleCols * Config.cellSize,
      Config.gridRows   * Config.cellSize
    )
    love.window.setTitle("Mazetriz")

    -- trap
    Traps.img = love.graphics.newImage("assets/spikes.png")

    -- Font HUD
    Font = {}
    Font.hud = love.graphics.newFont(32)
    love.graphics.setFont( Font.hud )

    -- HUD de oxigênio
    Oxygen.fullImg  = love.graphics.newImage("assets/oxy_full.png")
    Oxygen.emptyImg = love.graphics.newImage("assets/oxy_empty.png")

    -- Scroller
    for _, it in ipairs(Scroller.items) do
        it.scale        = 1
        it.targetScale  = 1
        it.alpha        = it.baseAlpha
        it.targetAlpha  = it.baseAlpha
        it.offsetX      = 0
        it.offsetY      = 0
        it.targetOX     = 0
        it.targetOY     = 0
    end

    -- Coin
    Coin.sheet = love.graphics.newImage("assets/coin.png")
    Coin.quad = love.graphics.newQuad(0, 0, Coin.frameW, Coin.frameH, Coin.sheet:getDimensions())

    -- Treasure
    Treasure = {}
    Treasure.lockImg  = love.graphics.newImage("assets/lock.png")
    Treasure.chestImg = love.graphics.newImage("assets/chest.png")

    -- OST: temas
    Audio.menuTheme    = love.audio.newSource("sounds/menu_theme.mp3",       "stream")
    Audio.musicTheme    = love.audio.newSource("sounds/main_theme.mp3",      "stream")
    Audio.gameOverTheme = love.audio.newSource("sounds/game_over_theme.mp3", "stream")
    Audio.victoryTheme  = love.audio.newSource("sounds/victory_theme.mp3",   "stream")
    -- SFX
    Audio.sndPlayerMove = love.audio.newSource("sounds/player_move.mp3",     "static")
    Audio.sndPlayerHit  = love.audio.newSource("sounds/player_hit.mp3",      "static")
    Audio.sndRotate     = love.audio.newSource("sounds/rotate.mp3",          "static")
    Audio.sndLockPiece  = love.audio.newSource("sounds/lock.ogg",            "static")
    Audio.sndCoin       = love.audio.newSource("sounds/coin.mp3",            "static")
    Audio.sndBubble     = love.audio.newSource("sounds/bubble.ogg",          "static")
    Audio.sndPassUI     = love.audio.newSource("sounds/pass_ui.mp3",         "static")
    Audio.sndClickUI    = love.audio.newSource("sounds/click_ui.mp3",        "static")
    Audio.sndDamage     = love.audio.newSource("sounds/damage.wav",          "static")

    -- configura looping e volumes dos temas
    Audio.menuTheme:setLooping(true)
    Audio.musicTheme:setLooping(true)
    Audio.gameOverTheme:setLooping(false)
    Audio.victoryTheme:setLooping(false)
    
    -- toca tema principal
    Audio.menuTheme:setVolume(0.5)
    Audio.musicTheme:setVolume(0.5)
    love.audio.play(Audio.menuTheme)
    State.inGameMusic = true

    -- fundo repetido
    Graphics.background = love.graphics.newImage("assets/space_wallpaper.png")
    Graphics.background:setWrap("repeat", "repeat")
    Graphics.bgQuad = love.graphics.newQuad( 0, 0, Config.visibleCols * Config.cellSize, Config.gridRows * Config.cellSize, Graphics.background:getWidth(), Graphics.background:getHeight() )

    -- player
    Player.spritesheet = love.graphics.newImage("assets/player_idle.png")
    for i = 0, 1 do table.insert( Player.frames, love.graphics.newQuad( i * 16, 0, 16, 16, Player.spritesheet:getDimensions() ) ) end
    Player.scale        = Config.cellSize / Player.spritesheet:getHeight()
    Player.currentFrame = 1
    Player.frameTimer   = 0

    -- aliens

    Guardian.img = love.graphics.newImage("assets/alien_guardian.png")
    for i = 0, 1 do table.insert(Guardian.frames, love.graphics.newQuad(i*16, 0, 16, 16, Guardian.img:getDimensions()) ) end
    Guardian.scale        = Config.cellSize / Guardian.img:getHeight()
    Guardian.currentFrame = 1
    Guardian.frameTimer   = 0

    Patrol.list = {}
    Patrol.img = love.graphics.newImage("assets/alien_patrol.png")
    for i = 0, 1 do
        table.insert(Patrol.frames,
            love.graphics.newQuad(i*16, 0, 16, 16, Patrol.img:getDimensions())
        )
    end
    spawnPatrol(3)

    -- Bullets
    Bullets.img = love.graphics.newImage("assets/bullet.png")

    -- estrela
    Star.img   = love.graphics.newImage("assets/star.png")
    Star.scale = Config.cellSize / Star.img:getWidth()

    -- inicializa grid vazio
    for x = 1, Config.visibleCols do
      State.grid[x] = {}
      for y = 1, Config.gridRows do
        State.grid[x][y] = false
      end
    end

    -- configura mecânicas principais
    initTetrominos()
    Coin.initVisitedAndCoins()
    placeRandomRooms()
    State.upcoming = {}
    for i = 1, 3 do local shapes = {} for k in pairs(State.tetrominos) do table.insert(shapes, k) end State.upcoming[i] = shapes[love.math.random(#shapes)] end
    spawnTetromino()
    initExitMatrix()
    injectExitIntoGrid()
    spawnStar()

    -- Fundo e quad
    Graphics.bgScroll = 0

    -- Título
    Menu.titleSprite = love.graphics.newImage("assets/title.png")
    local tw, th = Menu.titleSprite:getDimensions()
    Menu.titleScale = (Config.visibleCols*Config.cellSize * 0.7) / tw

    -- Fonte dos botões
    Menu.font = love.graphics.newFont(24)

    -- Define botões
    local sw = Config.visibleCols*Config.cellSize
    local sh = Config.gridRows*Config.cellSize
    local midY = sh * 0.6
    Menu.btns = {
        {
            text = "Start",
            x = (sw-200)/2, y = midY,
            w = 200, h = 50,
            scale = 1, targetScale = 1
        },
        {
            text = "Quit",
            x = (sw-200)/2, y = midY + 70,
            w = 200, h = 50,
            scale = 1, targetScale = 1
        }
    }
    -- Inicializa fade-in
    Menu.fadeTimer = 0
    Menu.overlayAlpha = 1
end

function love.update(dt)
    -- fim de jogo/verício
    if State.gameOver or State.victory then
        return
    end

    if GameState == "menu" then
        -- fundo parallax scroll
        Graphics.bgScroll = (Graphics.bgScroll + Config.bgScrollSpeed * dt) % Graphics.background:getWidth()
        Graphics.bgQuad:setViewport(Graphics.bgScroll, 0, Config.visibleCols*Config.cellSize, Config.gridRows*Config.cellSize)

        -- Fade-in
        if not Menu.transitioning then
            Menu.fadeTimer = math.min(Menu.fadeTimer + dt, Menu.fadeDur)
            Menu.overlayAlpha = 1 - Menu.fadeTimer / Menu.fadeDur
        else
            -- Fade-out
            Menu.transitionTimer = math.min(Menu.transitionTimer + dt, Menu.transitionDur)
            Menu.overlayAlpha = Menu.transitionTimer / Menu.transitionDur
            if Menu.transitionTimer >= Menu.transitionDur then
                -- toca tema principal
                Audio.menuTheme:stop()
                love.audio.play(Audio.musicTheme)
                -- entra no jogo
                GameState = "play"
                resetGame()
            end
        end

        -- Câmera segue mouse suavemente
        local mx, my = love.mouse.getPosition()
        local sw, sh = love.graphics.getDimensions()
        local targetX = (mx/sw - 0.5) * 2 * Menu.camLimit
        local targetY = (my/sh - 0.5) * 2 * Menu.camLimit
        Menu.camOffsetX = Menu.camOffsetX + (targetX - Menu.camOffsetX) * math.min(dt*Menu.camSmooth,1)
        Menu.camOffsetY = Menu.camOffsetY + (targetY - Menu.camOffsetY) * math.min(dt*Menu.camSmooth,1)

        -- Botão hover scaling
        local mx, my = love.mouse.getPosition()
        for _, btn in ipairs(Menu.btns) do
            if mx >= btn.x and mx <= btn.x+btn.w and my >= btn.y and my <= btn.y+btn.h then
                btn.targetScale = 1.1
            else
                btn.targetScale = 1
            end
            -- suaviza escala
            btn.scale = btn.scale + (btn.targetScale - btn.scale) * math.min(dt*8,1)
        end
        return
    end

    -- calcula posição normalizada do mouse
    local mx, my = love.mouse.getPosition()
    local sw, sh      = love.graphics.getDimensions()
    local nx     = (mx / sw  - 0.5) * 2
    local ny     = (my / sh  - 0.5) * 2
    local hoveredIdx

    -- dimensão da tela
    local screenW, screenH = love.graphics.getDimensions()

    -- define o alvo dentro dos limites
    Camera.mouseTargetX = math.max(-Camera.mouseLimit, math.min(Camera.mouseLimit, nx * Camera.mouseLimit))
    Camera.mouseTargetY = math.max(-Camera.mouseLimit, math.min(Camera.mouseLimit, ny * Camera.mouseLimit))

    -- interpola com lerp simples
    local t = math.min(dt * Camera.mouseSmoothSpeed, 1)
    Camera.mouseOffsetX = Camera.mouseOffsetX + (Camera.mouseTargetX - Camera.mouseOffsetX) * t
    Camera.mouseOffsetY = Camera.mouseOffsetY + (Camera.mouseTargetY - Camera.mouseOffsetY) * t

    -- câmera retorna ao centro (bounce)
    Camera.offsetX = Camera.offsetX + (0 - Camera.offsetX) * math.min(dt * Config.cameraReturnSpeed, 1)
    Camera.offsetY = Camera.offsetY + (0 - Camera.offsetY) * math.min(dt * Config.cameraReturnSpeed, 1)

    -- controle de oxigênio
    if Player.spawned then
        if isInVacuumCell() then
            Oxygen.timer = Oxygen.timer + dt
            if Oxygen.timer >= Config.oxyInterval then
                Oxygen.timer = Oxygen.timer - Config.oxyInterval
                Oxygen.current = math.max(Oxygen.current - 1, 0)
                love.audio.play(Audio.sndBubble:clone())
                ScreenFlash.timer = ScreenFlash.duration
                local shake = Config.cameraBounceAmount
                Camera.offsetX = (love.math.random() * 2 - 1) * shake
                Camera.offsetY = (love.math.random() * 2 - 1) * shake
            end
        else
            Oxygen.timer   = 0
            Oxygen.current = math.min(Oxygen.current + dt * 2, Config.maxOxy)
        end
        if Oxygen.current == 0 or State.topTouchTimer >= Config.topTouchThreshold then
            love.audio.play(Audio.sndDamage:clone())
            triggerGameOver()
            return
        end
    end

    -- turbulência
    Camera.turbTimer = Camera.turbTimer + dt * Config.turbSpeed

    -- Scroller
    for i, it in ipairs(Scroller.items) do
        local bs    = it.baseSize
        local bx    = Scroller.margin
        local byTop = sh - Scroller.margin - (i-1)*(Scroller.items[1].baseSize + Scroller.spacing) - bs
        if mx >= bx and mx <= bx + bs and my >= byTop and my <= byTop + bs then
            hoveredIdx = i
            break
        end
    end

    for i, it in ipairs(Scroller.items) do
        if i == hoveredIdx then
            it.targetScale = 1.2
            it.targetAlpha = 1.0
        else
            it.targetScale = 1.0
            it.targetAlpha = it.baseAlpha
        end

        if i == hoveredIdx then
            local bs    = it.baseSize
            local bx    = Scroller.margin
            local by    = sh - Scroller.margin - (i-1)*(Scroller.items[1].baseSize + Scroller.spacing) - bs
            local localX = ((mx - (bx + bs/2)) / (bs/2))
            local localY = ((my - (by + bs/2)) / (bs/2))
            
            it.targetOX  = math.max(-Scroller.maxMove, math.min(Scroller.maxMove, localX * Scroller.maxMove))
            it.targetOY  = math.max(-Scroller.maxMove, math.min(Scroller.maxMove, localY * Scroller.maxMove))
        else
            it.targetOX  = 0
            it.targetOY  = 0
        end

        local t1 = math.min(dt * Scroller.smoothSpeed, 1)
        it.scale = it.scale + (it.targetScale - it.scale) * t1
        it.alpha = it.alpha + (it.targetAlpha - it.alpha) * t1

        local t2 = math.min(dt * Scroller.moveSmooth, 1)
        it.offsetX = it.offsetX + (it.targetOX - it.offsetX) * t2
        it.offsetY = it.offsetY + (it.targetOY - it.offsetY) * t2
    end

    -- movimento dos Guardian
    for _, g in ipairs(Guardian.list) do
        if Player.spawned and Player.obj then
            g.frameTimer = g.frameTimer + dt
            if g.frameTimer >= g.frameDuration then
                g.frameTimer   = g.frameTimer - g.frameDuration
                g.currentFrame = g.currentFrame % #g.frames + 1
            end

            g.timer = g.timer + dt

            if clearLineOfSight(g.cellX, g.cellY, Player.obj.cellX, Player.obj.cellY) then
                local dx = (Player.obj.cellX > g.cellX) and 1 or (Player.obj.cellX < g.cellX) and -1 or 0
                local dy = (Player.obj.cellY > g.cellY) and 1 or (Player.obj.cellY < g.cellY) and -1 or 0
                
                g.sliding   = true
                g.destCellX = g.cellX + dx
                g.destCellY = g.cellY + dy
                g.slideVelX = dx * (Config.cellSize / Config.slideDuration) * 4
                g.slideVelY = dy * (Config.cellSize / Config.slideDuration) * 4
                g.dir       = (dx==1 and "right") or (dx==-1 and "left") or (dy==1 and "down") or "up"
                g.angle     = DirAngles[g.dir]
                
                goto continue_guardian
            end

            if not g.sliding and g.timer >= g.moveInterval then
                g.timer = g.timer - g.moveInterval

                local room = rooms[g.roomId]
                local moves = {}
                for _,d in pairs(Directions) do
                    local nx, ny = g.cellX + d.dx, g.cellY + d.dy
                    if nx >= room.x+1 and nx <= room.x+room.w-2 and ny >= room.y+1 and ny <= room.y+room.h-2 then
                        local c = State.grid[nx][ny]
                        if c and c.corridor and not (nx==room.treasureChest.cellX and ny==room.treasureChest.cellY) then
                            table.insert(moves, {dx=d.dx, dy=d.dy})
                        end
                    end
                end

                if #moves>0 then
                    local m = moves[love.math.random(#moves)]
                    g.sliding   = true
                    g.destCellX = g.cellX + m.dx
                    g.destCellY = g.cellY + m.dy
                    g.slideVelX = (m.dx * Config.cellSize) / Config.slideDuration
                    g.slideVelY = (m.dy * Config.cellSize) / Config.slideDuration
                    g.dir       = (m.dx==1 and "right") or (m.dx==-1 and "left") or (m.dy==1 and "down") or "up"
                    g.angle     = DirAngles[g.dir]
                end
            end

            ::continue_guardian::

            if g.sliding then
                g.px = g.px + g.slideVelX * dt
                g.py = g.py + g.slideVelY * dt

                local tx = (g.destCellX-1)*Config.cellSize
                local ty = (g.destCellY-1)*Config.cellSize
                local arrivedX = (g.slideVelX==0) or (g.slideVelX>0 and g.px>=tx) or (g.slideVelX<0 and g.px<=tx)
                local arrivedY = (g.slideVelY==0) or (g.slideVelY>0 and g.py>=ty) or (g.slideVelY<0 and g.py<=ty)
                if arrivedX and arrivedY then
                    g.cellX, g.cellY = g.destCellX, g.destCellY
                    g.px, g.py       = tx, ty
                    g.sliding        = false
                end
            end
        end
    end

    -- Patrol
    -- dentro de love.update(dt), no bloco de Patrol:
    for _, p in ipairs(Patrol.list) do
        -- animação independente (opcional você manter global ou deixar por-instância)
        p.frameTimer = (p.frameTimer or 0) + dt
        if p.frameTimer >= Patrol.frameDuration then
            p.frameTimer = p.frameTimer - Patrol.frameDuration
            p.currentFrame = (p.currentFrame or 1) % #Patrol.frames + 1
        end

        -- Movimento célula-a-célula (igual antes)...
        p.timer = p.timer + dt
        if p.timer >= Patrol.speedInterval then
            p.timer = p.timer - Patrol.speedInterval
            local dx, dy = (p.dir=="horizontal" and p.sign or 0), (p.dir=="vertical" and p.sign or 0)
            if isWallCell(p.cellX+dx, p.cellY+dy) then
                p.sign = -p.sign
            else
                p.cellX = p.cellX + dx
                p.cellY = p.cellY + dy
            end
        end

        -- Controle de cooldown de tiro
        p.shootTimer = p.shootTimer + dt
        if p.shootTimer >= Patrol.shootInterval then
            -- só atira se estiver na “visão” correta
            if Player.spawned then
                local px, py = Player.obj.cellX, Player.obj.cellY
                if (p.dir=="vertical" and py == p.cellY and clearLineOfSight(p.cellX, p.cellY, px, p.cellY))
                or  (p.dir=="horizontal" and px == p.cellX and clearLineOfSight(p.cellX, p.cellY, p.cellX, py))
                then
                    -- calcula vetor unitário até o centro da célula do player
                    local bx = (p.cellX-1)*Config.cellSize + Config.cellSize/2
                    local by = (p.cellY-1)*Config.cellSize + Config.cellSize/2
                    local tx = (px-1)*Config.cellSize  + Config.cellSize/2
                    local ty = (py-1)*Config.cellSize  + Config.cellSize/2
                    local dxv, dyv = tx - bx, ty - by
                    local dist = math.sqrt(dxv*dxv + dyv*dyv)
                    dxv, dyv = dxv/dist, dyv/dist

                    table.insert(Bullets.list, {
                        x  = bx, y  = by,
                        vx = dxv, vy = dyv,
                    })
                    p.shootTimer = 0  -- reinicia cooldown
                end
            end
        end
    end

    -- Bullets
    for i = #Bullets.list,1,-1 do
        local b = Bullets.list[i]
        b.x = b.x + b.vx * Bullets.speed * dt
        b.y = b.y + b.vy * Bullets.speed * dt

        local cx = math.floor(b.x/Config.cellSize)+1
        local cy = math.floor(b.y/Config.cellSize)+1
        if cx<1 or cx>Config.visibleCols or cy<1 or cy>Config.gridRows
        or (getCell(cx,cy) and getCell(cx,cy).wall)
        then
            table.remove(Bullets.list,i)
        elseif Player.spawned and cx==Player.obj.cellX and cy==Player.obj.cellY then
            love.audio.play(Audio.sndDamage:clone())
            triggerGameOver()
            return
        end
    end

    -- animação idle e movimento até colisão
    if Player.spawned then
        Player.frameTimer = Player.frameTimer + dt
        if Player.frameTimer >= Config.frameDuration then
            Player.frameTimer   = Player.frameTimer - Config.frameDuration
            Player.currentFrame = Player.currentFrame % #Player.frames + 1
        end
        if not Player.obj.collided then
            local obj = Player.obj
            obj.px = obj.px + obj.dx * dt
            obj.py = obj.py + obj.dy * dt
            local targetX = obj.cellX + Directions[obj.dir].dx
            local targetY = obj.cellY + Directions[obj.dir].dy
            local wallPx  = (targetX - 1) * Config.cellSize
            local wallPy  = (targetY - 1) * Config.cellSize
            if obj.dir == "right" and obj.px + Config.cellSize >= wallPx then
                obj.px, obj.collided = wallPx - Config.cellSize, true
            elseif obj.dir == "left" and obj.px <= wallPx + Config.cellSize then
                obj.px, obj.collided = wallPx + Config.cellSize, true
            elseif obj.dir == "down" and obj.py + Config.cellSize >= wallPy then
                obj.py, obj.collided = wallPy - Config.cellSize, true
            elseif obj.dir == "up" and obj.py <= wallPy + Config.cellSize then
                obj.py, obj.collided = wallPy + Config.cellSize, true
            end
        end
    end

    -- queda automática das piezas
    State.dropTimer = State.dropTimer + dt
    if State.dropTimer >= State.dropInterval then
        State.dropTimer = State.dropTimer - State.dropInterval
        if State.lineClearTimer == 0 then
            if not checkCollision(State.current, 0, 1) then
                State.current.y = State.current.y + 1
            else
                local touchingTop = false
                for _, b in ipairs(State.current.blocks) do
                    if State.current.y + b[2] <= 1 then
                        touchingTop = true; break
                    end
                end
                if touchingTop then
                    State.topTouchTimer = State.topTouchTimer + State.dropInterval
                    if State.topTouchTimer >= Config.topTouchThreshold then
                        triggerGameOver()
                        return
                    end
                else
                    State.topTouchTimer = 0
                end
                lockPiece()
                local rows = detectFullRows()
                if #rows > 0 then
                    State.linesToClear   = rows
                    State.lineClearTimer = State.lineClearDelay
                else
                    spawnTetromino()
                end
            end
        end
    end

    -- movimento contínuo das peças
    PieceInput.moveTimer = PieceInput.moveTimer + dt
    if PieceInput.moveTimer >= PieceInput.moveDelay then
        if PieceInput.moveHeld.left and not checkCollision(State.current, -1, 0) then
            State.current.x = State.current.x - 1
        elseif PieceInput.moveHeld.right and not checkCollision(State.current, 1, 0) then
            State.current.x = State.current.x + 1
        elseif PieceInput.moveHeld.down and not checkCollision(State.current, 0, 1) then
            State.current.y = State.current.y + 1
        end
        PieceInput.moveTimer = 0
    end

    -- trilha do player
    if Player.spawned and Player.sliding then table.insert( Player.trail, { x = Player.obj.px, y = Player.obj.py, t = Config.trailLifetime, dir = Player.obj.dir, } ) end

    -- atualiza trilhas expiradas
    for i = #Player.trail, 1, -1 do
        local p = Player.trail[i]
        p.t = p.t - dt
        if p.t <= 0 then table.remove(Player.trail, i) end
    end

    -- slide do player
    if Player.spawned and Player.sliding then
        -- deslocamento parcial dentro da célula
        local fx = Player.slideDirX * (Config.cellSize / 2)
        local fy = (Player.slideDirY == -1) and -Config.cellSize or 0
        local obj = Player.obj

        -- movimento
        obj.px = obj.px + Player.slideVelX * dt
        obj.py = obj.py + Player.slideVelY * dt

        -- **atualiza cellX/Y dinamicamente**
        local centerX = obj.px + Config.cellSize/2
        local centerY = obj.py + Config.cellSize/2
        obj.cellX = math.floor(centerX / Config.cellSize) + 1
        obj.cellY = math.floor(centerY / Config.cellSize) + 1

        -- chegada no destino original
        local targetX = (Player.destCellX - 1) * Config.cellSize + fx
        local targetY = (Player.destCellY - 1) * Config.cellSize + fy
        local arrivedX = Player.slideVelX == 0 or (Player.slideVelX > 0 and obj.px >= targetX) or (Player.slideVelX < 0 and obj.px <= targetX)
        local arrivedY = Player.slideVelY == 0 or (Player.slideVelY > 0 and obj.py >= targetY) or (Player.slideVelY < 0 and obj.py <= targetY)

        if arrivedX and arrivedY then
            -- mantém a célula final exata
            obj.cellX, obj.cellY = Player.destCellX, Player.destCellY
            obj.px, obj.py       = targetX, targetY
            obj.collided         = true
            Player.sliding       = false
            Player.slideVelX, Player.slideVelY = 0, 0

            Camera.offsetX =  Player.slideDirX * Config.cameraBounceAmount
            Camera.offsetY =  Player.slideDirY * Config.cameraBounceAmount

            love.audio.play(Audio.sndPlayerHit:clone())
        end
    end

    -- scroll de background
    Graphics.bgScroll = (Graphics.bgScroll + Config.bgScrollSpeed * dt) % Graphics.background:getWidth()
    Graphics.bgQuad:setViewport( Graphics.bgScroll, 0, Config.visibleCols * Config.cellSize, Config.gridRows * Config.cellSize )

    -- bobbing da estrela
    if Star.cellX and Star.cellY then
        Star.timer   = Star.timer + dt * 2
        Star.offsetY = math.sin(Star.timer) * (Config.cellSize * 0.2)
    end

    if ScreenFlash.timer > 0 then ScreenFlash.timer = math.max(ScreenFlash.timer - dt, 0) end -- atualiza flash game over
    if Coin.flashTimer > 0 then Coin.flashTimer = math.max(Coin.flashTimer - dt, 0) end -- atualiza flash/tremor do contador

    -- tentativa de spawn do player
    trySpawnExitPlayer()

    -- detecção de vitória
    if Player.spawned and Player.obj then
        local ps = Player.spritesheet:getHeight()    * Player.scale
        local px = Player.obj.px + Config.cellSize/2 - ps/2
        local py = Player.obj.py + Config.cellSize   + (((Player.obj.dir=="left" or Player.obj.dir=="right") and -ps/2) or 0)

        local ss = Star.img:getHeight() * Star.scale
        local sx = (Star.cellX - 1)     * Config.cellSize
        local sy = (Star.cellY - 1)     * Config.cellSize + Star.offsetY
    
        if px < sx + ss and px + ps > sx and py < sy + ss and py + ps > sy then
            love.audio.play(Audio.sndCoin:clone())
            proceedToNextLevel()
            return
        end
    end

    -- Visited Cell
    if Player.spawned and Player.obj then
        local cx, cy = Player.obj.cellX, Player.obj.cellY
        Visited[cx][cy] = true
    end

    -- Coin
    Coin.spawnTimer = Coin.spawnTimer + dt
    while Coin.spawnTimer >= Coin.spawnInterval do
        Coin.spawnTimer = Coin.spawnTimer - Coin.spawnInterval
        if #Coin.list < Coin.maxOnMap then spawnCoin() end
    end

    for i = #Coin.list, 1, -1 do
        local c = Coin.list[i]
        if Player.spawned and Player.obj.cellX == c.cellX and Player.obj.cellY == c.cellY then
            table.remove(Coin.list, i)
            Coin.count = Coin.count + 1
            Coin.flashTimer = Coin.flashDur
            love.audio.play(Audio.sndCoin:clone())
        end
    end

    -- checa trap
    if Player.spawned and not State.gameOver and not State.victory then
        for _, t in ipairs(Traps.list) do
            if t.cellX == Player.obj.cellX and t.cellY == Player.obj.cellY then
                t.triggered = true        
                ScreenFlash.timer = ScreenFlash.duration
                love.audio.play(Audio.sndDamage:clone())
                triggerGameOver()
                return
            end
        end
    end
  
    for _, room in ipairs(rooms) do
        if room.isTreasure and not room.chestCollected and Player.obj.cellX == room.treasureChest.cellX and Player.obj.cellY == room.treasureChest.cellY then
            room.chestCollected = true
            love.audio.play( Audio.sndCoin:clone() )
            local lx, ly = room.treasureLock.cellX, room.treasureLock.cellY
            State.grid[lx][ly] = false
        end
    end
end

function love.draw()
    -- aplicando transform de câmera
    love.graphics.push()
    love.graphics.translate(Menu.camOffsetX, Menu.camOffsetY)

    -- desenha fundo
    love.graphics.setColor(1,1,1)
    love.graphics.draw(Graphics.background, Graphics.bgQuad, 0, 0)

    if GameState == "menu" then
        -- título
        love.graphics.setColor(1,1,1)
        local tw, th = Menu.titleSprite:getDimensions()
        love.graphics.draw(
            Menu.titleSprite,
            (Config.visibleCols*Config.cellSize - tw*Menu.titleScale)/2,
            100,
            0,
            Menu.titleScale, Menu.titleScale
        )

        -- botões
        love.graphics.setFont(Menu.font)
        for idx, btn in ipairs(Menu.btns) do
            -- botão
            local bx = (btn.x + (1-btn.scale)*btn.w/2) * 1.2
            local by = btn.y + (1-btn.scale)*btn.h/2
            local bw = btn.w * btn.scale * 0.8
            local bh = btn.h * btn.scale * 0.8
            love.graphics.setColor(0.6,0.4,0.6,0.8)
            love.graphics.rectangle("fill", bx, by, bw, bh, 8,8)
            -- texto
            love.graphics.setColor(1,1,1)
            love.graphics.printf( btn.text, bx, by + (bh - Menu.font:getHeight())/2, bw, "center" )
        end

        -- overlay fade
        love.graphics.setColor(0,0,0, Menu.overlayAlpha)
        love.graphics.rectangle("fill", 0, 0, Config.visibleCols*Config.cellSize, Config.gridRows*Config.cellSize)

        love.graphics.pop()
        return
    end

    -- menu pop aplicado, segue jogo
    love.graphics.pop()

    -- calcula tremor + bounce
    local ox    = (love.math.noise(Camera.turbTimer) - 0.5) * Config.turbAmplitude + Camera.offsetX
    local oy    = (love.math.noise(Camera.turbTimer + 50) - 0.5) * Config.turbAmplitude + Camera.offsetY
    local angle = (love.math.noise(Camera.turbTimer + 100) - 0.5) * (math.pi/180) * 0.5

    -- desenha mundo com transformações
    love.graphics.push()
    love.graphics.translate(Camera.mouseOffsetX, Camera.mouseOffsetY)
    love.graphics.translate(ox, oy)
    love.graphics.rotate(angle)

    drawExitMatrix()

    -- desenha células fixas do grid
    for x = 1, Config.visibleCols do
        for y = 1, Config.gridRows do
            local cell = State.grid[x][y]
            if cell then
                local col = cell.corridor and Palette.passage or Palette.wall
                love.graphics.setColor( unpack(col) )
                love.graphics.rectangle( "fill", (x-1)*Config.cellSize, (y-1)*Config.cellSize, Config.cellSize, Config.cellSize )
            end
        end
    end

    -- destaca linhas marcadas para clear
    if State.lineClearTimer > 0 then
        love.graphics.setColor(1,0,0)
        love.graphics.setLineWidth(3)
        for _, y in ipairs(State.linesToClear) do
            love.graphics.rectangle( "line", 0, (y-1)*Config.cellSize, Config.visibleCols*Config.cellSize, Config.cellSize )
        end
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1,1,1)
    end

    -- desenha peça atual (blocks)
    for _, b in ipairs(State.current.blocks) do
        local bx = State.current.x + b[1]
        local by = State.current.y + b[2]
        if isInCorridor(b[1], b[2]) then love.graphics.setColor( unpack(Palette.passage) ) else love.graphics.setColor( unpack(Palette.wall) ) end
        love.graphics.rectangle( "fill", (bx-1)*Config.cellSize, (by-1)*Config.cellSize, Config.cellSize, Config.cellSize )
    end

    -- contorno branco da forma
    love.graphics.setLineWidth(3)
    love.graphics.setColor(1,1,1)
    for _, e in ipairs(findExternalEdges(State.current.blocks)) do
        local px = (State.current.x + e.x - 1) * Config.cellSize
        local py = (State.current.y + e.y - 1) * Config.cellSize
        if e.dir == "up" then
            love.graphics.line(px, py, px+Config.cellSize, py)
        elseif e.dir == "down" then
            love.graphics.line(px, py+Config.cellSize, px+Config.cellSize, py+Config.cellSize)
        elseif e.dir == "left" then
            love.graphics.line(px, py, px, py+Config.cellSize)
        elseif e.dir == "right" then
            love.graphics.line(px+Config.cellSize, py, px+Config.cellSize, py+Config.cellSize)
        end
    end
    love.graphics.setLineWidth(1)

    -- bordas especiais da peça
    for _, e in ipairs(findExternalEdges(State.current.blocks)) do
        local isPass = (e.x==State.current.p1.x and e.y==State.current.p1.y and e.dir==State.current.p1.dir)
                   or (e.x==State.current.p2.x and e.y==State.current.p2.y and e.dir==State.current.p2.dir)
        drawEdge(
          State.current.x+e.x,
          State.current.y+e.y,
          e.dir
        )
    end

    -- desenha traps
    for _, t in ipairs(Traps.list) do
        local cx = (t.cellX - 1) * Config.cellSize
        local cy = (t.cellY - 1) * Config.cellSize
        local size = Config.cellSize * 0.4
        local off = (Config.cellSize - size) / 2
    
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle( "fill", cx + off, cy + off, size, size )
    end

    for _, t in ipairs(Traps.list) do
        if t.triggered then
            local px = (t.cellX - 1) * Config.cellSize
            local py = (t.cellY - 1) * Config.cellSize
            love.graphics.setColor(1,1,1)
            love.graphics.draw( Traps.img, px, py, 0, Config.cellSize / Traps.img:getWidth(), Config.cellSize / Traps.img:getHeight() )
        end
    end
  
    -- Treasure Rooms
    for _, room in ipairs(rooms) do
        if room.isTreasure then
            local lx = (room.treasureLock.cellX - 1) * Config.cellSize
            local ly = (room.treasureLock.cellY - 1) * Config.cellSize
            love.graphics.draw( Treasure.lockImg, lx, ly, 0, Config.cellSize / Treasure.lockImg:getHeight(), Config.cellSize / Treasure.lockImg:getWidth() )
        
            local cx = (room.treasureChest.cellX - 1) * Config.cellSize
            local cy = (room.treasureChest.cellY - 1) * Config.cellSize
            love.graphics.draw( Treasure.chestImg, cx, cy, DirAngles[ room.treasureChest.dir ],  Config.cellSize / Treasure.chestImg:getWidth(), Config.cellSize / Treasure.chestImg:getHeight() )
        end
    end

    -- desenha Guardian
    for _, g in ipairs(Guardian.list) do
        local quad = g.frames[g.currentFrame]
        local _, _, qw, qh = quad:getViewport()
        local cx = g.px + Config.cellSize/2
        local cy = g.py + Config.cellSize/2
        local originX = qw/2
        local originY = qh/2
      
        love.graphics.setColor(1,1,1)
        love.graphics.draw(
            g.img,
            quad,
            cx, cy,
            g.angle,
            g.scale, g.scale,
            originX, originY
        )
    end

    -- desenha Patrol
    for _, p in ipairs(Patrol.list) do
        local quad = Patrol.frames[Patrol.currentFrame]
        local px = (p.cellX-1) * Config.cellSize
        local py = (p.cellY-1) * Config.cellSize
        love.graphics.draw(Patrol.img, quad,
            px + Config.cellSize/2, py + Config.cellSize/2,
            0,  p.cellScale or 1, p.cellScale or 1,
            8, 8
        )
    end

    -- desenha Bullets
    for _, b in ipairs(Bullets.list) do
        love.graphics.draw(Bullets.img,
            b.x - Bullets.width/2, b.y - Bullets.height/2,
            0, (Bullets.width/16)*(Config.cellSize/16), (Bullets.height/16)*(Config.cellSize/16)
        )
    end

    -- trilha do player
    for _, p in ipairs(Player.trail) do
        local alpha = (p.t / Config.trailLifetime) * 0.5
        love.graphics.setColor(0.09,0.79,0.79,alpha)
        local tx, ty = p.x, p.y
        if p.dir == "up"    then ty = ty + Config.cellSize
        elseif p.dir == "down"  then ty = ty - Config.cellSize
        elseif p.dir == "left"  then tx = tx + Config.cellSize
        elseif p.dir == "right" then tx = tx - Config.cellSize
        end
        love.graphics.rectangle("fill", tx, ty, Config.cellSize, Config.cellSize)
    end

    -- desenha player
    if Player.spawned and Player.obj then
        local halfW = (16 * Player.scale) / 2
        local extraY = ((Player.obj.dir == "left" or Player.obj.dir == "right") and -halfW) or 0
        love.graphics.setColor(1,1,1)
        love.graphics.draw(
          Player.spritesheet,
          Player.frames[Player.currentFrame],
          Player.obj.px + Config.cellSize/2,
          Player.obj.py + Config.cellSize + extraY,
          Player.obj.angle,
          Player.scale,
          Player.scale,
          8, 16
        )
    end

    -- estrela
    if Star.cellX and Star.cellY then
        local sx = (Star.cellX - 1) * Config.cellSize
        local sy = (Star.cellY - 1) * Config.cellSize + Star.offsetY
        love.graphics.setColor(1,1,1)
        love.graphics.draw( Star.img, sx, sy, 0, Star.scale, Star.scale )
    end

    -- moedas
    for _, c in ipairs(Coin.list) do
        local px = (c.cellX - 1) * Config.cellSize
        local py = (c.cellY - 1) * Config.cellSize
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw( Coin.sheet, Coin.quad, px, py, 0, Config.cellSize / Coin.frameW, Config.cellSize / Coin.frameH )
    end

    love.graphics.pop()

    -- guardian collision
    for _, g in ipairs(Guardian.list) do
        if Player.spawned and Player.obj.cellX == g.cellX and Player.obj.cellY == g.cellY then
            love.audio.play(Audio.sndDamage:clone())
            triggerGameOver()
            return
        end
    end

    -- cenas de vitória/game over
    if State.victory then
        love.graphics.push()
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle( "fill", 0, 0, Config.visibleCols*Config.cellSize, Config.gridRows*Config.cellSize)
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.setColor(0,1,0)
        love.graphics.printf( "YOU WIN!", 0, (Config.gridRows*Config.cellSize)/2 - 16, Config.visibleCols*Config.cellSize, "center" )
        love.graphics.setColor(0.8,0.8,0.8,0.9)
        love.graphics.printf( "Press any key to restart", Config.cellSize*4.5, (Config.gridRows*Config.cellSize)/2 + Config.cellSize*1.5, Config.visibleCols*Config.cellSize, "center", 0, 0.5, 0.5 )
        love.graphics.pop()
        return
    elseif State.gameOver then
        love.graphics.push()
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.rectangle( "fill", 0, 0, Config.visibleCols*Config.cellSize, Config.gridRows*Config.cellSize )
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.setColor(1,0,0)
        love.graphics.printf( "GAME OVER", 0, (Config.gridRows*Config.cellSize)/2 - 16, Config.visibleCols*Config.cellSize, "center" )
        love.graphics.setColor(0.8,0.8,0.8,0.9)
        love.graphics.printf( "Press any key to restart", Config.cellSize*4.5, Config.gridRows*Config.cellSize/2 + Config.cellSize*1.5, Config.visibleCols*Config.cellSize, "center", 0, 0.5, 0.5 )
        love.graphics.pop()
    end

    -- HUD de oxigênio
    love.graphics.push()
    for i = 1, Config.maxOxy do
        local img = (i <= Oxygen.current) and Oxygen.fullImg or Oxygen.emptyImg
        drawScaled( img, 4 + (i-1) * (img:getWidth() * (Config.cellSize/16) + 4), 4 )
    end
    love.graphics.pop()

    -- desenha flash vermelho por cima:
    if ScreenFlash.timer > 0 then
        local α = (ScreenFlash.timer / ScreenFlash.duration) * 0.5
        love.graphics.setColor(1, 0, 0, α)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight() )
        love.graphics.setColor(1,1,1,1)
    end

    -- Scroller
    love.graphics.push()
    local sw, sh = love.graphics.getDimensions()
    for i, it in ipairs(Scroller.items) do
        local col = Palette.wall
        love.graphics.setColor( col[1] * it.dark, col[2] * it.dark, col[3] * it.dark, it.alpha )

        local size = it.baseSize * it.scale
        local bx   = Scroller.margin + it.offsetX
        local by   = sh - Scroller.margin - (i-1)*(Scroller.items[1].baseSize + Scroller.spacing) - size + it.offsetY
        love.graphics.rectangle("fill", bx, by, size, size)

        local blocks = (i == 1) and State.current.blocks or State.tetrominos[ State.upcoming[i-1] ]
        drawMiniTetromino(blocks, bx, by, size)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()

    -- contador de moedas
    love.graphics.push()
    do
        local txt    = tostring(Coin.count)
        local font   = love.graphics.getFont()
        local w      = font:getWidth(txt)
        local h      = font:getHeight()
        local margin = 8

        if Coin.flashTimer > 0 then love.graphics.setColor(1, 1, 0) else love.graphics.setColor(1, 1, 1) end

        local shake = 0
        if Coin.flashTimer > 0 then
            local p = Coin.flashTimer / Coin.flashDur
            shake = Coin.shakeAmp * p
            local dx = (love.math.random() * 2 - 1) * shake
            local dy = (love.math.random() * 2 - 1) * shake
            love.graphics.printf(txt, Config.visibleCols*Config.cellSize - w - margin + dx, margin + dy, w, "left" )
        else
            love.graphics.printf(txt, Config.visibleCols*Config.cellSize - w - margin, margin, w, "left" )
        end

        love.graphics.setColor(1,1,1)
    end
    love.graphics.pop()
end

function love.keypressed(key)
    -- Reiniciar se acabou o jogo
    if State.gameOver or State.victory then
        resetGame()
        return
    end

    -- Bloqueia WASD antes de spawnar
    if (key == "w" or key == "a" or key == "s" or key == "d") and not Player.spawned then
        return
    end

    -- controle peça (setas)
    if key == "left" then
        if not checkCollision(State.current, -1, 0) then
            State.current.x = State.current.x - 1
        end
        PieceInput.moveHeld.left = true
        PieceInput.moveTimer = 0

    elseif key == "right" then
        if not checkCollision(State.current, 1, 0) then
            State.current.x = State.current.x + 1
        end
        PieceInput.moveHeld.right = true
        PieceInput.moveTimer = 0

    elseif key == "down" then
        if not checkCollision(State.current, 0, 1) then
            State.current.y = State.current.y + 1
        end
        PieceInput.moveHeld.down = true
        PieceInput.moveTimer = 0

    elseif key == "up" then
        local newBlocks = rotate(State.current.blocks)
        if not checkCollision(State.current, 0, 0, newBlocks) then
            State.current.blocks = newBlocks

            -- gira corredor
            local newCorr = {}
            for _, c in ipairs(State.current.corridor) do
                local nx, ny = rotateCoord(c[1], c[2])
                table.insert(newCorr, { nx, ny })
            end
            State.current.corridor = newCorr

            -- gira pontos p1/p2
            local p1x, p1y = rotateCoord(State.current.p1.x, State.current.p1.y)
            State.current.p1 = { x = p1x, y = p1y, dir = dirRotation[State.current.p1.dir] }
            local p2x, p2y = rotateCoord(State.current.p2.x, State.current.p2.y)
            State.current.p2 = { x = p2x, y = p2y, dir = dirRotation[State.current.p2.dir] }

            love.audio.play( Audio.sndRotate:clone() )
        end
    end

    -- ==== MOVIMENTO DO PLAYER (WASD) COM BUFFER ====
    local dx, dy
    if     key == "w" then dx,dy = 0, -1
    elseif key == "s" then dx,dy = 0,  1
    elseif key == "a" then dx,dy = -1, 0
    elseif key == "d" then dx,dy =  1, 0
    else
        return
    end

    if Player.sliding then
        Player.nextMove = { dx = dx, dy = dy }
    else
        startPlayerSlide(dx, dy)
    end

    if GameState ~= "menu" and not Player.sliding then
        for _, room in ipairs(rooms) do
            if room.isTreasure and not room.chestCollected then
                local lock = room.treasureLock
                local expectX = lock.cellX + Directions[lock.dir].dx
                local expectY = lock.cellY + Directions[lock.dir].dy
                if Player.obj.cellX == expectX and Player.obj.cellY == expectY and key == lock.dir then
                    room.lockHits = room.lockHits + 1
                    love.audio.play( Audio.sndPlayerHit:clone() )
                    if room.lockHits >= room.lockRequired then
                        State.grid[lock.cellX][lock.cellY] = { wall=false, corridor=true }
                        room.chestCollected = true
                end
                else
                    room.lockHits = 0
                end
            end
        end
    end
end

function love.keyreleased(key)
    if key == "left" then
        PieceInput.moveHeld.left = false
    elseif key == "right" then
        PieceInput.moveHeld.right = false
    elseif key == "down" then
        PieceInput.moveHeld.down = false
    end
end

function love.mousepressed(x,y,button)
    if GameState ~= "menu" then return end
    if button == 1 then
        for idx, btn in ipairs(Menu.btns) do
            if x >= btn.x and x <= btn.x+btn.w and y >= btn.y and y <= btn.y+btn.h then
                Camera.offsetX = (love.math.random()*2-1)*Config.cameraBounceAmount
                Camera.offsetY = (love.math.random()*2-1)*Config.cameraBounceAmount
                love.audio.play(Audio.sndPassUI:clone())

                if idx == 1 then
                    Menu.transitioning = true
                    Menu.transitionTimer = 0
                else
                    love.event.quit()
                end
            end
        end
    end
end
