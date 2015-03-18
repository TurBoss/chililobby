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
    local lblTitle = Label:New {
        x = 5,
        width = 120,
        y = 0,
        height = h,
        caption = queue.title:sub(1, 22),
        tooltip = queue.title, 
        font = { size = 18 },
        valign = 'center',
    }
    table.insert(children, lblTitle)

    local lblDescription = Label:New {
        x = 130,
        width = 200,
        y = 5,
        height = h,
        caption = queue.description:sub(1, 22) ,
        tooltip = queue.description, 
        valign = 'center'
    }
    table.insert(children, lblDescription)

    local btnJoin
    btnJoin = Button:New {
        right = 5,
        width = 100,
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
    table.insert(children, btnJoin)

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
