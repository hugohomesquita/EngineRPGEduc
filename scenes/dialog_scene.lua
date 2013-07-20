module(..., package.seeall)

local message1 = "Hello MessageBox"

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    view = widget.UIView {
        scene = scene
    }
    
    showButton = widget.Button {
        size = {200, 50},
        pos = {5, 5},
        text = "Show",
        parent = view,
        onClick = showButton_OnClik,
    }
    
    hideButton = widget.Button {
        size = {200, 50},
        pos = {5, showButton:getBottom() + 5},
        text = "Hide",
        parent = view,
        onClick = hideButton_OnClik,
    }
    
    msgbox = widget.MsgBox {
        size = {flower.viewWidth - 10, 100},
        pos = {5, flower.viewHeight - 105},
        text = message1,
        parent = view,
    }
     msgbox:showPopup()
end

function showButton_OnClik(e)
   
end

function hideButton_OnClik(e)
    msgbox:hidePopup()
end