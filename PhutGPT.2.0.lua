--[[
    PHUTGPT 2.0 - GOLD EDITION V2
    Updated by: Gemini
    Features: 
    - 3 Tabs: AI Chat, Infinite Yield, Script Executor
    - Dark Gold Inputs
    - Send Button (Cursor Icon)
    - Full IY Command Integration logic
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- Load Infinite Yield ngầm (Để kích hoạt hệ thống lệnh)
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
end)

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhutGPT_GUI_V2"
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- == MÀU SẮC ==
local GoldGradient = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 248, 220)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 165, 32))
}
local DarkGold = Color3.fromRGB(184, 134, 11) -- Vàng đậm cho TextBox
local TextColor = Color3.fromRGB(255, 255, 255) -- Chữ trắng

-- == DRAGGABLE FUNCTION ==
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- == UI CHÍNH ==
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 400) -- To hơn một chút để chứa 3 tab
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = GoldGradient
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

-- Thanh Tiêu đề
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "PhutGPT 2.0"
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Color3.new(0.2, 0.2, 0.2)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Nút Thu nhỏ (-) và Đóng (X)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0, 5)
MinBtn.BackgroundColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 0.5
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

MakeDraggable(MainFrame, TitleBar)

-- == MENU TABS (3 Dòng) ==
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0.94, 0, 0, 40)
TabContainer.Position = UDim2.new(0.03, 0, 0.12, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local function CreateTabBtn(text, posScale)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.32, 0, 1, 0) -- Chia 3 phần
    btn.Position = UDim2.new(posScale, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local ChatTabBtn = CreateTabBtn("Nói chuyện AI", 0)
local IYTabBtn = CreateTabBtn("Infinite Yield", 0.34)
local ExecTabBtn = CreateTabBtn("Execute Other", 0.68)

ChatTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100) -- Active mặc định

-- == PAGE 1: CHAT AI ==
local ChatPage = Instance.new("Frame")
ChatPage.Size = UDim2.new(0.94, 0, 0.7, 0)
ChatPage.Position = UDim2.new(0.03, 0, 0.25, 0)
ChatPage.BackgroundTransparency = 1
ChatPage.Parent = MainFrame

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Size = UDim2.new(1, 0, 0.82, 0)
ChatScroll.BackgroundTransparency = 0.8
ChatScroll.BackgroundColor3 = Color3.new(0,0,0)
ChatScroll.ScrollBarThickness = 4
ChatScroll.Parent = ChatPage
Instance.new("UICorner", ChatScroll).CornerRadius = UDim.new(0, 8)

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Parent = ChatScroll
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 5)

-- Thanh Chat Vàng Đậm
local ChatInput = Instance.new("TextBox")
ChatInput.PlaceholderText = "Nhập tin nhắn..."
ChatInput.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
ChatInput.Size = UDim2.new(0.82, 0, 0.15, 0)
ChatInput.Position = UDim2.new(0, 0, 0.85, 0)
ChatInput.BackgroundColor3 = DarkGold
ChatInput.TextColor3 = TextColor
ChatInput.Font = Enum.Font.Gotham
ChatInput.TextSize = 14
ChatInput.Parent = ChatPage
Instance.new("UICorner", ChatInput).CornerRadius = UDim.new(0, 8)

-- Nút Gửi (Hình con trỏ)
local SendBtn = Instance.new("ImageButton")
SendBtn.Name = "SendButton"
SendBtn.Image = "rbxassetid://7309968436" -- Icon cursor/send
SendBtn.BackgroundColor3 = DarkGold
SendBtn.Size = UDim2.new(0.15, 0, 0.15, 0)
SendBtn.Position = UDim2.new(0.85, 0, 0.85, 0)
SendBtn.Parent = ChatPage
Instance.new("UICorner", SendBtn).CornerRadius = UDim.new(0, 8)

-- == PAGE 2: INFINITE YIELD (Đầy đủ chức năng) ==
local IYPage = Instance.new("Frame")
IYPage.Size = UDim2.new(0.94, 0, 0.7, 0)
IYPage.Position = UDim2.new(0.03, 0, 0.25, 0)
IYPage.BackgroundTransparency = 1
IYPage.Visible = false
IYPage.Parent = MainFrame

-- Thanh tìm kiếm Vàng Đậm
local IYSearch = Instance.new("TextBox")
IYSearch.PlaceholderText = "Nhập lệnh IY (vd: fly, bang, goto...)"
IYSearch.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
IYSearch.Size = UDim2.new(1, 0, 0.15, 0)
IYSearch.BackgroundColor3 = DarkGold
IYSearch.TextColor3 = TextColor
IYSearch.Font = Enum.Font.Gotham
IYSearch.TextSize = 14
IYSearch.Parent = IYPage
Instance.new("UICorner", IYSearch).CornerRadius = UDim.new(0, 8)

local CmdScroll = Instance.new("ScrollingFrame")
CmdScroll.Size = UDim2.new(1, 0, 0.82, 0)
CmdScroll.Position = UDim2.new(0, 0, 0.18, 0)
CmdScroll.BackgroundTransparency = 0.8
CmdScroll.BackgroundColor3 = Color3.new(0,0,0)
CmdScroll.ScrollBarThickness = 4
CmdScroll.Parent = IYPage
Instance.new("UICorner", CmdScroll).CornerRadius = UDim.new(0, 8)

local CmdLayout = Instance.new("UIListLayout")
CmdLayout.Parent = CmdScroll
CmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
CmdLayout.Padding = UDim.new(0, 2)

-- Danh sách lệnh mở rộng (Infinite Yield Full Potential)
-- Lưu ý: Thực tế IY có hàng trăm lệnh, đây là list các lệnh quan trọng nhất. 
-- Thanh tìm kiếm ở trên đóng vai trò là Command Line để chạy BẤT KỲ lệnh nào của IY.
local allIYCmds = {
    "fly", "unfly", "noclip", "clip", "infjump", "spectate", "view", "unview",
    "btools", "f3x", "god", "ungod", "invisible", "visible", "tpwalk",
    "esp", "boxesp", "tracers", "nametags", "aimbot", "fullbright",
    "clicktp", "ctrlclicktp", "to [plr]", "goto [plr]", "bring [plr]",
    "freeze", "thaw", "kill [plr]", "loopkill [plr]", "fling [plr]",
    "spin", "unspin", "float", "platform", "swim",
    "rejoin", "serverhop", "serverinfo", "jobid",
    "dex", "remotespy", "rconsole", "explorer",
    "sit", "jump", "loopjump", "speed [num]", "jumppower [num]",
    "hipheight [num]", "fov [num]", "fixcam", "reset",
    "chat [msg]", "spam [msg]", "pm [plr] [msg]",
    "bang", "dance", "twerk", "whack", "insane",
    "antikick", "antiban", "antiafk", "headless"
}

local function ExecuteIYCommand(cmd)
    -- Gửi lệnh vào hệ thống chat để IY bắt lệnh
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(";"..cmd, "All")
    
    -- Thông báo nhỏ
    local notif = Instance.new("TextLabel")
    notif.Text = "> Đã gửi lệnh: " .. cmd
    notif.Size = UDim2.new(1,0,0,25)
    notif.BackgroundTransparency = 1
    notif.TextColor3 = Color3.fromRGB(0, 255, 0)
    notif.Font = Enum.Font.Gotham
    notif.Parent = CmdScroll
    game.Debris:AddItem(notif, 1.5)
end

local function PopulateCmdList(filter)
    for _, child in pairs(CmdScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    
    for _, cmd in ipairs(allIYCmds) do
        if filter == "" or string.find(cmd, filter) then
            local btn = Instance.new("TextButton")
            btn.Text = cmd
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(255, 220, 150)
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.new(0,0,0)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = CmdScroll
            -- Padding cho chữ
            local p = Instance.new("UIPadding"); p.PaddingLeft = UDim.new(0,10); p.Parent = btn
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                ExecuteIYCommand(cmd)
            end)
        end
    end
end
PopulateCmdList("")

-- Xử lý tìm kiếm/nhập lệnh trực tiếp
IYSearch.FocusLost:Connect(function(enter)
    if enter and IYSearch.Text ~= "" then
        ExecuteIYCommand(IYSearch.Text)
        IYSearch.Text = ""
    end
end)
IYSearch.Changed:Connect(function(prop)
    if prop == "Text" then PopulateCmdList(string.lower(IYSearch.Text)) end
end)

-- == PAGE 3: EXECUTE OTHER SCRIPT (Dòng thứ 3) ==
local ExecPage = Instance.new("Frame")
ExecPage.Size = UDim2.new(0.94, 0, 0.7, 0)
ExecPage.Position = UDim2.new(0.03, 0, 0.25, 0)
ExecPage.BackgroundTransparency = 1
ExecPage.Visible = false
ExecPage.Parent = MainFrame

-- Hộp nhập Script (MultiLine)
local ScriptBox = Instance.new("TextBox")
ScriptBox.PlaceholderText = "-- Dán Script hoặc Loadstring vào đây..."
ScriptBox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
ScriptBox.Size = UDim2.new(1, 0, 0.75, 0)
ScriptBox.BackgroundColor3 = DarkGold
ScriptBox.TextColor3 = TextColor
ScriptBox.Font = Enum.Font.Code
ScriptBox.TextSize = 14
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.ClearTextOnFocus = false
ScriptBox.MultiLine = true
ScriptBox.TextWrapped = true
ScriptBox.Parent = ExecPage
Instance.new("UICorner", ScriptBox).CornerRadius = UDim.new(0, 8)
local pad = Instance.new("UIPadding"); pad.PaddingLeft=UDim.new(0,5); pad.PaddingTop=UDim.new(0,5); pad.Parent=ScriptBox

-- Nút Execute Script
local RunScriptBtn = Instance.new("TextButton")
RunScriptBtn.Text = "KÍCH HOẠT SCRIPT"
RunScriptBtn.Size = UDim2.new(1, 0, 0.2, 0)
RunScriptBtn.Position = UDim2.new(0, 0, 0.8, 0)
RunScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Màu xanh lá để nổi bật nút chạy
RunScriptBtn.Font = Enum.Font.GothamBlack
RunScriptBtn.TextColor3 = Color3.new(1,1,1)
RunScriptBtn.TextSize = 16
RunScriptBtn.Parent = ExecPage
Instance.new("UICorner", RunScriptBtn).CornerRadius = UDim.new(0, 8)

RunScriptBtn.MouseButton1Click:Connect(function()
    if ScriptBox.Text ~= "" then
        local success, err = pcall(function()
            loadstring(ScriptBox.Text)()
        end)
        if success then
            RunScriptBtn.Text = "ĐÃ KÍCH HOẠT THÀNH CÔNG!"
            wait(1)
            RunScriptBtn.Text = "KÍCH HOẠT SCRIPT"
        else
            RunScriptBtn.Text = "LỖI: " .. tostring(err)
            wait(2)
            RunScriptBtn.Text = "KÍCH HOẠT SCRIPT"
        end
    end
end)

-- == XỬ LÝ CHUYỂN TAB ==
local function SwitchTab(tabName)
    ChatPage.Visible = (tabName == "Chat")
    IYPage.Visible = (tabName == "IY")
    ExecPage.Visible = (tabName == "Exec")
    
    -- Reset màu nút
    ChatTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    IYTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    ExecTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    
    -- Set màu active
    if tabName == "Chat" then ChatTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100) end
    if tabName == "IY" then IYTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100) end
    if tabName == "Exec" then ExecTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100) end
end

ChatTabBtn.MouseButton1Click:Connect(function() SwitchTab("Chat") end)
IYTabBtn.MouseButton1Click:Connect(function() SwitchTab("IY") end)
ExecTabBtn.MouseButton1Click:Connect(function() SwitchTab("Exec") end)

-- == CHỨC NĂNG AI CHAT ==
local function AddChat(sender, msg, color)
    local lbl = Instance.new("TextLabel")
    lbl.Text = sender .. ": " .. msg
    lbl.Size = UDim2.new(1, -10, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ChatScroll
    ChatScroll.CanvasPosition = Vector2.new(0, 9999) -- Tự cuộn xuống dưới
end

local function ProcessAI(msg)
    local lowerMsg = string.lower(msg)
    local response = "Xin lỗi, PhutGPT 2.0 chưa hiểu ý bạn."
    
    if string.find(lowerMsg, "chào") then response = "Chào bạn! Tôi là PhutGPT 2.0. Cần hack gì không?"
    elseif string.find(lowerMsg, "tên") then response = "PhutGPT 2.0 - Trí tuệ nhân tạo mạ vàng!"
    elseif string.find(lowerMsg, "lệnh") then response = "Vào tab Infinite Yield để xem danh sách lệnh nhé."
    elseif string.find(lowerMsg, "cười") then response = "Haha! Hack game vui quá đi!"
    end
    wait(0.5)
    AddChat("PhutGPT", response, Color3.fromRGB(255, 215, 0))
end

local function SendMessage()
    if ChatInput.Text ~= "" then
        local msg = ChatInput.Text
        AddChat("Bạn", msg, Color3.new(1,1,1))
        ChatInput.Text = ""
        ProcessAI(msg)
    end
end

ChatInput.FocusLost:Connect(function(enter) if enter then SendMessage() end end)
SendBtn.MouseButton1Click:Connect(SendMessage)

-- == ICON THU NHỎ & CONFIRM CLOSE ==
local MinimizedIcon = Instance.new("TextButton")
MinimizedIcon.Name = "PhutGPT_Icon"
MinimizedIcon.Size = UDim2.new(0, 60, 0, 60)
MinimizedIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
MinimizedIcon.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
MinimizedIcon.Text = "P"
MinimizedIcon.Font = Enum.Font.GothamBlack
MinimizedIcon.TextSize = 30
MinimizedIcon.Visible = false
MinimizedIcon.Parent = ScreenGui
Instance.new("UICorner", MinimizedIcon).CornerRadius = UDim.new(1, 0)
local IconGrad = Instance.new("UIGradient"); IconGrad.Color = GoldGradient; IconGrad.Parent = MinimizedIcon
MakeDraggable(MinimizedIcon)

MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; MinimizedIcon.Visible = true end)
MinimizedIcon.MouseButton1Click:Connect(function() MainFrame.Visible = true; MinimizedIcon.Visible = false end)

-- Bảng Confirm
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(0, 300, 0, 150)
ConfirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ConfirmFrame.Visible = false
ConfirmFrame.Parent = ScreenGui
Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConfirmFrame).Color = Color3.fromRGB(255,215,0)
Instance.new("UIStroke", ConfirmFrame).Thickness = 2

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Text = "Bạn có đồng ý tắt PhutGPT không?"
ConfirmText.Size = UDim2.new(1,0,0.5,0)
ConfirmText.TextColor3 = Color3.new(1,1,1)
ConfirmText.BackgroundTransparency = 1; ConfirmText.Font=Enum.Font.GothamBold; ConfirmText.TextSize=16
ConfirmText.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton"); YesBtn.Text="CÓ"; YesBtn.Size=UDim2.new(0.4,0,0.3,0); YesBtn.Position=UDim2.new(0.05,0,0.6,0); YesBtn.BackgroundColor3=Color3.fromRGB(200,50,50); YesBtn.Parent=ConfirmFrame; Instance.new("UICorner", YesBtn).CornerRadius=UDim.new(0,8)
local NoBtn = Instance.new("TextButton"); NoBtn.Text="KHÔNG"; NoBtn.Size=UDim2.new(0.4,0,0.3,0); NoBtn.Position=UDim2.new(0.55,0,0.6,0); NoBtn.BackgroundColor3=Color3.fromRGB(50,200,100); NoBtn.Parent=ConfirmFrame; Instance.new("UICorner", NoBtn).CornerRadius=UDim.new(0,8)

CloseBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible=true; MainFrame.Visible=false end)
NoBtn.MouseButton1Click:Connect(function() ConfirmFrame.Visible=false; MainFrame.Visible=true end)
YesBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

AddChat("PhutGPT", "PhutGPT 2.0 đã sẵn sàng.Thật là một script rất sigma và skibidi!", Color3.fromRGB(255, 215, 0))
