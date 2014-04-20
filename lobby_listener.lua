LobbyListener = LibLobby.Listener:extends{}

function LobbyListener:init(chatWindows, debugConsole)
    self.chatWindows = chatWindows
    self.debugConsole = debugConsole

    self.channelConsoles = {}
    self.channels = {} -- list of known channels retrieved from OnChannel
end

function LobbyListener:OnCommandReceived(command)
    self.debugConsole:AddMessage("<" .. command)
end

function LobbyListener:OnCommandSent(command)
    self.debugConsole:AddMessage(">" .. command)
end

function LobbyListener:OnClients(chanName, clients)
end

function LobbyListener:OnJoinReceived(chanName)
    local channelConsole = Console()
    self.channelConsoles[chanName] = channelConsole

    channelConsole.listener = function(message)
        lobby:Say(chanName, message)
    end

    self.chatWindows.tabPanel:AddTab({name = "#" .. chanName, children = {channelConsole.panel}})
end

function LobbyListener:OnSaid(chanName, userName, message)
    local channelConsole = self.channelConsoles[chanName]
    if channelConsole ~= nil then
        channelConsole:AddMessage(userName .. ": " .. message)
    end
end

function LobbyListener:OnChannel(chanName, userCount, topic)
    self.channels[chanName] = { userCount = userCount, topic = topic }
end

function LobbyListener:OnEndOfChannels()
    -- sort and populate retrieved channels
    channelsArray = {}
    for chanName, v in pairs(self.channels) do
        table.insert(channelsArray, { 
            chanName = chanName, 
            userCount = v.userCount, 
            topic = v.topic,
        })
    end
    table.sort(channelsArray, 
        function(a, b)
            return a.userCount > b.userCount
        end
    )

    self.chatWindows.serverPanel:ClearChildren()

    self.chatWindows.serverPanel:AddChild(
        Label:New {
            x = 0,
            width = 100,
            y = 0,
            height = 20,
            caption = "#",
        }
    )
    self.chatWindows.serverPanel:AddChild(
        Label:New {
            x = 50,
            width = 100,
            y = 0,
            height = 20,
            caption = "Channel",
        }
    )
    self.chatWindows.serverPanel:AddChild(
        Label:New {
            x = 130,
            width = 100,
            y = 0,
            height = 20,
            caption = "Topic",
        }
    )
    for i, channel in pairs(channelsArray) do
        self.chatWindows.serverPanel:AddChild(Control:New {
            x = 0,
            width = "100%",
            y = i * 50,
            height = 40,
            children = {
                Label:New {
                    x = 0,
                    width = 100,
                    y = 0,
                    height = 20,
                    caption = channel.userCount,
                },
                Label:New {
                    x = 50,
                    width = 100,
                    y = 0,
                    height = 20,
                    caption = channel.chanName,
                },
                Button:New {
                    x = 130,
                    width = 60,
                    y = 0,
                    height = 30,
                    caption = "Join",
                    OnClick = {
                        function()
                            lobby:Join(channel.chanName)
                        end
                    },
                },
            }
        })
    end
end
