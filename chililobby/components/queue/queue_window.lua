QueueWindow = LCS.class{}

function QueueWindow:init(queue)
    local joinedQueueTime = Spring.GetGameSeconds()
    local lastUpdate = Spring.GetGameSeconds()

    self.lblStatus = Label:New {
        x = 10,
        y = 25,
        width = 100,
        height = 100,
        caption = "Time in queue: ",
        font = { size = 18 },
        Update =
        function(...)
            Label.Update(self.lblStatus, ...)
            local currentTime = Spring.GetGameSeconds()
            if currentTime ~= lastUpdate then
                lastUpdate = curentTime
                local diff = math.floor(currentTime - joinedQueueTime)
                self.lblStatus:SetCaption("Time in queue: " .. tostring(diff) .. "s")
            end
            self.lblStatus:RequestUpdate()
        end,
    }

    self.queueWindow = Window:New {
        caption = queue.title,
        x = 10,
        y = 520,
        width = 500,
        height = 100,
        parent = screen0,
        draggable = false,
        resizable = false,
        children = {
            self.lblStatus,
            Button:New {
                caption = Configuration:GetErrorColor() .. "Leave\b",
                bottom = 10,
                right = 5,
                width = 70,
                height = 45,
                OnClick = { function () lobby:LeaveQueue(queue.queueId) end },
            },
        },
        OnDispose = { function() self:RemoveListeners() end },
    }

    self.onReadyCheck = function(listener, queueId, responseTime)
        if queueId == queue.queueId then
            self.queueWindow:Hide()
            ReadyCheckWindow(queue, responseTime, self.queueWindow)
        end
    end
    lobby:AddListener("OnReadyCheck", self.onReadyCheck)

    self.onLeftQueue = function(listener, queueId, reason)
        if queue.queueId == queueId then
            self.queueWindow:Dispose()
        end
    end
    lobby:AddListener("OnLeftQueue", self.onLeftQueue)
end

function QueueWindow:RemoveListeners()
    lobby:RemoveListener("OnLeftQueue", self.onLeftQueue)
    lobby:RemoveListener("OnReadyCheck", self.onReadyCheck)
end
