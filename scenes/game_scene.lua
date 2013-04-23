module(..., package.seeall)

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
function onCreate(e)       
    layer = flower.Layer()
    layer:setScene(scene)
    layer:setTouchEnabled(true)
    layer:setPriority(1)
    camera = flower.Camera()
    layer:setCamera(camera)
    
    --INIT WORLD PHYSICS
    world = MOAIBox2DWorld.new ()
    --world = physics.B2World()
    world:setGravity ( 0, 0 )
    world:setUnitsToMeters ( 1/30)
    --world:setDebugDrawEnabled(false)
    
    world:start()
    
    
    -- TODO: Tile Map Editor 0.9 Bug
    mapData = dofile("assets/flare.lue")
    mapData.tilesets[7].tileoffsetx = 0
    mapData.tilesets[7].tileoffsety = 48
    
    mapData.tilesets[4].tileoffsetx = 0
    mapData.tilesets[4].tileoffsety = 16
    
    mapa = rpgmap.RPG()
    mapa:setWorldPhysics(world)
    mapa:loadMapData(mapData)
    
    mapa:setLayer(layer)
    
    layer:setBox2DWorld (world)
    
    
    
    mapa:addEventListener("touchDown", tileMap_OnTouchDown)
    mapa:addEventListener("touchUp", tileMap_OnTouchUp)
    mapa:addEventListener("touchMove", tileMap_OnTouchMove)
    mapa:addEventListener("touchCancel", tileMap_OnTouchUp)
end

function onStart(e)
  
end

function joystick_OnStickChanged(e)
  
end

function onUpdate(e)
  
end

function tileMap_OnTouchDown(e) 
    --print(e.x,e.y)
    if mapa.lastTouchEvent then
        return
    end
    mapa.lastTouchIdx = e.idx
    mapa.lastTouchX = e.x
    mapa.lastTouchY = e.y
end
function tileMap_OnTouchUp(e)
    
    if not mapa.lastTouchIdx then
        return
    end
    if mapa.lastTouchIdx ~= e.idx then
        return
    end
    mapa.lastTouchIdx = nil
    mapa.lastTouchX = nil
    mapa.lastTouchY = nil    
end

function tileMap_OnTouchMove(e)
    if not mapa.lastTouchIdx then
        return
    end
    if mapa.lastTouchIdx ~= e.idx then
        return
    end
    
    local moveX = e.x - mapa.lastTouchX
    local moveY = e.y - mapa.lastTouchY
    camera:addLoc(-moveX, -moveY, 0)

    mapa.lastTouchX = e.x
    mapa.lastTouchY = e.y
end

