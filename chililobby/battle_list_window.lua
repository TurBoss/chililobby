BattleListWindow = LCS.class{}

function BattleListWindow:init()
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
		caption = "\255\255\0\0Quit\b",
		OnClick = {
			function()
				self.window:Dispose()
			end
		},
    }

    self.battlePanel = ScrollPanel:New {
        x = 5,
        right = 5,
        y = 50,
        bottom = 5,
    }

    local update = function() self:Update() end
	lobby:AddListener("OnBattleOpened", update)
    lobby:AddListener("OnBattleClosed", update)
	
    self.window = Window:New {
        x = 500,
        width = 600,
        y = 250,
        height = 450,
        parent = screen0,
        resizable = false,
        padding = {0, 20, 0, 0},
        children = {
            self.lblCustomGames,
            self.battlePanel,
			self.btnQuitBattle
        },
		OnDispose = { 
			function()
				lobby:RemoveListener("OnBattleOpened", onBattleClosed, update)
				lobby:RemoveListener("OnBattleClosed", onLeftBattle, update)
			end
		},
    }

    update()
end

function BattleListWindow:Update()
    self.battlePanel:ClearChildren()

    self.battlePanel:AddChild(
        Label:New {
            x = 0,
            width = 100,
            y = 0,
            height = 20,
            caption = "Players",
        }
    )
    self.battlePanel:AddChild(
        Label:New {
            x = 60,
            width = 100,
            y = 0,
            height = 20,
            caption = "Game",
        }
    )
    self.battlePanel:AddChild(
        Label:New {
            x = 265,
            width = 100,
            y = 0,
            height = 20,
            caption = "Map",
        }
    )
    local battles = lobby:GetBattles()
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

function BattleListWindow:AddBattle(battle)
    self.battlePanel:AddChild(Control:New {
        x = 0,
        width = "100%",
        y = (#(self.battlePanel.children) - 2) * 50,
        height = 40,
        children = {
            Label:New {
                x = 5,
                width = 50,
                y = 5,
                height = 20,
                caption = #battle.users .. "/" .. battle.maxPlayers,
            },
            Label:New {
                x = 60,
                width = 200,
                y = 5,
                height = 20,
                caption = battle.title:sub(1, 22),
                tooltip = battle.title, 
            },
            Label:New {
                x = 265,
                width = 200,
                y = 5,
                height = 20,
                caption = battle.map:sub(1, 22),
                tooltip = battle.map, 
            },
            Button:New {
                x = 470,
                width = 60,
                y = 0,
                height = 30,
                caption = "Join",
                OnClick = {
                    function()
						lobby:JoinBattle(battle.battleID)
                    end
                },
            },
        }
    })
end
