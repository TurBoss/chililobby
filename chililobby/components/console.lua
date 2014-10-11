Console = LCS.class{}

function Console:init()
    self.listener = nil

    self.spHistory = ScrollPanel:New {
        x = 0,
        right = 0,
        y = 0,
        bottom = 42,
        verticalSmartScroll = true,
    }
    self.tbHistory = TextBox:New {
        x = 0,
        right = 0,
        y = 0,
        bottom = 0,
        text = "",
        parent = self.spHistory,
    }
    self.ebInputText = EditBox:New {
        x = 0,
        bottom = 7,
        height = 25,
        right = 100,
        text = "",
    }
    self.btnSubmit = Button:New {
        bottom = 0,
        height = 40,
        right = 0,
        width = 90,
        caption = "Submit",
        OnClick = { 
            function(...)
                self:SendMessage()
            end
        }
    }
    self.ebInputText.OnKeyPress = {
        function(obj, key, mods, ...)
            if key == Spring.GetKeyCode("enter") or 
                key == Spring.GetKeyCode("numpad_enter") then
                self:SendMessage()
            end

        end
    }
    self.panel = Control:New {
        x = 0,
        y = 0,
        right = 0,
        bottom = 0,
        padding      = {0, 0, 0, 0},
        itemPadding  = {0, 0, 0, 0},
        itemMargin   = {0, 0, 0, 0},
        children = {
            self.spHistory,
            self.ebInputText,
            self.btnSubmit
        },
    }
end

function Console:SendMessage()
    if self.ebInputText.text ~= "" then
        message = self.ebInputText.text
        if self.listener then
            self.listener(message)
        end
        self.ebInputText:SetText("")
    end
end

function Console:AddMessage(message)
    self.tbHistory:SetText(self.tbHistory.text .. "\n" .. message)
end

