module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local localRepository = require('minigames/libs/repository')
local QuizData = localRepository.QuizData
local LojaView = views.LojaView
local AvatarInfoBox = widgets.AvatarInfoBox

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    player = e.data.player
    
    local dataMiniGame = QuizData()    
    playerData = dataMiniGame:getDataByPlayerId(player.id)
    
    local w,h = flower.getViewSize()    
    view = widget.UIView {
        scene = scene
    }     
                  
    lojaView = LojaView{
         size = {w-100,h-100},
         scene = scene,
         playerData = playerData
    }        
    lojaView:addEventListener('back', lojaView_onBack)
    lojaView:addEventListener('compraPular', lojaView_onCompraPular)
    lojaView:addEventListener('compraVerResposta', lojaView_onCompraVerResposta)
    
    playerInfo = AvatarInfoBox {        
        scene = scene,
        player = player
    }
                  
end

function onStart(e)
  
end

function lojaView_onCompraPular(e)
    if player.gold >= 1000 then
        player.gold = player.gold - 1000
        playerData.pular = playerData.pular + 1
    else
        flower.openScene("minigames/scenes/message_view_scene",{animation="overlay", message="MOEDAS INSUFICIENTES"})
    end
    lojaView:updateDisplay()
    playerInfo:updateDisplay()    
end

function lojaView_onCompraVerResposta(e)
    if player.gold >= 5000 then
        player.gold = player.gold - 5000
        playerData.verResposta = playerData.verResposta + 1
    else
        flower.openScene("minigames/scenes/message_view_scene",{animation="overlay", message="MOEDAS INSUFICIENTES"})
    end
    lojaView:updateDisplay()
    playerInfo:updateDisplay()
end

function lojaView_onBack(e)
    scene:dispatchEvent("onClose")
    flower.closeScene()
end

function onClose(e)
      
end
