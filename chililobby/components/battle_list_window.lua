BattleListWindow = LCS.class{}

function BattleListWindow:init(parent)
    self.battlePanelMapping = {}
    self.orderPanelMapping = {}

    self.lblCustomGames = Label:New {
        x = 20,
        right = 5,
        y = 5,
        height = 20,
        font = { size = 20 },
        caption = "Custom games",
    }

    self.btnQuitBattle = Button:New {
        right = 10,
        y = 0,
        width = 60,
        height = 35,
        caption = Configuration:GetErrorColor() .. "Close\b",
        OnClick = {
            function()
                self.window:Hide() --Dispose()
            end
        },
    }

    self.battlePanel = ScrollPanel:New {
        x = 5,
        right = 5,
        y = 50,
        bottom = 5,
        borderColor = {0,0,0,0},
        horizontalScrollbar = false,
    }

    self.window = Window:New {
        x = 250,
        right = 5,
        y = 0,
        bottom = 5,
        parent = parent,
        resizable = false,
        draggable = false,
        padding = {0, 20, 0, 0},
        children = {
            self.lblCustomGames,
            self.battlePanel,
            self.btnQuitBattle
        },
        OnDispose = { 
            function()
                self:RemoveListeners()
            end
        },
    }


    local update = function() self:Update() end

    self.onBattleOpened = function(listener, battleID)
        self:AddBattle(lobby:GetBattle(battleID))
    end
    lobby:AddListener("OnBattleOpened", self.onBattleOpened)

    self.onBattleClosed = function(listener, battleID)
        self:RemoveBattle(battleID)
    end
    lobby:AddListener("OnBattleClosed", self.onBattleClosed)

    self.onJoinedBattle = function(listener, battleID)
        self:JoinedBattle(battleID)
    end
    lobby:AddListener("OnJoinedBattle", self.onJoinedBattle)

    self.onLeftBattle = function(listener, battleID)
        self:LeftBattle(battleID)
    end
    lobby:AddListener("OnLeftBattle", self.onLeftBattle)

    update()
end

function BattleListWindow:RemoveListeners()
    lobby:RemoveListener("OnBattleOpened", self.onBattleOpened)
    lobby:RemoveListener("OnBattleClosed", self.onBattleClosed)
    lobby:RemoveListener("OnJoinedBattle", self.onJoinedBattle)
    lobby:RemoveListener("OnLeftBattle", self.onLeftBattle)
end

function BattleListWindow:Update()
    self.battlePanel:ClearChildren()

--     self.battlePanel:AddChild(
--         Label:New {
--             x = 0,
--             width = 100,
--             y = 0,
--             height = 20,
--             caption = "Players",
--         }
--     )
--     self.battlePanel:AddChild(
--         Label:New {
--             x = 60,
--             width = 100,
--             y = 0,
--             height = 20,
--             caption = "Title",
--         }
--     )
--     self.battlePanel:AddChild(
--         Label:New {
--             x = 265,
--             width = 100,
--             y = 0,
--             height = 20,
--             caption = "Game",
--         }
--     )
--     self.battlePanel:AddChild(
--         Label:New {
--             x = 470,
--             width = 100,
--             y = 0,
--             height = 20,
--             caption = "Map",
--         }
--     )
    local battles = lobby:GetBattles()
    Spring.Echo("Number of battles: " .. lobby:GetBattleCount())
    local tmp = {}
    for _, battle in pairs(battles) do
        table.insert(tmp, battle)
    end
    battles = tmp
    table.sort(battles, 
        function(a, b)
            return #a.users > #b.users
        end
    )

    for _, battle in pairs(battles) do
        self:AddBattle(battle)
    end
end

function BattleListWindow:GetElementCount()
    return #self.battlePanel.children
end

function BattleListWindow:AddBattle(battle)	
    local index = self:GetElementCount() + 1
    local children = {}

    local lblPlayers = Label:New {
        x = 5,
        width = 50,
        y = 5,
        height = 20,
        caption = #battle.users .. "/" .. battle.maxPlayers,
    }
    table.insert(children, lblPlayers)

    local lblTitle = Label:New {
        x = 60,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.title:sub(1, 22),
        tooltip = battle.title, 
    }
    table.insert(children, lblTitle)

    if battle.passworded then
        local imgPassworded = Image:New {
            file = CHILI_LOBBY_IMG_DIR .. "lock.png",
            height = 20,
            width = 20,
            margin = {0, 0, 0, 0},
            x = lblTitle.x + lblTitle.font:GetTextWidth(lblTitle.caption) + 10,
        }
        table.insert(children, imgPassworded)
    end

    local lblGame = Label:New {
        x = 265,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.gameName:sub(1, 22) .. (VFS.HasArchive(battle.gameName) and ' [' .. Configuration:GetSuccessColor() .. '✔\b]' or ' [' .. Configuration:GetErrorColor() .. '✘\b]'),
        tooltip = battle.gameName, 
    }
    table.insert(children, lblGame)

    local lblMap = Label:New {
        x = 470,
        width = 200,
        y = 5,
        height = 20,
        caption = battle.map:sub(1, 22) .. (VFS.HasArchive(battle.map) and ' [' .. Configuration:GetSuccessColor() .. '✔\b]' or ' [' .. Configuration:GetErrorColor() .. '✘\b]'),
        tooltip = battle.map, 
    }
    table.insert(children, lblMap)

    local btnJoin = Button:New {
        x = 675,
        width = 60,
        y = 0,
        height = 30,
        caption = "Join",
        OnClick = {
            function()
                self:JoinBattle(battle)
            end
        },
    }
    table.insert(children, btnJoin)

    local panel = Control:New {
        x = 0,
        width = "100%",
        y = (index - 1) * 50,
        height = 40,
        children = children,
        battleID = battle.battleID,
        index = index,
    }
    self.battlePanel:AddChild(panel)
    self.battlePanelMapping[battle.battleID] = panel
    self.orderPanelMapping[index] = panel
end

function BattleListWindow:RemoveBattle(battleID)
    local panel = self.battlePanelMapping[battleID]
    local index = panel.index

    -- move elements up
    while index < self:GetElementCount() - 1 do
        local pnl = self.orderPanelMapping[index + 1]
        pnl = (index - 1) * 50
        pnl = index
        self.orderPanelMapping[index] = pnl
        index = index + 1
        pnl:Invalidate()
    end
    self.orderPanelMapping[index] = nil
    
    self.battlePanel:RemoveChild(panel)
    self.battlePanelMapping[battleID] = nil
end

function BattleListWindow:SwapPlaces(panel1, panel2)
    tmp = panel1.index

    panel1.index = panel2.index
    panel1.y = (panel1.index - 1) * 50
    panel1:Invalidate()

    panel2.index = tmp
    panel2.y = (panel2.index - 1) * 50
    panel2:Invalidate()
end

function BattleListWindow:JoinedBattle(battleID)
    local panel = self.battlePanelMapping[battleID]
    local battle = lobby:GetBattle(battleID)
    panel.children[1]:SetCaption(#battle.users .. "/" .. battle.maxPlayers)

    -- move panel up if needed
    while panel.index > 1 do
        local pnl = self.orderPanelMapping[panel.index - 1]
        local btl = lobby:GetBattle(pnl.battleID)
        if #battle.users > #btl.users then
            self:SwapPlaces(panel, pnl)
        else
            return
        end
    end
end

function BattleListWindow:LeftBattle(battleID)
    local panel = self.battlePanelMapping[battleID]
    local battle = lobby:GetBattle(battleID)
    panel.children[1]:SetCaption(#battle.users .. "/" .. battle.maxPlayers)

    -- move panel down if needed
    while panel.index < self:GetElementCount() - 1 do
        local pnl = self.orderPanelMapping[panel.index + 1]
        local btl = lobby:GetBattle(pnl.battleID)
        if #battle.users < #btl.users then
            self:SwapPlaces(panel, pnl)
        else
            return
        end
    end
end

function BattleListWindow:JoinBattle(battle)
    if not battle.passworded then
        lobby:JoinBattle(battle.battleID)
        self.window:Dispose()
    else
        local tryJoin, passwordWindow

        local lblPassword = Label:New {
            x = 1,
            width = 100,
            y = 20,
            height = 20,
            caption = "Password: ",
        }
        local ebPassword = EditBox:New {
            x = 110,
            width = 120,
            y = 20,
            height = 20,
            text = "",
            hint = "Password",
            passwordInput = true,
            OnKeyPress = {
                function(obj, key, mods, ...)
                    if key == Spring.GetKeyCode("enter") or 
                        key == Spring.GetKeyCode("numpad_enter") then
                        tryJoin()
                    end
                end
            },
        }
        local btnJoin = Button:New {
            x = 1,
            bottom = 1,
            width = 80,
            height = 40,
            caption = "Join",
            OnClick = {
                function()
                    tryJoin()
                end
            },
        }
        local btnClose = Button:New {
            x = 110,
            bottom = 1,
            width = 80,
            height = 40,
            caption = "Close",
            OnClick = {
                function()
                    passwordWindow:Dispose()
                end
            },
        }

        local lblError = Label:New {
            x = 1,
            width = 100,
            y = 50,
            height = 80,
            caption = "",
            font = {
                color = { 1, 0, 0, 1 },
            },
        }


        local onJoinBattleFailed = function(listener, reason)
            lblError:SetCaption(reason)
        end
        lobby:AddListener("OnJoinBattleFailed", onJoinBattleFailed)
        local onJoinBattle = function(listener)
            passwordWindow:Dispose()
            self.window:Dispose()
        end
        lobby:AddListener("OnJoinBattle", onJoinBattle)

        passwordWindow = Window:New {
            x = 700,
            y = 300,
            width = 265,
            height = 160,
            caption = "Join passworded battle",
            resizable = false,
            parent = screen0,
            children = {
                lblPassword,
                ebPassword,
                lblError,
                btnJoin,
                btnClose,
            },
            OnDispose = { 
                function()
                    lobby:RemoveListener("OnJoinBattleFailed", onJoinBattleFailed)
                    lobby:RemoveListener("OnJoinBattle", onJoinBattle)
                end
            },
        }

        tryJoin = function()
            lblError:SetCaption("")
            lobby:JoinBattle(battle.battleID, ebPassword.text)
        end
    end
end