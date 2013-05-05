--------------------------------------------------------------------------------
-- This class is to observe the FPS.
--------------------------------------------------------------------------------

local flower = require "hanappe/flower"
local class = flower.class

local M = class()

--------------------------------------------------------------------------------
-- The constructor.
--------------------------------------------------------------------------------
function M:init(sec, onFPS)
    self._sec = sec
    self._onFPS = onFPS
    self._running = false
    
    self.timer = MOAITimer.new()
    self.timer:setMode(MOAITimer.LOOP)
    self.timer:setSpan(self._sec)
    self.timer:setListener(MOAITimer.EVENT_TIMER_LOOP, function() self:onTimer() end)

end

function M:onTimer()
    local fps = MOAISim.getPerformance()
    print("FpsMonitor:onTimer", "FPS:" .. fps)
    if self._onFPS then
        self._onFPS(fps)
    end
end

--------------------------------------------------------------------------------
-- To start the measurement.
--------------------------------------------------------------------------------
function M:play()
    self.timer:start()
    return self
end

--------------------------------------------------------------------------------
-- To end the measurement.
--------------------------------------------------------------------------------
function M:stop()
    self.timer:stop()
end

return M