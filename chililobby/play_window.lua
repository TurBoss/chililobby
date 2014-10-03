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

    self.btnPlayMultiplayerCustom = Button:New {
        x = 320,
        y = 260,
        height = 140,
        width = 140,
        caption = '',
        tooltip = "Play a custom multiplayer game", 
        OnClick = {
            function()
                self.battleListWindow = BattleListWindow()
                local sw = self.window
                local bw = self.battleListWindow.window
                if sw.x + sw.width + bw.width > sw.parent.width then
                    bw.x = sw.x - bw.width
                else
                    bw.x = sw.x + sw.width
                end
                bw.y = sw.y
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
                caption = "Custom",
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
    lobby:AddListener("OnAddUser", updateUserCount)
    lobby:AddListener("OnRemoveUser", updateUserCount)

    self.lblBattlesOpen = Label:New {
        right = 20,
        width = 100,
        y = 25,
        height = 20,
        caption = "",
        font = {
            size = 20,
        },
    }
    local updateBattleCount = function() 
        self.lblBattlesOpen:SetCaption("Battles: " .. lobby:GetBattleCount())
    end
    updateBattleCount()
    lobby:AddListener("OnBattleOpened", updateBattleCount)
    lobby:AddListener("OnBattleClosed", updateBattleCount)


    self.lblPing = Label:New {
        right = 20,
        width = 100,
        y = 50,
        height = 20,
        caption = "",
        font = {
            size = 20,
        },
    }

    -- FIXME: these listeners should be put in a separate file as they are not directly associated with the play window
    local updateStatus = function()
        local latency = lobby:GetLatency()
        local color
        if latency < 500 then
            color = "\255\0\255\0"
        elseif latency < 1000 then
            color = "\255\255\255\0"
        else
            color = "\255\255\125\0"
        end
        self.lblPing:SetCaption("Connection: " .. color .. lobby:GetLatency() .. "ms\b")
    end
    lobby:AddListener("OnPong", updateStatus)
    lobby:Ping()
    
    lobby:AddListener("OnAccepted", updateStatus)

    lobby:AddListener("OnDisconnected", function() 
        self.lblPing:SetCaption("Connection: \255\255\0\0Disconnected\b")
    end)
	
	lobby:AddListener("OnJoinBattle", 
		function(listener, battleID)
			succ, msg = pcall(function()
				local battleRoom = BattleRoomWindow(battleID)
			end)
			if not succ then
				Spring.Echo(msg)
			end
		end
	)

    self.window = Window:New {
        x = 10,
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
            self.btnPlayMultiplayerCustom,

            self.lblUsersOnline,
            self.lblBattlesOpen,
            self.lblPing,
        }
    }
end
