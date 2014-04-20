Console = LCS.class{}

function Console:init()
    self.listener = nil

    self.spHistory = ScrollPanel:New {
        x = 1,
        right = 7,
        y = 1,
        bottom = 42,
    }
    self.tbHistory = TextBox:New {
        x = 1,
        right = 1,
        y = 1,
        bottom = 1,
        text = "",
        parent = self.spHistory,
    }
    self.ebInputText = EditBox:New {
        x = 1,
        bottom = 8,
        height = 25,
        right = 100,
        text = "",
    }
    self.btnSubmit = Button:New {
        bottom = 1,
        height = 40,
        right = 3,
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
        x = 1,
        y = 1,
        width = "100%",
        height = "100%",
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

