ChatWindows = LCS.class{}

function ChatWindows:init()
    local debugConsole = Console()
    local lobbyListener = LobbyListener(self, debugConsole)
    lobby:AddListener(lobbyListener)
    debugConsole.listener = function(message)
        lobby:SendCustomCommand(message)
    end

    lobby:Channels()

    self.serverPanel = ScrollPanel:New {
        x = 0,
        width = "100%",
        y = 0,
        height = "100%",
    }

    self.tabPanel = Chili.TabPanel:New {
        x = 0, 
        right = 0,
        y = 20, 
        bottom = 0,
        padding = {0, 0, 0, 0},
        tabs = {
            { name = "server", children = {self.serverPanel} },
            { name = "debug", children = {debugConsole.panel} },
        },
    }

    self.window = Window:New {
        right = 0,
        width = 400,
        bottom = 0,
        height = 500,
        parent = screen0,
        caption = "Chat",
        resizable = false,
        padding = {5, 0, 0, 0},
        children = {
            self.tabPanel,
        }
    }
end
