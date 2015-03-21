StatusBar = Component:extends{}

function StatusBar:init()
    self:super('init')
    self.panel = Window:New {
        x = 10,
        right = 10,
        y = 2,
        height = 50,
        minHeight = 50,
        border = 1,
        parent = screen0,
        resizable = false,
        draggable = false,
        padding = {0, 0, 0, 0},
    }

    -- configuration
    self.showConnectionStatus = true
    self.showServerStatus = true
    self.showPlayerWelcome = true

    -- aligning
    self.iconSize = 32
    self.imagePadding = 8
    self.itemPadding = 10

    if self.showConnectionStatus then self:AddConnectionStatus() end
    if self.showServerStatus then self:AddServerStatus() end
    if self.showPlayerWelcome then self:AddPlayerWelcome() end

    -- this order must be preserved for aligning
    self:AddMenuIcon()
    self:AddFriendsIcon()
    self:AddDownloadsIcon()
    self:AddErrorsIcon()
end

function StatusBar:AddConnectionStatus()
    self.lblPing = Label:New {
        x = 10,
        y = 12,
        height = 20,
        caption = "\255\180\180\180" .. i18n("offline") .. "\b",
        font = {
            size = 20,
        },
    }

    local updateStatus = function()
        local latency = lobby:GetLatency()
        local color
        latency = math.ceil(latency)
        if latency < 500 then
            color = Configuration:GetSuccessColor()
        elseif latency < 1000 then
            color = Configuration:GetWarningColor()
        else
            if latency > 9000 then
                latency = "9000+"
            end
            color = "\255\255\125\0"
        end
        self.lblPing:SetCaption(color .. latency .. "ms\b")
    end
    lobby:AddListener("OnPong", updateStatus)

    lobby:AddListener("OnAccepted", 
        function(listener)
            lobby:Ping()
        end
    )

    lobby:AddListener("OnDisconnected", function() 
        self.lblPing:SetCaption(Configuration:GetErrorColor() .. "D/C\b")
    end)

    self.panel:AddChild(self.lblPing)
end

function StatusBar:AddServerStatus()
    -- users
    self.lblUsersOnline = Label:New {
        x = 115,
        width = 100,
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
    local updateUserCount = function() 
        local userCount = lobby:GetUserCount()
        if userCount >= 10000000 then -- yeah
            userCount = math.floor((userCount / 1000000)) .. "M"
        elseif userCount >= 10000 then
            userCount = math.floor((userCount / 1000)) .. "k"
        end
        self.lblUsersOnline:SetCaption(i18n("users") .. ": " .. userCount)
    end
    --updateUserCount()
    lobby:AddListener("OnAddUser", updateUserCount)
    lobby:AddListener("OnRemoveUser", updateUserCount)

    self.panel:AddChild(self.lblUsersOnline)

    -- battles
    self.lblBattlesOpen = Label:New {
        x = 220,
        width = 100,
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
    local updateBattleCount = function() 
        local battleCount = lobby:GetBattleCount()
        if battleCount >= 10000000 then -- yeah
            battleCount = math.floor((battleCount / 1000000)) .. "M"
        elseif battleCount >= 10000 then
            battleCount = math.floor((battleCount / 1000)) .. "k"
        end
        self.lblBattlesOpen:SetCaption(i18n("battles") .. ": " .. battleCount)
    end
    lobby:AddListener("OnAccepted", 
        function(listener)
            updateBattleCount()
            lobby:RemoveListener("OnAccepted", listener)
        end
    )
    lobby:AddListener("OnBattleOpened", updateBattleCount)
    lobby:AddListener("OnBattleClosed", updateBattleCount)

    self.panel:AddChild(self.lblBattlesOpen)

    -- queues 
    self.lblQueuesOpen = Label:New {
        x = 325,
        width = 100,
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }
    local updateQueueCount = function() 
        local queueCount = lobby:GetQueueCount()
        if queueCount >= 10000000 then -- yeah
            queueCount = math.floor((queueCount / 1000000)) .. "M"
        elseif queueCount >= 10000 then
            queueCount = math.floor((queueCount / 1000)) .. "k"
        end
        self.lblQueuesOpen:SetCaption(i18n("queues") .. ": " .. queueCount)
    end
    lobby:AddListener("OnAccepted", 
        function(listener)
            updateQueueCount()
            lobby:RemoveListener("OnAccepted", listener)
        end
    )
    lobby:AddListener("OnQueueOpened", updateQueueCount)
    lobby:AddListener("OnQueueClosed", updateQueueCount)
    lobby:AddListener("OnListQueues",  updateQueueCount)

    self.panel:AddChild(self.lblQueuesOpen)
end

function StatusBar:AddFriendsIcon()
    self.btnFriends = Button:New {
        right = self.btnMenu.right + self.btnMenu.width + self.itemPadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.panel.height - self.iconSize) / 2 - 4,
        caption = '',
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Label:New {
                x = 3,
                y = 28,
                height = 10,
                font = { 
                    size = 17, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 1, 0, 0, 0.6 },
                },
                caption = "",
            },
            Label:New {
                x = 28,
                y = 3,
                height = 10,
                font = { 
                    size = 14, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 0, 1, 0, 0.6 },
                },
                caption = "",
            },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "friends_off.png",
            },
        },
    }
    self.onFriend = function(listener)
        local onlineFriends = {}
        for key, friend in pairs(lobby:GetFriends()) do
            if lobby:GetUser(friend) ~= nil then
                table.insert(onlineFriends, friend)
            end
        end
        if #onlineFriends > 0 then
            self.btnFriends.children[1]:SetCaption("\255\0\200\0" .. tostring(#onlineFriends) .. "\b")
            self.btnFriends.children[3].file = CHILI_LOBBY_IMG_DIR .. "friends.png"
        end
    end
    lobby:AddListener("OnFriendListEnd", self.onFriend)

    self.onAccepted = function()
        lobby:FriendList()
    end
    lobby:AddListener("OnAccepted", self.onAccepted)
    self.panel:AddChild(self.btnFriends)
end

function StatusBar:AddPlayerWelcome()
    self.lblPlayerIcon = Label:New {
        right = "48%",
        y = 16,
        height = 20,
        caption = "",
        font = {
            size = 16,
        },
    }

    lobby:AddListener("OnAccepted", 
        function(listener)
            self.lblPlayerIcon:SetCaption(i18n("welcome") .. " " ..  lobby:GetMyUserName())
            --self.lblPlayerIcon:SetCaption("Welcome 12345123451234512345!")
        end
    )

    self.panel:AddChild(self.lblPlayerIcon)
end

function StatusBar:AddMenuIcon()
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
        right = 5,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.panel.height - self.iconSize) / 2 - 4,
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

    self.panel:AddChild(self.btnMenu)
end

function StatusBar:AddDownloadsIcon()
    self.btnDownloads = Button:New {
        right = self.btnFriends.right + self.btnFriends.width + self.itemPadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.panel.height - self.iconSize) / 2 - 4,
        caption = '',
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            Label:New {
                x = 3,
                y = 28,
                height = 10,
                font = { 
                    size = 17, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 1, 0, 0, 0.6 },
                },
                caption = "",
            },
            Label:New {
                x = 28,
                y = 3,
                height = 10,
                font = { 
                    size = 14, 
                    outline = true,
                    autoOutlineColor = false,
                    outlineColor = { 0, 1, 0, 0.6 },
                },
                caption = "",
            },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "download_off.png",
            },
        },
    }
    self.panel:AddChild(self.btnDownloads)
    self.downloads = 0
end

function StatusBar:UpdateDownloadStatus()
    if self.downloads > 0 then
        self.btnDownloads.children[1]:SetCaption("\255\0\200\0" .. tostring(self.downloads) .. "\b")
        self.btnDownloads.children[3].file = CHILI_LOBBY_IMG_DIR .. "download.png"
    else
        self.btnDownloads.children[1]:SetCaption("")
        self.btnDownloads.children[3].file = CHILI_LOBBY_IMG_DIR .. "download_off.png"
    end
end

function StatusBar:DownloadStarted(...)
    Spring.Echo("Download started")
    self:UpdateDownloadStatus()
end

function StatusBar:DownloadQueued(...)
    Spring.Echo("Download queued")
    self.downloads = self.downloads + 1
    self:UpdateDownloadStatus()
end

function StatusBar:DownloadFinished(...)
    Spring.Echo("Download finished")
    self.downloads = self.downloads - 1
    self:UpdateDownloadStatus()
end

function StatusBar:DownloadFailed(...)
    Spring.Echo("Download failed")
    self.downloads = self.downloads - 1
    self:UpdateDownloadStatus()
end


function StatusBar:AddErrorsIcon()
    self.btnErrors = Button:New {
        right = self.btnDownloads.right + self.btnDownloads.width + self.itemPadding,
        width = self.iconSize + self.imagePadding,
        height = self.iconSize + self.imagePadding,
        y = (self.panel.height - self.iconSize) / 2 - 4,
        caption = '',
        padding = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        borderThickness = 0,
        backgroundColor = {0, 0, 0, 0},
        focusColor      = {0.4, 0.4, 0.4, 1},
        children = {
            -- FIXME: make it work with pr errorer
--             Label:New {
--                 x = 3,
--                 y = 28,
--                 height = 10,
--                 font = { 
--                     size = 17, 
--                     outline = true,
--                     autoOutlineColor = false,
--                     outlineColor = { 1, 0, 0, 0.6 },
--                 },
--                 caption = "",
--             },
--             Label:New {
--                 x = 28,
--                 y = 3,
--                 height = 10,
--                 font = { 
--                     size = 14, 
--                     outline = true,
--                     autoOutlineColor = false,
--                     outlineColor = { 0, 1, 0, 0.6 },
--                 },
--                 caption = "",
--             },
            Image:New {
                x = 4,
                y = 4,
                width = self.iconSize,
                height = self.iconSize,
                margin = {0, 0, 0, 0},
                file = CHILI_LOBBY_IMG_DIR .. "warning_off.png",
            },
        },
    }
    self.panel:AddChild(self.btnErrors)
end