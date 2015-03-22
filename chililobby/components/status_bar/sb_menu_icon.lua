SBMenuIcon = SBItem:extends{}

function SBMenuIcon:init()
    self:super('init')

    self.btnSettings = Button:New {
        width = 100, height = 40,
        caption = i18n("settings"),
    }
    self.btnLogout = Button:New {
        width = 100, height = 40,
        caption = "\255\150\150\150" .. i18n("logout") .. "\b",
        state = { enabled = false },
    }
    self.btnQuit = Button:New {
        width = 100, height = 40,
        caption = i18n("quit"),
    }
    self.btnMenu = ComboBox:New {
        x = self.imagePadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.height - self.iconSize) / 2 - 4,
        caption = '',
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "menu.png",
            },
        },
        items = {
            self.btnSettings,
            Line:New {
                width = 100,
            },
            self.btnLogout,
            self.btnQuit,
        },
    }
    self.btnMenu.OnSelect = {
        function(obj, itemIdx, selected)
            if selected then
                if itemIdx == 1 then
                    Spring.Echo("Settings")
                elseif itemIdx == 3 then
                    Spring.Echo("Logout")
                elseif itemIdx == 4 then
                    Spring.Echo("Quitting...")
                    Spring.SendCommands("Quit")
                end
            end
        end
    }

    self:AddControl(self.btnMenu)
end
