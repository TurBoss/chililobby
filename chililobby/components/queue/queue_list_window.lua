QueueListWindow = LCS.class{}

function QueueListWindow:init(parent)
    self.lblQueues = Label:New {
        x = 20,
        right = 5,
        y = 5,
        height = 20,
        font = { size = 20 },
        caption = "Queues",
    }

    self.btnQuitQueue = Button:New {
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

    self.queuePanel = ScrollPanel:New {
        x = 5,
        right = 5,
        y = 50,
        bottom = 10,
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
            self.lblQueues,
            self.queuePanel,
            self.btnQuitQueue
        },
        OnDispose = {
            function()
                self:RemoveListeners()
            end
        },
    }

    self.onQueueOpened = function() self:Update() end
    self.onQueueClosed = function() self:Update() end
    self.OnListQueues = function() self:Update() end
    lobby:AddListener("OnQueueOpened", self.onQueueOpened)
    lobby:AddListener("OnQueueClosed", self.onQueueClosed)
    lobby:AddListener("OnListQueues", self.OnListQueues)

    self:Update()
end

function QueueListWindow:RemoveListeners()
    lobby:RemoveListener("OnQueueOpened", self.onQueueOpened)
    lobby:RemoveListener("OnQueueClosed", self.onQueueClosed)
    lobby:RemoveListener("OnListQueues", self.OnListQueues)
end

function QueueListWindow:Update()
    self.queuePanel:ClearChildren()

    local queues = lobby:GetQueues()
    for _, queue in pairs(queues) do
        self:AddQueue(queue)
    end
end

function QueueListWindow:AddQueue(queue)
    local h = 60
    local padding = 20
    local children = {}

    local img = "spring.png"
    local detected = false
    for _, game in pairs(queue.gameNames) do
        local notDetected = false
        if game:match("EvolutionRTS") then
            img = "evorts.png"
        elseif game:match("Cursed") then
            img = "cursed.png"
        elseif game:match("Balanced Annihilation") then
            img = "balogo.bmp"
        else
            notDetected = true
        end
        -- multiple games
        if not notDetected and detected then
            img = "spring.png"
            break
        else
            detected = true
        end
    end
    local gameNamesStr = ""
    for i = 1, #queue.gameNames do 
        local game = queue.gameNames[i]
        gameNamesStr = gameNamesStr .. game
        if i ~= #queue.gameNames then
            gameNamesStr = gameNamesStr .. ", "
        end
    end
    local imgGame = Image:New {
        x = 0,
        width = h - 10,
        y = 5,
        height = h - 10,
        file = CHILI_LOBBY_IMG_DIR .. "games/" .. img,
    }

    local lblTitle = Label:New {
        x = h + 10,
        width = 150,
        y = 0,
        height = h,
        caption = queue.title:sub(1, 15),
        font = { size = 18 },
        valign = 'center',
        tooltip = gameNamesStr, -- TODO: special (?) button for the tooltip
    }
--     if #queue.title > 15 then
--         lblTitle.tooltip = queue.title
--     end
    local missingMaps = {}
    local missingGames = {}
    for _, map in pairs(queue.mapNames) do
        if not VFS.HasArchive(map) then
            table.insert(missingMaps, map)
        end
    end
    for _, game in pairs(queue.gameNames) do
        if not VFS.HasArchive(game) then
            table.insert(missingGames, game)
        end
    end

    local btnJoin
    btnJoin = Button:New {
        x = lblTitle.x + lblTitle.width + 20,
        width = 120,
        y = 0,
        height = h,
        caption = "Join",
        font = { size = 18 },
        OnMouseUp = {
            function()
                if btnJoin.state.pressed then
                    return
                end
                btnJoin.state.pressed = true
                self:JoinQueue(queue, btnJoin)
            end
        },
    }
    local btnDownload
    btnDownload = Button:New {
        x = lblTitle.x + lblTitle.width + 20,
        width = 120,
        y = 0,
        height = h,
        caption = "Download",
        font = { size = 18 },
        OnMouseUp = {
            function()
                if btnDownload.state.pressed then
                    return
                end
                btnDownload.state.pressed = true
                for _, game in pairs(missingGames) do
                    Spring.Log("chililobby", "notice", "Downloading game " .. game)
                    VFS.DownloadArchive(game, "game")
                end
                for _, map in pairs(missingMaps) do
                    Spring.Log("chililobby", "notice", "Downloading map " .. map)
                    VFS.DownloadArchive(map, "map")
                end
                -- download game
            end
        },
    }
    local btnQueue = btnDownload

    if #missingMaps + #missingGames == 0 then
        btnQueue = btnJoin
    else
        Spring.Echo("[" .. queue.title .. "] " .. "Missing " .. tostring(#missingGames) .. " games and " .. tostring(#missingMaps) .. " maps.")
    end
    local ctrlLeft = Control:New {
        width = btnJoin.x + btnJoin.width,
        y = 0,
        height = h,
        padding = {0, 0, 0, 0},
        children = {
            lblTitle,
            imgGame,
            btnQueue,
        },
    }
    table.insert(children, LayoutPanel:New {
        x = 0,
        right = 0,
        height = h,
        padding = {0, 0, 0, 0},
        itemMargin    = {0, 0, 0, 0},
        itemPadding   = {0, 0, 0, 0},
        children = {
            ctrlLeft
        },
    })

    self.queuePanel:AddChild(Window:New {
        x = 0,
        right = 0,
        y = 10 + #self.queuePanel.children * (h + padding),
        height = h,
        children = children,
        resizable = false,
        draggable = false,
        padding={0,0,0,0},
    })
end

function QueueListWindow:JoinQueue(queue, btnJoin)
    self.onJoinQueue = function(listener)
        QueueWindow(queue)
        lobby:RemoveListener("OnJoinQueue", self.onJoinQueue)
        self.window:Hide() --Dispose()
        btnJoin.state.pressed = false
    end
    lobby:AddListener("OnJoinQueue", self.onJoinQueue)
    lobby:JoinQueue(queue.queueId)
end
