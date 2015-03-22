ListWindow = Component:extends{}

function ListWindow:init(parent, title)
    self.lblTitle = Label:New {
        x = 20,
        right = 5,
        y = 5,
        height = 20,
        font = { size = 20 },
        caption = title,
    }

    self.btnClose = Button:New {
        right = 10,
        y = 0,
        width = 60,
        height = 35,
        caption = Configuration:GetErrorColor() .. i18n("close") .. "\b",
        OnClick = {
            function()
                self:HideWindow()
            end
        },
    }

    self.listPanel = ScrollPanel:New {
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
            self.lblTitle,
            self.btnClose,
            self.listPanel,
        },
        OnDispose = {
            function()
                self:RemoveListeners()
            end
        },
    }

    self.itemPanelMapping = {}
    self.orderPanelMapping = {}
end

function ListWindow:HideWindow()
    ChiliFX:AddFadeEffect({
        obj = self.window, 
        time = 0.15,
        endValue = 0,
        startValue = 1,
        after = function()
            self.window:Hide()
        end
    })
    --self.window:Hide() --Dispose()
end

function ListWindow:AddListeners()
end

function ListWindow:RemoveListeners()
end

function ListWindow:Clear()
    self.listPanel:ClearChildren()
end

function ListWindow:AddRow(items, id)
    local w = items[#items].x + items[#items].width
    local h = 60
    local padding = 20

    local container = Control:New {
        width = w,
        y = 0,
        height = h,
        padding = {0, 0, 0, 0},
        children = items,
    }
    local panel = LayoutPanel:New {
        x = 0,
        right = 0,
        height = h,
        padding = {0, 0, 0, 0},
        itemMargin = {0, 0, 0, 0},
        itemPadding = {0, 0, 0, 0},
        children = { container },
    }

    local index = #self.listPanel.children + 1
    local w = Window:New {
        x = 0,
        right = 0,
        y = self:CalculateHeight(index),
        height = h,
        children = { panel },
        resizable = false,
        draggable = false,
        padding= {0, 0, 0, 0},
        id = id,
        index = index
    }
    self.listPanel:AddChild(w)
    self.itemPanelMapping[id] = w
    self.orderPanelMapping[index] = w

    self:RecalculatePosition(id)
end

function ListWindow:GetRowItems(id)
    local panel = self.itemPanelMapping[id]
    return panel.children[1].children[1].children
end

function ListWindow:CalculateHeight(index)
    local h = 60
    local padding = 20
    return 10 + (index - 1) * (h + padding)
end

-- res >  0: id1 before id2
-- res == 0: equal
-- res <  0: id2 before id1
function ListWindow:CompareItems(id1, id2)
    return 0
end

function ListWindow:SwapPlaces(panel1, panel2)
    tmp = panel1.index

    panel1.index = panel2.index
    self.orderPanelMapping[panel1.index] = panel1
    panel1.y = self:CalculateHeight(panel1.index)
    panel1:Invalidate()

    panel2.index = tmp
    self.orderPanelMapping[panel2.index] = panel2
    panel2.y = self:CalculateHeight(panel2.index)
    panel2:Invalidate()
end

function ListWindow:RecalculatePosition(id)
    local panel = self.itemPanelMapping[id]
    local index = panel.index

    -- move panel up if needed
    while panel.index > 1 do
        local panel2 = self.orderPanelMapping[panel.index - 1]
        if self:CompareItems(panel.id, panel2.id) > 0 then
            self:SwapPlaces(panel, panel2)
        else
            break
        end
    end
    -- move panel down if needed
    while panel.index < #self.listPanel.children - 1 do
        local panel2 = self.orderPanelMapping[panel.index + 1]
        if self:CompareItems(panel.id, panel2.id) < 0 then
            self:SwapPlaces(panel, panel2)
        else
            break
        end
    end
end

function ListWindow:RemoveRow(id)
    local panel = self.itemPanelMapping[id]
    local index = panel.index

    -- move elements up
    while index < #self.listPanel.children - 1 do
        local pnl = self.orderPanelMapping[index + 1]
        pnl.index = index
        pnl.h = self:CalculateHeight(pnl.index)
        self.orderPanelMapping[index] = pnl
        pnl:Invalidate()

        index = index + 1
    end
    self.orderPanelMapping[index] = nil

    self.listPanel:RemoveChild(panel)
    self.itemPanelMapping[id] = nil
end