PlayWindow = LCS.class{}

function PlayWindow:init()
    -- Singleplayer
    self.lblPlaySingleplayer = Label:New {
        x = 20,
        width = 100,
        y = 0,
        height = 20,
        caption = "Singleplayer",
        font = {
            size = 20,
        },
    }
    self.btnPlaySingleplayer = Button:New {
        x = 20,
        y = 40,
        height = 140,
        width = 140,
        caption = '',
        tooltip = "Play a singleplayer game", 
        OnClick = {
            function() 
            end
        },
        children = {
            Image:New { 
                file=CHILI_LOBBY_IMG_DIR .. "joystick-play.png", 
                height = 100, 
                width = 100,
                margin = {0, 0, 0, 0},
                x = 10,
            },
            Label:New {
                caption = "Skirmish",
                bottom = 0,
                x = 25,
                font = {
                    size = 18,
                },
            },
        },
    }
    
    self.line = Line:New {
        x = 0,
        y = 200,
        width = 400,
    }

    -- Multiplayer
    self.lblPlayMultiplayer = Label:New {
        x = 20,
        width = 100,
        y = 220,
        height = 20,
        caption = "Multiplayer",
        font = {
            size = 20,
        },
    }

    self.btnPlayMultiplayerNormal = Button:New {
        x = 20,
        y = 260,
        height = 140,
        width = 140,
        caption = '',
        tooltip = "Play a normal multiplayer game", 
        OnClick = {
            function() 
            end
        },
        children = {
            Image:New { 
                file=CHILI_LOBBY_IMG_DIR .. "joystick-play.png", 
                height = 100, 
                width = 100,
                margin = {0, 0, 0, 0},
                x = 10,
            },
            Label:New {
                caption = "Normal",
                bottom = 0,
                x = 25,
                font = {
                    size = 18,
                },
            },
        },
    }

    self.btnPlayMultiplayerRanked = Button:New {
        x = 170,
        y = 260,
        height = 140,
        width = 140,
        caption = '',
        tooltip = "Play a ranked multiplayer game", 
        OnClick = {
            function() 
            end
        },
        children = {
            Image:New { 
                file=CHILI_LOBBY_IMG_DIR .. "joystick-play.png", 
                height = 100, 
                width = 100,
                margin = {0, 0, 0, 0},
                x = 10,
            },
            Label:New {
                caption = "Ranked",
                bottom = 0,
                x = 25,           
                font = {
                    size = 18,
                },
            },
        },
    }

    self.lblUsersOnline = Label:New {
        right = 20,
        width = 100,
        y = 0,
        height = 20,
        caption = "",
        font = {
            size = 20,
        },
    }
    local updateUserCount = function() 
        self.lblUsersOnline:SetCaption("Users: " .. lobby:GetUserCount())
    end
    updateUserCount()
    lobby:Register("OnAddUser", updateUserCount)
    lobby:Register("OnRemoveUser", updateUserCount)

    self.lblPing = Label:New {
        right = 20,
        width = 100,
        y = 25,
        height = 20,
        caption = "",
        font = {
            size = 20,
        },
    }
    lobby:Register("OnPong", function() 
        self.lblPing:SetCaption("Ping: " .. lobby:GetLatency())
    end)
    lobby:Ping()

    self.window = Window:New {
        x = 500,
        width = 500,
        y = 250,
        height = 450,
        parent = screen0,
        resizable = false,
        padding = {0, 20, 0, 0},
        children = {
            self.lblPlaySingleplayer,
            self.lblPlayMultiplayer,
            self.btnPlaySingleplayer,
            self.btnPlayMultiplayerNormal,
            self.line,
            self.btnPlayMultiplayerRanked,

            self.lblUsersOnline,
            self.lblPing,
        }
    }
end
