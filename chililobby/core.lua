local includes = {
    "headers/exports.lua",
    "components/component.lua",
    "components/console.lua",
    "components/status_bar.lua",
    "components/login_window.lua",
    "components/downloader.lua",
    "components/chat_windows.lua",
    "components/play_window.lua",
    "components/background.lua",
    "components/configuration.lua",
    "components/battle_list_window.lua",    
    "components/battle_room_window.lua",
    "components/user_list_panel.lua",

    "components/queue/queue_list_window.lua",
    "components/queue/queue_window.lua",
    "components/queue/ready_check_window.lua",
}

local ChiliLobby = widget

for _, file in ipairs(includes) do
    VFS.Include(CHILILOBBY_DIR .. file, ChiliLobby, VFS.RAW_FIRST)
end

function ChiliLobby:initialize()
    local loginWindow = LoginWindow()
    self.downloader = Downloader()
    local statusBar = StatusBar()
    self.background = Background()

    lobby:AddListener("OnJoinBattle", 
        function(listener, battleID)
            local battleRoom = BattleRoomWindow(battleID)
        end
    )
end

function ChiliLobby:DrawScreen()
    self:WrapCall(function()
    end)
end

function ChiliLobby:GetRegisteredComponents()
    return Component.registeredComponents
end

function ChiliLobby:DownloadStarted(id)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadStarted(id)
        end
    end)
end

function ChiliLobby:DownloadFinished(id)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadFinished(id)
        end
    end)
end

function ChiliLobby:DownloadFailed(id, errorId)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadFailed(id, errorId)
        end
    end)
end

function ChiliLobby:DownloadProgress(id, downloaded, total)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadProgress(id, downloaded, total)
        end
    end)
end

function ChiliLobby:DownloadQueued(id, archiveName, archiveType)
    self:WrapCall(function()
        for i, comp in pairs(self:GetRegisteredComponents()) do
            comp:DownloadQueued(id, archiveName, archiveType)
        end
    end)
end

function ChiliLobby:WrapCall(func)
    xpcall(function() func() end, 
        function(err) self:_PrintError(err) end )
end

function ChiliLobby:_PrintError(err)
    Spring.Log("chiliLobby", LOG.ERROR, err)
    Spring.Log("chiliLobby", LOG.ERROR, debug.traceback(err))
end

return ChiliLobby
