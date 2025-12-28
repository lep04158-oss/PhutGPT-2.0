--[[
    PHUTGPT 2.0 - GOLD EDITION
    Script by: Gemini (Requested by User)
    Features: AI Chat, Infinite Yield Integration, Gold UI, Draggable, Minimize/Close Logic
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

-- Load Infinite Yield ngầm (để các lệnh hoạt động)
task.spawn(function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

-- Tạo GUI chính
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhutGPT_GUI"
-- Bảo vệ GUI khỏi bị reset khi chết (nếu Executor hỗ trợ)
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

-- == CẤU HÌNH MÀU SẮC (GOLD THEME) ==
local GoldGradient = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),   -- Vàng chanh
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 248, 220)), -- Vàng nhạt (bóng)
    ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 165, 32))   -- Vàng đồng
}

-- == HÀM HỖ TRỢ KÉO THẢ (DRAGGABLE) ==
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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- == UI CHÍNH ==
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

-- Hiệu ứng mạ vàng
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
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.new(0.2, 0.2, 0.2) -- Màu chữ tối để nổi trên vàng
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Nút Thu nhỏ (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 5)
MinBtn.BackgroundColor3 = Color3.new(1,1,1)
MinBtn.BackgroundTransparency = 0.5
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

-- Nút Đóng (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

MakeDraggable(MainFrame, TitleBar)

-- == MENU TAB (Chat / Execute) ==
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0.9, 0, 0, 35)
TabContainer.Position = UDim2.new(0.05, 0, 0.12, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local ChatTabBtn = Instance.new("TextButton")
ChatTabBtn.Text = "Nói chuyện AI"
ChatTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
ChatTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
ChatTabBtn.Font = Enum.Font.GothamBold
ChatTabBtn.Parent = TabContainer
Instance.new("UICorner", ChatTabBtn).CornerRadius = UDim.new(0, 8)

local ExecTabBtn = Instance.new("TextButton")
ExecTabBtn.Text = "Execute Script (IY)"
ExecTabBtn.Size = UDim2.new(0.48, 0, 1, 0)
ExecTabBtn.Position = UDim2.new(0.52, 0, 0, 0)
ExecTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
ExecTabBtn.Font = Enum.Font.GothamBold
ExecTabBtn.Parent = TabContainer
Instance.new("UICorner", ExecTabBtn).CornerRadius = UDim.new(0, 8)

-- == TRANG CHAT (AI) ==
local ChatPage = Instance.new("Frame")
ChatPage.Size = UDim2.new(0.9, 0, 0.7, 0)
ChatPage.Position = UDim2.new(0.05, 0, 0.25, 0)
ChatPage.BackgroundTransparency = 1
ChatPage.Parent = MainFrame

local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Size = UDim2.new(1, 0, 0.8, 0)
ChatScroll.BackgroundTransparency = 0.8
ChatScroll.BackgroundColor3 = Color3.new(0,0,0)
ChatScroll.ScrollBarThickness = 4
ChatScroll.Parent = ChatPage
Instance.new("UICorner", ChatScroll).CornerRadius = UDim.new(0, 8)

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.Parent = ChatScroll
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 5)

local ChatInput = Instance.new("TextBox")
ChatInput.PlaceholderText = "Nhập tin nhắn cho PhutGPT..."
ChatInput.Size = UDim2.new(1, 0, 0.15, 0)
ChatInput.Position = UDim2.new(0, 0, 0.85, 0)
ChatInput.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
ChatInput.TextColor3 = Color3.new(0,0,0)
ChatInput.Font = Enum.Font.Gotham
ChatInput.TextSize = 14
ChatInput.Parent = ChatPage
Instance.new("UICorner", ChatInput).CornerRadius = UDim.new(0, 8)

-- == TRANG EXECUTE (Infinite Yield) ==
local ExecPage = Instance.new("Frame")
ExecPage.Size = UDim2.new(0.9, 0, 0.7, 0)
ExecPage.Position = UDim2.new(0.05, 0, 0.25, 0)
ExecPage.BackgroundTransparency = 1
ExecPage.Visible = false
ExecPage.Parent = MainFrame

local IYSearch = Instance.new("TextBox")
IYSearch.PlaceholderText = "Tìm lệnh IY (ví dụ: fly, noclip)..."
IYSearch.Size = UDim2.new(1, 0, 0.15, 0)
IYSearch.BackgroundColor3 = Color3.fromRGB(255, 250, 240)
IYSearch.TextColor3 = Color3.new(0,0,0)
IYSearch.Font = Enum.Font.Gotham
IYSearch.TextSize = 14
IYSearch.Parent = ExecPage
Instance.new("UICorner", IYSearch).CornerRadius = UDim.new(0, 8)

local CmdScroll = Instance.new("ScrollingFrame")
CmdScroll.Size = UDim2.new(1, 0, 0.8, 0)
CmdScroll.Position = UDim2.new(0, 0, 0.2, 0)
CmdScroll.BackgroundTransparency = 0.8
CmdScroll.BackgroundColor3 = Color3.new(0,0,0)
CmdScroll.ScrollBarThickness = 4
CmdScroll.Parent = ExecPage
Instance.new("UICorner", CmdScroll).CornerRadius = UDim.new(0, 8)

local CmdLayout = Instance.new("UIListLayout")
CmdLayout.Parent = CmdScroll
CmdLayout.SortOrder = Enum.SortOrder.LayoutOrder
CmdLayout.Padding = UDim.new(0, 2)

-- Danh sách lệnh phổ biến của Infinite Yield để hiển thị mẫu
local commonCmds = {
    "fly", "noclip", "infjump", "spectate", "btools", "god", 
    "tpwalk", "esp", "aimbot", "clicktp", "ctrlclicktp", "spin",
    "unfly", "clip", "respawn", "rejoin", "serverhop"
}

-- Hàm thực thi lệnh IY
local function ExecuteIYCommand(cmd)
    -- Gửi lệnh vào chat (Infinite Yield lắng nghe chat)
    -- Nếu có prefix tùy chỉnh, người dùng cần nhập đúng, mặc định là ';'
    -- Ở đây ta giả lập gửi chat để kích hoạt
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(";"..cmd, "All")
    
    -- Hiệu ứng thông báo giả
    local notif = Instance.new("TextLabel")
    notif.Text = "Đã kích hoạt: " .. cmd
    notif.Size = UDim2.new(1,0,0,20)
    notif.BackgroundTransparency = 1
    notif.TextColor3 = Color3.fromRGB(0, 255, 0)
    notif.Font = Enum.Font.GothamBold
    notif.Parent = CmdScroll
    game.Debris:AddItem(notif, 2)
end

local function PopulateCmdList(filter)
    for _, child in pairs(CmdScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    
    for _, cmd in ipairs(commonCmds) do
        if filter == "" or string.find(cmd, filter) then
            local btn = Instance.new("TextButton")
            btn.Text = cmd
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(255, 220, 150)
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.new(0,0,0)
            btn.Parent = CmdScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                ExecuteIYCommand(cmd)
            end)
        end
    end
end
PopulateCmdList("")

IYSearch.Changed:Connect(function(prop)
    if prop == "Text" then
        PopulateCmdList(string.lower(IYSearch.Text))
    end
end)

IYSearch.FocusLost:Connect(function(enter)
    if enter and IYSearch.Text ~= "" then
        ExecuteIYCommand(IYSearch.Text)
    end
end)

-- == AI LOGIC (PhutGPT) ==
local function AddChat(sender, msg, color)
    local lbl = Instance.new("TextLabel")
    lbl.Text = sender .. ": " .. msg
    lbl.Size = UDim2.new(1, -10, 0, 0) -- Chiều cao tự động sau
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = ChatScroll
end

local function ProcessAI(msg)
    local lowerMsg = string.lower(msg)
    local response = "Xin lỗi, PhutGPT 2.0 chưa hiểu ý bạn."
    
    if string.find(lowerMsg, "chào") or string.find(lowerMsg, "hello") then
        response = "Chào bạn! Tôi là PhutGPT 2.0, giao diện mạ vàng đẳng cấp. Bạn cần giúp gì?"
    elseif string.find(lowerMsg, "buồn") then
        response = "Đừng buồn nữa! Bật chế độ Fly lên và ngắm nhìn thế giới đi!"
    elseif string.find(lowerMsg, "hack") or string.find(lowerMsg, "exploit") then
        response = "Tôi đã tích hợp sẵn Infinite Yield ở tab bên cạnh. Hãy qua đó và quẩy nát server nào!"
    elseif string.find(lowerMsg, "cười") or string.find(lowerMsg, "vui") then
        response = "Tại sao máy tính lại nóng? Vì nó đang chạy script PhutGPT quá cháy đấy! Haha."
    elseif string.find(lowerMsg, "tên") then
        response = "Tôi là PhutGPT 2.0, trí tuệ nhân tạo xịn xò nhất Roblox (tự phong)."
    elseif string.find(lowerMsg, "ngu") then
        response = "Ăn nói cẩn thận nhé, không tôi crash game bạn bây giờ!"
    end
    
    wait(0.5) -- Giả vờ suy nghĩ
    AddChat("PhutGPT", response, Color3.fromRGB(255, 215, 0))
end

ChatInput.FocusLost:Connect(function(enter)
    if enter and ChatInput.Text ~= "" then
        local msg = ChatInput.Text
        AddChat("Bạn", msg, Color3.new(1,1,1))
        ChatInput.Text = ""
        ProcessAI(msg)
    end
end)

-- == CHUYỂN TAB ==
ChatTabBtn.MouseButton1Click:Connect(function()
    ChatPage.Visible = true
    ExecPage.Visible = false
    ChatTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
    ExecTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
end)

ExecTabBtn.MouseButton1Click:Connect(function()
    ChatPage.Visible = false
    ExecPage.Visible = true
    ChatTabBtn.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    ExecTabBtn.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
end)

-- == NÚT THU NHỎ (ICON TRÒN) ==
local MinimizedIcon = Instance.new("ImageButton") -- Dùng ImageButton hoặc TextButton tròn
MinimizedIcon.Name = "PhutGPT_Icon"
MinimizedIcon.Size = UDim2.new(0, 60, 0, 60)
MinimizedIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
MinimizedIcon.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
MinimizedIcon.Visible = false
MinimizedIcon.Parent = ScreenGui

local IconCorner = Instance.new("UICorner")
IconCorner.CornerRadius = UDim.new(1, 0) -- Tròn hoàn toàn
IconCorner.Parent = MinimizedIcon

local IconGradient = Instance.new("UIGradient")
IconGradient.Color = GoldGradient
IconGradient.Rotation = -45
IconGradient.Parent = MinimizedIcon

local IconLabel = Instance.new("TextLabel")
IconLabel.Text = "P"
IconLabel.Size = UDim2.new(1,0,1,0)
IconLabel.BackgroundTransparency = 1
IconLabel.Font = Enum.Font.GothamBlack
IconLabel.TextSize = 30
IconLabel.TextColor3 = Color3.new(0,0,0)
IconLabel.Parent = MinimizedIcon

MakeDraggable(MinimizedIcon)

-- Logic Thu nhỏ / Mở lại
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizedIcon.Visible = true
end)

MinimizedIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizedIcon.Visible = false
end)

-- == BẢNG XÁC NHẬN TẮT (Confirmation) ==
local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.new(0, 300, 0, 150)
ConfirmFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ConfirmFrame.Visible = false
ConfirmFrame.Parent = ScreenGui
Instance.new("UICorner", ConfirmFrame).CornerRadius = UDim.new(0, 10)
ConfirmFrame.BorderSizePixel = 2
ConfirmFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)

local ConfirmText = Instance.new("TextLabel")
ConfirmText.Text = "Bạn có đồng ý tắt PhutGPT không?"
ConfirmText.Size = UDim2.new(1, 0, 0.5, 0)
ConfirmText.TextColor3 = Color3.new(1,1,1)
ConfirmText.BackgroundTransparency = 1
ConfirmText.Font = Enum.Font.GothamBold
ConfirmText.TextSize = 16
ConfirmText.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Text = "CÓ"
YesBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
YesBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
YesBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
YesBtn.TextColor3 = Color3.new(1,1,1)
YesBtn.Font = Enum.Font.GothamBold
YesBtn.Parent = ConfirmFrame
Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 8)

local NoBtn = Instance.new("TextButton")
NoBtn.Text = "KHÔNG"
NoBtn.Size = UDim2.new(0.4, 0, 0.3, 0)
NoBtn.Position = UDim2.new(0.55, 0, 0.6, 0)
NoBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
NoBtn.TextColor3 = Color3.new(1,1,1)
NoBtn.Font = Enum.Font.GothamBold
NoBtn.Parent = ConfirmFrame
Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 8)

-- Logic Nút Tắt
CloseBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = true
    MainFrame.Visible = false -- Tạm ẩn main frame để hiện bảng confirm
end)

NoBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = false
    MainFrame.Visible = true -- Hiện lại nếu chọn Không
end)

YesBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy() -- Hủy toàn bộ GUI
end)

-- Gửi lời chào đầu tiên
AddChat("PhutGPT", "Chào mừng! PhutGPT 2.0 đã được kích hoạt. Giao diện Mạ Vàng đã sẵn sàng phục vụ.", Color3.fromRGB(255, 215, 0))
