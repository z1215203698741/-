 ---Skeet Ui---
 if Library and Library.Unload then
    Library:Unload()
end
--
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")
--
local Client = Players.LocalPlayer
local Camera = Workspace:FindFirstChildWhichIsA("Camera")
local Viewport = Camera.ViewportSize
--
do -- Folders
    -- 部分执行器（尤其手机端）的 isfolder/isfile/listfiles 会直接抛错而不是返回 false，
    -- 统一包一层 pcall 兜底（黑曜石 SaveManager 同款处理），否则配置系统可能整体失效
    local OldIsFolder, OldIsFile, OldListFiles = isfolder, isfile, listfiles
    if type(OldIsFolder) == "function" then
        isfolder = function(Path)
            local Success, Result = pcall(OldIsFolder, Path)
            return Success and Result == true
        end
    end
    if type(OldIsFile) == "function" then
        isfile = function(Path)
            local Success, Result = pcall(OldIsFile, Path)
            return Success and Result == true
        end
    end
    if type(OldListFiles) == "function" then
        listfiles = function(Path)
            local Success, Result = pcall(OldListFiles, Path)
            if Success and typeof(Result) == "table" then return Result end
            return {}
        end
    end
    --
    if not isfolder("gamesense") then
        makefolder("gamesense")
    end
    --
    if not isfolder("gamesense/Configs") then
        makefolder("gamesense/Configs")
    end
end
--
do -- Library
    getgenv().Library = {
        Connections = {},
        Errors = {},
        Tweens = {},
        Objects = {},
        Sections = {},
        ThemeSections = {},
        Flags = {},
        UnnamedFlags = 0,
        Build = "Beta",
        UID = "1",
        UnsafeMode = false,
        InitTime = os.clock(),
        Folder = "gamesense",
        ConfigFolder = "gamesense/Configs",
        UI = {
            Name = "gamesense",
            CloseBind = Enum.KeyCode.Insert,
            SectionResizeIncrements = 1,
            WatermarkRefreshRate = 1,
            MainUI = nil,
            Initialized = false,
            Faded = false,
            LastCopiedColor = nil,
            TabIndex = 0,
            Viewing = false,
            CurrentSelectedColorPicker = nil,
            CurrentSelectedColorPickerExtra = nil,
            CurrentSelectedKeybindMode = nil,
            TotalColorPickers = 0,
            TotalKeybindModes = 0,
            WatermarkPosition = "Top Right",
            SectionZIndex = 100,
            Resizing = false,
            DropdownZIndex = 1,
            OpenColorFrames = 0,
            ScreenGUI = nil,
            TweenSpeed = 0.15,
            NewFont = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            FontSize = 13,
            DraggingGui = nil,
            Notifications = {TopLeft = {}, Middle = {}},
            Keys = {
                [Enum.KeyCode.LeftShift] = "LSHF",
                [Enum.KeyCode.RightShift] = "RSHF",
                [Enum.KeyCode.LeftControl] = "LCTR",
                [Enum.KeyCode.RightControl] = "RCTR",
                [Enum.KeyCode.LeftAlt] = "LALT",
                [Enum.KeyCode.RightAlt] = "RALT",
                [Enum.KeyCode.CapsLock] = "CAPS",
                [Enum.KeyCode.Space] = "SPCE",
                [Enum.KeyCode.One] = "ONE",
                [Enum.KeyCode.Two] = "TWO",
                [Enum.KeyCode.Three] = "THREE",
                [Enum.KeyCode.Four] = "FOUR",
                [Enum.KeyCode.Five] = "FIVE",
                [Enum.KeyCode.Six] = "SIX",
                [Enum.KeyCode.Seven] = "SEVEN",
                [Enum.KeyCode.Eight] = "EIGHT",
                [Enum.KeyCode.Nine] = "NINE",
                [Enum.KeyCode.Zero] = "ZERO",
                [Enum.KeyCode.KeypadOne] = "NUM1",
                [Enum.KeyCode.KeypadTwo] = "NUM2",
                [Enum.KeyCode.KeypadThree] = "NUM3",
                [Enum.KeyCode.KeypadFour] = "NUM4",
                [Enum.KeyCode.KeypadFive] = "NUM5",
                [Enum.KeyCode.KeypadSix] = "NUM6",
                [Enum.KeyCode.KeypadSeven] = "NUM7",
                [Enum.KeyCode.KeypadEight] = "NUM8",
                [Enum.KeyCode.KeypadNine] = "NUM9",
                [Enum.KeyCode.KeypadZero] = "NUM0",
                [Enum.KeyCode.Insert] = "INS",
                [Enum.KeyCode.Minus] = "-",
                [Enum.KeyCode.Equals] = "=",
                [Enum.KeyCode.Tilde] = "~",
                [Enum.KeyCode.LeftBracket] = "[",
                [Enum.KeyCode.RightBracket] = "]",
                [Enum.KeyCode.RightParenthesis] = ")",
                [Enum.KeyCode.LeftParenthesis] = "(",
                [Enum.KeyCode.Semicolon] = ",",
                [Enum.KeyCode.Quote] = "'",
                [Enum.KeyCode.BackSlash] = "\\",
                [Enum.KeyCode.Comma] = ",",
                [Enum.KeyCode.Period] = ".",
                [Enum.KeyCode.Slash] = "/",
                [Enum.KeyCode.Asterisk] = "*",
                [Enum.KeyCode.Plus] = "+",
                [Enum.KeyCode.Period] = ".",
                [Enum.KeyCode.Backquote] = "`",
                [Enum.UserInputType.MouseButton1] = "M1",
                [Enum.UserInputType.MouseButton2] = "M2",
                [Enum.UserInputType.MouseButton3] = "M3"
            },
        },
        Theme = {
            Objects = {},
            Default = {
                Accent = Color3.fromRGB(153, 196, 39),
                SecondAccent = Color3.fromRGB(124, 158, 32),
                TextColor = Color3.fromRGB(205, 205, 205),
                Risky = Color3.fromRGB(165, 165, 120),
            }
        }
    }
    --
    -- ==================== 移动端适配（参考黑曜石 UI 库） ====================
    -- 黑曜石的核心做法：所有点击判定 = MouseButton1 或 Touch，所有移动判定 = MouseMovement 或 Touch。
    -- 本库原来所有 InputBegan/Changed 只认鼠标类型，导致手机上拖动/缩放/滑条/色板全部失效。
    do
        local IsMobile = false
        pcall(function()
            local Platform = UserInputService:GetPlatform()
            IsMobile = (Platform == Enum.Platform.Android or Platform == Enum.Platform.IOS)
        end)
        -- 兜底：有触摸没鼠标（部分模拟器 GetPlatform 可能失败）
        if not IsMobile and UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
            IsMobile = true
        end
        --
        Library.IsMobile = IsMobile
        Library.UI._TouchCount = 0
        --
        -- 点击判定：鼠标左键 或 手指按下（含 Begin 状态校验）
        function Library:IsClickInput(Input)
            if not Input then return false end
            --
            local T = Input.UserInputType
            if T ~= Enum.UserInputType.MouseButton1 and T ~= Enum.UserInputType.Touch then return false end
            --
            return Input.UserInputState == Enum.UserInputState.Begin
        end
        --
        -- 移动判定：鼠标移动 或 手指拖动（含 Change 状态校验）
        function Library:IsMoveInput(Input)
            if not Input then return false end
            --
            local T = Input.UserInputType
            if T ~= Enum.UserInputType.MouseMovement and T ~= Enum.UserInputType.Touch then return false end
            --
            return Input.UserInputState == Enum.UserInputState.Change
        end
        --
        -- 释放判定：鼠标左键 或 手指抬起
        function Library:IsReleaseInput(Input)
            if not Input then return false end
            --
            local T = Input.UserInputType
            if T ~= Enum.UserInputType.MouseButton1 and T ~= Enum.UserInputType.Touch then return false end
            --
            return Input.UserInputState == Enum.UserInputState.End or Input.UserInputState == Enum.UserInputState.Cancel
        end
        --
        -- 当前是否有按下（鼠标或手指）。旧代码直接 IsMouseButtonPressed(MouseButton1)，
        -- 触摸时永远 false，导致滑条/色板拖动第一帧就被取消
        function Library:IsInputDown()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return true end
            --
            return Library.UI._TouchCount > 0
        end
        --
        -- 按钮点击统一入口（手机双保险方案）：
        -- 1) InputBegan 按下即触发（黑曜石语义）
        -- 2) GuiButton.Activated = Roblox 官方跨平台点击事件（触摸按下+抬起即触发，
        --    官方为移动端设计，容忍手指轻微位移）
        -- 两者 0.3s 防抖窗口去重；PC 保持 MouseButton1Click 原语义
        function Library:OnClick(Button, Callback)
            if Library.IsMobile then
                local LastFire = 0
                local function SafeFire()
                    local Now = os.clock()
                    if Now - LastFire < 0.3 then return end
                    LastFire = Now
                    --
                    Callback()
                end
                --
                Library:Connection(Button.Activated, SafeFire)
                return Library:Connection(Button.InputBegan, function(Input)
                    if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin then
                        SafeFire()
                    end
                end)
            end
            --
            return Library:Connection(Button.MouseButton1Click, Callback)
        end
        --
        -- 维护触摸计数（不管 GameProcessed：按下即按住）
        UserInputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin then
                Library.UI._TouchCount += 1
            end
        end)
        --
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then
                Library.UI._TouchCount = math.max(0, Library.UI._TouchCount - 1)
            end
        end)
    end
    --
    function Library:Validate(Defaults, Options)
        for Index, Value in Defaults do
            if Options[Index] == nil then
                Options[Index] = Value
            end
        end
        --
        return Options
    end
    --
    function Library:Connection(Signal, Func, Name, Table)
        Name = Name or "Unknown"
        Table = Table or Library.Connections
        --
        local Connection; Connection = Signal:Connect(function(...)
            local Args = {...}
            --
            -- 直接在信号闭包内调用：该闭包保留 executor 身份；
            -- 切勿用 coroutine.wrap/task.spawn 包一层——新协程会丢失 Plugin capability
            -- （信号回调本身支持 yield，Roblox 每次触发在独立线程中运行闭包）
            local Success, Message = pcall(function() return Func(unpack(Args)) end)
            --
            -- 重要：回调报错绝不断开连接！
            -- 旧逻辑 error 一次就永久 Disconnect——手机上功能回调只要报一次错（执行器缺 API 等），
            -- 该控件就彻底点不动了（表现为"关闭了再开启就调不了""90%按钮没反应"）。
            -- 现在只弹通知（同错误去重限频），控件保持可用
            if not Success then
                if not Library.Errors[Message] then
                    Library.Errors[Message] = Message
                    --
                    if Library.Notify then
                        Library:Notify({Message = ("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name), Delay = 10})
                    else
                        warn(("[ERROR] | An error has occurred:\n%s\nName: %s"):format(Message, Name))
                    end
                end
            end
        end)
        --
        if Connection and Table then
            table.insert(Table, Connection)
        end
        --
        return Connection
    end
    --
    function Library:TweenObject(Object, Info, Goal, Callback)
        if not Object then return end
        --
        local Tween = TweenService:Create(Object, Info, Goal)
        --
        Library:Connection(Tween.Completed, Callback or function() end)
        --
        Tween:Play()
        --
        Library.Tweens[#Library.Tweens + 1] = Tween
    end
    --

    -- ==================== 可靠的行折叠/展开（带向下展开动画） ====================
    -- 旧实现依赖 Objects 记账 + 负高度 hack，主开关关闭时设置项经常折叠失败。
    -- 这里直接管理行的 Visible + 高度补间：显示 = 先 Visible 再从 0 长到原始高度（向下展开），
    -- 隐藏 = 高度收到 0 后 Visible=false（UIListLayout 会跳过不可见行，布局立即回收）。
    Library.__RowMeta = setmetatable({}, {__mode = "k"})
    function Library:SetRowVisible(Row, Bool)
        if typeof(Row) ~= "Instance" or not Row:IsA("GuiObject") then return end
        local meta = Library.__RowMeta[Row]
        if not meta then
            meta = { Size = Row.Size, Hidden = not Row.Visible and true or false }
            if Row.Visible then
                meta.Hidden = false
            end
            Library.__RowMeta[Row] = meta
        end
        --
        if Bool then
            if meta.Hidden then
                meta.Hidden = false
                pcall(function()
                    Library:Fade(true, Library:GetObjectsTable(Row), Row, 0.075)
                end)
                -- Fade 内部会把 Active 设为 true；行 Frame 吸收触摸会挡住内部按钮，
                -- 必须在 Fade 之后强制还原为 false（触摸直达行内按钮/滑条/下拉框）
                Row.Active = false
                Row.Visible = true
                Row.Size = UDim2.new(meta.Size.X.Scale, meta.Size.X.Offset, 0, 0)
                Library:TweenObject(Row, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = meta.Size})
            end
        else
            if not meta.Hidden then
                meta.Hidden = true
                pcall(function()
                    Library:Fade(false, Library:GetObjectsTable(Row), Row, 0.075)
                end)
                Library:TweenObject(Row, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(meta.Size.X.Scale, meta.Size.X.Offset, 0, 0)}, function()
                    if Library.__RowMeta[Row] and Library.__RowMeta[Row].Hidden then
                        Row.Visible = false
                    end
                end)
            end
        end
    end
    --
    -- ==================== 3D 模型视口（双线程：游戏线程取模型 / executor 线程挂 GUI） ====================
    do
        local SkinsLib = nil
        local Turntable = setmetatable({}, {__mode = "k"})
        local RenderConn = nil
        local Diag = {}
        local ExecJobs = {}
        local UiJobs = {}

        -- UI 事件回调（按钮/网格点击）在游戏信号线程触发，缺 Plugin capability，
        -- 凡是回调里要建 Instance 或调外部 require 的逻辑都丢到这个注入身份串行线程。
        -- 单线程保证多次点击按顺序执行。
        task.spawn(function()
            while true do
                local job = table.remove(UiJobs, 1)
                if job then
                    local ok, err = pcall(job)
                    if not ok then
                        warn("[NERX][UI] 回调执行失败: " .. tostring(err))
                    end
                else
                    task.wait()
                end
            end
        end)

        function Library:RunAsync(fn)
            UiJobs[#UiJobs + 1] = fn
        end

        local function ensureTurntable()
            if RenderConn then return end
            RenderConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
                for handle in pairs(Turntable) do
                    if handle.Hovered and handle._step then
                        pcall(handle._step, handle, dt)
                    end
                end
            end)
        end

        local function getSkinsLib()
            if SkinsLib then return SkinsLib end
            pcall(function()
                SkinsLib = require(game:GetService("ReplicatedStorage").Database.Components.Libraries.Skins)
            end)
            return SkinsLib
        end

        local function diagOnce(key, msg)
            if not Diag[key] then
                Diag[key] = true
                warn("[NERX][Viewport] " .. msg)
            end
        end

        -- executor 身份常驻工作线程（库代码在注入线程执行，task.spawn 保持注入身份）：
        -- 所有 Camera / ImageLabel / 父级挂载只在这里做。
        -- 游戏信号回调线程缺 Plugin capability，直接建 Instance 会报 lacking capability Plugin。
        for _ = 1, 3 do
            task.spawn(function()
                while true do
                    local job = table.remove(ExecJobs, 1)
                    if job then
                        local ok, err = pcall(job)
                        if not ok then
                            warn("[NERX][Viewport] 渲染任务失败: " .. tostring(err))
                        end
                    else
                        task.wait()
                    end
                end
            end)
        end

        -- 把 fn 派发到游戏身份线程（主脚本相机 hook 每帧泵 _G.NERXGameJobs）。
        -- 只有游戏线程能 require 普通游戏 ModuleScript（Skins 库内部 GetWeaponProperties 依赖它）。
        local function runOnGameThread(fn, timeout)
            local q = _G.NERXGameJobs
            if not q then
                return nil, "game job queue unavailable"
            end
            local job = {fn = fn}
            q[#q + 1] = job
            local deadline = os.clock() + (timeout or 15)
            while not job.done do
                if os.clock() > deadline then
                    return nil, "timeout"
                end
                task.wait(0.02)
            end
            if not job.ok then
                return nil, tostring(job.result)
            end
            return job.result
        end

        local function buildViewport(ViewportFrame, Opts, handle)
            local lib = getSkinsLib()

            local function showIcon(iconId)
                if not iconId or iconId == "" or type(iconId) ~= "string" then return false end
                local img = Instance.new("ImageLabel")
                img.BackgroundTransparency = 1
                img.AnchorPoint = Vector2.new(0.5, 0.5)
                img.Position = UDim2.new(0.5, 0, 0.46, 0)
                img.Size = UDim2.new(0.86, 0, 0.86, 0)
                img.Image = iconId
                img.ScaleType = Enum.ScaleType.Fit
                img.ZIndex = 6
                img.Parent = ViewportFrame
                return true
            end

            if not lib or not Opts.Model or Opts.Model == "" then
                showIcon(Opts.FallbackIcon)
                return
            end

            -- 候选皮肤名：指定皮肤 → Stock（游戏对任意武器/手套都能合成 Stock schema）→ Vanilla → 通用名兜底
            local tries = {}
            if Opts.Skin and Opts.Skin ~= "" and Opts.Skin ~= "Random" and Opts.Skin ~= "Special" and Opts.Skin ~= "Default" then
                table.insert(tries, Opts.Skin)
            end
            table.insert(tries, "Stock")
            table.insert(tries, "Vanilla")
            if Opts.Type == "gloves" then
                table.insert(tries, "Specialist")
            else
                table.insert(tries, "Fade")
                table.insert(tries, "Midas")
                table.insert(tries, "Lore")
            end

            -- 1) 游戏线程取模型；模型取不到时顺带解析官方 2D 图标（同样依赖游戏身份 require）
            local res, gErr = runOnGameThread(function()
                local lastErr
                for attempt = 1, 3 do
                    for _, s in ipairs(tries) do
                        local ok, m = pcall(function()
                            if Opts.Type == "gloves" then
                                return lib.GetGloves(Opts.Model, s, Opts.Wear or 0.99)
                            end
                            return lib.GetCharacterModel(Opts.Model, s, Opts.Wear or 0.001)
                        end)
                        if ok and m then
                            return {model = m}
                        end
                        if not ok then
                            lastErr = tostring(m)
                        end
                    end
                    if attempt < 3 then
                        task.wait(0.25)
                    end
                end
                local icon
                if Opts.Skin and Opts.Skin ~= "Default" then
                    pcall(function()
                        local info = lib.GetSkinInformation(Opts.Model, Opts.Skin)
                        if info then
                            if lib.GetWearImageForFloat then
                                icon = lib.GetWearImageForFloat(info, Opts.Wear or 0.99)
                            end
                            if not icon and info.imageAssetId then
                                icon = info.imageAssetId
                            end
                        end
                    end)
                end
                return {icon = icon, err = lastErr}
            end, 15)

            -- 卡片已被重建/销毁
            if not ViewportFrame.Parent then
                if res and res.model then
                    pcall(function() res.model:Destroy() end)
                end
                return
            end

            local model = res and res.model
            if not model then
                diagOnce(Opts.Model .. "|" .. tostring(Opts.Skin),
                    ("模型不可用: %s (skin=%s) %s"):format(Opts.Model, tostring(Opts.Skin),
                        tostring((res and res.err) or gErr or "未知原因")))
                local used = showIcon(res and res.icon)
                if not used then
                    showIcon(Opts.FallbackIcon)
                end
                return
            end

            -- 2) executor 线程完成克隆与挂载
            local clone
            local okClone, c = pcall(function() return model:Clone() end)
            if okClone and c then
                clone = c
                pcall(function() model:Destroy() end)
            else
                clone = model
            end

            pcall(function()
                for _, d in ipairs(clone:GetDescendants()) do
                    if d:IsA("BasePart") then d.Anchored = true end
                end
            end)
            clone.Parent = ViewportFrame

            if Opts.Type == "gloves" then
                -- 手套是散装部件模型，bbox 与武器差异极大：先归一化尺寸再取景，避免贴脸特写
                pcall(function()
                    local _, sz0 = clone:GetBoundingBox()
                    local m0 = math.max(sz0.X, sz0.Y, sz0.Z, 0.01)
                    clone:ScaleTo(1.7 / m0)
                end)
            end

            local cf, sz = clone:GetBoundingBox()
            local maxDim = math.max(sz.X, sz.Y, sz.Z, 0.5)
            -- 手套取景更远一点，显得更小
            local dist = maxDim * ((Opts.Type == "gloves") and 1.3 or 0.81)
            local offset = Vector3.new(dist * 0.75, dist * 0.35, dist * 0.8)
            local camPos = cf.Position + offset

            local camera = Instance.new("Camera")
            camera.FieldOfView = 50
            camera.CFrame = CFrame.new(camPos, cf.Position)
            camera.Parent = ViewportFrame
            ViewportFrame.CurrentCamera = camera
            pcall(function() ViewportFrame.LightColor = Color3.fromRGB(245, 245, 255) end)
            pcall(function() ViewportFrame.Ambient = Color3.fromRGB(150, 150, 160) end)
            pcall(function() ViewportFrame.LightDirection = Vector3.new(-1, -1.2, -1).Unit end)

            local angle = 0
            handle._step = function(_, dt)
                if not clone.Parent or not camera.Parent then return end
                angle = angle + dt * 1.8
                local rotated = CFrame.Angles(0, angle, 0) * offset
                camera.CFrame = CFrame.new(cf.Position + rotated, cf.Position)
            end
            function handle.SetHover(h, State)
                h.Hovered = State and true or false
                if not h.Hovered and camera.Parent then
                    angle = 0
                    camera.CFrame = CFrame.new(camPos, cf.Position)
                end
            end

            Turntable[handle] = true
            ensureTurntable()
        end

        function Library:CreateModelViewport(ViewportFrame, Opts)
            Opts = Opts or {}
            local handle = {Hovered = false}
            -- 先占位，挂载完成后替换为真实实现（ModelGrid 悬停时可能立刻调用）
            handle.SetHover = function() end
            ExecJobs[#ExecJobs + 1] = function()
                buildViewport(ViewportFrame, Opts, handle)
            end
            return handle
        end
    end
    --
    function Library:NewFlag()
        Library.UnnamedFlags += 1
        --
        return ("UnknownFlag%s"):format(tostring(Library.UnnamedFlags))
    end
    --
    function Library:ClampString(String, MaxWidth)
        local Clamped = String
        --
        local TextLabel = Library:CreateObject("TextLabel", {
            FontFace = Library.UI.NewFont,
            TextStrokeTransparency = 0,
            Text = String,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextScaled = false,
            TextWrapped = false,
            Visible = false,
            TextSize = Library.UI.FontSize,
            Parent = Client.PlayerGui
        })
        --
        if TextLabel.TextBounds.X <= MaxWidth then
            TextLabel:Destroy()
            --
            return String
        end
        --
        while TextLabel.TextBounds.X > MaxWidth and #Clamped > 0 do
            Clamped = Clamped:sub(1, #Clamped - 1)
            --
            TextLabel.Text = Clamped .. "..."
            --
            task.wait()
        end
        --
        TextLabel:Destroy()
        --
        return Clamped .. "..."
    end
    --
    function Library:GetConfig()
        local Config = {}
        --
        for Index, Value in Library.Flags do
            if Value.Get and not string.find(Index, "_Status") then
                local Got = Value:Get()
                --
                -- Keybind 抢占 Toggle flag 的特殊情况（Keybind:Toggle 里 Flags[ToggleFlag] = Keybind）：
                -- 此时 Get() 返回键位名，开关状态会丢——必须打包 {Key, State} 一起保存，
                -- 否则所有带 ChangeToggle 热键的功能开关加载后永远不会恢复（"保存配置无效"的主因）
                -- 注意：独立 Keybind 的 Value.Toggle 是方法（function），必须限定 typeof == "table"
                -- （否则 "attempt to index function with 'State'"，保存直接失败）
                if Value.RegKeybind ~= nil and typeof(Value.Toggle) == "table" then
                    Config[Index] = {Key = Got, State = Value.Toggle.State, Mode = Value.Mode}
                elseif typeof(Got) == "table" and Got.Color and Got.Transparency then
                    local Transparency = Got.Transparency
                    local Hue, Saturation, Val = Got.Color:ToHSV()
                    --
                    Config[Index] = {Hue, Saturation, Val, Transparency}
                elseif typeof(Got) == "table" then
                    -- 表值白名单过滤：只保留 bool/number/string（嵌套一层），
                    -- 防止 MultiDropdown 等控件的值里混入 Enum/Color3 等 userdata 导致整个 JSONEncode 失败
                    local SafeTable = {}
                    for K, V in Got do
                        if typeof(K) == "string" or typeof(K) == "number" then
                            if typeof(V) == "boolean" or typeof(V) == "number" or typeof(V) == "string" then
                                SafeTable[K] = V
                            end
                        end
                    end
                    Config[Index] = SafeTable
                elseif typeof(Got) == "boolean" or typeof(Got) == "number" or typeof(Got) == "string" then
                    Config[Index] = Got
                end
                -- 其余类型（Enum 等）无法 JSON 序列化，直接跳过，避免整个保存报错
            end
        end
        --
        return HttpService:JSONEncode(Config)
    end
    --
    -- ===== 配置文件管理（对齐黑曜石 SaveManager 架构，逻辑全部收在库内） =====
    --
    -- 非 ASCII（中文等）转 \uXXXX：部分手机执行器 writefile/readfile 对 UTF-8 编码处理有问题
    local function jsonAsciiSafe(s)
        if not (utf8 and utf8.codepoint) then return s end
        local out = {}
        local i, n = 1, #s
        while i <= n do
            local byte = s:byte(i)
            if byte < 0x80 then
                out[#out + 1] = s:sub(i, i)
                i += 1
            else
                local len = byte >= 0xF0 and 4 or byte >= 0xE0 and 3 or 2
                local seq = s:sub(i, i + len - 1)
                local okCP, cp = pcall(utf8.codepoint, seq)
                if okCP and cp and cp > 0x7F then
                    if cp > 0xFFFF then
                        cp -= 0x10000
                        local hi = 0xD800 + (cp // 0x400)
                        local lo = 0xDC00 + (cp % 0x400)
                        out[#out + 1] = string.format("\\u%04x\\u%04x", hi, lo)
                    else
                        out[#out + 1] = string.format("\\u%04x", cp)
                    end
                else
                    out[#out + 1] = seq
                end
                i += len
            end
        end
        return table.concat(out)
    end
    --
    -- 保存配置：GetConfig → 数值清洗（NaN/Infinity）→ ASCII 转义 → 删旧写入 → 回读校验（含长度对比，定位执行器 8KB 限制）
    -- 成功返回 true；失败返回 false + 错误描述
    function Library:SaveConfigFile(Folder, Name)
        local ok, encoded = pcall(function() return self:GetConfig() end)
        if not ok or type(encoded) ~= "string" then
            return false, "生成配置失败: " .. tostring(encoded)
        end
        -- 数值清洗：NaN/Infinity 是裸 token 不是合法 JSON（字符串值里不会出现这些词，替换安全）
        local okS, sanitized = pcall(function()
            return encoded:gsub("NaN", "0"):gsub("%-?Infinity", "999999")
        end)
        if okS and type(sanitized) == "string" then encoded = sanitized end
        -- 中文等非 ASCII 转 \uXXXX（JSONDecode 自动还原），文件变纯 ASCII 编码安全
        local okA, ascii = pcall(jsonAsciiSafe, encoded)
        if okA and type(ascii) == "string" then encoded = ascii end
        local Path = Folder .. "/" .. Name .. ".cfg"
        pcall(delfile, Path)
        local okW, werr = pcall(writefile, Path, encoded)
        if not okW then
            return false, "写入失败（执行器不支持 writefile?）: " .. tostring(werr)
        end
        local raw = ""
        pcall(function() raw = tostring(readfile(Path)) end)
        local okV, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
        if not okV or type(decoded) ~= "table" then
            local hint = ""
            if #raw < #encoded then
                hint = string.format("（截断: 写入%d字节 读回%d字节 → 执行器单文件限制约%dKB，请减少配置体积或换执行器）", #encoded, #raw, math.floor(#raw / 1024))
            end
            return false, "回读校验失败: 长度" .. #raw .. "/" .. #encoded .. hint .. " 头[" .. raw:sub(1, 30) .. "] 尾[" .. raw:sub(-25) .. "]"
        end
        return true
    end
    --
    -- 加载配置：逐 Flag 单独 pcall（单个控件 Set 失败只跳过该项），返回 true,成功数,跳过数 / false,错误
    function Library:LoadConfigFile(Folder, Name)
        local Path = Folder .. "/" .. Name .. ".cfg"
        if isfile and not isfile(Path) then
            return false, "文件不存在"
        end
        local raw = ""
        pcall(function() raw = tostring(readfile(Path)) end)
        local okD, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not okD or type(data) ~= "table" then
            return false, "文件损坏: 长度" .. #raw .. " 头[" .. raw:sub(1, 30) .. "] 尾[" .. raw:sub(-25) .. "]"
        end
        local applied, failed = 0, 0
        for Index, Value in data do
            local Flag = self.Flags[Index]
            if Flag and type(Flag.Set) == "function" then
                local ok = pcall(function() Flag:Set(Value) end)
                if ok then applied += 1 else failed += 1 end
            end
        end
        return true, applied, failed
    end
    --
    function Library:LoadConfig(Config)
        local Config = HttpService:JSONDecode(Config)
        --
        for Index, Value in Config do
            if Library.Flags[Index] and Library.Flags[Index].Set then
                Library.Flags[Index]:Set(Value)
            end
        end
    end
    --
    function Library:SectionDragging(Frame)
        local MousePosition = UserInputService:GetMouseLocation()
        local Position = Frame.AbsolutePosition
        local Size = Frame.AbsoluteSize
        --
        local InsideX = MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X
        local InsideY = MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
        --
        return InsideX and InsideY
    end
    --
    function Library:CreateObject(Type, Properties, Hidden)
        local Hidden = Hidden or false
        local Object = Instance.new(Type)
        --
        for Index, Value in Properties do
            if (not RunService:IsStudio()) and Index == "Name" and not string.match(Value, "%d") then
                Value = "\0"
            end
            --
            if Index == "TextStrokeTransparency" and Value == 0 then
                local Stroke = Instance.new("UIStroke")
                --
                Stroke.Parent = Object
                Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                --
                Library.Objects[Stroke] = {Stroke, {Parent = Object, LineJoinMode = Enum.LineJoinMode.Miter}, Hidden}
            else
                Object[Index] = Value
            end
        end
        --
        Library.Objects[Object] = {Object, Properties, Hidden}
        --
        return Object
    end
    --
    function Library:AddTheme(Object, Properties)
        for Index, Value in Properties do
            Library.Theme.Objects[Object] = Library.Theme.Objects[Object] or {}
            Library.Theme.Objects[Object][Index] = Value
        end
    end
    --
    function Library:GetTableIndexes(Table, Custom)
        local Table2 = {}
        --
        for Index, Value in Table do
            Table2[Custom and Value[1] or #Table2 + 1] = Index 
        end
        --
        return Table2
    end
    --
    function Library:UpdateConfigList(List, Type)
        for _, File in listfiles("gamesense/Configs") do
            -- 手机执行器 listfiles 返回的前缀/分隔符不统一：统一取最后一段文件名再剥后缀，
            -- 避免 "gamesense/Configs/" 前缀不匹配时列表项变成全路径导致加载失败
            local FileName = File:gsub("\\", "/"):match("[^/]+$")
            FileName = FileName and FileName:gsub("%.cfg$", "") or ""
            --
            if FileName ~= "" then
                if Type == "Remove" then
                    List:RemoveValue(FileName)
                else
                    List:AddValue(FileName)
                end
            end
        end
    end
    --
    function Library:GetObjectsTable(MainUI, AddMain, Ignored)
        local AddMain = AddMain or false
        local Ignored = Ignored or {}
        local DescendantTable = {}
        local NewTable = {}
        --
        for _, Descendant in MainUI:GetDescendants() do
            if table.find(Ignored, Descendant) then continue end
            --
            DescendantTable[#DescendantTable + 1] = Descendant
        end
        --
        if AddMain then
            DescendantTable[#DescendantTable + 1] = MainUI
        end
        --
        for _, Descendant in DescendantTable do
            local Found = Library.Objects[Descendant]
            --
            if Found then
                local Properties = Found[2]
                local HiddenValue = Found[3]
                --
                NewTable[#NewTable + 1] = {Descendant, Properties, HiddenValue}
            end
        end
        --
        return NewTable
    end
    --
    function Library:SetTableVisible(Table, State, Ignored)
        local Ignored = Ignored or {}
        --
        for _, Object in Table do
            if table.find(Ignored, Object) then continue end
            --
            if typeof(Object) == "table" and Object.SetVisible then 
                Object:SetVisible(State)
            end
        end
    end
    --
    function Library:UpdateColor(ColorType, ColorValue)
        Library.Theme.Default[ColorType] = ColorValue
        --
        for Object, Properties in Library.Theme.Objects do
            for Property, ThemeKeys in Properties do
                if typeof(ThemeKeys) == "table" then
                    if Object:IsA("UIGradient") and Property == "Color" then
                        if Library.Theme.Default[ThemeKeys[1]] then
                            Object.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Library.Theme.Default[ThemeKeys[1]]), ColorSequenceKeypoint.new(1, Library.Theme.Default[ThemeKeys[2]])}
                        end
                    end
                else
                    if ThemeKeys == ColorType then
                        Object[Property] = Library.Theme.Default[ThemeKeys]
                    end
                end
            end
        end
    end
    --
    function Library:ViewPlayer(Player)
        -- 角色模型可能没有 Humanoid（游戏自定义角色/死亡/加载中），必须容错否则报错中断
        if not Library.UI.Viewing then
            local Char = Player and Player.Character
            local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
            if not Humanoid then return end
            --
            Camera.CameraSubject = Humanoid
        else
            local Char = Client.Character
            local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
            if not Humanoid then return end
            --
            Camera.CameraSubject = Humanoid
        end
        --
        Library.UI.Viewing = not Library.UI.Viewing
    end
    --
    function Library:GetTableLength(Table)
        local Length = 0
        --
        for Index, Value in pairs(Table) do
            Length += 1
        end
        --
        return Length
    end
    --
    function Library:ScrollingCheck(ScrollingFrame, Frame)
        if not ScrollingFrame:IsA("ScrollingFrame") then return true end
        --
        local VisibleTopLeft = ScrollingFrame.CanvasPosition
        local VisibleBottomRight = VisibleTopLeft + ScrollingFrame.AbsoluteWindowSize
        --
        local FrameTopLeft = Frame.AbsolutePosition - ScrollingFrame.AbsolutePosition + ScrollingFrame.CanvasPosition
        local FrameBottomRight = FrameTopLeft + Frame.AbsoluteSize
        --
        return FrameBottomRight.X > VisibleTopLeft.X and FrameTopLeft.X < VisibleBottomRight.X and FrameBottomRight.Y > VisibleTopLeft.Y and FrameTopLeft.Y < VisibleBottomRight.Y
    end
    --
    function Library:ClampPosition(Object, Position, Offset)
        local ClampedX = math.clamp(Position.X.Offset, Offset, Viewport.X - Object.AbsoluteSize.X - Offset)
        local ClampedY = math.clamp(Position.Y.Offset, Offset, Viewport.Y - Object.AbsoluteSize.Y - Offset)
        --
        return UDim2.new(Position.X.Scale, ClampedX, Position.Y.Scale, ClampedY)
    end
    --
    function Library:Fade(State, Table, MainUI, Speed)
        local IsMainUI = Table == Library.Objects
        --
        MainUI.Active = State
        --
        if State then
            MainUI.Visible = true
        end
        --
        if IsMainUI then
            Library.UI.Faded = not State
        end
        --  handle toggle transparency when fading out since im not using fade out for now as it causes fps issues
        if not State and IsMainUI then
            -- find all toggle elements and force them transparent immediately instead of waiting since some things may not leave instantly
            for _, obj in pairs(MainUI:GetDescendants()) do
                if obj.ClassName == "Frame" then
                    if obj.Name == "ToggleMain" then
                        obj.BackgroundTransparency = 1
                    end
                end
            end
        end
        --
        for _, Object in Table do
            if not Object[3] then
                if Object[1].ClassName == "Frame" and (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                    -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1})
                    Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                elseif Object[1].ClassName == "ImageLabel" or Object[1].ClassName == "ImageButton" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1})
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    --
                    if (Object[2]["ImageTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1})
                        Object[1].ImageTransparency = State and (Object[2]["ImageTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "TextLabel" or Object[1].ClassName == "TextButton" or Object[1].ClassName == "TextBox" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1})
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    --
                    if (Object[2]["TextTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1})
                        Object[1].TextTransparency = State and (Object[2]["TextTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "ScrollingFrame" then
                    if (Object[2]["BackgroundTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1})
                        Object[1].BackgroundTransparency = State and (Object[2]["BackgroundTransparency"] or 0) or 1
                    end
                    --
                    if (Object[2]["ScrollBarImageTransparency"] or 0) ~= 1 then
                        -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {ScrollBarImageTransparency = State and (Object[2]["ScrollBarImageTransparency"] or 0) or 1})
                        Object[1].ScrollBarImageTransparency = State and (Object[2]["ScrollBarImageTransparency"] or 0) or 1
                    end
                elseif Object[1].ClassName == "UIStroke" then
                    -- Library:TweenObject(Object[1], TweenInfo.new(Speed, Enum.EasingStyle.Linear, State and Enum.EasingDirection["Out"] or Enum.EasingDirection["In"]), {Transparency = State and (Object[2]["Transparency"] or 0) or 1})
                    Object[1].Transparency = State and (Object[2]["Transparency"] or 0) or 1
                end
            end
        end
        --
        if not State then
            task.delay(Speed, function()
                if not MainUI.Parent then return end
                MainUI.Visible = false
            end)
        end
    end
    --
    function Library:CheckFrameFirst(FrameA, FrameB)
        local Parent = FrameA.Parent
        local Frames = {}
        local IndexA, IndexB
        --
        for _, Child in Parent:GetChildren() do
            if Child:IsA("Frame") then
                table.insert(Frames, Child)
            end
        end
        --
        table.sort(Frames, function(a, b)
            if a.LayoutOrder == b.LayoutOrder then
                for _, Child in Parent:GetChildren() do
                    if Child == a then return true end
                    if Child == b then return false end
                end
            end
            --
            return a.LayoutOrder < b.LayoutOrder
        end)
        --
        for i, Frame in Frames do
            if Frame == FrameA then IndexA = i end
            if Frame == FrameB then IndexB = i end
        end
        --
        return IndexA and IndexB and IndexA < IndexB
    end
    --
    function Library:Resizable(Object, DragFrame, MinResize, MaxResize, Increments, UseIcon, UseParent, Delay)
        local StartingSize, ObjectSize, Dragging, MouseLocation, PerformanceDragUI, NewMouse, Hovering
        -- 触摸设备上 GetMouseLocation 不一定跟随手指，改为跟踪最近一次输入位置
        local CurrentInputPos
        --
        local function UpdateSize()
            if not MouseLocation or not CurrentInputPos then return end
            --
            Library.UI.Resizing = true
            --
            local CurrentMousePosition = CurrentInputPos
            local Delta = CurrentMousePosition - MouseLocation
            local NewSizeX = StartingSize.X.Offset + Delta.X
            local NewSizeY = StartingSize.Y.Offset + Delta.Y
            local Parent = Object.Parent
            local ParentSize = Parent.AbsoluteSize
            --
            if UseParent then
                local OccupiedSpaceY = 0
                local FrameCount = 0
                --
                for _, Child in Parent:GetChildren() do
                    if Child:IsA("Frame") and Child ~= Object then
                        FrameCount += 1
                        --
                        if Library:CheckFrameFirst(Object, Child) then
                            if Child.AbsoluteSize.Y >= (ParentSize.Y - Object.AbsoluteSize.Y) - 57 then
                                Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (ParentSize.Y - Object.AbsoluteSize.Y) - 57))
                            end
                        else
                            OccupiedSpaceY += Child.AbsoluteSize.Y + 19
                        end
                    end
                end
                --
                if OccupiedSpaceY == 0 then
                    MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - (FrameCount * (50 + 19)) - 38)
                else
                    MaxResize = UDim2.new(0, 0, 0, (ParentSize.Y - OccupiedSpaceY) - 38)
                end
            end
            --
            if Increments then
                NewSizeY = math.clamp(math.round(NewSizeY / Increments) * Increments, MinResize.Y.Offset, MaxResize.Y.Offset)
            else
                NewSizeY = math.clamp(NewSizeY, MinResize.Y.Offset, MaxResize.Y.Offset)
                NewSizeX = math.clamp(NewSizeX, MinResize.X.Offset, MaxResize.X.Offset)
            end
            --
            return UseParent and UDim2.new(1, 0, 0, NewSizeY) or UDim2.new(0, NewSizeX, 0, NewSizeY)
        end
        
        --
        Library:Connection(DragFrame.MouseEnter, function()
            Hovering = true
        end)
        --
        Library:Connection(DragFrame.MouseLeave, function()
            if NewMouse then NewMouse:Destroy() NewMouse = nil end
            --
            UserInputService.MouseIconEnabled = true
            Hovering = false
        end)
        --
        Library:Connection(DragFrame.InputBegan, function(Input)
            if Library:IsClickInput(Input) then
                Dragging = true
                MouseLocation = Vector2.new(Input.Position.X, Input.Position.Y)
                CurrentInputPos = MouseLocation
                StartingSize = Object.Size
                --
                Library.UI.Resizing = true
            end
        end)
        --
        Library:Connection(UserInputService.InputChanged, function(Input)
            if Library:IsMoveInput(Input) then
                CurrentInputPos = Vector2.new(Input.Position.X, Input.Position.Y)
            end
        end)
        --
        Library:Connection(RunService.PreRender, function()
            if (Hovering or Dragging) and UseIcon then
                local MousePosition = UserInputService:GetMouseLocation()
                --
                UserInputService.MouseIconEnabled = false
                --
                if not NewMouse then
                    NewMouse = Library:CreateObject("ImageLabel", {
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Image = "rbxassetid://87982048533100",
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Name = "Transparency",
                        Size = UDim2.new(0, 35, 0, 35),
                        ZIndex = 10000,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = Library.UI.ScreenGUI
                    }, true)
                end
                --
                NewMouse.Position = UDim2.new(0, MousePosition.X, 0, MousePosition.Y)
            end
            --
            if Dragging then
                if Delay then task.delay(Delay, function()
                        Object.Size = UpdateSize()
                    end)
                else
                    Object.Size = UpdateSize()
                end
            end
        end)
        --
        Library:Connection(UserInputService.InputEnded, function(Input)
            if Library:IsReleaseInput(Input) and Dragging then
                if NewMouse then NewMouse:Destroy() NewMouse = nil end
                --
                if UseParent then
                    for _, Child in Object.Parent:GetChildren() do
                        if Child:IsA("Frame") and Child ~= Object then
                            if Library:CheckFrameFirst(Object, Child) then
                                if Child.AbsoluteSize.Y >= (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57 then
                                    Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (Object.Parent.AbsoluteSize.Y - Object.AbsoluteSize.Y) - 57))
                                end
                            end
                        end
                    end
                end
                --
                UserInputService.MouseIconEnabled = true
                Dragging = false
                Library.UI.Resizing = false
            end
        end)
    end
    --
    Library.__index = Library
    Library.Sections.__index = Library.Sections
    --
    local Sections = Library.Sections
    --
    function Library:ColorPicker(Options)
        Options = Library:Validate({
            Name = "Preview Color Picker",
            Default = Library.Theme.Default.Accent,
            Alpha = 0,
            AlphaBar = true,
            Parent = nil,
            MainUI = nil,
            TabUI = nil,
            Count = 1,
            Keybind = false,
            Flag = Library:NewFlag(),
            Callback = function() end,
        }, Options or {})
        --
        local Hue, Saturation, Value = Options.Default:ToHSV()
        --
        local ColorPicker = {
            Hover = false,
            Active = false,
            MouseDown = false,
            MainFrameHover = false,
            Color = Options.Default,
            SecondColor = Color3.fromRGB(math.max(math.floor(Options.Default.R * 255) - 14, 0), math.max(math.floor(Options.Default.G * 255) - 14, 0), math.max(math.floor(Options.Default.B * 255) - 14, 0)),
            Saturation = {Saturation, Value},
            Alpha = Options.Alpha,
            Hue = Hue,
            ActiveFrame = false,
            LastCopiedColor = {self.Color, self.Alpha},
            FrameOpened = false,
        }
        --
        Library.Flags[Options.Flag] = ColorPicker
        --
        Library.UI.TotalColorPickers += 1
        --
        if Options.Keybind then
            Options.Count += 1
        end
        --
        local ColorPickerOutline_1 = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(1, 0),
            Name = "ColorPickerOutline" .. Library.UI.TotalColorPickers,
            Position = UDim2.new(1, 0 - (Options.Count - 1) * 22, 0, 0),
            Size = UDim2.new(0, 17, 0, 9),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = Options.Parent
        })
        --
        local ColorPickerChecker = Library:CreateObject("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 4),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false,
            BorderSizePixel = 0,
            Parent = ColorPickerOutline_1
        })
        --
        local Button_9 = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_9",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ColorPickerOutline_1
        })
        --
        local ColorPickerTransparency = Library:CreateObject("ImageLabel", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Image = "rbxassetid://18249241978",
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Name = "Transparency",
            Size = UDim2.new(1, -2, 1, -2),
            Position = UDim2.new(0, 1, 0, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 6, 0, 6),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ColorPickerOutline_1
        })
        --
        local ColorPickerInline_1 = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ColorPickerInline_1",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ColorPickerOutline_1
        })
        --
        local UIGradient_24 = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, ColorPicker.Color),
                ColorSequenceKeypoint.new(1, ColorPicker.SecondColor)
            },
            Parent = ColorPickerInline_1
        })
        --
        do -- Functions
            function ColorPicker:SetVisible(Bool)
                ColorPickerOutline_1.Visible = Bool
                --
                if Bool == false then
                    ColorPicker:RemoveFrame()
                end
            end
            --
            function ColorPicker:AddFrame()
                Library.UI.CurrentSelectedColorPicker = {ColorPicker = ColorPicker, ColorPickerOutline = ColorPickerOutline_1, Parent = Options.Parent}
                --
                Library.UI.OpenColorFrames += 1
                --
                local ColorPickerOutline = Library:CreateObject("Frame", {
                    Size = UDim2.new(0, 180, 0, 175),
                    Name = "ColorPickerFrame" .. Library.UI.TotalColorPickers,
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Library.UI.ScreenGUI
                })
                --
                ColorPickerOutline.BackgroundTransparency = 1
                --
                local ColorPickerInline = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "ColorPickerInline",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                    Parent = ColorPickerOutline
                })
                --
                ColorPickerInline.BackgroundTransparency = 1
                --
                local ColorPickerMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "ColorPickerMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Parent = ColorPickerInline
                })
                --
                ColorPickerMain.BackgroundTransparency = 1
                --
                local MainPicker = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -24, 1, -19),
                    Name = "MainPicker",
                    Position = UDim2.new(0, 2, 0, 2),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = ColorPickerMain
                })
                --
                MainPicker.BackgroundTransparency = 1
                --
                local Button_91 = Library:CreateObject("TextButton", {
                    FontFace = Library.UI.NewFont,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_9",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    ZIndex = 250,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = MainPicker
                })
                --
                local MainPickerColor = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "MainPickerColor",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = MainPicker
                })
                --
                MainPickerColor.BackgroundTransparency = 1
                --
                local UIGradient_20 = Library:CreateObject("UIGradient", {
                    Rotation = 180,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    },
                    Parent = MainPickerColor
                })
                --
                local BackImage = Library:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Image = "rbxassetid://13966897785",
                    BackgroundTransparency = 1,
                    Name = "BackImage",
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Parent = MainPickerColor
                })
                --
                BackImage.ImageTransparency = 1
                --
                local DraggingMainOutline = Library:CreateObject("Frame", {
                    Size = UDim2.new(0, 4, 0, 4),
                    Name = "DraggingMainOutline",
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = MainPicker
                })
                --
                DraggingMainOutline.BackgroundTransparency = 1
                --
                local DraggingMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "DraggingMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = DraggingMainOutline
                })
                --
                DraggingMain.BackgroundTransparency = 1
                --
                local SaturationSlider = Library:CreateObject("Frame", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    AnchorPoint = Vector2.new(0, 1),
                    Name = "SaturationSlider",
                    Position = UDim2.new(0, 2, 1, -2),
                    Size = UDim2.new(1, -24, 0, 12),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = ColorPickerMain
                })
                --
                SaturationSlider.BackgroundTransparency = 1
                --
                local Button_915241 = Library:CreateObject("TextButton", {
                    FontFace = Library.UI.NewFont,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_9",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    ZIndex = 250,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SaturationSlider
                })
                --
                local SaturationColor = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "SaturationColor",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SaturationSlider
                })
                --
                SaturationColor.BackgroundTransparency = 1
                --
                local UIGradient_21 = Library:CreateObject("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                    },
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0.10000000149011612),
                        NumberSequenceKeypoint.new(0.5, 0.800000011920929),
                        NumberSequenceKeypoint.new(1, 1)
                    },
                    Rotation = 180,
                    Parent = SaturationColor
                })
                --
                local BackImage_1 = Library:CreateObject("ImageLabel", {
                    ScaleType = Enum.ScaleType.Tile,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "BackImage_1",
                    TileSize = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://18249241978",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Parent = SaturationSlider
                })
                --
                BackImage_1.ImageTransparency = 1
                --
                local DraggingSatOutline = Library:CreateObject("Frame", {
                    Size = UDim2.new(0, 4, 1, 0),
                    Name = "DraggingSatOutline",
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = SaturationSlider
                })
                --
                DraggingSatOutline.BackgroundTransparency = 1
                --
                local DraggingSatMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "DraggingSatMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = DraggingSatOutline
                })
                --
                DraggingSatMain.BackgroundTransparency = 1
                --
                local HueSlider = Library:CreateObject("Frame", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    Name = "HueSlider",
                    Position = UDim2.new(1, -2, 0, 2),
                    Size = UDim2.new(0, 17, 1, -19),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = ColorPickerMain
                })
                --
                HueSlider.BackgroundTransparency = 1
                --
                local Button_9141 = Library:CreateObject("TextButton", {
                    FontFace = Library.UI.NewFont,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_9",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    ZIndex = 250,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = HueSlider
                })
                --
                local BackImage_2 = Library:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "BackImage_2",
                    TileSize = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://8180989234",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 1, 0, 1),
                    Size = UDim2.new(1, -2, 1, -2),
                    ZIndex = 250,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Parent = HueSlider
                })
                --
                BackImage_2.ImageTransparency = 1
                --
                local DraggingHueOutline = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, 0, 0, 4),
                    Name = "DraggingHueOutline",
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = HueSlider
                })
                --
                DraggingHueOutline.BackgroundTransparency = 1
                --
                local DraggingHueMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "DraggingHueMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 251,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = DraggingHueOutline
                })
                --
                DraggingHueMain.BackgroundTransparency = 1
                --
                do -- Functions
                    function ColorPicker:UpdateSize()
                        ColorPickerOutline.Position = UDim2.new(0, ColorPickerOutline_1.AbsolutePosition.X, 0, (ColorPickerOutline_1.AbsolutePosition.Y + ColorPickerOutline_1.AbsoluteSize.Y + GuiService:GetGuiInset().Y + 2))
                    end
                    --
                    ColorPicker:UpdateSize()
                    --
                    Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), ColorPicker.UpdateSize)
                    --
                    local StartingY = ColorPickerOutline_1.AbsolutePosition.Y
                    local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
                    local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
                    --
                    Library:Connection(ColorPickerOutline_1:GetPropertyChangedSignal("AbsolutePosition"), function()
                        local CurrentY = ColorPickerOutline_1.AbsolutePosition.Y
                        local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                        local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                        --
                        if MainUICurrentY ~= MainUIStartingY then
                            MainUIStartingY = MainUICurrentY
                            StartingY = CurrentY
                            --
                            return
                        end
                        --
                        if CurrentCanvasPosition ~= StartingCanvasPosition then
                            StartingCanvasPosition = CurrentCanvasPosition
                            StartingY = CurrentY
                            --
                            return
                        end
                        --
                        if Library.UI.Resizing then
                            return
                        end
                        --
                        if CurrentY ~= StartingY then
                            ColorPicker:RemoveFrame(true)
                        end
                        --
                        StartingY = CurrentY
                    end)
                    --
                    Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                        if ColorPicker.Active then
                            ColorPickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                        end
                        --
                        ColorPicker:UpdateSize()
                    end)
                    --
                    if Options.Parent.Parent:IsA("ScrollingFrame") then
                        Library:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                            ColorPicker:UpdateSize()
                            --
                            if ColorPicker.Active then
                                ColorPickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                            end
                        end)
                    end
                    --
                    Library:Connection(Options.MainUI:GetPropertyChangedSignal("Visible"), function()
                        if not Options.MainUI.Visible then
                            ColorPickerOutline.Visible = false
                        else
                            ColorPickerOutline.Visible = ColorPicker.Active
                        end
                    end)
                    --
                    Library:Connection(Options.Parent.Parent:GetPropertyChangedSignal("Visible"), function()
                        if not Options.Parent.Parent.Visible then
                            ColorPickerOutline.Visible = false
                        else
                            ColorPickerOutline.Visible = ColorPicker.Active
                        end
                    end)
                    --
                    function ColorPicker:Update()
                        ColorPicker.Color = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Saturation[1], ColorPicker.Saturation[2])
                        ColorPicker.SecondColor = Color3.fromRGB(math.max(math.floor(ColorPicker.Color.R * 255) - 23, 0), math.max(math.floor(ColorPicker.Color.G * 255) - 23, 0), math.max(math.floor(ColorPicker.Color.B * 255) - 23, 0))
                        --
                        UIGradient_24.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, ColorPicker.SecondColor)}
                        UIGradient_20.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}
                        UIGradient_21.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, ColorPicker.Color), ColorSequenceKeypoint.new(1, ColorPicker.Color)}
                        UIGradient_20.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromHSV(ColorPicker.Hue, 1, 1)), ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))}
                        --
                        local MaxSaturationX = math.max(0, MainPickerColor.AbsoluteSize.X - DraggingMainOutline.AbsoluteSize.X) / MainPickerColor.AbsoluteSize.X
                        local MaxSaturationY = math.max(0, MainPickerColor.AbsoluteSize.Y - DraggingMainOutline.AbsoluteSize.Y) / MainPickerColor.AbsoluteSize.Y
                        local MaxAlpha = math.max(0, SaturationColor.AbsoluteSize.X - DraggingSatOutline.AbsoluteSize.X) / SaturationColor.AbsoluteSize.X
                        local MaxHue = math.max(0, BackImage_2.AbsoluteSize.Y - DraggingHueOutline.AbsoluteSize.Y) / BackImage_2.AbsoluteSize.Y
                        --
                        Library:TweenObject(DraggingMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.fromScale(math.clamp(ColorPicker.Saturation[1], 0, MaxSaturationX), math.clamp(1 - ColorPicker.Saturation[2], 0, MaxSaturationY))})
                        Library:TweenObject(DraggingSatOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(math.clamp(1 - ColorPicker.Alpha, 0, MaxAlpha), 0, 0, 0)})
                        Library:TweenObject(DraggingHueOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, math.clamp(ColorPicker.Hue, 0, MaxHue), 0)})
                        --
                        DraggingMain.BackgroundColor3 = ColorPicker.Color
                        DraggingSatMain.BackgroundColor3 = ColorPicker.Color
                        DraggingHueMain.BackgroundColor3 = ColorPicker.Color
                        ColorPickerInline_1.BackgroundTransparency = ColorPicker.Alpha
                        UIGradient_21.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.304 + (0.604 - 0.304) * ColorPicker.Alpha), NumberSequenceKeypoint.new(0.5, 0.7), NumberSequenceKeypoint.new(1, 1)}
                        --
                        Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                        Library.Flags[Options.Flag] = ColorPicker
                    end
                    --
                    function ColorPicker:Set(Color, Transparency)
                        if typeof(Color) == "table" then
                            ColorPicker.Color = Color3.fromHSV(Color[1], Color[2], Color[3])
                            ColorPicker.Alpha = Color[4]
                            ColorPicker.Hue = Color[1]
                            ColorPicker.Saturation[1] = Color[2]
                            ColorPicker.Saturation[2] = Color[3]
                            ColorPicker:Update()
                            Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                        elseif typeof(Color) == "Color3" then
                            local h, s, v = Color:ToHSV()
                            --
                            ColorPicker.Color = Color3.fromHSV(h, s, v)
                            ColorPicker.Alpha = Transparency or 1
                            ColorPicker.Hue = h
                            ColorPicker.Saturation[1] = s
                            ColorPicker.Saturation[2] = v
                            ColorPicker:Update()
                            Options.Callback(ColorPicker.Color, ColorPicker.Alpha)
                        end
                    end
                    --
                    function ColorPicker:Get()
                        return {Color = ColorPicker.Color, Transparency = ColorPicker.Alpha}
                    end
                    --
                    function ColorPicker:UpdateHue(Percentage)
                        local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
                        --
                        ColorPicker.Hue = Percentage
                        --
                        ColorPicker:Update()
                    end
                    --
                    function ColorPicker:UpdateAlpha(Percentage)
                        local Percentage = typeof(Percentage == "number") and math.clamp(Percentage, 0, 1) or 0
                        --
                        ColorPicker.Alpha = Percentage
                        --
                        ColorPicker:Update()
                    end
                    --
                    function ColorPicker:UpdateSaturation(PercentageX, PercentageY)
                        local PercentageX = typeof(PercentageX == "number") and math.clamp(PercentageX, 0, 1) or 0
                        local PercentageY = typeof(PercentageY == "number") and math.clamp(PercentageY, 0, 1) or 0
                        --
                        ColorPicker.Saturation[1] = PercentageX
                        ColorPicker.Saturation[2] = 1 - PercentageY
                        --
                        ColorPicker:Update()
                    end
                end
                --
                do -- Connections
                    Library:Connection(Button_91.InputBegan, function(Input)
                        if Library:IsClickInput(Input) then
                            Library.UI.DraggingGui = MainPickerColor
                            --
                            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                            local Percentage = (InputPosition - MainPickerColor.AbsolutePosition) / MainPickerColor.AbsoluteSize
                            --
                            ColorPicker:UpdateSaturation(Percentage.X, Percentage.Y)
                        end
                    end)
                    --
                    Library:Connection(Button_915241.InputBegan, function(Input)
                        if Library:IsClickInput(Input) then
                            Library.UI.DraggingGui = SaturationColor
                            --
                            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                            local GuiPosition = SaturationColor.AbsolutePosition.X
                            local GuiSize = SaturationColor.AbsoluteSize.X
                            local Percentage = ((GuiPosition + GuiSize - InputPosition.X) / GuiSize)
                            --
                            ColorPicker:UpdateAlpha(Percentage)
                        end
                    end)
                    --
                    Library:Connection(Button_9141.InputBegan, function(Input)
                        if Library:IsClickInput(Input) then
                            Library.UI.DraggingGui = BackImage_2
                            --
                            local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                            local Percentage = (InputPosition - BackImage_2.AbsolutePosition) / BackImage_2.AbsoluteSize
                            --
                            ColorPicker:UpdateHue(Percentage.Y)
                        end
                    end)
                    --
                    Library:Connection(UserInputService.InputChanged, function(Input)
                        if (Library.UI.DraggingGui ~= SaturationColor and Library.UI.DraggingGui ~= MainPickerColor and Library.UI.DraggingGui ~= BackImage_2) then return end
                        --
                        -- 触摸时 IsMouseButtonPressed 恒 false，改用统一按下判定（含触摸计数）
                        if not (Library:IsInputDown()) then
                            Library.UI.DraggingGui = nil
                            return
                        end
                        --
                        local InputPosition = Vector2.new(Input.Position.X, Input.Position.Y)
                        --
                        -- MouseMovement 或 Touch（手指拖动色板）
                        if Library:IsMoveInput(Input) then
                            if Library.UI.DraggingGui == MainPickerColor then
                                local Percentage = (InputPosition - MainPickerColor.AbsolutePosition) / MainPickerColor.AbsoluteSize
                                --
                                ColorPicker:UpdateSaturation(Percentage.X, Percentage.Y)
                            end
                            --
                            if Library.UI.DraggingGui == SaturationColor then
                                local GuiPosition = SaturationColor.AbsolutePosition.X
                                local GuiSize = SaturationColor.AbsoluteSize.X
                                local Percentage = ((GuiPosition + GuiSize - InputPosition.X) / GuiSize)
                                --
                                ColorPicker:UpdateAlpha(Percentage)
                            end
                            --
                            if Library.UI.DraggingGui == BackImage_2 then
                                local Percentage = (InputPosition - BackImage_2.AbsolutePosition) / BackImage_2.AbsoluteSize
                                --
                                ColorPicker:UpdateHue(Percentage.Y)
                            end
                        end
                    end)
                end
                --
                ColorPicker:Update()
                Library:Fade(true, Library:GetObjectsTable(ColorPickerOutline, true), ColorPickerOutline, 0.1)
            end
            --
            function ColorPicker:RemoveFrame(Fast)
                local Fast = Fast or false
                --
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "ColorPickerFrame" .. Library.UI.TotalColorPickers then
                        if Fast then
                            Value:Destroy()
                        else
                            Library:Fade(false, Library:GetObjectsTable(Value, true), Value, 0.1)
                            --
                            task.delay(Library.UI.TweenSpeed, function()
                                Value:Destroy()
                            end)
                        end
                    end
                end
            end
            --
            function ColorPicker:FindFrame()
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "ColorPickerFrame" .. Library.UI.TotalColorPickers then
                        return true
                    end
                end
                --
                return false
            end
            --
            function ColorPicker:Toggle()
                if Library.UI.CurrentSelectedColorPicker and Library.UI.CurrentSelectedColorPicker.ColorPickerOutline.Name ~= ColorPickerOutline_1.Name then
                    Library.UI.CurrentSelectedColorPicker.ColorPicker:RemoveFrame()
                end
                --
                if not ColorPicker:FindFrame() then
                    ColorPicker.Active = true
                    ColorPicker:AddFrame()
                else
                    ColorPicker.Active = false
                    ColorPicker:RemoveFrame()
                end
            end
            --
            function ColorPicker:AddOtherFrame()
                Library.UI.CurrentSelectedColorPickerExtra = {ColorPicker = ColorPicker, ColorPickerObject = ColorPickerOutline_1, Parent = Options.Parent}
                --
                local KeybindModePickerOutline = Library:CreateObject("Frame", {
                    Name = "ColorPickerOutline" .. Library.UI.TotalColorPickers,
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(0, 100, 0, 55),
                    BorderSizePixel = 0,
                    ZIndex = 25,
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Library.UI.ScreenGUI
                })
                --
                local KeybindModePickerMain = Library:CreateObject("Frame", {
                    Name = "KeybindModePickerMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = KeybindModePickerOutline
                })
                --
                KeybindModePickerOutline.BackgroundTransparency = 1
                KeybindModePickerMain.BackgroundTransparency = 1
                --
                local UIListLayout_9 = Library:CreateObject("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = KeybindModePickerMain
                })
                --
                function ColorPicker:UpdateSize()
                    KeybindModePickerOutline.Position = UDim2.new(0, ColorPickerOutline_1.AbsolutePosition.X - 2, 0, ColorPickerOutline_1.AbsolutePosition.Y + ColorPickerOutline_1.AbsoluteSize.Y + KeybindModePickerOutline.AbsoluteSize.Y - 4)
                end
                --
                ColorPicker:UpdateSize()
                --
                Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), ColorPicker.UpdateSize)
                --
                local StartingY = ColorPickerOutline_1.AbsolutePosition.Y
                local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
                local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
                --
                Library:Connection(ColorPickerOutline_1:GetPropertyChangedSignal("AbsolutePosition"), function()
                    local CurrentY = ColorPickerOutline_1.AbsolutePosition.Y
                    local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                    local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                    --
                    if MainUICurrentY ~= MainUIStartingY then
                        MainUIStartingY = MainUICurrentY
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if CurrentCanvasPosition ~= StartingCanvasPosition then
                        StartingCanvasPosition = CurrentCanvasPosition
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if Library.UI.Resizing then
                        return
                    end
                    --
                    if CurrentY ~= StartingY then
                        ColorPicker:RemoveOtherFrame(true)
                    end
                    --
                    StartingY = CurrentY
                end)
                --
                Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                    if ColorPicker.ActiveFrame then
                        KeybindModePickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                    end
                    --
                    ColorPicker:UpdateSize()
                end)
                --
                if Options.Parent.Parent:IsA("ScrollingFrame") then
                    Library:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                        ColorPicker:UpdateSize()
                        --
                        if ColorPicker.ActiveFrame then
                            KeybindModePickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, ColorPickerChecker)
                        end
                    end)
                end
                --
                for Index, Value in {"Copy", "Paste", "Reset"} do
                    local ModeItem = {
                        Active = false,
                        Hovering = false,
                    }
                    --
                    local Inactive = Library:CreateObject("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(208, 208, 208),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = Value,
                        Text = Value,
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, 0, 0, 17),
                        BorderSizePixel = 0,
                        TextSize = Library.UI.FontSize,
                        ZIndex = 25,
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Parent = KeybindModePickerMain
                    })
                    --
                    local Button_4 = Library:CreateObject("TextButton", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Button_4",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        TextTransparency = 1,
                        TextSize = Library.UI.FontSize,
                        ZIndex = 25,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = Inactive
                    })
                    --
                    local UIPadding_48 = Library:CreateObject("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        Parent = Inactive
                    })
                    --
                    Inactive.TextTransparency = 1
                    --
                    do -- Functions
                        function ModeItem:Activate()
                            if not ModeItem.Active then
                                ModeItem.Active = true
                                --
                                Inactive.Text = "<b>" .. Value .. "</b>"
                                Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Library.Theme.Default.Accent})
                                --
                                if Value == "Copy" then
                                    Library.UI.LastCopiedColor = {Color = ColorPicker.Color, Alpha = ColorPicker.Alpha}
                                elseif Value == "Paste" then
                                    if Library.UI.LastCopiedColor then
                                        ColorPicker:Set(Library.UI.LastCopiedColor.Color, Library.UI.LastCopiedColor.Alpha)
                                    end
                                elseif Value == "Reset" then
                                    ColorPicker:Set(Options.Default, Options.Alpha)
                                end
                                --
                                ColorPicker:RemoveOtherFrame()
                            end
                        end
                        --
                        function ModeItem:Deactivate()
                            if ModeItem.Active then
                                ModeItem.Active = false
                                ModeItem.Hovering = false
                                Inactive.Text = Value
                                Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                            end
                        end
                    end
                    --
                    do -- Connections
                        Library:OnClick(Button_4, function()
                            ModeItem:Activate()
                        end)
                        --
                        Library:Connection(Inactive.MouseEnter, function()
                            Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            --
                            if ModeItem.Active then return end
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                        end)
                        --
                        Library:Connection(Inactive.MouseLeave, function()
                            Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            --
                            if ModeItem.Active then return end
                            --
                            Inactive.Text = Value
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        end)
                    end
                end
                --
                Library:Fade(true, Library:GetObjectsTable(KeybindModePickerOutline, true), KeybindModePickerOutline, 0.1)
            end
            --
            function ColorPicker:RemoveOtherFrame(Fast)
                local Fast = Fast or false
                --
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "ColorPickerOutline" .. Library.UI.TotalColorPickers then
                        if Fast then
                            Value:Destroy()
                        else
                            Library:Fade(false, Library:GetObjectsTable(Value, true), Value, 0.1)
                            --
                            task.delay(Library.UI.TweenSpeed, function()
                                Value:Destroy()
                            end)
                        end
                    end
                end
            end
            --
            function ColorPicker:FindOtherFrame()
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "ColorPickerOutline" .. Library.UI.TotalColorPickers then
                        return true
                    end
                end
                --
                return false
            end
            --
            function ColorPicker:ToggleOtherFrame()
                if Library.UI.CurrentSelectedColorPickerExtra and Library.UI.CurrentSelectedColorPickerExtra.ColorPickerObject.Name ~= ColorPickerOutline_1.Name then
                    Library.UI.CurrentSelectedColorPickerExtra.ColorPicker:RemoveFrame()
                end
                --
                if not ColorPicker:FindOtherFrame() then
                    ColorPicker.ActiveFrame = true
                    ColorPicker:AddOtherFrame()
                else
                    ColorPicker.ActiveFrame = false
                    ColorPicker:RemoveOtherFrame()
                end
            end
        end
        --
        do -- Connections
            Library:Connection(Button_9.MouseButton2Click, function()
                ColorPicker:ToggleOtherFrame()
            end)
            --
            Library:OnClick(Button_9, function()
                ColorPicker:Toggle()
            end)
        end
        --
        ColorPicker:AddFrame()
        ColorPicker:Update()
        ColorPicker:RemoveFrame()
        --
        return ColorPicker
    end
    --
    function Library:Keybind(Options)
        Options = Library:Validate({
            Default = Enum.KeyCode.Backspace,
            Mode = "Toggle",
            UseMode = true,
            HideFromList = false,
            Blacklisted = {},
            Parent = nil,
            Toggle = nil,
            MainUI = nil,
            Hiding = false,
            ToggleState = false,
            Flag = Library.NewFlag(),
            Count = 1,
            ChangeToggle = false,
            Callback = function() end,
        }, Options or {})
        --
        if Options.Toggle == nil then return end
        --
        local Keybind = {
            Hover = false,
            ActiveFrame = false,
            Keybind = Options.Default,
            RegKeybind = nil,
            State = false,
            SelectingKeybind = false,
            Toggle = false,
            -- 关联的功能开关本体：快捷键列表 HUD 用它取名称和开启状态
            Owner = Options.Toggle,
            Connection = nil,
            Mode = Options.Mode,
            ConfigKeybind = nil,
            Current = {},
            CurrentMode = nil,
            Hiding = false,
        }
        --
        Library.Flags[Options.Flag] = Keybind
        -- 键位注册表：快捷键列表 HUD 遍历这里（登记制，替代 Flags 类型嗅探）
        Library.KeybindList = Library.KeybindList or {}
        table.insert(Library.KeybindList, Keybind)
        Library.UI.TotalKeybindModes += 1
        --
        local KeybindObject = Library:CreateObject("TextLabel", {
            FontFace = Font.new("rbxassetid://12187371840", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(117, 117, 117),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = "[-]",
            Name = "KeybindOutline" .. Library.UI.TotalKeybindModes,
            AnchorPoint = Vector2.new(1, 0),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 16, 0, 7),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0 - (Options.Count - 1) * 22, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 3,
            TextStrokeTransparency = 0,
            TextSize = 9,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local KeybindChecker = Library:CreateObject("Frame", {
            Position = UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false,
            BorderSizePixel = 0,
            Parent = KeybindObject
        })
        --
        local Button_4 = Library:CreateObject("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_4",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = KeybindObject
        })
        --
        local UserInputTypeBinds = {"MouseButton1", "MouseButton2", "MouseButton3"}
        --
        do -- Functions
            function Keybind:SetVisible(Bool)
                Keybind.Hiding = not Bool
                --
                Library:SetRowVisible(KeybindObject, Bool)
            end
            --
            function Keybind:Set(Key)
                if Keybind.Hiding then return end
                if typeof(Key) == "boolean" then return end
                --
                -- 兼容 GetConfig 的保存格式 {Key = 键位, State = 开关状态, Mode = 触发模式}：
                -- 恢复键位的同时把关联的功能开关状态、触发模式一并还原
                if typeof(Key) == "table" and Key.Key ~= nil then
                    local RestoreState = typeof(Key.State) == "boolean" and Key.State or nil
                    local RestoreMode = typeof(Key.Mode) == "string" and Key.Mode or nil
                    local RestoreToggle = Keybind.Toggle
                    --
                    Key = Key.Key
                    --
                    if RestoreState ~= nil and RestoreToggle and RestoreToggle.Set then
                        task.defer(function()
                            -- 先恢复触发模式再恢复开关状态，保证状态按新模式生效
                            if RestoreMode and Keybind.SetMode then
                                pcall(function() Keybind:SetMode(RestoreMode) end)
                            end
                            --
                            if Keybind.Toggle and Keybind.Toggle.GetState and Keybind.Toggle:GetState() ~= RestoreState then
                                if RestoreToggle.ToggleGUI then
                                    Keybind:Toggle(RestoreState)
                                else
                                    RestoreToggle:Set(RestoreState)
                                end
                            end
                        end)
                    end
                end
                --
                if typeof(Key) == "EnumItem" then
                    Keybind.RegKeybind = Key
                elseif typeof(Key) == "string" then
                    if table.find(UserInputTypeBinds, Key) then
                        Keybind.RegKeybind = Enum.UserInputType[Key]
                        Key = Enum.UserInputType[Key]
                    else
                        Keybind.RegKeybind = Enum.KeyCode[Key]
                        Key = Enum.KeyCode[Key]
                    end
                end
                --
                if typeof(Key) == "string" then
                    if Key:find("KEY") then
                        Key = Enum.KeyCode[Key:gsub("KEY_", "")]
                    elseif Key:find("Input") then
                        Key = Enum.UserInputType[Key:gsub("Input_", "")]
                    end
                end
                --
                local ValidKey = false
                local KeyString = ""
                --
                if table.find(Options.Blacklisted, Key) then
                    Key = nil
                end
                --
                if Key then
                    if ((Key.EnumType == Enum.KeyCode and UserInputService:GetStringForKeyCode(Key) ~= "") or Library.UI.Keys[Key]) then
                        ValidKey = true
                        KeyString = Library.UI.Keys[Key] or UserInputService:GetStringForKeyCode(Key)
                    end
                end
                --
                if ValidKey then
                    Keybind.Keybind = KeyString
                    KeybindObject.Text = "[" .. KeyString:upper() .. "]"
                    --
                    Options.Callback(Key)
                    Library.Flags[Options.Flag] = Keybind
                else
                    Keybind.Keybind = "[-]"
                    KeybindObject.Text = Keybind.Keybind
                end
                --
                Library:TweenObject(KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
                KeybindObject.Size = UDim2.new(0, KeybindObject.TextBounds.X + 2, 0, 7)
            end
            --
            function Keybind:Toggle(Bool)
                if Keybind.Hiding then return end
                --
                if Bool == nil then
                    Keybind.State = not Keybind.State
                else
                    Keybind.State = Bool
                end
                --
                if not Options.HideFromList then
                    if Keybind.State then
                        --Library:AddKeybindFrame(Keybind.Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                    else
                        --Library:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
                    end
                end
                --
                if Options.Toggle.GetFlag then
                    Library.Flags[Options.Toggle:GetFlag()] = Keybind
                end
                --
                if Options.ChangeToggle then
                    -- viuslaly toggle the UI element and update its state
                    Options.Toggle:Set(Keybind.State)
                else
                    Options.Toggle:GetCallback(Keybind.State)
                end
            end
            --
            task.delay(1, function()
                Keybind:Set(Options.Default)
            end)
            --
            function Keybind:Get()
                local KeyString = Keybind.RegKeybind.EnumType == Enum.KeyCode and tostring(Keybind.RegKeybind):match("^Enum%.KeyCode%.(.+)$") or tostring(Keybind.RegKeybind):match("^Enum%.UserInputType%.(.+)$")
                --
                return KeyString
            end
            --
            function Keybind:Active()
                return (Keybind.Keybind:lower() == "[-]" and true or Keybind.State)
            end
            --
            if Options.Mode == "Always on" then
                Keybind:Toggle(true)
            end
            --
            function Keybind:SetMode(Mode)
                Keybind.Mode = Mode
                --
                if Mode == "Always on" then
                    if Mode == "Always on" then
                        Keybind:Toggle(true)
                    end
                    --
                    if not Keybind.State then
                        Keybind.State = true
                        --
                        --Library:AddKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                    else
                        --Library:UpdateKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                    end
                elseif Mode == "Toggle" then
                    if Keybind.State then
                        --Library:UpdateKeybindFrame(Mode, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                    end
                elseif Mode == "On hotkey" then
                    Keybind.State = false
                    --
                    --Library:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
                end
            end
            --
            function Keybind:AddFrame()
                Library.UI.CurrentSelectedKeybindMode = {Keybind = Keybind, KeybindObject = KeybindObject, Parent = Options.Parent}
                --
                local KeybindModePickerOutline = Library:CreateObject("Frame", {
                    Name = "KeybindModePickerOutline" .. Library.UI.TotalKeybindModes,
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(0, 100, 0, 55),
                    BorderSizePixel = 0,
                    ZIndex = 25,
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Library.UI.ScreenGUI
                })
                --
                local KeybindModePickerMain = Library:CreateObject("Frame", {
                    Name = "KeybindModePickerMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    ZIndex = 25,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = KeybindModePickerOutline
                })
                --
                KeybindModePickerOutline.BackgroundTransparency = 1
                KeybindModePickerMain.BackgroundTransparency = 1
                --
                local UIListLayout_9 = Library:CreateObject("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = KeybindModePickerMain
                })
                --
                function Keybind:UpdateSize()
                    KeybindModePickerOutline.Position = UDim2.new(0, KeybindObject.AbsolutePosition.X , 0, KeybindObject.AbsolutePosition.Y + KeybindObject.AbsoluteSize.Y + KeybindModePickerOutline.AbsoluteSize.Y - 2)
                end
                --
                Keybind:UpdateSize()
                --
                Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsolutePosition"), Keybind.UpdateSize)
                --
                local StartingY = KeybindObject.AbsolutePosition.Y
                local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
                local StartingCanvasPosition = Options.Parent.Parent.CanvasPosition
                --
                Library:Connection(KeybindObject:GetPropertyChangedSignal("AbsolutePosition"), function()
                    local CurrentY = KeybindObject.AbsolutePosition.Y
                    local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                    local CurrentCanvasPosition = Options.Parent.Parent.CanvasPosition
                    --
                    if MainUICurrentY ~= MainUIStartingY then
                        MainUIStartingY = MainUICurrentY
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if CurrentCanvasPosition ~= StartingCanvasPosition then
                        StartingCanvasPosition = CurrentCanvasPosition
                        StartingY = CurrentY
                        --
                        return
                    end
                    --
                    if Library.UI.Resizing then
                        return
                    end
                    --
                    if CurrentY ~= StartingY then
                        Keybind:RemoveFrame(true)
                    end
                    --
                    StartingY = CurrentY
                end)
                --
                Library:Connection(Options.MainUI:GetPropertyChangedSignal("AbsoluteSize"), function()
                    if Keybind.ActiveFrame then
                        KeybindModePickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, KeybindChecker)
                    end
                    --
                    Keybind:UpdateSize()
                end)
                --
                Library:Connection(KeybindObject:GetPropertyChangedSignal("AbsoluteSize"), function()
                    Keybind:UpdateSize()
                end)
                --
                if Options.Parent.Parent:IsA("ScrollingFrame") then
                    Library:Connection(Options.Parent.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                        Keybind:UpdateSize()
                        --
                        if Keybind.ActiveFrame then
                            KeybindModePickerOutline.Visible = Library:ScrollingCheck(Options.Parent.Parent, KeybindChecker)
                        end
                    end)
                end
                --
                for Index, Value in {"Always on", "On hotkey", "Toggle"} do
                    local ModeItem = {
                        Active = false,
                        Hovering = false,
                    }
                    --
                    local Inactive = Library:CreateObject("TextLabel", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(208, 208, 208),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = Value,
                        Text = Value,
                        RichText = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Size = UDim2.new(1, 0, 0, 17),
                        BorderSizePixel = 0,
                        TextSize = Library.UI.FontSize,
                        ZIndex = 25,
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Parent = KeybindModePickerMain
                    })
                    --
                    local Button_4 = Library:CreateObject("TextButton", {
                        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Button_4",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        TextTransparency = 1,
                        TextSize = Library.UI.FontSize,
                        ZIndex = 25,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = Inactive
                    })
                    --
                    local UIPadding_48 = Library:CreateObject("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        Parent = Inactive
                    })
                    --
                    Inactive.TextTransparency = 1
                    --
                    do -- Functions
                        function ModeItem:Activate()
                            if not ModeItem.Active then
                                if Keybind.CurrentMode ~= nil then
                                    Keybind.CurrentMode:Deactivate()
                                end
                                --
                                ModeItem.Active = true
                                --
                                Keybind.Mode = Value
                                Keybind.CurrentMode = ModeItem
                                --
                                Inactive.Text = "<b>" .. Value .. "</b>"
                                Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Library.Theme.Default.Accent})
                                --
                                if Value == "Always on" then
                                    if Keybind.Mode == "Always on" then
                                        Keybind:Toggle(true)
                                    end
                                    --
                                    if not Keybind.State then
                                        Keybind.State = true
                                        --
                                        --Library:AddKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                    else
                                        --Library:UpdateKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                    end
                                elseif Value == "Toggle" then
                                    if Keybind.State then
                                        --Library:UpdateKeybindFrame(Value, Options.Toggle:GetName(), Keybind.Keybind, Options.Toggle:GetSection())
                                    end
                                elseif Value == "On hotkey" then
                                    Keybind.State = false
                                    --
                                    --Library:RemoveKeybindFrame(Options.Toggle:GetName(), Options.Toggle:GetSection())
                                end
                            end
                        end
                        --
                        function ModeItem:Deactivate()
                            if ModeItem.Active then
                                ModeItem.Active = false
                                ModeItem.Hovering = false
                                Inactive.Text = Value
                                Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                            end
                        end
                    end
                    --
                    do -- Connections
                        Library:OnClick(Button_4, function()
                            ModeItem:Activate()
                        end)
                        --
                        Library:Connection(Inactive.MouseEnter, function()
                            Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            --
                            if ModeItem.Active then return end
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                        end)
                        --
                        Library:Connection(Inactive.MouseLeave, function()
                            Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            --
                            if ModeItem.Active then return end
                            --
                            Inactive.Text = Value
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                        end)
                    end
                    --
                    if Value == Keybind.Mode then
                        ModeItem:Activate()
                    end
                end
                --
                Library:Fade(true, Library:GetObjectsTable(KeybindModePickerOutline, true), KeybindModePickerOutline, 0.1)
            end
            --
            function Keybind:RemoveFrame(Fast)
                local Fast = Fast or false
                --
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "KeybindModePickerOutline" .. Library.UI.TotalKeybindModes then
                        if Fast then
                            Value:Destroy()
                        else
                            Library:Fade(false, Library:GetObjectsTable(Value, true), Value, 0.1)
                            --
                            task.delay(Library.UI.TweenSpeed, function()
                                Value:Destroy()
                            end)
                        end
                    end
                end
            end
            --
            function Keybind:FindFrame()
                for Index, Value in Library.UI.ScreenGUI:GetChildren() do
                    if Value:IsA("Frame") and Value.Name == "KeybindModePickerOutline" .. Library.UI.TotalKeybindModes then
                        return true
                    end
                end
                --
                return false
            end
            --
            function Keybind:ToggleFrame()
                Library:TweenObject(KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(176, 176, 176)})
                --
                if Library.UI.CurrentSelectedKeybindMode and Library.UI.CurrentSelectedKeybindMode.KeybindObject.Name ~= KeybindObject.Name then
                    Library.UI.CurrentSelectedKeybindMode.Keybind:RemoveFrame()
                    --
                    Library:TweenObject(Library.UI.CurrentSelectedKeybindMode.KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
                end
                --
                if not Keybind:FindFrame() then
                    Keybind.ActiveFrame = true
                    Keybind:AddFrame()
                else
                    Keybind.ActiveFrame = false
                    Keybind:RemoveFrame()
                end
            end
        end
        --
        do -- Connections
            Library:Connection(KeybindObject.MouseEnter, function()
                if Keybind.SelectingKeybind then return end
                --
                Library:TweenObject(KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(176, 176, 176)})
            end)
            --
            Library:Connection(KeybindObject.MouseLeave, function()
                if Keybind.SelectingKeybind then return end
                --
                Library:TweenObject(KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(117, 117, 117)})
            end)
            --
            Library:Connection(Button_4.MouseButton2Click, function()
                if not Options.UseMode then return end
                --
                Keybind:ToggleFrame()
            end)
            --
            Library:OnClick(Button_4, function()
                -- 手机无右键：单击直接打开模式菜单（键盘绑定在手机上不可用）
                if Library.IsMobile and Options.UseMode and not Keybind.SelectingKeybind then
                    Keybind:ToggleFrame()
                    return
                end
                --
                if Keybind.Connection then
                    Keybind.Connection:Disconnect()
                end
                --
                Keybind.SelectingKeybind = true
                --
                Library:TweenObject(KeybindObject, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 0, 0)})
                --
                Keybind.Connection = Library:Connection(UserInputService.InputBegan, function(Input)
                    -- 触摸不参与键位绑定（手机上没有键盘，绑成 Touch 无意义还会破坏状态）
                    if Input.UserInputType == Enum.UserInputType.Touch then return end
                    --
                    Keybind:Set(Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType)
                    --
                    if Keybind.Connection then
                        Keybind.Connection:Disconnect()
                        --
                        task.delay(0.1, function()
                            Keybind.Connection = nil
                            Keybind.SelectingKeybind = false
                        end)
                    end
                end)
            end)
            --
            Library:Connection(UserInputService.InputBegan, function(Input, Proccessed)
                if Proccessed then return end
                --
                if (Input.UserInputType == Enum.UserInputType.Keyboard and Keybind.Keybind ~= "[-]" and Input.KeyCode == Keybind.RegKeybind) or (Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Keybind == "MB1") or (Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Keybind == "MB2") or (Input.UserInputType == Enum.UserInputType.MouseButton3 and Keybind.Keybind == "MMB") then
                    if Keybind.Mode == "Always on" then
                        Keybind:Toggle(true)
                    else
                        Keybind:Toggle()
                    end
                end
            end)
            --
            Library:Connection(UserInputService.InputEnded, function(Input, Proccessed)
                if Proccessed then return end
                --
                if Keybind.Mode == "On hotkey" then
                    if (Input.UserInputType == Enum.UserInputType.Keyboard and Keybind.Keybind ~= "[-]" and Input.KeyCode == Keybind.RegKeybind) or (Input.UserInputType == Enum.UserInputType.MouseButton1 and Keybind.Keybind == "MB1") or (Input.UserInputType == Enum.UserInputType.MouseButton2 and Keybind.Keybind == "MB2") or (Input.UserInputType == Enum.UserInputType.MouseButton3 and Keybind.Keybind == "MMB") then
                        Keybind:Toggle()
                    end
                end
            end)
        end
        --
        if Options.Hiding then
            Keybind:SetVisible(false)
        end
        --
        return Keybind
    end
    --
    function Library:MultiBox(Options)
        Options = Library:Validate({
            Default = "None",
            Name = "Preview MultiBox",
            Content = {},
            Parent = nil,
            MainUI = nil,
            Hiding = false,
            TabUI = nil,
            Risky = false,
            Flag = Library.NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        local MultiBox = {
            Open = false,
            Hover = false,
            Items = Options.Content,
            Scrollable = false,
            Value = {},
            SelectedOrder = {},
            AllItems = {},
        }
        --
        Library.Flags[Options.Flag] = MultiBox
        Options.Callback(Options.Default)
        --
        local PreviewMultiBox_5 = Library:CreateObject("Frame", {
            Name = "PreviewMultiBox_5",
            BackgroundTransparency = 1,
            Size = Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local MultiBoxOutline_5 = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(0, 1),
            Name = "MultiBoxOutline_5",
            Position = UDim2.new(0, -1, 1, 0),
            Size = UDim2.new(1, -19, 0, 20),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewMultiBox_5
        })
        --
        local MultiBoxChecker = Library:CreateObject("Frame", {
            Name = "MultiBoxChecker",
            Position = UDim2.new(0, 0, 1, 0),
            Visible = false,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Parent = MultiBoxOutline_5
        })
        --
        local MultiBoxBack_5 = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "MultiBoxBack_5",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            Parent = MultiBoxOutline_5
        })
        --
        local MultiBoxArrow = Library:CreateObject("ImageLabel", {
            ImageColor3 = Color3.fromRGB(151, 151, 151),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "MultiBoxArrow",
            Image = "rbxassetid://15556784588",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -11, 0, 6),
            Size = UDim2.new(0, 5, 0, 4),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = MultiBoxBack_5
        })
        --
        local UIGradient_34 = Library:CreateObject("UIGradient", {
            Rotation = -90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            },
            Parent = MultiBoxBack_5
        })
        --
        local MultiBoxValue_5 = Library:CreateObject("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(152, 152, 152),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = "None",
            Name = "MultiBoxValue_5",
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = MultiBoxBack_5
        })
        --
        local UIPadding_87 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            Parent = MultiBoxValue_5
        })
        --
        local Button_44 = Library:CreateObject("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_44",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = MultiBoxOutline_5
        })
        --
        local MultiBoxName_5 = Library:CreateObject("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Library.Theme.Default.TextColor,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Name,
            Name = "MultiBoxName_5",
            ZIndex = 3,
            Size = UDim2.new(1, -19, 1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, -4),
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewMultiBox_5
        })
        --
        local UIPadding_88 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewMultiBox_5
        })
        --
        local MultiBoxMainOutline = Library:CreateObject("Frame", {
            Name = "MultiBoxMainOutline",
            Position = UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 10,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = Library.UI.ScreenGUI
        })
        --
        local MultiBoxMain = Library:CreateObject("Frame", {
            Name = "MultiBoxMain",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            ZIndex = 10,
            ClipsDescendants = true,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Parent = MultiBoxMainOutline
        })
        --
        MultiBoxMainOutline.BackgroundTransparency = 1
        MultiBoxMain.BackgroundTransparency = 1
        --
        local UIListLayout_9 = Library:CreateObject("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = MultiBoxMain
        })
        --
        do -- Functions
            function MultiBox:Set(Values)
                for Index, Item in MultiBox.AllItems do
                    if not table.find(Values, Index) then
                        MultiBox.Items[Index] = false
                    else
                        MultiBox.Items[Index] = true
                    end
                    --
                    Item:Toggle()
                end
            end
            --
            function MultiBox:Get()
                return MultiBox.Value
            end
            --
            function MultiBox:SetVisible(Bool)
                MultiBox.Hiding = not Bool
                --
                Library:SetRowVisible(PreviewMultiBox_5, Bool)
            end
            --
            function MultiBox:AddValue(Value)
                local Item = {
                    Active = false,
                    Hovering = false,
                }
                --
                MultiBox.Items[Value] = Item
                --
                local Inactive = Library:CreateObject("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(208, 208, 208),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = Value,
                    Text = Value,
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = Library.UI.FontSize,
                    ZIndex = 10,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = MultiBoxMain
                })
                --
                local Button_4 = Library:CreateObject("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_4",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Library.UI.FontSize,
                    ZIndex = 11,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Inactive
                })
                --
                local UIPadding_48 = Library:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = Inactive
                })
                --
                Inactive.TextTransparency = 1
                --
                do -- Functions
                    function Item:GetSelectedItems()
                        local SelectedItems = {}
                        --
                        for _, Item in MultiBox.SelectedOrder do
                            if MultiBox.Items[Item] then
                                table.insert(SelectedItems, Item)
                            end
                        end
                        --
                        return SelectedItems
                    end
                    --
                    function MultiBox:UpdateValue()
                        MultiBox.Value = Item:GetSelectedItems()
                        --
                        MultiBoxValue_5.Text = Library:ClampString(table.concat(MultiBox.Value, ", "), MultiBoxMain.AbsoluteSize.X - MultiBoxArrow.AbsoluteSize.X - 4)
                    end
                    --
                    function Item:SelectItem(Item)
                        if not table.find(MultiBox.SelectedOrder, Item) then
                            table.insert(MultiBox.SelectedOrder, Item)
                        end
                        --
                        MultiBox:UpdateValue()
                    end

                    function Item:DeselectItem(Item)
                        for Index, Value in MultiBox.SelectedOrder do
                            if Value == Item then
                                table.remove(MultiBox.SelectedOrder, Index)
                                --
                                break
                            end
                        end
                        --
                        MultiBox:UpdateValue()
                    end
                    --
                    function Item:Activate()
                        if not Item.Active then
                            Item.Active = true
                            MultiBox.CurrentItem = Item
                            MultiBox.Items[Value] = true
                            Library.Flags[Options.Flag] = MultiBox
                            Item:SelectItem(Value)
                            Options.Callback(MultiBox.Value)
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Library.Theme.Default.Accent})
                            Library:AddTheme(Inactive, {
                                TextColor3 = "Accent",
                            })
                        end
                    end
                    --
                    function Item:Deactivate()
                        if Item.Active then
                            Item.Active = false
                            Item.Hovering = false
                            MultiBox.CurrentItem = nil
                            Library.Flags[Options.Flag] = MultiBox
                            MultiBox.Items[Value] = false
                            Item:DeselectItem(Value)
                            Options.Callback(MultiBox.Value)
                            --
                            Inactive.Text = Value
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                            Library:AddTheme(Inactive, {
                                TextColor3 = "TextColor",
                            })
                        end
                    end
                    --
                    function Item:Toggle()
                        MultiBox.Items[Value] = not MultiBox.Items[Value]
                        --
                        if MultiBox.Items[Value] then
                            Item:Activate()
                        else
                            Item:Deactivate()
                        end
                    end
                end
                --
                do -- Connections
                    Library:OnClick(Button_4, function()
                        if MultiBox.Hiding then return end
                        --
                        Item:Toggle()
                    end)
                    --
                    Library:Connection(Inactive.MouseEnter, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        --
                        if Item.Active then return end
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                    end)
                    --
                    Library:Connection(Inactive.MouseLeave, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        --
                        if Item.Active then return end
                        --
                        Inactive.Text = Value
                        Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                    end)
                end
                --
                if typeof(Options.Default) == "table" and table.find(Options.Default, Value) then
                    Item:Activate()
                    Item:SelectItem(Value)
                else
                    MultiBox.Items[Value] = false
                end
            end
            --
            function MultiBox:Toggle(Fast)
                local Fast = Fast or false
                local OldValues = Library.Objects[MultiBoxMainOutline]
                --
                if MultiBox.Open then
                    if Fast then
                        Library:Fade(false, Library:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0)
                        MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, 0)
                        Library.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], true}
                    else
                        Library:Fade(false, Library:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
                        Library:TweenObject(MultiBoxMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, 0)}, function()
                            Library.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], true}
                        end)
                    end
                else
                    Library.Objects[MultiBoxMainOutline] = {MultiBoxMainOutline, OldValues[2], false}
                    --
                    if Fast then
                        Library:Fade(true, Library:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0)
                        MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)
                    else
                        Library:Fade(true, Library:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
                        Library:TweenObject(MultiBoxMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, (#Options.Content * 20) + 2)})
                    end	
                end
                --
                MultiBox.Open = not MultiBox.Open
            end
            --
            function MultiBox:Update()
                MultiBoxMainOutline.Size = UDim2.new(0, MultiBoxOutline_5.AbsoluteSize.X, 0, MultiBoxMainOutline.AbsoluteSize.Y)
                MultiBoxMainOutline.Position = UDim2.new(0, MultiBoxOutline_5.AbsolutePosition.X, 0, ((MultiBoxOutline_5.AbsolutePosition.Y + MultiBoxOutline_5.AbsoluteSize.Y) + GuiService:GetGuiInset().Y + 2))
                --
                if MultiBox.Open then
                    MultiBoxMainOutline.Visible = Library:ScrollingCheck(Options.Parent, MultiBoxChecker)
                end
            end
            --
            MultiBox:Update()
            --
            Library:Connection(MultiBoxOutline_5:GetPropertyChangedSignal("AbsolutePosition"), MultiBox.Update)
            Library:Connection(MultiBoxOutline_5:GetPropertyChangedSignal("AbsoluteSize"), MultiBox.Update)
            --
            local StartingX = PreviewMultiBox_5.AbsolutePosition.X
            local StartingY = PreviewMultiBox_5.AbsolutePosition.Y
            local MainUIStartingX = Options.MainUI.AbsolutePosition.X
            local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
            -- Parent 可能是非滚动容器（如自定义并排工具行）：IsA 守卫防 nil 属性报错
            local StartingCanvasPosition = Options.Parent:IsA("ScrollingFrame") and Options.Parent.CanvasPosition or nil
            --
            Library:Connection(PreviewMultiBox_5:GetPropertyChangedSignal("AbsolutePosition"), function()
                if not MultiBox.Open then return end
                --
                local CurrentX = PreviewMultiBox_5.AbsolutePosition.X
                local CurrentY = PreviewMultiBox_5.AbsolutePosition.Y
                local MainUICurrentX = Options.MainUI.AbsolutePosition.X
                local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                local CurrentCanvasPosition = Options.Parent:IsA("ScrollingFrame") and Options.Parent.CanvasPosition or nil
                --
                if MainUICurrentX ~= MainUIStartingX or MainUICurrentY ~= MainUIStartingY then
                    MainUIStartingX = MainUICurrentX
                    MainUIStartingY = MainUICurrentY
                    StartingX = CurrentX
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if CurrentCanvasPosition ~= StartingCanvasPosition then
                    StartingCanvasPosition = CurrentCanvasPosition
                    StartingX = CurrentX
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if Library.UI.Resizing then
                    return
                end
                --
                if CurrentX ~= StartingX or CurrentY ~= StartingY then
                    MultiBox:Toggle(true)
                end
                --
                StartingX = CurrentX
                StartingY = CurrentY
            end)
            --
            if Options.Parent:IsA("ScrollingFrame") then
                Library:Connection(Options.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                    MultiBox:Update()
                end)
            end
        end
        --
        do -- Connections
            Library:OnClick(Button_44, function()
                if MultiBox.Hiding then return end
                --
                MultiBox:Toggle()
            end)
            --
            Library:Connection(MultiBoxOutline_5.MouseEnter, function()
                if Library.UI.Faded then return end
                --
                if not MultiBox.Open then
                    MultiBox.Hovering = true
                    Library:TweenObject(MultiBoxBack_5, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                end	
            end)
            --
            Library:Connection(MultiBoxOutline_5.MouseLeave, function()
                if Library.UI.Faded then return end
                --
                if not MultiBox.Open then
                    MultiBox.Hovering = false
                    Library:TweenObject(MultiBoxBack_5, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
                end	
            end)
        end
        --
        for Index, Value in Options.Content do
            if typeof(Value) == "boolean" or typeof(Value) == "table" then continue end
            --
            MultiBox:AddValue(Value)
        end
        --
        Library:Fade(false, Library:GetObjectsTable(MultiBoxMainOutline, true), MultiBoxMainOutline, 0.1)
        --
        if Options.Hiding then
            MultiBox:SetVisible(false)
        end
        --
        MultiBox:Toggle(true)
        --
        return MultiBox
    end
    --
    function Library:Dropdown(Options)
        Options = Library:Validate({
            Default = "None",
            Name = "Preview Dropdown",
            Content = {},
            Parent = nil,
            MainUI = nil,
            Hiding = false,
            TabUI = nil,
            Risky = false,
            Flag = Library.NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        local Dropdown = {
            Open = false,
            Active = false,
            Hovering = false,
            CurrentItem = nil,
            Scrollable = false,
            Hiding = false,
            Items = {},
            Value = Options.Default,
        }
        --
        Library.Flags[Options.Flag] = Dropdown
        --
        local PreviewDropdown_5 = Library:CreateObject("Frame", {
            Name = "PreviewDropdown_5",
            BackgroundTransparency = 1,
            Size = Options.Size or (Options.Name == "" and UDim2.new(1, 0, 0, 20) or UDim2.new(1, 0, 0, 31)),
            Position = Options.Position or UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local DropdownOutline_5 = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(0, 1),
            Name = "DropdownOutline_5",
            Position = UDim2.new(0, -1, 1, 0),
            Size = UDim2.new(1, -19, 0, 20),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewDropdown_5
        })
        --
        local DropdownChecker = Library:CreateObject("Frame", {
            Name = "DropdownChecker",
            Position = UDim2.new(0, 0, 1, 0),
            Visible = false,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Parent = DropdownOutline_5
        })
        --
        local DropdownBack_5 = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "DropdownBack_5",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            Parent = DropdownOutline_5
        })
        --
        local DropdownArrow = Library:CreateObject("ImageLabel", {
            ImageColor3 = Color3.fromRGB(151, 151, 151),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "DropdownArrow",
            Image = "rbxassetid://15556784588",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -11, 0, 6),
            Size = UDim2.new(0, 5, 0, 4),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = DropdownBack_5
        })
        --
        local UIGradient_34 = Library:CreateObject("UIGradient", {
            Rotation = -90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            },
            Parent = DropdownBack_5
        })
        --
        local DropdownValue_5 = Library:CreateObject("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(152, 152, 152),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Default ~= "None" and table.find(Options.Content, Options.Default) and Options.Default or "None",
            Name = "DropdownValue_5",
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = DropdownBack_5
        })
        --
        local UIPadding_87 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 5),
            Parent = DropdownValue_5
        })
        --
        local Button_44 = Library:CreateObject("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_44",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = DropdownOutline_5
        })
        --
        local DropdownName_5 = Library:CreateObject("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Library.Theme.Default.TextColor,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Name,
            Name = "DropdownName_5",
            ZIndex = 3,
            Position = UDim2.new(0, 0, 0, -4),
            Size = UDim2.new(1, -19, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewDropdown_5
        })
        --
        local UIPadding_88 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewDropdown_5
        })
        --
        local DropdownMainOutline = Library:CreateObject("Frame", {
            Name = "DropdownMainOutline",
            Position = UDim2.new(0, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 10,
            BorderSizePixel = 0,
            Visible = false,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = Library.UI.ScreenGUI
        })
        --
        local DropdownMain = Library:CreateObject("ScrollingFrame", {
            Name = "DropdownMain",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            ZIndex = 10,
            ClipsDescendants = true,
            -- 选项过多时可滚动（手机友好）：隐藏滚动条，触摸直接滑动
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Parent = DropdownMainOutline
        })
        --
        DropdownMainOutline.BackgroundTransparency = 1
        DropdownMain.BackgroundTransparency = 1
        --
        local UIListLayout_9 = Library:CreateObject("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = DropdownMain
        })
        --
        do -- Functions
            function Dropdown:Set(State)
                for Index, Value in Dropdown.Items do
                    if Index == State then
                        Value:Activate()
                    else
                        Value:Deactivate()
                    end
                end
            end
            --
            function Dropdown:Get()
                return Dropdown.Value
            end
            --
            function Dropdown:SetVisible(Bool)
                Dropdown.Hiding = not Bool
                --
                if not Bool then
                    if Dropdown.Open then Dropdown:Toggle(true) end
                    DropdownMainOutline.Visible = false
                end
                --
                Library:SetRowVisible(PreviewDropdown_5, Bool)
            end
            --
            function Dropdown:AddValue(Value)
                local Item = {
                    Active = false,
                    Hovering = false,
                }
                --
                Dropdown.Items[Value] = Item
                --
                local Inactive = Library:CreateObject("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(208, 208, 208),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = Value,
                    Text = Value,
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    TextSize = Library.UI.FontSize,
                    ZIndex = 10,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = DropdownMain
                })
                --
                local Button_4 = Library:CreateObject("TextButton", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_4",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Library.UI.FontSize,
                    ZIndex = 10,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = Inactive
                })
                --
                local UIPadding_48 = Library:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = Inactive
                })
                --
                Inactive.TextTransparency = 1
                --
                do -- Functions
                    function Item:Activate()
                        if not Item.Active then
                            if Dropdown.CurrentItem ~= nil then
                                Dropdown.CurrentItem:Deactivate()
                            end
                            --
                            Item.Active = true
                            Dropdown.CurrentItem = Item
                            Dropdown.Value = Value
                            Library.Flags[Options.Flag] = Dropdown
                            Options.Callback(Value)
                            DropdownValue_5.Text = Value
                            --
                            Inactive.Text = "<b>" .. Value .. "</b>"
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Library.Theme.Default.Accent})
                            Library:AddTheme(Inactive, {
                                TextColor3 = "Accent",
                            })
                        end
                    end
                    --
                    function Item:Deactivate()
                        if Item.Active then
                            Item.Active = false
                            Item.Hovering = false
                            Inactive.Text = Value
                            Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                            Library:AddTheme(Inactive, {
                                TextColor3 = "TextColor",
                            })
                        end
                    end
                end
                --
                do -- Connections
                    Library:OnClick(Button_4, function()
                        if Dropdown.Hiding then return end
                        --
                        Item:Activate()
                        Dropdown:Toggle()
                    end)
                    --
                    Library:Connection(Inactive.MouseEnter, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        --
                        if Item.Active then return end
                        --
                        Inactive.Text = "<b>" .. Value .. "</b>"
                    end)
                    --
                    Library:Connection(Inactive.MouseLeave, function()
                        Inactive.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        --
                        if Item.Active then return end
                        --
                        Inactive.Text = Value
                        Library:TweenObject(Inactive, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(205, 205, 205)})
                    end)
                end
                --
                if Value == Options.Default then
                    Item:Activate()
                end
            end
            --
            function Dropdown:Toggle(Fast)
                local Fast = Fast or false
                local OldValues = Library.Objects[DropdownMainOutline]
                -- 面板高度按实际选项数算（支持 AddValue 动态加项；Items 为空回退 Content）
                local ItemCount = 0
                for _ in pairs(Dropdown.Items) do ItemCount += 1 end
                if ItemCount == 0 then ItemCount = #Options.Content end
                --
                if Dropdown.Open then
                    if Fast then
                        Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                        DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, 0)
                        DropdownMainOutline.Visible = false
                        Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                    else
                        Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                        Library:TweenObject(DropdownMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, 0)}, function()
                            DropdownMainOutline.Visible = false
                            Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                        end)
                    end
                else
                    Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], false}
                    DropdownMainOutline.Visible = true
                    --
                    DropdownMain.CanvasPosition = Vector2.zero -- 每次展开回到顶部
                    if Fast then
                        Library:Fade(true, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                        DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, math.min(ItemCount * 20 + 2, Camera.ViewportSize.Y - 80))
                    else
                        Library:Fade(true, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                        Library:TweenObject(DropdownMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, math.min(ItemCount * 20 + 2, Camera.ViewportSize.Y - 80))})
                    end
                end
                --
                Dropdown.Open = not Dropdown.Open
            end
            --
            function Dropdown:Update()
                DropdownMainOutline.Size = UDim2.new(0, DropdownOutline_5.AbsoluteSize.X, 0, DropdownMainOutline.AbsoluteSize.Y)
                DropdownMainOutline.Position = UDim2.new(0, DropdownOutline_5.AbsolutePosition.X, 0, ((DropdownOutline_5.AbsolutePosition.Y + DropdownOutline_5.AbsoluteSize.Y) + GuiService:GetGuiInset().Y + 2))
                --
                if Dropdown.Open then
                    DropdownMainOutline.Visible = Library:ScrollingCheck(Options.Parent, DropdownChecker)
                else
                    DropdownMainOutline.Visible = false
                end
            end
            --
            Dropdown:Update()
            --
            Library:Connection(DropdownOutline_5:GetPropertyChangedSignal("AbsolutePosition"), Dropdown.Update)
            Library:Connection(DropdownOutline_5:GetPropertyChangedSignal("AbsoluteSize"), Dropdown.Update)
            --
            local StartingX = PreviewDropdown_5.AbsolutePosition.X
            local StartingY = PreviewDropdown_5.AbsolutePosition.Y
            local MainUIStartingX = Options.MainUI.AbsolutePosition.X
            local MainUIStartingY = Options.MainUI.AbsolutePosition.Y
            -- Parent 可能是非滚动容器（如自定义并排工具行）：IsA 守卫防 nil 属性报错
            local StartingCanvasPosition = Options.Parent:IsA("ScrollingFrame") and Options.Parent.CanvasPosition or nil
            --
            Library:Connection(PreviewDropdown_5:GetPropertyChangedSignal("AbsolutePosition"), function()
                if not Dropdown.Open then return end
                --
                local CurrentX = PreviewDropdown_5.AbsolutePosition.X
                local CurrentY = PreviewDropdown_5.AbsolutePosition.Y
                local MainUICurrentX = Options.MainUI.AbsolutePosition.X
                local MainUICurrentY = Options.MainUI.AbsolutePosition.Y
                local CurrentCanvasPosition = Options.Parent:IsA("ScrollingFrame") and Options.Parent.CanvasPosition or nil
                --
                if MainUICurrentX ~= MainUIStartingX or MainUICurrentY ~= MainUIStartingY then
                    MainUIStartingX = MainUICurrentX
                    MainUIStartingY = MainUICurrentY
                    StartingX = CurrentX
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if CurrentCanvasPosition ~= StartingCanvasPosition then
                    StartingCanvasPosition = CurrentCanvasPosition
                    StartingX = CurrentX
                    StartingY = CurrentY
                    --
                    return
                end
                --
                if Library.UI.Resizing then
                    return
                end
                --
                if CurrentX ~= StartingX or CurrentY ~= StartingY then
                    Dropdown:Toggle(true)
                end
                --
                StartingX = CurrentX
                StartingY = CurrentY
            end)
            --
            if Options.Parent:IsA("ScrollingFrame") then
                Library:Connection(Options.Parent:GetPropertyChangedSignal("CanvasPosition"), function()
                    Dropdown:Update()
                end)
            end
        end
        --
        do -- Connections
            Library:OnClick(Button_44, function()
                if Dropdown.Hiding then return end
                --
                Dropdown:Toggle()
            end)
            --
            Library:Connection(DropdownOutline_5.MouseEnter, function()
                if Library.UI.Faded then return end
                --
                if not Dropdown.Open then
                    Dropdown.Hovering = true
                    Library:TweenObject(DropdownBack_5, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                end	
            end)
            --
            Library:Connection(DropdownOutline_5.MouseLeave, function()
                if Library.UI.Faded then return end
                --
                if not Dropdown.Open then
                    Dropdown.Hovering = false
                    Library:TweenObject(DropdownBack_5, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
                end	
            end)
        end
        --
        for _, Value in Options.Content do
            Dropdown:AddValue(Value)
        end
        --
        Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
        --
        if Options.Hiding then
            Dropdown:SetVisible(false)
        end
        --
        -- 初始化：先打开一次测量内容尺寸，再立即复位为关闭态（修复非活动 Tab 创建时浮层泄露）
        Dropdown:Toggle(true)
        Dropdown:Toggle(true)
        DropdownMainOutline.Visible = false
        --
        return Dropdown
    end
    --
    function Library:Slider(Options)
        Options = Library:Validate({
            Name = "Preview Slider",
            Min = 0,
            Max = 100,
            Default = 1,
            Decimal = 1,
            UseIcons = true,
            Ending = "",
            Disable = {},
            Hidden = false,
            Risky = false,
            Parent = nil,
            OverrideLimit = false, -- new parameter to allow values beyond max
            Flag = Library.NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        -- Decimal 是步长（1=整数步）：传 0/nil 会触发 Value/0=inf → 0*inf=NaN，导致填充与数值全部失效
        Options.Decimal = tonumber(Options.Decimal)
        if not Options.Decimal or Options.Decimal <= 0 then Options.Decimal = 1 end
        --
        local Slider = {
            MouseDown = false,
            Hiding = false,
            Hovering = false,
            Connection = nil,
            CurrentValue = -9999,
            LeftControlDown = false,
        }
        --
        Library.Flags[Options.Flag] = Slider
        --
        local PreviewSlider = Library:CreateObject("Frame", {
            Name = "PreviewSlider",
            BackgroundTransparency = 1,
            Size = Options.Name == "" and UDim2.new(1, 0, 0, 7) or UDim2.new(1, 0, 0, 20),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local SliderOutline = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(0, 1),
            Name = "SliderOutline",
            Position = UDim2.new(0, -1, 1, 0),
            Size = UDim2.new(1, -19, 0, 7),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewSlider
        })
        --
        local SliderBack = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "SliderBack",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(205, 205, 205),
            Parent = SliderOutline
        })
        --
        local UIGradient_2 = Library:CreateObject("UIGradient", {
            Rotation = -90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(81, 81, 81)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(68, 68, 68))
            },
            Parent = SliderBack
        })
        --
        local SliderDrag = Library:CreateObject("Frame", {
            Name = "Slider",
            Size = UDim2.new(0.5, 0, 1, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = SliderBack
        })
        --
        local UIGradient_3 = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library.Theme.Default.Accent),
                ColorSequenceKeypoint.new(1, Library.Theme.Default.SecondAccent)
            },
            Parent = SliderDrag
        })
        --
        Library:AddTheme(UIGradient_3, {
            Color = {"Accent", "SecondAccent"},
        })
        --
        local Button_4 = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_4",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = SliderOutline
        })
        --
        local SliderName = Library:CreateObject("TextLabel", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Options.Risky and Library.Theme.Default.Risky or Library.Theme.Default.TextColor,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Name,
            Name = "SliderName",
            ZIndex = 3,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewSlider
        })
        --
        if Options.Risky then
            Library:AddTheme(SliderName, {
                TextColor3 = "Risky",
            })
        end
        --
        local UIPadding_3 = Library:CreateObject("UIPadding", {
            PaddingTop = UDim.new(0, -4),
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewSlider
        })
        --
        local SliderValue = Library:CreateObject("TextBox", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(198, 198, 198),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = Options.Default,
            Name = "SliderValue",
            ZIndex = 3,
            AnchorPoint = Vector2.new(1, 0),
            Size = UDim2.new(0, 10, 0, 10),
            Position = UDim2.new(0, 100, 0, 0),
            BackgroundTransparency = 1,
            RichText = true,
            BorderSizePixel = 0,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextSize = Library.UI.FontSize,
            TextStrokeTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = SliderDrag
        })
        --
        local AddButton = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(1, 1),
            Name = "AddButton",
            Position = UDim2.new(1, -13, 1, -3),
            Size = UDim2.new(0, 3, 0, 1),
            ZIndex = 3,
            BorderSizePixel = 0,
            Visible = Options.UseIcons,
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = PreviewSlider
        })
        --
        local AddButton2 = Library:CreateObject("Frame", {
            Size = UDim2.new(0, 1, 0, 3),
            Name = "AddButton2",
            Position = UDim2.new(0, 1, 0, -1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            Visible = Options.UseIcons,
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = AddButton
        })
        --
        local AddActualButton = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "AddActualButton",
            TextTransparency = 1,
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.new(0, 11, 0, 7),
            Visible = Options.UseIcons,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -9, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 3,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewSlider
        })
        --
        local MinusActualButton = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "MinusActualButton",
            TextTransparency = 1,
            Visible = Options.UseIcons,
            AnchorPoint = Vector2.new(0, 1),
            Size = UDim2.new(0, 11, 0, 7),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -12, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 3,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewSlider
        })
        --
        local MinusButton = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Vector2.new(0, 1),
            Name = "MinusButton",
            Visible = Options.UseIcons,
            Position = UDim2.new(0, -8, 1, -3),
            Size = UDim2.new(0, 3, 0, 1),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(100, 100, 100),
            Parent = PreviewSlider
        })
        --
        local function GetValue(Value)
            return typeof(Value) == "string" and Value or ("%.14g"):format(Value)
        end
        --
        local function SetValue(Value, IgnoreLimit)
            if (not Value) or Slider.Hiding then return end
            --
            local OriginalValue = Value
            -- check if we should allow values beyond the max
            if Options.OverrideLimit and IgnoreLimit then
                -- allow any value (still enforce min and decimal rounding)
                Value = Value and math.max(Options.Decimal * math.round(tonumber(Value) / Options.Decimal), Options.Min) or 0
            else
                -- default behavior: clamp between min and max
                Value = Value and math.clamp(Options.Decimal * math.round(tonumber(Value) / Options.Decimal), Options.Min, Options.Max) or 0
            end
            
            local ValueText = Options.Disable[1] and ((Value <= Options.Disable[2] or Value >= Options.Disable[3]) and Options.Disable[1]) or tostring(GetValue(Value)) .. Options.Ending
            --
            SliderValue.Text = "<b>" .. ValueText .. "</b>"
            --
            if Value ~= Slider.CurrentValue then
                Slider.CurrentValue = Value
                --
                -- always display the slider within bounds, even if the value is beyond max
                local DisplayValue = math.min(Value, Options.Max)
                Library:TweenObject(SliderDrag, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new((DisplayValue - Options.Min) / (Options.Max - Options.Min), 0, 1, 0)})
                --
                SliderValue.Size = UDim2.fromOffset(SliderValue.TextBounds.X, SliderValue.TextBounds.Y)
                SliderValue.Position = UDim2.new(1, SliderValue.TextBounds.X / 2, 0, -4)
            end
            --
            Library.Flags[Options.Flag] = Slider
            Options.Callback(tonumber(GetValue(Value)))
        end
        --
        SetValue(Options.Default)
        --
        function Slider:Get()
            return tonumber(GetValue(Slider.CurrentValue))
        end
        --
        function Slider:Max()
            return Options.Max
        end
        --
        function Slider:Min()
            return Options.Min
        end
        --
        function Slider:Set(Value)
            if not Value then return end
            --
            SetValue(Value, Options.OverrideLimit) -- allow overriding limits for api calls too
        end
        --
        function Slider:GetName()
            return Options.Name
        end
        --
        function Slider:SetVisible(Bool)
            Slider.Hiding = not Bool
            --
            SliderValue.Visible = Bool
            --
            Library:SetRowVisible(PreviewSlider, Bool)
        end
        --
        local function SlideBar(Input)
            local SizeX = (Input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X
            local Value = math.clamp((Options.Max - Options.Min) * SizeX + Options.Min, Options.Min, Options.Max)
            --
            SetValue(Value)
        end
        --
        do -- Connections
            Library:Connection(SliderOutline.MouseEnter, function()
                if Library.UI.Faded then return end
                --
                Library:TweenObject(SliderBack, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end)
            --
            Library:Connection(SliderOutline.MouseLeave, function()
                if Library.UI.Faded then return end
                --
                Library:TweenObject(SliderBack, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(205, 205, 205)})
            end)
            --
            Library:OnClick(MinusActualButton, function()
                if Library.UI.Faded then return end
                --
                Slider:Set(Slider.CurrentValue - Options.Decimal)
            end)
            --
            Library:OnClick(AddActualButton, function()
                if Library.UI.Faded then return end
                --
                Slider:Set(Slider.CurrentValue + Options.Decimal)
            end)
            --
            Library:Connection(Button_4.MouseButton1Down, function(x, y)
                if Library.UI.Faded then return end
                --
                Library.UI.DraggingGui = SliderDrag
                Slider.MouseDown = true
                -- 注意：MouseButton1Down 回调参数是 (x, y) 数字，不是 InputObject（旧版当成 InputObject 取 .Position 直接报错）
                SlideBar({Position = Vector2.new(typeof(x) == "number" and x or UserInputService:GetMouseLocation().X, 0)})
            end)
            --
            Library:Connection(SliderValue.FocusLost, function()
                local NewValue = tonumber(SliderValue.Text)
                --
                if NewValue then
                    SetValue(NewValue, Options.OverrideLimit) -- pass true to allow exceeding max
                else
                    SetValue(Options.Min)
                end
            end)
            --
            Library:Connection(UserInputService.InputChanged, function(Input)
                if Library.UI.Faded then return end
                --
                -- 触摸时 IsMouseButtonPressed 恒 false，改用统一的按下判定（含触摸计数）
                if Library.UI.DraggingGui ~= SliderDrag and not (Library:IsInputDown()) then
                    return
                end
                --
                -- MouseMovement 或 Touch（手指拖动滑条）
                if Slider.MouseDown and Library:IsMoveInput(Input) then
                    SlideBar(Input)
                end
            end)
            --
            Library:Connection(UserInputService.InputEnded, function(Input)
                if Library:IsReleaseInput(Input) then
                    Slider.MouseDown = false
                end
            end)
        end
        --
        if Options.Hidden then
            Slider:SetVisible(false)
        end
        --
        return Slider
    end
    --
    function Library:Toggle(Options)
        Options = Library:Validate({
            Default = false,
            Name = "Preview Toggle",
            Risky = false,
            SectionName = nil,
            Parent = nil,
            Hidden = false,
            AnchorPoint = Vector2.new(0, 0),
            MainUI = nil,
            Size = UDim2.new(1, 0, 0, 8),
            Position = UDim2.new(0, 0, 0, 0),
            UseToggleOutline = false,
            ZIndex = 2,
            Flag = Library:NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        local Toggle = {
            Active = false,
            Hovering = false,
            State = false,
            Hiding = false,
            MainUI = Options.MainUI,
            TabUI = Options.TabUI,
            ColorPickers = {},
            KeybindState = false,
        }
        --
        Library.Flags[Options.Flag] = Toggle
        --
        local PreviewToggle = Library:CreateObject("Frame", {
            Name = "PreviewToggle",
            BackgroundTransparency = 1,
            Size = Options.Size,
            Position = Options.Position,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            AnchorPoint = Options.AnchorPoint,
            ZIndex = Options.ZIndex or 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local ToggleOutline = Library:CreateObject("Frame", {
            Name = "ToggleOutline",
            Size = UDim2.new(0, 8, 0, 8),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = Options.ZIndex or 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewToggle
        })
        --
        if Options.UseToggleOutline then
            ToggleOutline.AnchorPoint = Options.AnchorPoint
            ToggleOutline.Position = Options.Position
        end
        --
        local ToggleInline = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ToggleInline",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = Options.ZIndex or 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(227, 227, 227),
            Parent = ToggleOutline
        })
        --
        local UIGradient_3 = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(84, 84, 84)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(74, 74, 74))
            },
            Parent = ToggleInline
        })
        --
        local ToggleMain = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ToggleInline",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = Options.ZIndex or 2,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ToggleOutline
        })
        --
        Library.Objects[ToggleMain] = {ToggleMain, {BackgroundTransparency = ToggleMain.BackgroundTransparency}, false}
        --
        local UIGradient_32 = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Library.Theme.Default.Accent),
                ColorSequenceKeypoint.new(1, Library.Theme.Default.SecondAccent)
            },
            Parent = ToggleMain
        })
        --
        Library:AddTheme(UIGradient_32, {
            Color = {"Accent", "SecondAccent"},
        })
        --
        local ToggleName = Library:CreateObject("TextLabel", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "ToggleName",
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = Options.ZIndex or 2,
            FontFace = Library.UI.NewFont,
            RichText = true,
            Text = Options.Name,
            TextColor3 = Options.Risky and Library.Theme.Default.Risky or Library.Theme.Default.TextColor,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewToggle
        })
        --
        if Options.Risky then
            Library:AddTheme(ToggleName, {
                TextColor3 = "Risky",
            })
        end
        --
        local UIPadding_7 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = ToggleName
        })
        --
        local Button_9 = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_9",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewToggle
        })
        --
        do -- Functions
            function Toggle:ToggleGUI(Bool)
                if Bool == nil then
                    Toggle.State = not Toggle.State
                else
                    Toggle.State = Bool
                end
                --
                Library:TweenObject(ToggleMain, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = Toggle.State and 0 or 1})
                
                -- update the stored transparency value in the objects table, this is for the temp fix for the toggle out and toggle in 
                -- since this uses instant out and instant in instead of the normal fade in and fade out
                if Library.Objects[ToggleMain] then
                    Library.Objects[ToggleMain][2].BackgroundTransparency = Toggle.State and 0 or 1
                end
                
                --
                Library.Flags[Options.Flag] = Toggle
                Options.Callback(Toggle.State)
            end
            --
            function Toggle:GetName()
                return Options.Name
            end
            --
            function Toggle:GetFlag()
                return Options.Flag
            end
            --
            function Toggle:GetSection()
                return Options.SectionName
            end
            --
            function Toggle:GetState()
                return Toggle.State
            end
            --
            function Toggle:GetCallback(b)
                Options.Callback(b)
            end
            --
            function Toggle:Set(Value)
                Toggle:ToggleGUI(Value)
            end
            --
            function Toggle:SetName(Name)
                Options.Name = Name
                ToggleName.Text = Name
            end
            --
            function Toggle:Get()
                return Toggle.State
            end
            --
            function Toggle:SetVisible(Bool)
                Toggle.Hiding = not Bool
                --
                Library:SetRowVisible(PreviewToggle, Bool)
            end
            --
            function Toggle:ColorPicker(Options)
                Options = Library:Validate({
                    Name = "Preview Color Picker",
                    Default = Library.Theme.Default.Accent,
                    Flag = Library.NewFlag(),
                    Alpha = 0,
                    AlphaBar = true,
                    Callback = function() end,
                }, Options or {})
                --
                local ColorPicker = {}
                --
                Toggle.ColorPickers[#Toggle.ColorPickers + 1] = ColorPicker
                --
                local ColorPickerFrame = Library:ColorPicker({
                    Name = Options.Name,
                    Default = Options.Default,
                    Flag = Options.Flag,
                    Alpha = Options.Alpha,
                    AlphaBar = Options.AlphaBar,
                    MainUI = Toggle.MainUI,
                    TabUI = Toggle.TabUI,
                    Callback = Options.Callback,
                    Parent = PreviewToggle,
                    Keybind = Toggle.KeybindState,
                    Count = #Toggle.ColorPickers,
                })
                --
                return ColorPickerFrame
            end
            --
            function Toggle:Keybind(Options)
                Options = Library:Validate({
                    Default = Enum.KeyCode.Backspace,
                    Mode = "Toggle",
                    UseMode = true,
                    HideFromList = false,
                    Blacklisted = {},
                    Hiding = false,
                    ChangeToggle = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end,
                }, Options or {})
                --
                local Keybind = {}
                --
                Toggle.KeybindState = true
                --
                Library:Keybind({
                    Default = Options.Default,
                    Mode = Options.Mode,
                    HideFromList = Options.HideFromList,
                    Blacklisted = Options.Blacklisted,
                    Parent = PreviewToggle,
                    UseMode = Options.UseMode,
                    Toggle = Toggle,
                    MainUI = Toggle.MainUI,
                    TabUI = Toggle.TabUI,
                    Hiding = Options.Hiding,
                    ToggleState = Toggle.State,
                    ChangeToggle = Options.ChangeToggle,
                    Flag = Options.Flag,
                    Callback = Options.Callback,
                    Count = #Toggle.ColorPickers + 1,
                })
                --
                return Keybind
            end
        end
        --
        do -- Connections
            Library:Connection(PreviewToggle.MouseEnter, function()
                if Library.UI.Faded then return end
                --
                Library:TweenObject(ToggleInline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            end)
            --
            Library:Connection(PreviewToggle.MouseLeave, function()
                if Library.UI.Faded then return end
                --
                Library:TweenObject(ToggleInline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(227, 227, 227)})
            end)
            --
            Library:OnClick(Button_9, function()
                if Library.UI.Faded then return end
                --
                if Toggle.Hiding then return end
                --
                Toggle:ToggleGUI()
            end)
        end
        --
        Toggle:ToggleGUI(Options.Default)
        --
        if Options.Hidden then
            Toggle:SetVisible(false)
        end
        --
        return Toggle
    end
    --
    function Library:Label(Options)
        Options = Library:Validate({
            Message = "Preview Label",
            Side = "Left",
            Risky = false,
            Parent = nil,
            MainUI = nil,
            SectionName = nil,
            Hidden = false,
            TabUI = nil,
            Callback = function() end
        }, Options or {})
        --
        local Label = {
            ColorPickers = {},
            KeybindState = false,
            Hiding = false,
            MainUI = Options.MainUI,
            TabUI = Options.TabUI,
            State = true,
        }
        --
        local PreviewLabel = Library:CreateObject("Frame", {
            Name = "PreviewLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 7),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 2,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local LabelText = Library:CreateObject("TextLabel", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "ToggleName",
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment[Options.Side],
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, -1),
            ZIndex = 2,
            FontFace = Library.UI.NewFont,
            RichText = true,
            Text = Options.Message,
            TextColor3 = Color3.fromRGB(198, 198, 198),
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PreviewLabel
        })
        --
        local UIPadding_7 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = LabelText
        })
        --
        do -- Functions
            function Label:GetName()
                return Options.Message
            end
            --
            function Label:GetState()
                return Label.State
            end
            --
            function Label:GetSection()
                return Options.SectionName
            end
            --
            function Label:GetCallback(Bool)
                Options.Callback(Bool)
            end
            --
            function Label:SetVisible(Bool)
                Label.Hiding = not Bool
                --
                Library:SetRowVisible(PreviewLabel, Bool)
            end
            --
            function Label:ColorPicker(Options)
                Options = Library:Validate({
                    Name = "Preview Color Picker",
                    Default = Library.Theme.Default.Accent,
                    Flag = Library.NewFlag(),
                    Alpha = 0,
                    AlphaBar = true,
                    MainUI = nil,
                    Callback = function() end,
                }, Options or {})
                --
                local ColorPicker = {}
                --
                Label.ColorPickers[#Label.ColorPickers + 1] = ColorPicker
                --
                local ColorPickerFrame = Library:ColorPicker({
                    Name = Options.Name,
                    Default = Options.Default,
                    Flag = Options.Flag,
                    Alpha = Options.Alpha,
                    AlphaBar = Options.AlphaBar,
                    MainUI = Label.MainUI,
                    TabUI = Label.TabUI,
                    Callback = Options.Callback,
                    Parent = PreviewLabel,
                    Keybind = Label.KeybindState,
                    Count = #Label.ColorPickers,
                })
                --
                return ColorPickerFrame
            end
            --
            function Label:Keybind(Options)
                Options = Library:Validate({
                    Default = Enum.KeyCode.Backspace,
                    Mode = "Toggle",
                    UseMode = true,
                    HideFromList = false,
                    Blacklisted = {},
                    Hiding = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end,
                }, Options or {})
                --
                local Keybind = {}
                --
                Label.KeybindState = true
                --
                Library:Keybind({
                    Default = Options.Default,
                    Mode = Options.Mode,
                    HideFromList = Options.HideFromList,
                    Blacklisted = Options.Blacklisted,
                    Parent = PreviewLabel,
                    Toggle = Label,
                    UseMode = Options.UseMode,
                    MainUI = Label.MainUI,
                    TabUI = Label.TabUI,
                    Hiding = Options.Hiding,
                    ToggleState = Label.State,
                    Flag = Options.Flag,
                    Callback = Options.Callback,
                    Count = #Label.ColorPickers + 1,
                })
                --
                return Keybind
            end
            --
            --[[function Label:Update()
                LabelText.Size = UDim2.new(LabelText.Size.X.Scale, LabelText.Size.X.Offset, 0, math.huge)
                LabelText.Size = UDim2.new(LabelText.Size.X.Scale, LabelText.Size.X.Offset, 0, LabelText.TextBounds.Y)
                PreviewLabel.Size = UDim2.new(PreviewLabel.Size.X.Scale, PreviewLabel.Size.X.Offset, 0, LabelName.TextBounds.Y + 6)
            end]]
        end
        --
        --Label:Update()
        --
        if Options.Hidden then
            Label:SetVisible(false)
        end
        --
        return Label
    end
    --
    function Library:TextBox(Options)
        Options = Library:Validate({
            Default = "",
            Name = "Preview TextBox",
            Max = 32,
            Placeholder = "_",
            Parent = nil,
            Size = UDim2.new(1, 0, 0, 19),
            Position = UDim2.new(0, 0, 0, 0),
            NumbersOnly = false,
            ClearOnFocus = false,
            Hidden = false,
            TypedCheck = false,
            CheckIfPressedEnter = false,
            Risky = false,
            Flag = Library.NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        local TextBox = {
            Focused = false,
            Hovering = false,
            Hiding = false,
        }
        --
        Library.Flags[Options.Flag] = TextBox
        --
        local PreviewTextBox = Library:CreateObject("Frame", {
            Name = "PreviewTextBox",
            BackgroundTransparency = 1,
            Size = Options.Size,
            Position = Options.Position,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local TextBoxOutline = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "TextBoxOutline",
            Position = UDim2.new(0, -1, 0, 0),
            Size = UDim2.new(1, -19, 0, 19),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewTextBox
        })
        --
        local TextBoxInline = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "TextBoxInline",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Parent = TextBoxOutline
        })
        --
        local TextBoxMain = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "TextBoxMain",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Parent = TextBoxInline
        })
        --
        local TextBoxObject = Library:CreateObject("TextBox", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Library.Theme.Default.TextColor,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Text = "",
            ZIndex = 3,
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            SelectionStart = 1,
            ClearTextOnFocus = Options.ClearOnFocus,
            PlaceholderColor3 = Library.Theme.Default.TextColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            PlaceholderText = Options.Placeholder or "_",
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = TextBoxMain
        })
        --
        TextBox.Object = TextBoxObject
        --
        local UIPadding_6 = Library:CreateObject("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 5),
            Parent = TextBoxObject
        })
        --
        local UIPadding_7 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewTextBox
        })
        --
        do -- Functions
            function TextBox:SetVisible(Bool)
                TextBox.Hiding = not Bool
                TextBoxObject.Visible = Bool
                --
                Library:SetRowVisible(PreviewTextBox, Bool)
            end
            --
            function TextBox:Get()
                return TextBoxObject.Text
            end
            --
            -- Set：配置加载恢复用（LoadConfig 对每个 Flag 调 Set——TextBox 没有它则文本永远恢复不了）
            function TextBox:Set(Text)
                TextBoxObject.Text = tostring(Text or "")
                Options.Callback(TextBoxObject.Text)
            end
        end
        --
        do -- Connections
            Library:Connection(TextBoxObject:GetPropertyChangedSignal("Text"), function()
                TextBoxObject.Text = TextBoxObject.Text:sub(1, Options.Max)
                --
                if Options.NumbersOnly then
                    TextBoxObject.Text = TextBoxObject.Text:gsub('[^%d%.%-]+', '')
                end
                --
                if Options.TypedCheck then
                    Library.Flags[Options.Flag] = TextBox
                    Options.Callback(TextBoxObject.Text)
                end
                --
                TextBox.Focused = true
            end)
            --
            Library:Connection(TextBoxObject.Focused, function()
                if Library.UI.Faded then return end
                --
                if TextBox.Hiding then
                    TextBoxObject:ReleaseFocus()
                    --
                    return
                end
                --
                TextBox.Focused = true
                --
                TextBoxObject.TextColor3 = Library.Theme.Default.Accent
                --
                Library:AddTheme(TextBoxObject, {
                    TextColor3 = "Accent",
                })
                --
                TextBoxObject.PlaceholderText = ""
            end)
            --
            Library:Connection(TextBoxObject.FocusLost, function(EnterPressed)
                if Options.CheckIfPressedEnter and not EnterPressed then return end
                --
                TextBox.Focused = false
                TextBoxObject.PlaceholderText = Options.Placeholder or "_"
                --
                TextBoxObject.TextColor3 = Library.Theme.Default.TextColor
                --
                Library:AddTheme(TextBoxObject, {
                    TextColor3 = "TextColor",
                })
                --
                Library.Flags[Options.Flag] = TextBox
                Options.Callback(TextBoxObject.Text)
            end)
        end
        --
        if Options.Hidden then
            TextBox:SetVisible(false)
        end
        --
        return TextBox
    end
    --
    function Library:List(Options)
        Options = Library:Validate({
            Size = 100,
            Hidden = false,
            Flag = Library.NewFlag(),
            Callback = function() end
        }, Options or {})
        --
        local List = {
            CurrentValue = nil,
            CurrentValueName = nil,
        }
        --
        Library.Flags[Options.Flag] = List
        --
        local PreviewList = Library:CreateObject("Frame", {
            Name = "PreviewList",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Options.Size),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local UIPadding_11 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewList
        })
        --
        local ListOutline = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -19, 1, -18),
            Name = "ListOutline",
            Position = UDim2.new(0, -1, 0, 18),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewList
        })
        --
        local ListMain = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ListMain",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 4,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Parent = ListOutline
        })
        --
        local DownArrow = Library:CreateObject("ImageButton", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "DownArrow",
            Image = "rbxassetid://15540867448",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -10, 1, -9),
            Size = UDim2.new(0, 5, 0, 4),
            ZIndex = 7,
            Visible = false,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ListMain
        })
        --
        local UpArrow = Library:CreateObject("ImageButton", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "UpArrow",
            Image = "rbxassetid://15540851994",
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -10, 0, 5),
            Size = UDim2.new(0, 5, 0, 4),
            ZIndex = 7,
            Visible = false,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ListMain
        })
        --
        local ListScrolling = Library:CreateObject("ScrollingFrame", {
            ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
            MidImage = "rbxassetid://158362264",
            Active = true,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ScrollBarThickness = 5,
            Name = "ListScrolling",
            ZIndex = 3,
            TopImage = "rbxassetid://158362264",
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            BottomImage = "rbxassetid://158362264",
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            CanvasPosition = Vector2.new(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = ListOutline
        })
        --
        local UIListLayout_2 = Library:CreateObject("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = ListScrolling
        })
        --
        local TextBox = Library:TextBox({Parent = PreviewList, TypedCheck = true, Size = UDim2.new(1, 20, 0, 19), Position = UDim2.new(0, -20, 0, 0), Callback = function(Text)
            List:UpdateSection()
            --
            for _, Frame in ListScrolling:GetChildren() do
                if Frame:IsA("Frame") then
                    Frame.Visible = string.find(Frame.Name:lower(), Text:lower()) and true or false
                end
            end
        end})
        --
        do -- Functions
            function List:Get()
                return List.CurrentValueName
            end
            --
            function List:SetVisible(Bool)
                TextBox.Object.Visible = Bool
                --
                Library:SetRowVisible(PreviewList, Bool)
            end
            --
            function List:AddValue(Value, Icon)
                List.ListScrolling = ListScrolling; List.Entries = List.Entries or {}
                if ListScrolling:FindFirstChild(Value) then return end
                --
                local ListValue = {
                    Active = false,
                    Hovering = false,
                }
                --
                local InactiveValue = Library:CreateObject("Frame", {
                    Name = Value .. "1",
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 5,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = ListScrolling
                })
                --
                local Button_912 = Library:CreateObject("TextButton", {
                    FontFace = Library.UI.NewFont,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_9",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = InactiveValue
                })
                --
                local ValueName_1 = Library:CreateObject("TextLabel", {
                    FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    TextColor3 = Color3.fromRGB(208, 208, 208),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "ValueName_1",
                    BorderSizePixel = 0,
                    Text = Value,
                    RichText = true,
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 5,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = InactiveValue
                })
                --
                if Icon then
                    local Color = Icon.Color or Color3.fromRGB(255, 255, 255)
                    --
                    local IconImage = Library:CreateObject("ImageLabel", {
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Image = Icon.Image,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = Icon.Position or UDim2.new(0, 7, 0.5, 0),
                        BackgroundTransparency = 1,
                        Name = "BackImage",
                        Size = Icon.Size or UDim2.new(0, 13, 0, 13),
                        ZIndex = 5,
                        BorderSizePixel = 0,
                        ImageColor3 = Color,
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        Parent = InactiveValue
                    })
                    --
                    local UIPadding_135 = Library:CreateObject("UIPadding", {
                        PaddingLeft = UDim.new(0, 10),
                        Parent = IconImage
                    })
                end
                --
                ValueName_1.Text = Library:ClampString(Value, ValueName_1.AbsoluteSize.X - 25)
                List.Entries[Value] = ValueName_1
                --
                local UIPadding_13 = Library:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, (Icon and 25 or 10)),
                    Parent = ValueName_1
                })
                --
                do -- Functions
                    function ListValue:Activate()
                        if not ListValue.Active then
                            --
                            if List.CurrentValue then
                                List.CurrentValue:Deactivate()
                            end
                            --
                            ListValue.Active = true
                            --
                            ValueName_1.TextColor3 = Library.Theme.Default.Accent
                            ValueName_1.Text = "<b>" .. Value .. "</b>"
                            --
                            Library:AddTheme(ValueName_1, {
                                TextColor3 = "Accent",
                            })
                            --
                            List.CurrentValue = ListValue
                            List.CurrentValueName = Value
                            Library.Flags[Options.Flag] = List
                            Options.Callback(Value)
                        end
                    end
                    --
                    function ListValue:Deactivate()
                        if ListValue.Active then
                            ListValue.Active = false
                            ListValue.Hovering = false
                            ValueName_1.TextColor3 = Library.Theme.Default.TextColor
                            --
                            Library:AddTheme(ValueName_1, {
                                TextColor3 = "TextColor",
                            })
                        end
                    end
                end
                --
                do -- Connections
                    local OldText = ValueName_1.Text
                    --
                    Library:Connection(PreviewList:GetPropertyChangedSignal("AbsoluteSize"), function()
                        ValueName_1.Text = Library:ClampString(Value, ValueName_1.AbsoluteSize.X - 25)
                    end)
                    --
                    Library:Connection(InactiveValue.MouseEnter, function()
                        if Library.UI.Faded then return end
                        --
                        InactiveValue.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                        OldText = ValueName_1.Text
                        --
                        if not ListValue.Active then
                            ValueName_1.Text = "<b>" .. OldText .. "</b>"
                        end
                    end)
                    --
                    Library:Connection(InactiveValue.MouseLeave, function()
                        if Library.UI.Faded then return end
                        --
                        InactiveValue.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                        --
                        if not ListValue.Active then
                            ValueName_1.Text = OldText
                        end
                    end)
                    --
                    Library:OnClick(Button_912, function()
                        if Library.UI.Faded then return end
                        --
                        ListValue:Activate()
                    end)
                    --
                    -- 手机兜底：行 Frame 级触摸直接激活（按钮若被列表容器/层级问题挡住仍可选中）
                    -- Activate 内部有 Active 幂等检查，与上面的按钮点击双触发无害
                    if Library.IsMobile then
                        Library:Connection(InactiveValue.InputBegan, function(Input)
                            if Library.UI.Faded then return end
                            --
                            if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin then
                                ListValue:Activate()
                            end
                        end)
                    end
                end
            end
            --
            function List:RemoveValue(Value)
                if List.Entries then List.Entries[Value] = nil end
                for _, Object in ListScrolling:GetChildren() do
                    if Object.Name == Value .. "1" then
                        Object:Destroy()
                    end
                end
            end
            --
            function List:UpdateSection()
                local CanvasSize = ListScrolling.AbsoluteCanvasSize.Y
                local AbsoluteSize = ListMain.AbsoluteSize.Y
                --
                if CanvasSize > AbsoluteSize then
                    ListMain.Size = UDim2.new(1, -8, 1, -2)
                    UpArrow.Visible = not List:CheckArrows("Up")
                    DownArrow.Visible = not List:CheckArrows("Down")
                elseif CanvasSize == AbsoluteSize then
                    ListMain.Size = UDim2.new(1, -2, 1, -2)
                    UpArrow.Visible = false
                    DownArrow.Visible = false
                end
            end
            --
            function List:CheckArrows(Type)
                if Type == "Up" then
                    return ListScrolling.CanvasPosition == Vector2.new(0, 0)
                elseif Type == "Down" then
                    return ListScrolling.CanvasPosition == Vector2.new(0, ListScrolling.AbsoluteCanvasSize.Y - ListScrolling.AbsoluteSize.Y)
                else
                    return false
                end
            end
        end
        --
        List:UpdateSection()
        --
        do -- Connections
            Library:Connection(ListScrolling.ChildAdded, function()
                List:UpdateSection()
            end)
            --
            Library:Connection(ListScrolling.ChildRemoved, function()
                List:UpdateSection()
            end)
            --
            Library:Connection(ListOutline:GetPropertyChangedSignal("AbsoluteSize"), function()
                List:UpdateSection()
            end)
            --
            Library:Connection(ListScrolling:GetPropertyChangedSignal("AbsoluteSize"), function()
                List:UpdateSection()
            end)
            --
            Library:Connection(ListScrolling:GetPropertyChangedSignal("CanvasPosition"), function()
                List:UpdateSection()
            end)
            --
            Library:OnClick(UpArrow, function()
                if Library.UI.Faded then return end
                --
                if not UpArrow.Visible then return end
                --
                Library:TweenObject(ListScrolling, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, 0)})
            end)
            --
            Library:OnClick(DownArrow, function()
                if Library.UI.Faded then return end
                --
                if not DownArrow.Visible then return end
                --
                Library:TweenObject(ListScrolling, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, ListScrolling.AbsoluteCanvasSize.Y - ListScrolling.AbsoluteSize.Y)})
            end)
        end
        --
        if Options.Hidden then
            List:SetVisible(false)
        end
        --
        return List
    end
    --
    -- ==================== ModelGrid：3D 模型网格选择器（皮肤选择等） ====================
    function Library:ModelGrid(Options)
        Options = Library:Validate({
            Size = 300,
            CellSize = UDim2.fromOffset(124, 136),
            Search = false,
            Hidden = false,
            SelectedColor = Color3.fromRGB(255, 170, 30),
            Flag = Library.NewFlag(),
            Callback = function() end,
            RightClick = function() end,
        }, Options or {})
        --
        local Grid = {
            CurrentValueName = nil,
            Cells = {},
            Strokes = {},
            Hiding = false,
        }
        Grid._specs = {}
        Grid._handles = {}
        Grid._subLabels = {}
        Grid._viewports = {}
        Library.Flags[Options.Flag] = Grid
        --
        local PreviewGrid = Library:CreateObject("Frame", {
            Name = "PreviewModelGrid1",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Options.Size),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            Parent = Options.Parent,
        })
        --
        local topOffset = 0
        local searchText = ""
        if Options.Search then
            topOffset = 20
            Library:TextBox({
                Parent = PreviewGrid,
                TypedCheck = true,
                Size = UDim2.new(1, 20, 0, 19),
                Position = UDim2.new(0, -20, 0, 0),
                Callback = function(Text)
                    searchText = (Text or ""):lower()
                    for _, cell in pairs(Grid.Cells) do
                        local q = cell:GetAttribute("Query") or ""
                        cell.Visible = searchText == "" or string.find(q, searchText, nil, true) ~= nil
                    end
                end,
            })
        end
        --
        local GridOutline = Library:CreateObject("Frame", {
            Name = "ModelGridOutline1",
            Position = UDim2.new(0, -1, 0, topOffset),
            Size = UDim2.new(1, -19, 1, -topOffset + 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewGrid,
        })
        --
        local GridInline = Library:CreateObject("Frame", {
            Name = "ModelGridInline1",
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 4,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Parent = GridOutline,
        })
        --
        local GridScrolling = Library:CreateObject("ScrollingFrame", {
            ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
            MidImage = "rbxassetid://158362264",
            Active = true,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ScrollBarThickness = 4,
            Name = "ModelGridScrolling1",
            ZIndex = 4,
            TopImage = "rbxassetid://158362264",
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BottomImage = "rbxassetid://158362264",
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = GridInline,
        })
        Grid.GridScrolling = GridScrolling
        --
        Library:CreateObject("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            Parent = GridScrolling,
        })
        Library:CreateObject("UIGridLayout", {
            CellSize = Options.CellSize,
            CellPadding = UDim2.fromOffset(6, 6),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = GridScrolling,
        })
        --
        local layoutOrder = 0
        --
        do -- Functions
            function Grid:Get()
                return Grid.CurrentValueName
            end
            --
            function Grid:SetSelected(name)
                local prev = Grid.SelectedStroke
                if prev then
                    prev.Color = Grid.SelectedRarity or Color3.fromRGB(150, 155, 165)
                    prev.Transparency = 0.55
                    prev.Thickness = 1
                end
                local cell = name and Grid.Cells[name]
                if cell then
                    local stroke = cell:FindFirstChildOfClass("UIStroke")
                    if stroke then
                        stroke.Color = Options.SelectedColor
                        stroke.Transparency = 0
                        stroke.Thickness = 2
                        Grid.SelectedStroke = stroke
                        Grid.SelectedRarity = Grid.Strokes[name]
                    end
                    Grid.CurrentValueName = name
                else
                    Grid.CurrentValueName = nil
                    Grid.SelectedStroke = nil
                    Grid.SelectedRarity = nil
                end
                Library.Flags[Options.Flag] = Grid
            end
            --
            function Grid:AddItem(Item)
                if not Item or not Item.Name or Grid.Cells[Item.Name] then return end
                layoutOrder += 1
                local name = Item.Name
                local subText = Item.Sub or ""
                local rarity = Item.RarityColor or Color3.fromRGB(150, 155, 165)
                --
                local cell = Instance.new("Frame")
                cell.Name = name .. "_mg1"
                cell.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                cell.BorderSizePixel = 0
                cell.LayoutOrder = layoutOrder
                cell.ZIndex = 5
                cell:SetAttribute("Query", name:lower())
                cell.Parent = GridScrolling
                Grid.Cells[name] = cell
                Grid.Strokes[name] = rarity
                --
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = 1
                stroke.Color = rarity
                stroke.Transparency = 0.55
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                stroke.Parent = cell
                --
                local viewport = Instance.new("ViewportFrame")
                viewport.BackgroundTransparency = 1
                viewport.BorderSizePixel = 0
                viewport.Position = UDim2.new(0, 3, 0, 3)
                viewport.Size = UDim2.new(1, -6, 1, -38)
                viewport.ZIndex = 5
                viewport.Parent = cell
                Grid._viewports[name] = viewport
                --
                local bottom = Instance.new("Frame")
                bottom.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                bottom.BackgroundTransparency = 0.25
                bottom.BorderSizePixel = 0
                bottom.Size = UDim2.new(1, 0, 0, 32)
                bottom.Position = UDim2.new(0, 0, 1, -32)
                bottom.ZIndex = 6
                bottom.Parent = cell
                --
                local title = Instance.new("TextLabel")
                title.Name = "InfoBar"
                title.BackgroundTransparency = 1
                title.FontFace = Library.UI.NewFont
                title.Text = name
                title.TextColor3 = rarity
                title.TextSize = Library.UI.FontSize
                title.TextXAlignment = Enum.TextXAlignment.Center
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Size = UDim2.new(1, -8, 0, 16)
                title.Position = UDim2.new(0, 4, 0, 2)
                title.ZIndex = 7
                title.Parent = bottom
                --
                local subLabel = Instance.new("TextLabel")
                subLabel.BackgroundTransparency = 1
                subLabel.FontFace = Library.UI.NewFont
                subLabel.Text = subText
                subLabel.TextColor3 = Color3.fromRGB(165, 165, 165)
                subLabel.TextSize = 11
                subLabel.TextXAlignment = Enum.TextXAlignment.Center
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Size = UDim2.new(1, -8, 0, 12)
                subLabel.Position = UDim2.new(0, 4, 0, 18)
                subLabel.ZIndex = 7
                subLabel.Parent = bottom
                cell:SetAttribute("SubLabel", true)
                Grid._subLabels[name] = subLabel
                --
                Grid._specs[name] = Item
                --
                local button = Instance.new("TextButton")
                button.BackgroundTransparency = 1
                button.Text = ""
                button.AutoButtonColor = false
                button.Size = UDim2.new(1, 0, 1, 0)
                button.ZIndex = 8
                button.Parent = cell
                --
                -- 渲染 3D：视口需有实际尺寸（隐藏 Tab 中创建时等显示后再挂相机，否则可能永久黑屏）
                task.spawn(function()
                    local elapsed = 0
                    while viewport.AbsoluteSize.Y < 2 do
                        task.wait(0.1)
                        elapsed += 0.1
                        if not cell.Parent or elapsed > 10 then return end
                    end
                    pcall(function()
                        Grid._handles[name] = Library:CreateModelViewport(viewport, (Grid._specs[name] and Grid._specs[name].Viewport) or {})
                    end)
                end)
                --
                Library:OnClick(button, function()
                    if Library.UI.Faded then return end
                    Grid:SetSelected(name)
                    -- 用户回调在游戏信号线程触发，统一派发到注入身份线程（可建 Instance / 调外部逻辑）
                    Library:RunAsync(function()
                        Options.Callback(name, Grid._specs[name])
                    end)
                end, "ModelGrid Click")
                Library:Connection(button.MouseButton2Click, function()
                    if Library.UI.Faded then return end
                    if Options.RightClick then
                        Library:RunAsync(function()
                            Options.RightClick(name, Grid._specs[name])
                        end)
                    end
                end, "ModelGrid RightClick")
                Library:Connection(button.MouseEnter, function()
                    if Library.UI.Faded then return end
                    cell.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                    local h = Grid._handles[name]
                    if h and h.SetHover then h:SetHover(true) end
                end, "ModelGrid Enter")
                Library:Connection(button.MouseLeave, function()
                    cell.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    local h = Grid._handles[name]
                    if h and h.SetHover then h:SetHover(false) end
                end, "ModelGrid Leave")
            end
            --
            -- 局部刷新卡片（装备皮肤后同步左网格的 3D/颜色/副标题）
            function Grid:UpdateItem(name, Props)
                local cell = Grid.Cells[name]
                local spec = Grid._specs[name]
                if not cell or not spec then return end
                Props = Props or {}
                if Props.Sub ~= nil then
                    spec.Sub = Props.Sub
                    if Grid._subLabels[name] then Grid._subLabels[name].Text = Props.Sub end
                end
                if Props.Viewport ~= nil then spec.Viewport = Props.Viewport end
                local rarity = Props.RarityColor
                if rarity then
                    spec.RarityColor = rarity
                    Grid.Strokes[name] = rarity
                    local title = cell:FindFirstChild("InfoBar", true)
                    if title then title.TextColor3 = rarity end
                    if Grid.SelectedStroke then
                        local cellStroke = cell:FindFirstChildOfClass("UIStroke")
                        if not (cellStroke and cellStroke == Grid.SelectedStroke) then
                            cellStroke.Color = rarity
                        end
                    else
                        local cellStroke = cell:FindFirstChildOfClass("UIStroke")
                        if cellStroke then cellStroke.Color = rarity end
                    end
                end
                if Props.Viewport ~= nil then
                    local vp = Grid._viewports[name]
                    if vp then
                        for _, ch in ipairs(vp:GetChildren()) do
                            if ch:IsA("Camera") or ch:IsA("Model") or ch:IsA("ImageLabel") then ch:Destroy() end
                        end
                        Grid._handles[name] = nil
                        pcall(function()
                            Grid._handles[name] = Library:CreateModelViewport(vp, (Grid._specs[name] and Grid._specs[name].Viewport) or {})
                        end)
                    end
                end
            end
            --
            function Grid:RemoveItem(name)
                local cell = Grid.Cells[name]
                if cell then cell:Destroy() end
                Grid.Cells[name] = nil
                Grid.Strokes[name] = nil
                Grid._specs[name] = nil
                Grid._handles[name] = nil
                Grid._subLabels[name] = nil
                Grid._viewports[name] = nil
                if Grid.CurrentValueName == name then
                    Grid.CurrentValueName = nil
                    Grid.SelectedStroke = nil
                    Grid.SelectedRarity = nil
                end
            end
            --
            function Grid:Clear()
                for _, cell in pairs(Grid.Cells) do
                    cell:Destroy()
                end
                Grid.Cells = {}
                Grid.Strokes = {}
                Grid._specs = {}
                Grid._handles = {}
                Grid._subLabels = {}
                Grid._viewports = {}
                Grid.CurrentValueName = nil
                Grid.SelectedStroke = nil
                Grid.SelectedRarity = nil
                layoutOrder = 0
            end
            --
            function Grid:SetSub(name, text)
                if Grid._subLabels and Grid._subLabels[name] then
                    Grid._subLabels[name].Text = text or ""
                end
            end
            --
            function Grid:SetVisible(Bool)
                Grid.Hiding = not Bool
                --
                Library:SetRowVisible(PreviewGrid, Bool)
            end
        end
        --
        if Options.Hidden then
            PreviewGrid.Visible = false
        end
        --
        return Grid
    end
    --
    function Library:Button(Options)
        Options = Library:Validate({
            Name = "Preview Button",
            Confirmation = false,
            Parent = nil,
            Hidden = false,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 0),
            Risky = false,
            Callback = function() end
        }, Options or {})
        --
        local Button = {
            MouseDown = false,
            Hovering = false,
            WaitingForConfirm = false,
            Hiding = false,
            ConfirmationTime = 0,
            ConfirmationConnection = nil,
        }
        --
        local PreviewButton = Library:CreateObject("Frame", {
            Name = "PreviewButton",
            BackgroundTransparency = 1,
            Size = Options.Size,
            Position = Options.Position,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Options.Parent
        })
        --
        local ButtonOutline = Library:CreateObject("Frame", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "ButtonOutline",
            Position = UDim2.new(0, -1, 0, 0),
            Size = UDim2.new(1, -19, 0, 25),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = PreviewButton
        })
        --
        local ButtonInline = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ButtonInline",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            Parent = ButtonOutline
        })
        --
        local ButtonMain_1 = Library:CreateObject("Frame", {
            Size = UDim2.new(1, -2, 1, -2),
            Name = "ButtonMain_1",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            ZIndex = 3,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(220, 220, 220),
            Parent = ButtonInline
        })
        --
        local UIGradient_4 = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 39, 39)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 35))
            },
            Parent = ButtonMain_1
        })
        --
        local Button_6 = Library:CreateObject("TextButton", {
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            TextColor3 = Options.Risky and Library.Theme.Default.Risky or Library.Theme.Default.TextColor,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button_6",
            RichText = true,
            Text = "<b>" .. Options.Name .. "</b>",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 3,
            TextSize = Library.UI.FontSize,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = ButtonOutline
        })
        --
        if Options.Risky then
            Library:AddTheme(Button_6, {
                TextColor3 = "Risky",
            })
        end
        --
        local UIPadding_8 = Library:CreateObject("UIPadding", {
            PaddingLeft = UDim.new(0, 20),
            Parent = PreviewButton
        })
        --
        do -- Functions
            function Button:UpdateSize(Size)
                ButtonOutline.Size = Size
            end
            --
            function Button:UpdatePosition(Position)
                PreviewButton.Position = Position
            end
            --
            function Button:SetVisible(Bool)
                Button.Hiding = not Bool
                --
                Library:SetRowVisible(PreviewButton, Bool)
            end
            --
            function Button:ConfirmationStart()
                Button.MouseDown = true
                Button.WaitingForConfirm = true
                Button.ConfirmationTime = 3
                Button_6.Text = "<b>Are you sure?</b>"
                --
                if Button.ConfirmationConnection then
                    coroutine.close(Button.ConfirmationConnection)
                    Button.ConfirmationConnection = nil
                end
                --
                Button.ConfirmationConnection = coroutine.create(function()
                    for i = 1, 3 do 
                        task.wait(1)
                        --
                        Button.ConfirmationTime = Button.ConfirmationTime - 1
                        --
                        if Button.ConfirmationTime <= 0 then
                            Button_6.Text = "<b>" .. Options.Name .. "</b>"
                            --
                            if Button.MouseDown then
                                Library:TweenObject(Button_6, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextColor3 = Library.Theme.Default.TextColor})
                                --
                                Button.MouseDown = false
                                Button.WaitingForConfirm = false
                            end
                            --
                            break
                        end
                    end
                end)
                --
                coroutine.resume(Button.ConfirmationConnection)
            end
        end
        --
        do -- Connections
            Library:Connection(Button_6.MouseButton1Down, function()
                if Library.UI.Faded then return end
                --
                if Button.Hiding then return end
                --
                Library:TweenObject(ButtonMain_1, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(180, 180, 180)})
                --
                if Options.Confirmation then
                    if not Button.WaitingForConfirm then
                        Button:ConfirmationStart()
                    else
                        if Button.ConfirmationConnection then
                            coroutine.close(Button.ConfirmationConnection)
                            Button.ConfirmationConnection = nil
                        end
                        --
                        Options.Callback()
                        Button.MouseDown = true
                        Button.Hovering = false
                        Button.WaitingForConfirm = false
                        --
                        Library:TweenObject(ButtonMain_1, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(180, 180, 180)})
                        --
                        Button_6.Text = "<b>" .. Options.Name .. "</b>"
                    end
                else
                    Options.Callback()
                    Button.MouseDown = true
                end
            end)
            --
            Library:Connection(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and Button.MouseDown and not Button.WaitingForConfirm then
                    Button.Hovering = false
                    Button.MouseDown = false
                end
                --
                Library:TweenObject(ButtonMain_1, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
            end)
            --
            Library:Connection(ButtonOutline.MouseEnter, function()
                if Library.UI.Faded then return end
                --
                if not Button.MouseDown then
                    Button.Hovering = true
                    Library:TweenObject(ButtonMain_1, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                end	
            end)
            --
            Library:Connection(ButtonOutline.MouseLeave, function()
                if Library.UI.Faded then return end
                --
                if not Button.MouseDown then
                    Button.Hovering = false
                    Library:TweenObject(ButtonMain_1, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)})
                end	
            end)
        end
        --
        if Options.Hidden then
            Button:SetVisible(false)
        end
        --
        return Button
    end
    --
    function Library:Window(Options)
        Options = Library:Validate({
            Name = "gamesense",
            Size = UDim2.new(0, 700, 0, 612),
            MinResize = UDim2.new(0, 500, 0, 400),
            MaxResize = UDim2.new(0, 10000, 0, 10000),
            CloseBind = Enum.KeyCode.Insert,
        }, Options or {})
        --
        -- 手机屏幕按比例缩放窗口：默认 700x612 超出手机宽度，导致 UI 异常庞大且无法完整查看
        if Library.IsMobile then
            local vw, vh = Viewport.X, Viewport.Y
            local TargetW = math.clamp(vw * 0.92, 320, 700)
            local TargetH = TargetW * 612 / 700
            --
            if TargetH > vh * 0.72 then
                TargetH = vh * 0.72
                TargetW = math.clamp(TargetH * 700 / 612, 300, vw * 0.92)
            end
            --
            Options.Size = UDim2.fromOffset(math.floor(TargetW), math.floor(TargetH))
            Options.MinResize = UDim2.fromOffset(280, 220)
        end
        --
        local Window = {
            Visible = true,
            CurrentTab = nil,
            Tabs = {},
        }
        --
        local MainUI = Library:CreateObject("ScreenGui", {
            ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
            DisplayOrder = 1000,
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            Name = "\0",
            Parent = gethui()
        })
        --
        Library.UI.ScreenGUI = MainUI
        --
        local Outline = Library:CreateObject("Frame", {
            Name = "Outline",
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = Options.Size,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            Parent = MainUI
        })
        --
        Outline:SetAttribute("g", Window.CurrentTab)
        Library.UI.MainUI = Outline
        --
        Outline.Position = UDim2.fromOffset((Viewport.X / 2) - (Outline.Size.X.Offset / 2), (Viewport.Y / 2) - (Outline.Size.Y.Offset / 2))
        Outline.Active = true
        Outline.Draggable = true
        --
        -- ==================== Neverlose 原版风格指示器（屏幕左侧垂直居中，渐变竖线胶囊，复刻 source.luau CreateIndicator） ====================
        -- 规格：底 RGB(8,8,13)@0.2 · 角25 · 左侧3px上下渐隐竖线 · 图标+GothamBold文字 · 宽度随文本自适应 · 红/绿/白三色
        -- 手机适配：Library.IsMobile 时整体 0.78 缩放；挂 ScreenGui 根节点，锚定屏幕左缘，与菜单位置无关
        local IndHolder = Library:CreateObject("Frame", {
            Name = "RageIndicatorHolder",
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.new(0, 100, 0, 100),
            Parent = MainUI
        })
        --
        Library:CreateObject("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = IndHolder
        })
        --
        local IndItems, IndColors, IndOrder = {}, {
            red = Color3.fromRGB(255, 102, 105),
            green = Color3.fromRGB(135, 255, 143),
            white = Color3.fromRGB(186, 186, 186)
        }, 0
        --
        -- BuilderIcons 图标字体（Roblox 内置资产；失败则省略图标列，仅保留渐变竖线+文字）
        local IndIconFont = nil
        pcall(function()
            IndIconFont = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Bold)
        end)
        local IndIconMap = {
            RG = "crosshairs",
            DT = "chevron-large-right",
            BT = "chevron-large-left"
        }
        --
        local IndTextService = game:GetService("TextService")
        local function indMeasure(str, size)
            local ok, w = pcall(function()
                return IndTextService:GetTextSize(tostring(str), size, Enum.Font.GothamBold, Vector2.new(5000, 5000)).X
            end)
            if ok and w and w > 0 then return w end
            return #tostring(str) * size * 0.62
        end
        --
        -- key: 唯一标识；text: 缩写；param: 括号参数（可 nil）；colorType: "red"/"green"/"white"
        function Window:SetRageIndicator(key, active, text, param, colorType)
            colorType = IndColors[colorType] and colorType or "red"
            local col = IndColors[colorType]
            local s = Library.IsMobile and 0.78 or 1
            local item = IndItems[key]
            if active and not item then
                IndOrder = IndOrder + 1
                local h = math.floor(40 * s + 0.5)
                local pill = Library:CreateObject("Frame", {
                    Name = "RageInd_" .. tostring(key),
                    LayoutOrder = IndOrder,
                    BackgroundColor3 = Color3.fromRGB(8, 8, 13),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Size = UDim2.new(0, math.floor(85 * s + 0.5), 0, h),
                    Visible = false,
                    Parent = IndHolder
                })
                Library:CreateObject("UICorner", { CornerRadius = UDim.new(0, math.floor(25 * s + 0.5)), Parent = pill })
                local line = Library:CreateObject("Frame", {
                    Name = "Line",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = col,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, math.floor(2 * s + 0.5), 0.5, 0),
                    Size = UDim2.new(0, math.floor(3 * s + 0.5), 0.65, 0),
                    Parent = pill
                })
                Library:CreateObject("UICorner", { CornerRadius = UDim.new(0, math.floor(25 * s + 0.5)), Parent = line })
                Library:CreateObject("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = line })
                local icon
                if IndIconFont then
                    icon = Library:CreateObject("TextLabel", {
                        Name = "Icon",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        FontFace = IndIconFont,
                        Position = UDim2.new(0, math.floor(10 * s + 0.5), 0.5, 0),
                        Size = UDim2.new(0, math.floor(25 * s + 0.5), 0, math.floor(25 * s + 0.5)),
                        Text = IndIconMap[key] or "crosshairs",
                        TextColor3 = col,
                        TextSize = math.floor(21 * s + 0.5),
                        TextTransparency = 1,
                        TextWrapped = true,
                        Parent = pill
                    })
                end
                local abbr = Library:CreateObject("TextLabel", {
                    Name = "Abbr",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamBold,
                    Position = UDim2.new(0, math.floor(40 * s + 0.5), 0.5, 0),
                    Size = UDim2.new(1, -math.floor(40 * s + 0.5), 0, math.floor(25 * s + 0.5)),
                    Text = tostring(text or key),
                    TextColor3 = col,
                    TextSize = math.floor(20 * s + 0.5),
                    TextTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = pill
                })
                local paramLabel = Library:CreateObject("TextLabel", {
                    Name = "Param",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Font = Enum.Font.GothamMedium,
                    Position = UDim2.new(0, math.floor(40 * s + 0.5), 0.5, 0),
                    Size = UDim2.new(0, 0, 0, math.floor(25 * s + 0.5)),
                    Text = "",
                    TextColor3 = col,
                    TextSize = math.floor(13 * s + 0.5),
                    TextTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Visible = false,
                    Parent = pill
                })
                item = { pill = pill, line = line, icon = icon, abbr = abbr, param = paramLabel, shown = false }
                IndItems[key] = item
            end
            --
            if not item then return end
            --
            -- 宽度自适应：文本/参数变化时重算并缓动（等价原版 Indicator.Update，显示时无条件 tween 到目标宽度）
            local function fitWidth()
                local tw = indMeasure(text or key, math.floor(20 * s + 0.5))
                local newParam = param and tostring(param) or ""
                local pw = 0
                if newParam ~= "" then
                    pw = indMeasure(newParam, math.floor(13 * s + 0.5)) + math.floor(6 * s + 0.5)
                end
                item.param.Position = UDim2.new(0, math.floor(40 * s + tw + 6 * s + 0.5), 0.5, 0)
                Library:TweenObject(item.pill, TweenInfo.new(0.175), { Size = UDim2.new(0, math.floor(40 * s + tw + pw + 20 * s + 0.5), 0, item.pill.Size.Y.Offset) })
                return newParam
            end
            --
            if active then
                local newParam = fitWidth()
                item.param.Text = newParam
                item.param.Visible = newParam ~= ""
                item.abbr.Text = tostring(text or key)
                item.abbr.TextColor3 = col
                item.param.TextColor3 = col
                item.line.BackgroundColor3 = col
                if item.icon then
                    item.icon.TextColor3 = col
                end
                if not item.shown then
                    item.shown = true
                    item.pill.Visible = true
                    Library:TweenObject(item.pill, TweenInfo.new(0.175), { BackgroundTransparency = 0.2 })
                    Library:TweenObject(item.line, TweenInfo.new(0.175), { BackgroundTransparency = 0 })
                    local vslow = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
                    Library:TweenObject(item.abbr, vslow, { TextTransparency = 0.2, TextColor3 = col })
                    Library:TweenObject(item.param, vslow, { TextTransparency = 0.35, TextColor3 = col })
                    if item.icon then
                        Library:TweenObject(item.icon, vslow, { TextTransparency = 0.25, TextColor3 = col })
                    end
                end
            else
                if item.shown then
                    item.shown = false
                    Library:TweenObject(item.pill, TweenInfo.new(0.175), { BackgroundTransparency = 1 })
                    Library:TweenObject(item.line, TweenInfo.new(0.175), { BackgroundTransparency = 1 })
                    local vslow = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
                    Library:TweenObject(item.abbr, vslow, { TextTransparency = 1, TextColor3 = col })
                    Library:TweenObject(item.param, vslow, { TextTransparency = 1, TextColor3 = col })
                    if item.icon then
                        Library:TweenObject(item.icon, vslow, { TextTransparency = 1, TextColor3 = col })
                    end
                    task.delay(0.25, function()
                        if not item.shown then item.pill.Visible = false end
                    end)
                end
            end
        end
        --
        local Inline = Library:CreateObject("Frame", {
            Name = "Inline",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Parent = Outline
        })
        --
        local Inner = Library:CreateObject("Frame", {
            Name = "Inner",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = Inline
        })
        --
        local Outline_1 = Library:CreateObject("Frame", {
            Name = "Outline_1",
            Position = UDim2.new(0, 3, 0, 3),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -6, 1, -6),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(60, 60, 60),
            Parent = Inner
        })
        --
        local PatternHolder = Library:CreateObject("Frame", {
            Name = "PatternHolder",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            Parent = Outline_1
        })
        --
        local Pattern = Library:CreateObject("ImageLabel", {
            ImageColor3 = Color3.fromRGB(12, 12, 12),
            ScaleType = Enum.ScaleType.Tile,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Image = "rbxassetid://8547666218",
            BackgroundTransparency = 1,
            Name = "Pattern",
            Size = UDim2.new(1, 0, 1, 0),
            TileSize = UDim2.new(0, 8, 0, 8),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = PatternHolder
        })
        --
        local TopBarGradientHolder = Library:CreateObject("Frame", {
            Name = "TopBarGradientHolder",
            Position = UDim2.new(0, 1, 0, 1),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, -2, 0, 4),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Outline_1
        })
        --
        local GradientBar = Library:CreateObject("ImageLabel", {
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Image = "rbxassetid://8508019876",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 1, 0, 1),
            Name = "GradientBar",
            Size = UDim2.new(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = TopBarGradientHolder
        })
        --
        local UIGradient = Library:CreateObject("UIGradient", {
            Rotation = 90,
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0.550000011920929)
            },
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
            },
            Parent = TopBarGradientHolder
        })
        --
        local SideBarMain = Library:CreateObject("Frame", {
            Name = "SideBarMain",
            Position = UDim2.new(0, 1, 0, 5),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0, 75, 1, -6),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            ClipsDescendants = true,
            Parent = Outline_1
        })
        --
        local Outline_2 = Library:CreateObject("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Name = "Outline_2",
            Position = UDim2.new(1, 0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Parent = SideBarMain
        })
        --
        local Holder = Library:CreateObject("ScrollingFrame", {
            BackgroundTransparency = 1,
            Name = "Holder",
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            -- Tabs 滑轨：手机 tab 超出侧栏高度时可以上下滑动（滚动条隐藏，纯触摸/滚轮滚动）
            ScrollBarThickness = 0,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
            Parent = SideBarMain
        })
        --
        local UIListLayout = Library:CreateObject("UIListLayout", {
            Padding = UDim.new(0, 0),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = Holder
        })
        --
        -- 内容高度变化（增删 Tab）时自动扩展滚动范围
        Library:Connection(UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Holder.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end)
        --
        local UIPadding = Library:CreateObject("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            Parent = Holder
        })
        --
        local Inline_4 = Library:CreateObject("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            Name = "Inline_4",
            Position = UDim2.new(1, -1, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Parent = SideBarMain
        })
        --
        local ResizeButton = Library:CreateObject("TextButton", {
            FontFace = Library.UI.NewFont,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            Name = "Button",
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.new(0, 20, 0, 20),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            TextTransparency = 1,
            TextSize = Library.UI.FontSize,
            ZIndex = 5,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = Outline
        })
        --
        -- 手机上 20px 的缩放热区手指点不准，放大热区（仍然透明不可见）
        if Library.IsMobile then
            ResizeButton.Size = UDim2.fromOffset(36, 36)
        end
        --
        do -- Functions
            function Window:SetTab(Number)
                for Index, Tab in Window.Tabs do
                    if Index == Number then
                        if Window.CurrentTab ~= nil then
                            Window.CurrentTab:Deactivate()
                        end
                        --
                        Tab:Activate()
                    end
                end
            end
        end
        --
        do -- Connections
            -- 统一显隐入口：键盘 CloseBind 和手机悬浮球共用，保证悬浮球状态同步
            local function ToggleMainWindow(State)
                Window.Visible = State ~= nil and State or not Window.Visible
                --
                Library:Fade(Window.Visible, Library.Objects, Outline, 0.2)
                --
                if Window.FloatingBallCallback then
                    Window.FloatingBallCallback(Window.Visible)
                end
            end
            Window.ToggleMainWindow = ToggleMainWindow
            --
            Library:Connection(UserInputService.InputBegan, function(Input)
                if Input.KeyCode == Library.UI.CloseBind then
                    ToggleMainWindow()
                end
            end)
            --
            Library:Resizable(Outline, ResizeButton, Options.MinResize, Options.MaxResize)
            --
            -- 触摸拖动窗口：内置 Draggable 只响应鼠标，手机上无效（黑曜石同款 InputBegan→InputChanged 增量法）
            if Library.IsMobile then
                local DragStart, FramePos
                --
                Outline.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin then
                        -- 关键：只允许从空白区拖动。触摸点下有任何按钮/滚动区/Active 控件时直接放弃，
                        -- 否则手指按按钮时的轻微滑动会拖走窗口，导致点击全部失效（"按钮按不动"的根因）
                        local ok, GuiObjects = pcall(function()
                            return UserInputService:GetGuiObjectsAtPosition(Input.Position.X, Input.Position.Y)
                        end)
                        --
                        if ok and GuiObjects then
                            for _, obj in ipairs(GuiObjects) do
                                if obj:IsA("GuiButton") or obj:IsA("ScrollingFrame") or obj.Active then
                                    return
                                end
                            end
                        end
                        --
                        DragStart = Vector2.new(Input.Position.X, Input.Position.Y)
                        FramePos = Vector2.new(Outline.Position.X.Offset, Outline.Position.Y.Offset)
                    end
                end)
                --
                Library:Connection(UserInputService.InputChanged, function(Input)
                    if DragStart and Library:IsMoveInput(Input) and Input.UserInputType == Enum.UserInputType.Touch then
                        -- 滑条/色板/缩放拖动进行中时不拖窗口，避免抢输入
                        if Library.UI.DraggingGui or Library.UI.Resizing then
                            DragStart = nil
                            return
                        end
                        --
                        local Delta = Vector2.new(Input.Position.X, Input.Position.Y) - DragStart
                        Outline.Position = UDim2.fromOffset(FramePos.X + Delta.X, FramePos.Y + Delta.Y)
                    end
                end)
                --
                Library:Connection(UserInputService.InputEnded, function(Input)
                    if Input.UserInputType == Enum.UserInputType.Touch then
                        DragStart = nil
                    end
                end)
            end
        end
        --
        -- ==================== 手机悬浮开关球（显隐菜单的固定按钮） ====================
        -- 手机没有键盘，Insert 之类 CloseBind 无法触发；做一个可拖动的圆形悬浮钮，
        -- 风格对齐本 UI：深色底 + 三层描边 + 顶部渐变条 + Pattern 纹理 + 主题色
        if Library.IsMobile then
            local BallSize = 56
            --
            local Fab = Instance.new("TextButton")
            Fab.Name = "MobileToggleFab"
            Fab.AnchorPoint = Vector2.new(1, 1)
            Fab.Position = UDim2.new(1, -14, 1, -78)
            Fab.Size = UDim2.fromOffset(BallSize, BallSize)
            Fab.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            Fab.AutoButtonColor = false
            Fab.BorderSizePixel = 0
            Fab.Text = ""
            Fab.ZIndex = 200
            Fab.Parent = MainUI
            --
            local FabCorner = Instance.new("UICorner")
            FabCorner.CornerRadius = UDim.new(1, 0)
            FabCorner.Parent = Fab
            --
            -- 三层描边：还原窗口 Outline → Inline → Inner 的边框风格
            for StrokeIndex, StrokeColor in ipairs({Color3.fromRGB(0, 0, 0), Color3.fromRGB(60, 60, 60), Color3.fromRGB(40, 40, 40)}) do
                local Stroke = Instance.new("UIStroke")
                Stroke.Name = "FabStroke" .. StrokeIndex
                Stroke.Color = StrokeColor
                Stroke.Thickness = 1
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                Stroke.ZIndex = 200 + StrokeIndex
                Stroke.Parent = Fab
            end
            --
            local FabLabel = Instance.new("TextLabel")
            FabLabel.Name = "FabLabel"
            FabLabel.BackgroundTransparency = 1
            FabLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            FabLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            FabLabel.Size = UDim2.new(1, 0, 0, 18)
            FabLabel.Font = Enum.Font.GothamBold
            FabLabel.Text = "NX"
            FabLabel.TextSize = 16
            FabLabel.TextColor3 = Library.Theme.Default.Accent
            FabLabel.ZIndex = 202
            FabLabel.Parent = Fab
            --
            -- 拖动 + 点击（阈值 8px：原地松手 = 点击切换菜单，拖动 = 移动球）
            local PressStart, BallStartCenter, Moved = nil, nil, false
            --
            -- AnchorPoint (1,1)：Position offset 是"球右下角相对屏幕右下角"的负偏移
            local function GetBallCenter()
                local vx = Camera.ViewportSize
                return Vector2.new(vx.X + Fab.Position.X.Offset - BallSize / 2, vx.Y + Fab.Position.Y.Offset - BallSize / 2)
            end
            --
            local function SetBallCenter(Center)
                local vx = Camera.ViewportSize
                local cx = math.clamp(Center.X, BallSize / 2 + 4, vx.X - BallSize / 2 - 4)
                local cy = math.clamp(Center.Y, BallSize / 2 + 4, vx.Y - BallSize / 2 - 4)
                --
                Fab.Position = UDim2.new(1, cx + BallSize / 2 - vx.X, 1, cy + BallSize / 2 - vx.Y)
            end
            --
            Fab.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin then
                    PressStart = Vector2.new(Input.Position.X, Input.Position.Y)
                    BallStartCenter = GetBallCenter()
                    Moved = false
                end
            end)
            --
            Library:Connection(UserInputService.InputChanged, function(Input)
                if PressStart and Library:IsMoveInput(Input) and Input.UserInputType == Enum.UserInputType.Touch then
                    local Delta = Vector2.new(Input.Position.X, Input.Position.Y) - PressStart
                    --
                    if not Moved and Delta.Magnitude > 8 then
                        Moved = true
                    end
                    --
                    if Moved then
                        SetBallCenter(BallStartCenter + Delta)
                    end
                end
            end)
            --
            Library:Connection(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.Touch and PressStart then
                    local WasMoved = Moved
                    PressStart, BallStart, Moved = nil, nil, false
                    --
                    if not WasMoved then
                        if Window.ToggleMainWindow then
                            Window.ToggleMainWindow()
                        end
                    end
                end
            end)
            --
            -- 菜单显隐时同步球的外观：显示 = 收起样式（暗淡），隐藏 = 呼出样式（高亮呼吸感）
            Window.FloatingBallCallback = function(Visible)
                Library:TweenObject(Fab, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = Visible and 0.45 or 0})
                Library:TweenObject(FabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {TextTransparency = Visible and 0.35 or 0})
            end
        end
        --
        function Window:CreateTab(Options)
            Options = Library:Validate({
                Icon = "rbxassetid://8547236654",
            }, Options or {})
            --
            local Tab = {
                Hovering = false,
                Active = false,
                Index = Library.UI.TabIndex + 1,
                SubSectionEnabled = false,
                DropdownSectionEnabled = false,
                Position = "Bottom",
                Sides = {
                    Left = {
                        Sections = {},
                        Sizes = 0,
                    },
                    Right = {
                        Sections = {},
                        Sizes = 0,
                    }
                }
            }
            --
            Library.UI.TabIndex = Tab.Index
            --
            local TabActive = Library:CreateObject("Frame", {
                BackgroundTransparency = 1,
                Name = "TabActive",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -2, 0, 64),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = Holder
            })
            --
            local Outline_3 = Library:CreateObject("Frame", {
                Name = "Outline_3",
                Size = UDim2.new(1, 0, 1, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Visible = false,
                Parent = TabActive
            })
            --
            local Inline_1 = Library:CreateObject("Frame", {
                Size = UDim2.new(1, 1, 1, -2),
                Name = "Inline_1",
                Position = UDim2.new(0, 0, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Parent = Outline_3
            })
            --
            local Main = Library:CreateObject("Frame", {
                Size = UDim2.new(1, 1, 1, -2),
                Name = "Main",
                Position = UDim2.new(0, 0, 0, 1),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Parent = Inline_1
            })
            --
            local Pattern_1 = Library:CreateObject("ImageLabel", {
                ImageColor3 = Color3.fromRGB(12, 12, 12),
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Pattern_1",
                Image = "rbxassetid://8547666218",
                BackgroundTransparency = 1,
                TileSize = UDim2.new(0, 8, 0, 8),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = Main
            })
            --
            local Button = Library:CreateObject("TextButton", {
                FontFace = Font.new("rbxasset://fonts/families/Zekton.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button",
                Text = Options.Icon,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                TextColor3 = Color3.fromRGB(90, 90, 90),
                BorderSizePixel = 0,
                TextTransparency = 1,
                TextSize = Library.UI.FontSize,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = TabActive
            })
            --
            local Icon = Library:CreateObject("ImageLabel", {
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Name = "Button",
                Image = Options.Icon,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ImageColor3 = Color3.fromRGB(109, 109, 109),
                BorderSizePixel = 0,
                ZIndex = 3,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = TabActive
            })
            --
            local SectionsHolder = Library:CreateObject("Frame", {
                Name = "SectionsHolder",
                BackgroundTransparency = 1,
                Visible = true,
                Position = UDim2.new(0, 76, 0, 5),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -78, 1, -6),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ClipsDescendants = true,
                Parent = Outline_1
            })
            --
            local Left = Library:CreateObject("Frame", {
                BackgroundTransparency = 1,
                Name = "Left",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 1, 0, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ClipsDescendants = true,
                Parent = SectionsHolder
            })
            --
            local UIPadding_1 = Library:CreateObject("UIPadding", {
                PaddingTop = UDim.new(0, 19),
                PaddingBottom = UDim.new(0, 19),
                PaddingRight = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 21),
                Parent = Left
            })
            --
            local UIListLayout12 = Library:CreateObject("UIListLayout", {
                Padding = UDim.new(0, 19),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Left
            })
            --
            local Right = Library:CreateObject("Frame", {
                Name = "Right",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 1, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0.5, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ClipsDescendants = true,
                Parent = SectionsHolder
            })
            --
            local UIPadding_2 = Library:CreateObject("UIPadding", {
                PaddingTop = UDim.new(0, 19),
                PaddingBottom = UDim.new(0, 19),
                PaddingRight = UDim.new(0, 19),
                PaddingLeft = UDim.new(0, 10),
                Parent = Right
            })
            --
            local UIListLayout52 = Library:CreateObject("UIListLayout", {
                Padding = UDim.new(0, 19),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Right
            })
            --
            local SectionsHolder2 = Library:CreateObject("Frame", {
                Name = "SectionsHolder",
                BackgroundTransparency = 1,
                Visible = true,
                Position = UDim2.new(0, 76, 0, 5),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -78, 1, -6),
                BorderSizePixel = 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ClipsDescendants = true,
                Parent = Outline_1
            })
            --
            local SubSectionHolder = Library:CreateObject("Frame", {
                Name = "SubSectionHolder",
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(1, -39, 0, 61),
                BorderSizePixel = 0,
                ZIndex = 1,
                Visible = false,
                BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                Parent = SectionsHolder2
            })
            --
            Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
            Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
            SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
            --
            do -- Functions
                function Tab:MoveSides(State)
                    task.spawn(function()
                        if State then
                            if Tab.Position == "Bottom" then
                                Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
                                Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
                                SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
                            else
                                Left.Position = UDim2.new(0, 0, 0, -Left.AbsoluteSize.Y)
                                Right.Position = UDim2.new(0.5, 1, 0, -Right.AbsoluteSize.Y)
                                SubSectionHolder.Position = UDim2.new(0, 21, 0, -(SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y))
                            end
                            --
                            Library:TweenObject(SubSectionHolder, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 21, 0, 19)})
                            Library:TweenObject(Left, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
                            Library:TweenObject(Right, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 1, 0, 0)})
                        else
                            task.wait(0.001)
                            --
                            local SubSectionPosition = Tab.Position == "Bottom" and SectionsHolder2.AbsoluteSize.Y + 10 or -SectionsHolder2.AbsoluteSize.Y
                            local LeftPosition = Tab.Position == "Bottom" and Left.AbsoluteSize.Y + 10 or -Left.AbsoluteSize.Y
                            local RightPosition = Tab.Position == "Bottom" and Right.AbsoluteSize.Y + 10 or -Right.AbsoluteSize.Y
                            --
                            Library:TweenObject(SubSectionHolder, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 21, 0, SubSectionPosition)})
                            Library:TweenObject(Left, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, LeftPosition)})
                            Library:TweenObject(Right, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 1, 0, RightPosition)})
                        end
                    end)
                end
                --
                function Tab:Activate()
                    if not Tab.Active then
                        --
                        if Window.CurrentTab ~= nil then
                            Window.CurrentTab:Deactivate()
                        end
                        --
                        Tab.Active = true
                        Tab:MoveSides(true)
                        --
                        Library:TweenObject(Icon, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(210, 210, 210)})
                        Outline_3.Visible = true
                        --
                        Window.CurrentTab = Tab
                        Outline:SetAttribute("g", table.find(Window.Tabs, Tab))
                    end
                end
                --
                function Tab:Deactivate()
                    if Tab.Active then
                        Tab.Active = false
                        Tab.Hovering = false
                        Outline_3.Visible = false
                        Library:TweenObject(Icon, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(90, 90, 90)})
                        --
                        Tab:MoveSides(false)
                    end
                end
            end
            --
            do -- Connections
                Library:Connection(Outline:GetAttributeChangedSignal("g"), function()
                    if Outline:GetAttribute("g") > Tab.Index then
                        Tab.Position = "Top"
                    elseif Outline:GetAttribute("g") < Tab.Index then
                        Tab.Position = "Bottom"
                    end
                end)
                --
                Library:Connection(Outline:GetPropertyChangedSignal("AbsoluteSize"), function()
                    if not Tab.Active then
                        SubSectionHolder.Position = UDim2.new(0, 21, 0, SectionsHolder2.AbsoluteSize.Y + SubSectionHolder.AbsoluteSize.Y)
                        Left.Position = UDim2.new(0, 0, 0, Left.AbsoluteSize.Y)
                        Right.Position = UDim2.new(0.5, 1, 0, Right.AbsoluteSize.Y)
                    else
                        Left.Position = UDim2.new(0, 0, 0, 0)
                        Right.Position = UDim2.new(0.5, 1, 0, 0)
                    end
                end)
                --
                Library:OnClick(Button, function()
                    Tab:Activate()
                end)
                --
                Library:Connection(TabActive.MouseEnter, function()
                    if not Tab.Active then
                        Tab.Hovering = true
                        Library:TweenObject(Icon, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(168, 168, 168)})
                    end
                end)
                --
                Library:Connection(TabActive.MouseLeave, function()
                    if not Tab.Active then
                        Tab.Hovering = false
                        Library:TweenObject(Icon, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(90, 90, 90)})
                    end
                end)
            end
            --
            -- 暴露 Tab 内部容器：供外部嵌入整幅自定义面板（如内置服务器浏览器）
            Tab.Holders = { Outline1 = Outline_1, SectionsHolder = SectionsHolder, Left = Left, Right = Right }
            --
            Window.Tabs[#Window.Tabs + 1] = Tab
            --
            function Tab:Section(Options)
                Options = Library:Validate({
                    Name = "Preview Section",
                    Side = "Left",
                    Fill = false,
                    Size = UDim2.new(1, 0, 0, 40),
                    ParentOptions = {},
                    Icon = nil,
                    Parent = nil,
                }, Options or {})
                --
                local Section = {
                    Elements = {},
                    SizeButton = nil,
                    Hovering = false,
                    DragConnection = nil,
                    Left = {
                        Order = 1,
                    },
                    Right = {
                        Order = 1,
                    },
                }
                --
                local Parent = Options.Side == "Left" and Left or Right
                --
                local SectionOutline = Library:CreateObject("Frame", {
                    Name = "SectionOutline",
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 0, 0, Options.Size),
                    AutomaticSize = Options.Fill and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
                    BorderSizePixel = 0,
                    ZIndex = 1,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Options.Parent or Parent
                })
                --
                table.insert(Tab.Sides[Options.Side].Sections, SectionOutline)
                --
                task.delay(0.01, function()
                    if Options.Fill == false then
                        Tab.Sides[Options.Side].Sizes += SectionOutline.AbsoluteSize.Y + 19
                    end
                    --
                    if Options.Fill then
                        SectionOutline.Size = UDim2.new(1, 0, 1, -(Tab.Sides[Options.Side].Sizes))
                    else
                        SectionOutline.Size = UDim2.new(1, 0, 0, Options.Size)
                    end
                end)
                --
                local SectionInline = Library:CreateObject("Frame", {
                    Name = "SectionInline",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Parent = SectionOutline
                })
                --
                local SectionScrolling = Library:CreateObject("ScrollingFrame", {
                    ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
                    MidImage = "rbxassetid://158362264",
                    Active = true,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ScrollBarThickness = 5,
                    Size = UDim2.new(1, -2, 1, -2),
                    TopImage = "rbxassetid://158362264",
                    Position = UDim2.new(0, 1, 0, 1),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    CanvasPosition = Vector2.new(0, 0),
                    BottomImage = "rbxassetid://158362264",
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = SectionInline
                })
                --
                local UIListLayout_3 = Library:CreateObject("UIListLayout", {
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = SectionScrolling
                })
                --
                local UIPadding_8 = Library:CreateObject("UIPadding", {
                    PaddingTop = UDim.new(0, 19),
                    PaddingBottom = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 18),
                    PaddingLeft = UDim.new(0, 18),
                    Parent = SectionScrolling
                })
                --
                local SectionMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "SectionMain_1",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 1,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                    Parent = SectionInline
                })
                --
                local SectionFader = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    AnchorPoint = Vector2.new(0, 1),
                    Name = "SectionFader",
                    Position = UDim2.new(0, 0, 1, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                    Parent = SectionMain
                })
                --
                local DownArrow = Library:CreateObject("ImageButton", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "DownArrow",
                    Image = "rbxassetid://15540867448",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -10, 1, -9),
                    Size = UDim2.new(0, 5, 0, 4),
                    ZIndex = 4,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SectionMain
                })
                --
                local UpArrow = Library:CreateObject("ImageButton", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "UpArrow",
                    Image = "rbxassetid://15540851994",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -10, 0, 5),
                    Size = UDim2.new(0, 5, 0, 4),
                    ZIndex = 4,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SectionMain
                })
                --
                local UIGradient = Library:CreateObject("UIGradient", {
                    Rotation = -90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    },
                    Parent = SectionFader
                })
                --
                local SectionFader2 = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Name = "SectionFader",
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 3,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                    Parent = SectionMain
                })
                --
                local UIGradient = Library:CreateObject("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    },
                    Parent = SectionFader2
                })
                --
                local TitleInline = Library:CreateObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "TitleInline",
                    BorderSizePixel = 0,
                    Parent = SectionOutline,
                    Position = UDim2.new(0, 9, 0, 0),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 5
                })
                --
                local UIGradient2 = Library:CreateObject("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))
                    },
                    Parent = TitleInline
                })
                --
                local Title = Library:CreateObject("TextButton", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = SectionOutline,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -26, 0, 15),
                    ZIndex = 5,
                    FontFace = Library.UI.NewFont,
                    RichText = true,
                    Text = "<b>" .. Options.Name .. "</b>",
                    TextColor3 = Color3.fromRGB(198, 198, 198),
                    TextSize = Library.UI.FontSize,
                    TextStrokeTransparency = 1,
                    TextXAlignment = "Left"
                })
                --
                local ResizableButton_6 = Library:CreateObject("ImageButton", {
                    ImageColor3 = Color3.fromRGB(40, 40, 40),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    AnchorPoint = Vector2.new(1, 1),
                    Image = "http://www.roblox.com/asset/?id=127012144286347",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -2, 1, -2),
                    Name = "ResizableButton_6",
                    Size = UDim2.new(0, 6, 0, 6),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = SectionOutline
                })
                --
                Section.Elements = {
                    Name = Title,
                    ContentHolder = SectionScrolling,
                }
                --
                Title.Size = UDim2.fromOffset(Title.TextBounds.X, 15)
                TitleInline.Size = UDim2.new(0, Title.TextBounds.X + 6, 0, 2)
                --
                do -- Functions
                    function Section:UpdateSection()
                        local CanvasSizeFloored = math.floor(SectionScrolling.AbsoluteCanvasSize.Y)
                        local AbsoluteSizeFloored = math.floor(SectionMain.AbsoluteSize.Y)
                        --
                        if CanvasSizeFloored > AbsoluteSizeFloored then
                            SectionMain.Size = UDim2.new(1, -8, 1, -2)
                            UpArrow.Visible = not Section:CheckArrows("Up")
                            DownArrow.Visible = not Section:CheckArrows("Down")
                        elseif CanvasSizeFloored == AbsoluteSizeFloored then
                            SectionMain.Size = UDim2.new(1, -2, 1, -2)
                            UpArrow.Visible = false
                            DownArrow.Visible = false
                        end
                    end
                    --
                    function Section:CheckArrows(Type)
                        if Type == "Up" then
                            return SectionScrolling.CanvasPosition == Vector2.new(0, 0)
                        elseif Type == "Down" then
                            return SectionScrolling.CanvasPosition == Vector2.new(0, SectionScrolling.AbsoluteCanvasSize.Y - SectionScrolling.AbsoluteSize.Y)
                        else
                            return false
                        end
                    end
                    --
                    function Section:CalculateHeight(Section, Container)
                        local Padding = 10
                        local Height = 0
                        --
                        for _, Child in Container:GetChildren() do
                            if Child:IsA("GuiObject") and Child.Visible then
                                Height = Height + Child.AbsoluteSize.Y + Padding
                            end
                        end
                        --
                        Section.Size = UDim2.new(Section.Size.X.Scale, Section.Size.X.Offset, 0, math.clamp(Height + 31, 50, SectionOutline.Parent.AbsoluteSize.Y))
                    end
                    --
                    function Section:CalculateButton(Position)
                        if Section.SizeButton then return end
                        --
                        local ButtonOutline = Library:CreateObject("Frame", {
                            Name = "SectionOutline",
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Size = UDim2.new(0, 30, 0, 25),
                            BorderSizePixel = 0,
                            Position = Position,
                            ZIndex = 5,
                            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                            Parent = Library.UI.ScreenGUI
                        })
                        --
                        local ButtonMain = Library:CreateObject("Frame", {
                            Size = UDim2.new(1, -2, 1, -2),
                            Name = "SectionMain_1",
                            Position = UDim2.new(0, 1, 0, 1),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            ZIndex = 5,
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                            Parent = ButtonOutline
                        })
                        --
                        local ButtonText = Library:CreateObject("TextLabel", {
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = ButtonOutline,
                            Position = UDim2.new(0, 0, 0.5, -1),
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 5,
                            FontFace = Library.UI.NewFont,
                            RichText = true,
                            Text = "Calculate height",
                            TextColor3 = Color3.fromRGB(198, 198, 198),
                            TextSize = Library.UI.FontSize,
                            TextStrokeTransparency = 1,
                            TextXAlignment = "Left"
                        })
                        --
                        local UIPadding_82 = Library:CreateObject("UIPadding", {
                            PaddingLeft = UDim.new(0, 8),
                            Parent = ButtonText
                        })
                        --
                        local Button_945 = Library:CreateObject("TextButton", {
                            FontFace = Library.UI.NewFont,
                            TextColor3 = Color3.fromRGB(0, 0, 0),
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            Name = "Button_9",
                            BackgroundTransparency = 1,
                            ZIndex = 5,
                            Size = UDim2.new(1, 0, 1, 0),
                            BorderSizePixel = 0,
                            TextTransparency = 1,
                            TextSize = Library.UI.FontSize,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            Parent = ButtonOutline
                        })
                        --
                        Section.SizeButton = ButtonOutline
                        ButtonOutline.Size = UDim2.fromOffset(ButtonText.TextBounds.X + 16, 25)
                        ButtonOutline.BackgroundTransparency = 1
                        ButtonMain.BackgroundTransparency = 1
                        ButtonText.TextTransparency = 1
                        Button_945.TextTransparency = 1
                        --
                        do -- Connections
                            Library:Connection(Button_945.MouseEnter, function()
                                Section.Hovering = true
                            end)
                            --
                            Library:Connection(Button_945.MouseLeave, function()
                                Section.Hovering = false
                            end)
                            --
                            Library:OnClick(Button_945, function()
                                Section:CalculateHeight(SectionOutline, SectionScrolling)
                                Library:Fade(false, Library:GetObjectsTable(ButtonOutline, true), ButtonOutline, 0.1)
                                --
                                task.delay(Library.UI.TweenSpeed, function()
                                    for _, Value in ButtonOutline:GetDescendants() do
                                        Value:Destroy()
                                    end
                                    --
                                    ButtonOutline:Destroy()
                                    Section.SizeButton = nil
                                end)
                            end)
                        end
                        --
                        Library:Fade(true, Library:GetObjectsTable(ButtonOutline, true), ButtonOutline, 0.1)
                    end
                end
                --
                do -- Connections
                    Library:Connection(SectionScrolling.ChildAdded, function()
                        Section:UpdateSection()
                    end)
                    --
                    Library:Connection(SectionScrolling.ChildRemoved, function()
                        Section:UpdateSection()
                    end)
                    --
                    Library:Connection(SectionOutline:GetPropertyChangedSignal("AbsoluteSize"), function()
                        Section:UpdateSection()
                    end)
                    --
                    Library:Connection(RunService.PreRender, function() -- fastest option
                        if SectionOutline.AbsoluteSize.Y >= ((SectionOutline.Parent.AbsoluteSize.Y - Tab.Sides[Options.Side].Sizes) - 38) then
                            if Tab.SubSectionEnabled then
                                if #Tab.Sides[Options.Side].Sections <= 3 then
                                    SectionOutline.Size = UDim2.new(1, 0, 1, -Tab.Sides[Options.Side].Sizes)
                                end
                            else
                                SectionOutline.Size = UDim2.new(1, 0, 1, -Tab.Sides[Options.Side].Sizes)
                            end
                        end
                        --
                        for _, Child in SectionOutline.Parent:GetChildren() do
                            if Child:IsA("Frame") and Child ~= SectionOutline then
                                if Library:CheckFrameFirst(SectionOutline, Child) then
                                    if Child.AbsoluteSize.Y >= ((Child.Parent.AbsoluteSize.Y - Tab.Sides[Options.Side].Sizes) - 38) then
                                        Child.Size = UDim2.new(Child.Size.X.Scale, Child.Size.X.Offset, 0, math.max(50, (SectionOutline.Parent.AbsoluteSize.Y - SectionOutline.AbsoluteSize.Y) - 57))
                                    end
                                    --
                                    if Child.AbsoluteSize.Y == 50 and (SectionOutline.AbsoluteSize.Y == SectionOutline.Parent.AbsoluteSize.Y - 107) then
                                        SectionOutline.Size = UDim2.new(SectionOutline.Size.X.Scale, SectionOutline.Size.X.Offset, 0, SectionOutline.Parent.AbsoluteSize.Y - 107)
                                    end
                                end
                            end
                        end
                    end)
                    --
                    Library:Connection(SectionScrolling:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
                        Section:UpdateSection()
                    end)
                    --
                    Library:Connection(SectionScrolling:GetPropertyChangedSignal("CanvasPosition"), function()
                        UpArrow.Visible = not Section:CheckArrows("Up")
                        DownArrow.Visible = not Section:CheckArrows("Down")
                    end)
                    --
                    Library:OnClick(UpArrow, function()
                        if not UpArrow.Visible then return end
                        --
                        Library:TweenObject(SectionScrolling, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, 0)})
                    end)
                    --
                    Library:OnClick(DownArrow, function()
                        if not DownArrow.Visible then return end
                        --
                        Library:TweenObject(SectionScrolling, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {CanvasPosition = Vector2.new(0, SectionScrolling.AbsoluteCanvasSize.Y - SectionScrolling.AbsoluteSize.Y)})
                    end)
                    --
                    do -- Dragging
                        Library:Connection(Title.MouseButton1Down, function()
                            Title.TextColor3 = Library.Theme.Default.Accent
                            --
                            Section.DragConnection = Library:Connection(UserInputService.InputChanged, function(Input)
                                if Library:IsMoveInput(Input) then
                                    local SelectedOptions = {["SubSection"] = Options.ParentOptions, ["Other"] = {Left, Right}}
                                    local Selected = Tab.SubSectionEnabled and "SubSection" or "Other"
                                    local NewLeft, NewRight = SelectedOptions[Selected][1], SelectedOptions[Selected][2]
                                    local Parent2 = Library:SectionDragging(NewLeft) and NewLeft or Library:SectionDragging(NewRight) and NewRight
                                    local ParentName = Parent2 == NewLeft and "Left" or "Right"
                                    local TopHalf = Parent2 and Input.Position.Y < Parent2.AbsoluteSize.Y / 2
                                    --
                                    if not Parent2 then return end
                                    --
                                    SectionOutline.Parent = Parent2
                                    --
                                    for _, SectionChild in Parent2:GetChildren() do
                                        if SectionChild:IsA("Frame") and SectionChild.Visible then
                                            if SectionChild == SectionOutline then
                                                if TopHalf then
                                                    SectionChild.LayoutOrder = (Tab.DropdownSectionEnabled and Parent2 == NewLeft and 2) or 1
                                                else
                                                    SectionChild.LayoutOrder = Section[ParentName].Order + 1
                                                end
                                            else
                                                if SectionChild.Name == "DropdownSection1" then
                                                    SectionChild.LayoutOrder = 1
                                                else
                                                    SectionChild.LayoutOrder = Section[ParentName].Order
                                                    Section[ParentName].Order = 3
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                        end)
                    end
                    --
                    do -- Resizing
                        Library:Connection(ResizableButton_6.MouseButton2Click, function()
                            Section:CalculateButton(UDim2.fromOffset(ResizableButton_6.AbsolutePosition.X + ResizableButton_6.AbsoluteSize.X + 4, ResizableButton_6.AbsolutePosition.Y + ResizableButton_6.AbsoluteSize.Y + GuiService:GetGuiInset().Y))
                        end)
                        --
                        Library:Connection(ResizableButton_6.MouseButton1Down, function()
                            ResizableButton_6.ImageColor3 = Library.Theme.Default.Accent
                            SectionInline.BackgroundColor3 = Library.Theme.Default.Accent
                            --
                            SectionOutline.Size = UDim2.new(SectionOutline.Size.X.Scale, SectionOutline.Size.X.Offset, 0, SectionOutline.AbsoluteSize.Y)
                        end)
                        --
                        Library:Connection(UserInputService.InputBegan, function(Input)
                            if Library:IsClickInput(Input) and Section.SizeButton and not Section.Hovering then
                                Library:Fade(false, Library:GetObjectsTable(Section.SizeButton, true), Section.SizeButton, 0.1)
                                --
                                task.delay(Library.UI.TweenSpeed, function()
                                    for _, Value in Section.SizeButton:GetDescendants() do
                                        Value:Destroy()
                                    end
                                    --
                                    Section.SizeButton:Destroy()
                                    Section.SizeButton = nil
                                end)
                            end
                        end)
                        --
                        Library:Resizable(SectionOutline, ResizableButton_6, UDim2.fromOffset(200, 50), UDim2.fromOffset(SectionOutline.Parent.AbsoluteSize.X - 29, SectionOutline.Parent.AbsoluteSize.Y - 38), Library.UI.SectionResizeIncrements, false, true, 0.01)
                    end
                    --
                    Library:Connection(UserInputService.InputEnded, function(Input)
                        if Library:IsReleaseInput(Input) then
                            if Section.DragConnection then Section.DragConnection:Disconnect() Section.DragConnection = nil end
                            Section.Left.Order = 1
                            Section.Right.Order = 1
                            Title.TextColor3 = Color3.fromRGB(198, 198, 198)
                            --
                            ResizableButton_6.ImageColor3 = Color3.fromRGB(40, 40, 40)
                            SectionInline.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        end
                    end)
                end
                --
                Section.__Outline = SectionOutline; Section.__Scrolling = SectionScrolling; Section.__Fill = Options.Fill and true or false
                Library.AllSections = Library.AllSections or {}; table.insert(Library.AllSections, Section)
                --
                return setmetatable(Section, Library.Sections)
            end
            --
            function Tab:SubSection(Options)
                Options = Library:Validate({
                    Name = "Preview Sub Section",
                    Options = {},
                    Flag = Library:NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local SubSection = {
                    CurrentSection = nil,
                    Sections = {},
                    List = {},
                    Elements = {},
                }
                --
                SubSectionHolder.Visible = true
                Tab.SubSectionEnabled = true
                Tab.Sides.Right.Sizes = 0
                Tab.Sides.Left.Sizes = 0
                --
                local SectionOutline = Library:CreateObject("Frame", {
                    Name = "SectionOutline",
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    ZIndex = 1,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = SubSectionHolder
                })
                --
                SectionOutline:SetAttribute("g", 0)
                --
                local SectionInline = Library:CreateObject("Frame", {
                    Name = "SectionInline",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    ZIndex = 2,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Parent = SectionOutline
                })
                --
                local SectionMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "SectionMain_1",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                    Parent = SectionInline
                })
                --
                local UIPadding_81 = Library:CreateObject("UIPadding", {
                    PaddingRight = UDim.new(0, 10),
                    PaddingLeft = UDim.new(0, 10),
                    Parent = SectionMain
                })
                --
                local UIListLayout52 = Library:CreateObject("UIListLayout", {
                    Padding = UDim.new(0, -0),
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    Parent = SectionMain
                })
                --
                local TitleInline = Library:CreateObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "TitleInline",
                    BorderSizePixel = 0,
                    Parent = SectionOutline,
                    Position = UDim2.new(0, 9, 0, 0),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 5
                })
                --
                local UIGradient2 = Library:CreateObject("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))
                    },
                    Parent = TitleInline
                })
                --
                local Title = Library:CreateObject("TextLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = SectionOutline,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -26, 0, 15),
                    ZIndex = 5,
                    FontFace = Library.UI.NewFont,
                    RichText = true,
                    Text = "<b>" .. Options.Name .. "</b>",
                    TextColor3 = Color3.fromRGB(198, 198, 198),
                    TextSize = Library.UI.FontSize,
                    TextStrokeTransparency = 1,
                    TextXAlignment = "Left"
                })
                --
                for Index, Value in Options.Options do
                    local SectionItem = {
                        Active = false,
                        Hovering = false,
                        Position = "Bottom",
                        Elements = {},
                    }
                    --
                    local SectionsHolder2 = Library:CreateObject("Frame", {
                        Name = "SectionsHolder",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Position = UDim2.new(0, 97, 0, 33),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, -112, 1, -34),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        ClipsDescendants = true,
                        Parent = Outline_1
                    })
                    --
                    local UIPadding_141 = Library:CreateObject("UIPadding", {
                        PaddingTop = UDim.new(0, 52),
                        Parent = SectionsHolder2
                    })
                    --
                    local Left2 = Library:CreateObject("Frame", {
                        BackgroundTransparency = 1,
                        Name = "Left2",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = SectionsHolder2
                    })
                    --
                    local UIPadding_11 = Library:CreateObject("UIPadding", {
                        PaddingTop = UDim.new(0, 19),
                        PaddingBottom = UDim.new(0, 19),
                        PaddingRight = UDim.new(0, 12),
                        Parent = Left2
                    })
                    --
                    local UIListLayout12 = Library:CreateObject("UIListLayout", {
                        Padding = UDim.new(0, 19),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Left2
                    })
                    --
                    local Right2 = Library:CreateObject("Frame", {
                        Name = "Right2",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = SectionsHolder2
                    })
                    --
                    local UIPadding_21 = Library:CreateObject("UIPadding", {
                        PaddingTop = UDim.new(0, 19),
                        PaddingBottom = UDim.new(0, 19),
                        PaddingRight = UDim.new(0, 6),
                        PaddingLeft = UDim.new(0, 6),
                        Parent = Right2
                    })
                    --
                    local UIListLayout521 = Library:CreateObject("UIListLayout", {
                        Padding = UDim.new(0, 19),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = Right2
                    })
                    --
                    local iconPrimary = type(Value) == "table" and Value[1] or Value
                    local Icon = Library:CreateObject("ImageButton", {
                        ImageColor3 = Color3.fromRGB(100, 100, 100),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Icon",
                        Image = iconPrimary,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 75, 0, 57),
                        ZIndex = 2,
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = SectionMain
                    })
                    --
                    -- 图标候选链：Value 可传字符串或 {候选1, 候选2, ...}
                    -- 新上传图片可能还在审核：循环重试所有候选，审核通过后自动显示
                    local iconCandidates = type(Value) == "table" and Value or {Value}
                    if #iconCandidates > 1 then
                        task.spawn(function()
                            local idx = 1
                            Icon.Image = iconCandidates[1]
                            while Icon.Parent do
                                local t = 0
                                while Icon.Parent and not Icon.IsLoaded and t < 4 do
                                    task.wait(0.1)
                                    t += 0.1
                                end
                                if not Icon.Parent then return end
                                if Icon.IsLoaded then return end
                                idx = (idx % #iconCandidates) + 1
                                Icon.Image = iconCandidates[idx]
                            end
                        end)
                    end
                    --
                    Left2.Position = UDim2.new(0, -(Left2.AbsoluteSize.X * 2), 0, 0)
                    Right2.Position = UDim2.new(0.5, -(Right2.AbsoluteSize.X * 2), 0, 0)
                    --
                    do -- Functions
                        function SectionItem:MoveSides(State)
                            task.spawn(function()
                                if State then
                                    if SectionItem.Position == "Bottom" then
                                        Left2.Position = UDim2.new(0, (Left2.AbsoluteSize.X * 2), 0, 0)
                                        Right2.Position = UDim2.new(0.5, (Right2.AbsoluteSize.X * 2), 0, 0)
                                    else
                                        Left2.Position = UDim2.new(0, -(Left2.AbsoluteSize.X * 2), 0, 0)
                                        Right2.Position = UDim2.new(0.5, -(Right2.AbsoluteSize.X * 2), 0, 0)
                                    end
                                    --
                                    SectionsHolder2.Visible = Outline:GetAttribute("g") == table.find(Window.Tabs, Tab)
                                    Library:TweenObject(Left2, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 1, 0, 0)})
                                    Library:TweenObject(Right2, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 1, 0, 0)})
                                else
                                    task.wait(0.001)
                                    --
                                    local LeftPosition = SectionItem.Position == "Bottom" and (Left2.AbsoluteSize.X * 2) + 10 or -(Left2.AbsoluteSize.X * 2)
                                    local RightPosition = SectionItem.Position == "Bottom" and (Right2.AbsoluteSize.X * 2) + 10 or -(Right2.AbsoluteSize.X * 2)
                                    --
                                    Library:TweenObject(Left2, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, LeftPosition, 0, 0)})
                                    Library:TweenObject(Right2, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, RightPosition, 0, 0)})
                                end
                            end)
                        end
                        --
                        function SectionItem:Activate()
                            if not SectionItem.Active then
                                if SubSection.CurrentSection ~= nil then
                                    SubSection.CurrentSection:Deactivate()
                                end
                                --
                                SectionItem.Active = true
                                --
                                SectionItem:MoveSides(true)
                                Icon.ImageColor3 = Color3.fromRGB(188, 188, 188)
                                --
                                SubSection.CurrentSection = SectionItem
                                SectionOutline:SetAttribute("g", Index)
                            end
                        end
                        --
                        function SectionItem:Deactivate()
                            if SectionItem.Active then
                                SectionItem.Active = false
                                SectionItem.Hovering = false
                                --
                                SectionItem:MoveSides(false)
                                Icon.ImageColor3 = Color3.fromRGB(93, 93, 93)
                            end
                        end
                        --
                        function SectionItem:Section(Options)
                            Options = Library:Validate({
                                Name = "Preview Section",
                                Side = "Left",
                                Size = 40,
                            }, Options or {})
                            --
                            local Section = Tab:Section({
                                Name = Options.Name,
                                Side = Options.Side,
                                Fill = Options.Fill,
                                Size = Options.Size,
                                Parent = Options.Side == "Left" and Left2 or Right2,
                                ParentOptions = {Left2, Right2},
                                Icon = Icon,
                            })
                            --
                            return Section
                        end
                    end
                    --
                    do -- Connections
                        Library:Connection(Outline:GetPropertyChangedSignal("AbsoluteSize"), function()
                            if not SectionItem.Active then
                                Left2.Position = UDim2.new(0, Left2.AbsoluteSize.X * 2, 0, 0)
                                Right2.Position = UDim2.new(0.5, Right2.AbsoluteSize.X * 2, 0, 0)
                            end
                        end)
                        --
                        Library:Connection(Outline:GetAttributeChangedSignal("g"), function()
                            if Outline:GetAttribute("g") == table.find(Window.Tabs, Tab) then
                                SectionsHolder2.Visible = true
                            end
                        end)
                        --
                        Library:Connection(SectionOutline:GetAttributeChangedSignal("g"), function()
                            if SectionOutline:GetAttribute("g") > Index then
                                SectionItem.Position = "Top"
                            elseif SectionOutline:GetAttribute("g") < Index then
                                SectionItem.Position = "Bottom"
                            end
                        end)
                        --
                        Library:Connection(Left:GetPropertyChangedSignal("AbsolutePosition"), function()
                            if SectionItem.Active then
                                Left2.Position = Left.Position
                            end
                        end)
                        --
                        Library:Connection(Right:GetPropertyChangedSignal("AbsolutePosition"), function()
                            if SectionItem.Active then
                                Right2.Position = Right.Position
                            end
                        end)
                        --
                        Library:OnClick(Icon, function()
                            SectionItem:Activate()
                        end)
                        --
                        Library:Connection(Icon.MouseEnter, function()
                            if not SectionItem.Active then
                                SectionItem.Hovering = true
                                Icon.ImageColor3 = Color3.fromRGB(124, 124, 124)
                            end
                        end)
                        --
                        Library:Connection(Icon.MouseLeave, function()
                            if not SectionItem.Active then
                                SectionItem.Hovering = false
                                Icon.ImageColor3 = Color3.fromRGB(93, 93, 93)
                            end
                        end)
                    end
                    --
                    if SubSection.CurrentSection == nil then
                        SectionItem:Activate()
                    end
                    --
                    SubSection.Sections[#SubSection.Sections + 1] = setmetatable(SectionItem, Library.Sections)
                end
                --
                SubSection.Elements = {
                    Name = Title,
                    ContentHolder = SectionMain,
                }
                --
                TitleInline.Size = UDim2.new(0, Title.TextBounds.X + 6, 0, 2)
                --
                return table.unpack(SubSection.Sections)
            end
            --
            function Tab:ImageDropdown(Options)
                Options = Library:Validate({
                    Name = "Weapon Type",
                    Options = {},
                    Default = nil,
                    Flag = Library:NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local ImageDropdown = {
                    Open = false,
                    Active = false,
                    Hovering = false,
                    CurrentItem = nil,
                    Scrollable = false,
                    Hiding = false,
                    ContentLength = Library:GetTableLength(Options.Options),
                }
                --
                Tab.DropdownSectionEnabled = true
                Tab.Sides.Left.Sizes = 70
                --
                local DropdownImageOutline = Library:CreateObject("Frame", {
                    Name = "DropdownSection1",
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 51),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Left
                })
                --
                local DropdownChecker = Library:CreateObject("Frame", {
                    Name = "DropdownChecker",
                    Position = UDim2.new(0, 0, 1, 0),
                    Visible = false,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 1),
                    BorderSizePixel = 0,
                    Parent = DropdownImageOutline
                })
                --
                local DropdownImageInline = Library:CreateObject("Frame", {
                    Name = "DropdownImageInline",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                    Parent = DropdownImageOutline
                })
                --
                local DropdownImageMain = Library:CreateObject("Frame", {
                    Size = UDim2.new(1, -2, 1, -2),
                    Name = "DropdownImageMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(23, 23, 23),
                    Parent = DropdownImageInline
                })
                --
                local Button_92 = Library:CreateObject("TextButton", {
                    FontFace = Library.UI.NewFont,
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Button_9",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    TextTransparency = 1,
                    TextSize = Library.UI.FontSize,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = DropdownImageMain
                })
                --
                local DownArrow = Library:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "DownArrow",
                    Size = UDim2.new(0, 5, 0, 4),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = "rbxassetid://15540867448",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -6, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ImageColor3 = Color3.fromRGB(210, 210, 210),
                    Parent = DropdownImageMain
                })
                --
                local Icon = Library:CreateObject("ImageLabel", {
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "Icon",
                    Size = UDim2.new(0, 50, 1, -6),
                    AnchorPoint = Vector2.new(1, 0.5),
                    Image = "rbxassetid://18657040454",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -14, 0.5, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    ImageColor3 = Color3.fromRGB(210, 210, 210),
                    Parent = DropdownImageMain
                })
                --
                local ToggleHolder = Library:CreateObject("Frame", {
                    Name = "ToggleHolder",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 100, 1, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Parent = DropdownImageMain
                })
                --
                local ActualToggleButton = Library:Toggle({
                    Default = false,
                    Name = "Global",
                    SectionName = "ToggleHolder",
                    Parent = ToggleHolder,
                    Risky = false,
                    MainUI = Outline,
                    ZIndex = 2,
                    TabUI = SideBarMain,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    UseToggleOutline = true,
                    Hidden = false,
                    Flag = Options.Flag .. "Extra",
                    Callback = function(State)
                        if ImageDropdown.CurrentItem then
                            ImageDropdown.CurrentItem:SetValue(State)
                            Library.Flags[Options.Flag] = ImageDropdown.CurrentItem
                            Options.Callback(ImageDropdown.CurrentItem.Name, ImageDropdown.CurrentItem.CurrentValue)
                        end
                    end,
                })
                --
                local UIPadding = Library:CreateObject("UIPadding", {
                    PaddingLeft = UDim.new(0, 18),
                    Parent = ToggleHolder
                })
                --
                local TitleInline = Library:CreateObject("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Name = "TitleInline",
                    BorderSizePixel = 0,
                    Parent = DropdownImageOutline,
                    Position = UDim2.new(0, 9, 0, 0),
                    Size = UDim2.new(0, 0, 0, 2),
                    ZIndex = 5
                })
                --
                local UIGradient2 = Library:CreateObject("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(19, 19, 19)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 24))
                    },
                    Parent = TitleInline
                })
                --
                local Title = Library:CreateObject("TextButton", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    Parent = DropdownImageOutline,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -26, 0, 15),
                    ZIndex = 5,
                    FontFace = Library.UI.NewFont,
                    RichText = true,
                    Text = "<b>" .. Options.Name .. "</b>",
                    TextColor3 = Color3.fromRGB(198, 198, 198),
                    TextSize = Library.UI.FontSize,
                    TextStrokeTransparency = 1,
                    TextXAlignment = "Left"
                })
                --
                local DropdownMainOutline = Library:CreateObject("Frame", {
                    Name = "DropdownMainOutline",
                    Position = UDim2.new(0, 0, 0, 0),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 50,
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                    Parent = Library.UI.ScreenGUI
                })
                --
                local DropdownMain = Library:CreateObject("Frame", {
                    Name = "DropdownMain",
                    Position = UDim2.new(0, 1, 0, 1),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    ZIndex = 50,
                    ClipsDescendants = true,
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    Parent = DropdownMainOutline
                })
                --
                DropdownMainOutline.BackgroundTransparency = 1
                DropdownMain.BackgroundTransparency = 1
                --
                local UIListLayout_9 = Library:CreateObject("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownMain
                })
                --
                Title.Size = UDim2.fromOffset(Title.TextBounds.X, 15)
                TitleInline.Size = UDim2.new(0, Title.TextBounds.X + 6, 0, 2)
                --
                for Index, Value in Options.Options do
                    local DropdownOption = {
                        Hovering = false,
                        Active = false,
                        CurrentValue = false,
                        Name = Index,
                    }
                    --
                    local ButtonMain = Library:CreateObject("Frame", {
                        Name = "DropdownMain",
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 30),
                        BorderSizePixel = 0,
                        ZIndex = 50,
                        ClipsDescendants = true,
                        LayoutOrder = Value.Order,
                        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                        Parent = DropdownMain
                    })
                    --
                    local Button_925 = Library:CreateObject("TextButton", {
                        FontFace = Library.UI.NewFont,
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Button_9",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        BorderSizePixel = 0,
                        ZIndex = 50,
                        TextTransparency = 1,
                        TextSize = Library.UI.FontSize,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = ButtonMain
                    })
                    --
                    ButtonMain.BackgroundTransparency = 1
                    --
                    local ToggleButton = Library:Toggle({
                        Default = false,
                        Name = Index,
                        SectionName = "ImageDropdown",
                        Parent = ButtonMain,
                        Risky = false,
                        MainUI = Outline,
                        ZIndex = 50,
                        TabUI = SideBarMain,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 15, 0.5, 0),
                        Hidden = false,
                        Callback = function(State)

                        end,
                    })
                    --
                    local IconButton = Library:CreateObject("ImageLabel", {
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        Name = "Icon",
                        Size = UDim2.new(0, 35, 1, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        Image = Value.Icon,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -10, 0.5, 0),
                        ZIndex = 50,
                        BorderSizePixel = 0,
                        ImageColor3 = Color3.fromRGB(124, 124, 124),
                        Parent = ButtonMain
                    })
                    --
                    do -- Functions
                        function DropdownOption:Activate()
                            if not DropdownOption.Active then
                                if ImageDropdown.CurrentItem ~= nil then
                                    ImageDropdown.CurrentItem:Deactivate()
                                end
                                --
                                DropdownOption.Active = true
                                ImageDropdown.CurrentItem = DropdownOption
                                --
                                IconButton.ImageColor3 = Color3.fromRGB(210, 210, 210)
                                Icon.Image = Value.Icon
                                ActualToggleButton:SetName(Index)
                            end
                        end
                        --
                        function DropdownOption:Deactivate()
                            if DropdownOption.Active then
                                DropdownOption.Active = false
                                DropdownOption.Hovering = false
                                ImageDropdown.CurrentItem = nil
                                --
                                ButtonMain.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                                IconButton.ImageColor3 = Color3.fromRGB(124, 124, 124)
                            end
                        end
                        --
                        function DropdownOption:SetValue(Value)
                            ToggleButton:Set(Value)
                            DropdownOption.CurrentValue = Value
                        end
                        --
                        function DropdownOption:Get()
                            return {Name = DropdownOption.Name, Value = DropdownOption.CurrentValue}
                        end
                    end
                    --
                    do -- Connections
                        Library:Connection(ButtonMain.MouseEnter, function()
                            ButtonMain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                            IconButton.ImageColor3 = Color3.fromRGB(210, 210, 210)
                        end)
                        --
                        Library:Connection(ButtonMain.MouseLeave, function()
                            ButtonMain.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                            --
                            if DropdownOption.Active then return end
                            --
                            IconButton.ImageColor3 = Color3.fromRGB(124, 124, 124)
                        end)
                        --
                        Library:OnClick(Button_925, function()
                            DropdownOption:Activate()
                            ActualToggleButton:Set(DropdownOption.CurrentValue)
                        end)
                    end
                    --
                    if Options.Default == Index then
                        DropdownOption:Activate()
                    end
                    --
                    Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                end
                --
                do -- Functions
                    function ImageDropdown:Toggle(Fast)
                        local Fast = Fast or false
                        local OldValues = Library.Objects[DropdownMainOutline]
                        --
                        if ImageDropdown.Open then
                            if Fast then
                                Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                                DropdownMainOutline.Size = UDim2.new(0, DropdownImageOutline.AbsoluteSize.X, 0, 0)
                                DropdownMainOutline.Visible = false
                                Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                            else
                                Library:Fade(false, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                                Library:TweenObject(DropdownMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownImageOutline.AbsoluteSize.X, 0, 0)}, function()
                                    DropdownMainOutline.Visible = false
                                    Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], true}
                                end)
                            end
                        else
                            Library.Objects[DropdownMainOutline] = {DropdownMainOutline, OldValues[2], false}
                            DropdownMainOutline.Visible = true
                            --
                            if Fast then
                                Library:Fade(true, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0)
                                DropdownMainOutline.Size = UDim2.new(0, DropdownImageOutline.AbsoluteSize.X, 0, (ImageDropdown.ContentLength * 30) + 2)
                            else
                                Library:Fade(true, Library:GetObjectsTable(DropdownMainOutline, true), DropdownMainOutline, 0.1)
                                Library:TweenObject(DropdownMainOutline, TweenInfo.new(Library.UI.TweenSpeed, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(0, DropdownImageOutline.AbsoluteSize.X, 0, (ImageDropdown.ContentLength * 30) + 2)})
                            end	
                        end
                        --
                        ImageDropdown.Open = not ImageDropdown.Open
                    end
                    --
                    function ImageDropdown:Update()
                        DropdownMainOutline.Size = UDim2.new(0, DropdownImageOutline.AbsoluteSize.X, 0, DropdownMainOutline.AbsoluteSize.Y)
                        DropdownMainOutline.Position = UDim2.new(0, DropdownImageOutline.AbsolutePosition.X, 0, ((DropdownImageOutline.AbsolutePosition.Y + DropdownImageOutline.AbsoluteSize.Y) + GuiService:GetGuiInset().Y + 2))
                    end
                end
                --
                do -- Dropdown Connections
                    ImageDropdown:Update()
                    --
                    Library:Connection(DropdownImageOutline:GetPropertyChangedSignal("AbsolutePosition"), ImageDropdown.Update)
                    Library:Connection(DropdownImageOutline:GetPropertyChangedSignal("AbsoluteSize"), ImageDropdown.Update)
                    --
                    local StartingY = DropdownImageOutline.AbsolutePosition.Y
                    local MainUIStartingY = Outline.AbsolutePosition.Y
                    --
                    Library:Connection(DropdownImageOutline:GetPropertyChangedSignal("AbsolutePosition"), function()
                        if not ImageDropdown.Open then return end
                        --
                        local CurrentY = DropdownImageOutline.AbsolutePosition.Y
                        local MainUICurrentY = Outline.AbsolutePosition.Y
                        --
                        if MainUICurrentY ~= MainUIStartingY then
                            MainUIStartingY = MainUICurrentY
                            StartingY = CurrentY
                            --
                            return
                        end
                        --
                        if Library.UI.Resizing then
                            return
                        end
                        --
                        if CurrentY ~= StartingY then
                            ImageDropdown:Toggle(true)
                        end
                        --
                        StartingY = CurrentY
                    end)
                end
                --
                do -- Connections
                    Library:OnClick(Button_92, function()
                        ImageDropdown:Toggle()
                    end)
                end
            end
            --
            function Sections:Dropdown(Options)
                Options = Library:Validate({
                    Default = "None",
                    Name = "Preview Dropdown",
                    Content = {},
                    Hiding = false,
                    Risky = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local Dropdown = Library:Dropdown({
                    Default = Options.Default,
                    Name = Options.Name,
                    Content = Options.Content,
                    MainUI = Outline,
                    TabUI = SideBarMain,
                    Hiding = Options.Hiding,
                    Risky = Options.Risky,
                    Flag = Options.Flag,
                    Callback = Options.Callback,
                    Parent = self.Elements.ContentHolder
                })
                --
                return Dropdown
            end
            --
            function Sections:MultiBox(Options)
                Options = Library:Validate({
                    Default = {},
                    Name = "Preview MultiBox",
                    Content = {},
                    Hiding = false,
                    Risky = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local Dropdown = Library:MultiBox({
                    Default = Options.Default,
                    Name = Options.Name,
                    Content = Options.Content,
                    MainUI = Outline,
                    TabUI = SideBarMain,
                    Hiding = Options.Hiding,
                    Risky = Options.Risky,
                    Flag = Options.Flag,
                    Callback = Options.Callback,
                    Parent = self.Elements.ContentHolder
                })
                --
                return Dropdown
            end
            --
            function Sections:Toggle(Options)
                Options = Library:Validate({
                    Default = false,
                    Name = "Preview Toggle",
                    Risky = false,
                    Hidden = false,
                    Flag = Library:NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local Toggle = Library:Toggle({
                    Default = Options.Default,
                    Name = Options.Name,
                    SectionName = self.Elements.Name,
                    Parent = self.Elements.ContentHolder,
                    Risky = Options.Risky,
                    MainUI = Outline,
                    TabUI = SideBarMain,
                    Hidden = Options.Hidden,
                    Flag = Options.Flag,
                    Callback = Options.Callback
                })
                --
                return Toggle
            end
            --
            function Sections:Slider(Options)
                Options = Library:Validate({
                    Name = "Preview Slider",
                    Min = 0,
                    Max = 100,
                    Default = 1,
                    Decimal = 1,
                    Ending = "",
                    Hidden = false,
                    UseIcons = true,
                    Disable = {},
                    Risky = false,
                    OverrideLimit = false, -- new parameter to allow values beyond max
                    Flag = Library.NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local Slider = Library:Slider({
                    Name = Options.Name,
                    Min = Options.Min,
                    Max = Options.Max,
                    Default = Options.Default,
                    Decimal = Options.Decimal,
                    Ending = Options.Ending,
                    Hidden = Options.Hidden,
                    Parent = self.Elements.ContentHolder,
                    Risky = Options.Risky,
                    Disable = Options.Disable,
                    OverrideLimit = Options.OverrideLimit, -- pass the parameter
                    Flag = Options.Flag,
                    UseIcons = Options.UseIcons,
                    Callback = Options.Callback
                })
                --
                return Slider
            end
            --
            function Sections:Label(Options)
                Options = Library:Validate({
                    Message = "Preview Label",
                    Risky = false,
                    Side = "Left",
                    Hidden = false,
                }, Options or {})
                --
                local Label = Library:Label({
                    Message = Options.Message,
                    Side = Options.Side,
                    Risky = Options.Risky,
                    MainUI = Outline,
                    Hidden = Options.Hidden,
                    TabUI = SideBarMain,
                    SectionName = self.Elements.Name,
                    Callback = Options.Callback,
                    Parent = self.Elements.ContentHolder
                })
                --
                return Label
            end
            --
            function Sections:TextBox(Options)
                Options = Library:Validate({
                    Default = "",
                    Name = "Preview TextBox",
                    Max = 32,
                    NumbersOnly = false,
                    ClearOnFocus = false,
                    CheckIfPressedEnter = false,
                    TypedCheck = false,
                    Placeholder = "_",
                    Risky = false,
                    Hidden = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local TextBox = Library:TextBox({
                    Default = Options.Default,
                    Name = Options.Name,
                    Max = Options.Max,
                    NumbersOnly = Options.NumbersOnly,
                    ClearOnFocus = Options.ClearOnFocus,
                    CheckIfPressedEnter = Options.CheckIfPressedEnter,
                    TypedCheck = Options.TypedCheck,
                    Placeholder = Options.Placeholder,
                    Risky = Options.Risky,
                    Hidden = Options.Hidden,
                    Parent = self.Elements.ContentHolder,
                    Flag = Options.Flag,
                    Callback = Options.Callback
                })
                --
                return TextBox
            end
            --
            function Sections:List(Options)
                Options = Library:Validate({
                    Size = 100,
                    Hidden = false,
                    Flag = Library.NewFlag(),
                    Callback = function() end
                }, Options or {})
                --
                local TextBox = Library:List({
                    Size = Options.Size,
                    Hidden = Options.Hidden,
                    Parent = self.Elements.ContentHolder,
                    Flag = Options.Flag,
                    Callback = Options.Callback
                })
                --
                return TextBox
            end
            --
            function Sections:ModelGrid(Options)
                Options = Library:Validate({
                    Size = 300,
                    CellSize = UDim2.fromOffset(124, 136),
                    Search = false,
                    Hidden = false,
                    SelectedColor = Color3.fromRGB(255, 170, 30),
                    Flag = Library.NewFlag(),
                    Callback = function() end,
                    RightClick = function() end,
                }, Options or {})
                --
                local Grid = Library:ModelGrid({
                    Size = Options.Size,
                    CellSize = Options.CellSize,
                    Search = Options.Search,
                    Hidden = Options.Hidden,
                    SelectedColor = Options.SelectedColor,
                    Parent = self.Elements.ContentHolder,
                    Flag = Options.Flag,
                    Callback = Options.Callback,
                    RightClick = Options.RightClick,
                })
                --
                return Grid
            end
            --
            function Sections:Button(Options)
                Options = Library:Validate({
                    Name = "Preview Button",
                    Confirmation = false,
                    Risky = false,
                    Hidden = false,
                    Callback = function() end
                }, Options or {})
                --
                local Button = Library:Button({
                    Name = Options.Name,
                    Confirmation = Options.Confirmation,
                    Risky = Options.Risky,
                    Hidden = Options.Hidden,
                    Parent = self.Elements.ContentHolder,
                    Callback = Options.Callback
                })
                --
                return Button
            end
            --
            return Tab
        end
        --
        function Library:CreateWatermark()
            local Watermark = {
                CanUse = true,
                Tick = tick(),
                RefreshTick = tick(),
            }
            --
            local MainWatermark = Library:CreateObject("Frame", {
                Name = "Watermark",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0, 400, 0, 20),
                BorderSizePixel = 0,
                ZIndex = 10000,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = Library.UI.ScreenGUI
            }, true)
            --
            local UIGradient = Library:CreateObject("UIGradient", {
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.25, 0.6119999885559082),
                    NumberSequenceKeypoint.new(0.5, 0.625),
                    NumberSequenceKeypoint.new(0.75, 0.625),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = MainWatermark
            }, true)
            --
            local UIStroke = Library:CreateObject("UIStroke", {
                Parent = MainWatermark
            }, true)
            --
            local UIGradient_1 = Library:CreateObject("UIGradient", {
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.232, 0.4000000059604645),
                    NumberSequenceKeypoint.new(0.5, 0.4000000059604645),
                    NumberSequenceKeypoint.new(0.75, 0.4000000059604645),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = UIStroke
            }, true)
            --
            local WatermarkText = Library:CreateObject("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(208, 208, 208),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Text = "gamesense",
                Name = "Text",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex = 10000,
                RichText = true,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = MainWatermark
            }, true)
            --
            local Stroke = Library:CreateObject("UIStroke", {
                Parent = WatermarkText,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Color = Color3.fromRGB(50, 50, 50),
            }, true)
            --
            local UIPadding = Library:CreateObject("UIPadding", {
                PaddingRight = UDim.new(0, 22),
                PaddingLeft = UDim.new(0, 22),
                Parent = WatermarkText
            }, true)
            --
            do -- Functions
                function Library:ToggleWatermark(State)
                    Watermark.CanUse = State
                    MainWatermark.Visible = State
                end
                --
                function Library:UpdateWatermark(Text)
                    if Watermark.CanUse and not MainWatermark.Visible then MainWatermark.Visible = true end
                    --
                    WatermarkText.Text = tostring(Text)
                    MainWatermark.Size = UDim2.new(0, WatermarkText.TextBounds.X + 44, 0, MainWatermark.Size.Y.Offset)
                    MainWatermark.Position = UDim2.new(1, -(MainWatermark.Size.X.Offset) - 5, 0, 5)
                end
            end
            --
            local R, G, B = Library.Theme.Default.Accent.R * 255, Library.Theme.Default.Accent.G * 255, Library.Theme.Default.Accent.B * 255
            --
            local _pingInit = 0; pcall(function() _pingInit = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end); Library:UpdateWatermark(("<font color='rgb(%d, %d, %d)'>NERX Beta</font>  <font size='10'>FPS</font> 60  <font size='10'>Time</font> %s  <font size='10'>Ping</font> <font color='rgb(%d, %d, %d)'>%s</font>"):format(R, G, B, os.date("%X"), R, G, B, tostring(_pingInit)))
            --
            Library:Notify({
                Message = ("<font color='rgb(%d, %d, %d)'>十分感谢你的购买以及对 Nerx 团队的支持</font>"):format(R, G, B),
                Position = "Top Left",
                Delay = 8
            })
            --
            do -- Connections
                Library:Connection(RunService.PostSimulation, function()
                    if Library.UI.Initialized and MainWatermark.Visible then
                        local R, G, B = Library.Theme.Default.Accent.R * 255, Library.Theme.Default.Accent.G * 255, Library.Theme.Default.Accent.B * 255
                        local FPS = math.floor(1 / math.abs(Watermark.Tick - tick()))
                        --
                        Watermark.Tick = tick()
                        --
                        if (tick() - Watermark.RefreshTick) > Library.UI.WatermarkRefreshRate then
                            local _pingVal = 0; pcall(function() _pingVal = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end); Library:UpdateWatermark(("<font color='rgb(%d, %d, %d)'>NERX Beta</font>  <font size='10'>FPS</font> %d  <font size='10'>Time</font> %s  <font size='10'>Ping</font> <font color='rgb(%d, %d, %d)'>%s</font>"):format(R, G, B, FPS, os.date("%X"), R, G, B, tostring(_pingVal)))
                            --
                            Watermark.RefreshTick = tick()
                        end
                    end
                end)
            end
        end
        --
        local _notifyQueue = nil
        local function pumpNotifyQueue()
            if not _notifyQueue then return end
            while #_notifyQueue > 0 do
                local opts = table.remove(_notifyQueue, 1)
                pcall(function() Library:_NotifyImpl(opts) end)
            end
        end
        --
        function Library:Notify(Options)
            Options = Library:Validate({
                Message = "Notification",
                Delay = 3,
                Position = "Top Left",
            }, Options or {})
            --
            -- 游戏 hook 线程无 Plugin capability 时无法创建 UI：转队列由心跳（注入线程）重放
            local canCreate = pcall(function()
                local probe = Instance.new("Folder")
                probe.Parent = Library.UI.ScreenGUI
                probe:Destroy()
            end)
            if not canCreate then
                if not _notifyQueue then
                    _notifyQueue = {}
                    game:GetService("RunService").Heartbeat:Connect(pumpNotifyQueue)
                end
                table.insert(_notifyQueue, Options)
                return
            end
            Library:_NotifyImpl(Options)
        end
        --
        function Library:_NotifyImpl(Options)
            --
            local Notification = {}
            local Path = Options.Position == "Top Left" and Library.UI.Notifications.TopLeft or Library.UI.Notifications.Middle
            --
            local NotificationFrameObject = Library:CreateObject("Frame", {
                Name = "Watermark",
                Position = UDim2.new(0, 0, 0, 0),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Size = UDim2.new(0, 400, 0, 20),
                BorderSizePixel = 0,
                ZIndex = 10000,
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                Parent = Library.UI.ScreenGUI
            }, true)
            --
            NotificationFrameObject.BackgroundTransparency = 1
            --
            local UIGradient = Library:CreateObject("UIGradient", {
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.25, 0.6119999885559082),
                    NumberSequenceKeypoint.new(0.5, 0.625),
                    NumberSequenceKeypoint.new(0.75, 0.625),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = NotificationFrameObject
            }, true)
            --
            local UIStroke = Library:CreateObject("UIStroke", {
                Parent = NotificationFrameObject
            }, true)
            --
            UIStroke.Transparency = 1
            --
            local UIGradient_1 = Library:CreateObject("UIGradient", {
                Transparency = NumberSequence.new{
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.232, 0.4000000059604645),
                    NumberSequenceKeypoint.new(0.5, 0.4000000059604645),
                    NumberSequenceKeypoint.new(0.75, 0.4000000059604645),
                    NumberSequenceKeypoint.new(1, 1)
                },
                Parent = UIStroke
            }, true)
            --
            local NotificationText = Library:CreateObject("TextLabel", {
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(208, 208, 208),
                BorderColor3 = Color3.fromRGB(0, 0, 0),
                Text = Options.Message,
                Name = "Text",
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 10000,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                RichText = true,
                TextSize = 14,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = NotificationFrameObject
            }, true)
            --
            local Stroke = Library:CreateObject("UIStroke", {
                Parent = NotificationText,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Color = Color3.fromRGB(50, 50, 50),
            }, true)
            --
            Stroke.Transparency = 1
            --
            NotificationText.TextTransparency = 1
            --
            local UIPadding = Library:CreateObject("UIPadding", {
                PaddingRight = UDim.new(0, 22),
                PaddingLeft = UDim.new(0, 22),
                Parent = NotificationText
            }, true)
            --
            local NotificationFrame = {
                Class = "Notification",
                Object = NotificationFrameObject,
                Text = NotificationText,
            }
            --
            NotificationFrameObject.Position = Options.Position == "Top Left" and UDim2.new(0, -70, 0, 80 + (#Path * 24)) or UDim2.new(0, Viewport.X / 2 - (NotificationText.TextBounds.X + 4) / 2, 1, -150)
            --
            do -- Functions
                function Notification:UpdatePositions()
                    local TotalHeight = 80
                    local Padding = 6
                    --
                    for Index = #Path, 1, -1 do
                        local Value = Path[Index]
                        local NewPosition
                        --
                        if Options.Position == "Top Left" then
                            NewPosition = UDim2.new(0, 5, 0, TotalHeight)
                            TotalHeight = TotalHeight + Value.Object.AbsoluteSize.Y + Padding
                        else
                            NewPosition = UDim2.new(0, Viewport.X / 2 - (Value.Text.TextBounds.X + 4) / 2, 1, -150 - (Index * 24))
                        end
                        --
                        Library:TweenObject(Value.Object, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = NewPosition})
                    end
                end
                --
                function Notification:RemoveFrame()
                    Library:TweenObject(NotificationFrameObject, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
					Library:TweenObject(NotificationText, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 1})
					Library:TweenObject(UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1})
					Library:TweenObject(Stroke, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 1})
                    --
                    task.delay(0.25, function()
                        NotificationFrameObject:Destroy()

                        table.remove(Path, table.find(Path, NotificationFrame))

                        Notification:UpdatePositions()
                    end)
                end
                --
                function Notification:UpdateText(Text)
                    NotificationText.Text = Text
                    NotificationFrameObject.Size = UDim2.new(NotificationFrameObject.Size.X.Scale, NotificationText.TextBounds.X + 44, 0, NotificationText.TextBounds.Y + 4)
                end
                --
                function Notification:Update()
                    local TotalHeight = 50
                    local Padding = 6
                    --
					Library:TweenObject(NotificationFrameObject, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
					Library:TweenObject(NotificationText, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0})
					Library:TweenObject(UIStroke, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0})
					Library:TweenObject(Stroke, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0})
                    NotificationFrameObject.Size = UDim2.new(NotificationFrameObject.Size.X.Scale, NotificationText.TextBounds.X + 44, 0, NotificationText.TextBounds.Y + 4)
                    --
                    for _, Value in Path do
                        TotalHeight = TotalHeight + Value.Object.AbsoluteSize.Y + Padding
                    end
                    --
                    local NewPosition = Options.Position == "Top Left" and UDim2.new(0, 5, 0, TotalHeight) or UDim2.new(0, Viewport.X / 2 - (NotificationText.TextBounds.X + 4) / 2, 1, -150)
                    --
                    Library:TweenObject(NotificationFrameObject, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = NewPosition}, function()
                        if Options.Delay ~= math.huge then
                            task.delay(Options.Delay, Notification.RemoveFrame)
                        end
                    end)
                end
            end
            --
            Notification:Update()
            --
            table.insert(Path, 1, NotificationFrame)
            --
            Notification:UpdatePositions()
            --
            return Notification
        end
        --
        -- ==================== HUD 悬浮窗：速度表（心跳网格ECG）+ 快捷键绑定列表（方块SK风格，可拖动，默认隐藏） ====================
        local function hudSquareFrame(name, sizeU2)
            local Border = Instance.new("Frame")
            Border.Name = "HUD_" .. name
            Border.Size = sizeU2
            Border.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Border.BorderColor3 = Color3.fromRGB(12, 12, 12)
            Border.BorderSizePixel = 1
            Border.Active = true
            Border.ZIndex = 500
            Border.Parent = MainUI
            --
            local Border2 = Instance.new("Frame")
            Border2.Size = UDim2.new(1, -4, 1, -4)
            Border2.Position = UDim2.new(0, 2, 0, 2)
            Border2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Border2.BorderColor3 = Color3.fromRGB(40, 40, 40)
            Border2.BorderSizePixel = 1
            Border2.ZIndex = 500
            Border2.Parent = Border
            --
            local Background = Instance.new("ImageLabel")
            Background.Size = UDim2.new(1, -6, 1, -6)
            Background.Position = UDim2.new(0, 3, 0, 3)
            Background.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
            Background.BorderColor3 = Color3.fromRGB(60, 60, 60)
            Background.BorderSizePixel = 0
            Background.Image = "rbxassetid://15453092054"
            Background.ScaleType = Enum.ScaleType.Tile
            Background.TileSize = UDim2.new(0, 4, 0, 548)
            Background.ZIndex = 500
            Background.Parent = Border2
            return Border, Background
        end
        --
        local function hudEnableDrag(frame)
            local UIS = game:GetService("UserInputService")
            local dragging = false
            local dragStart, frameStart
            frame.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    frameStart = frame.Position
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if not dragging then return end
                if frame:GetAttribute("Resizing") then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
        --
        local HUDRun = game:GetService("RunService")
        local HUDPlayers = game:GetService("Players")
        local HUDUIS = game:GetService("UserInputService")
        --
        local function hudEnableResize(frame, minW, minH)
            local grip = Instance.new("Frame")
            grip.Size = UDim2.new(0, 14, 0, 14)
            grip.Position = UDim2.new(1, -14, 1, -14)
            grip.BackgroundTransparency = 1
            grip.Active = true
            grip.ZIndex = 510
            grip.Parent = frame
            local resizing = false
            local start, startSize
            grip.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    resizing = true
                    frame:SetAttribute("Resizing", true)
                    start = input.Position
                    startSize = frame.AbsoluteSize
                end
            end)
            HUDUIS.InputChanged:Connect(function(input)
                if not resizing then return end
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local dx = input.Position.X - start.X
                    local dy = input.Position.Y - start.Y
                    frame.Size = UDim2.fromOffset(math.max(minW, math.floor(startSize.X + dx)), math.max(minH, math.floor(startSize.Y + dy)))
                end
            end)
            HUDUIS.InputEnded:Connect(function(input)
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    frame:SetAttribute("Resizing", false)
                end
            end)
        end
        --
        function Library:CreateSpeedHUD()
            if not MainUI then return nil end
            local Border, Background = hudSquareFrame("Speed", UDim2.fromOffset(232, 126))
            Border.Position = UDim2.fromOffset(24, 220)
            Border.Visible = false
            hudEnableDrag(Border)
            hudEnableResize(Border, 180, 100)
            --
            local title = Instance.new("TextLabel")
            title.Text = "速度表"
            title.FontFace = Library.UI.NewFont
            title.TextSize = Library.UI.FontSize
            title.TextColor3 = Library.Theme.Default.TextColor
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, -12, 0, 14)
            title.Position = UDim2.new(0, 6, 0, 4)
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 502
            title.Parent = Background
            --
            local value = Instance.new("TextLabel")
            value.Text = "0.0 st/s"
            value.FontFace = Library.UI.NewFont
            value.TextSize = 15
            value.TextColor3 = Library.Theme.Default.Accent
            value.BackgroundTransparency = 1
            value.Size = UDim2.new(1, -12, 0, 16)
            value.Position = UDim2.new(0, 6, 0, 18)
            value.TextXAlignment = Enum.TextXAlignment.Left
            value.ZIndex = 502
            value.Parent = Background
            --
            local wave = Instance.new("Frame")
            wave.Position = UDim2.new(0, 6, 0, 38)
            wave.Size = UDim2.new(1, -12, 1, -44)
            wave.BackgroundTransparency = 1
            wave.ClipsDescendants = true
            wave.ZIndex = 502
            wave.Parent = Background
            --
            local Accent = Library.Theme.Default.Accent
            local gridHolder = nil
            local lastW, lastH = 0, 0
            local segs = {}
            local segsBuilt = false
            local maxN = 54
            local history = {}
            local visible = false
            local acc = 0
            local lastPos = nil
            local smooth = 0
            --
            -- 网格随尺寸变化重建（拉大/缩小后结构线始终铺满）
            local function buildStatic()
                local w = wave.AbsoluteSize.X
                local h = wave.AbsoluteSize.Y
                if w < 10 or h < 10 then return end
                if gridHolder and w == lastW and h == lastH then return end
                lastW, lastH = w, h
                if gridHolder then gridHolder:Destroy() end
                gridHolder = Instance.new("Frame")
                gridHolder.BackgroundTransparency = 1
                gridHolder.Size = UDim2.new(1, 0, 1, 0)
                gridHolder.ZIndex = 502
                gridHolder.Parent = wave
                local x = 0
                while x < w do
                    local v = Instance.new("Frame")
                    v.Size = UDim2.new(0, 1, 1, 0)
                    v.Position = UDim2.new(0, x, 0, 0)
                    v.BackgroundColor3 = Accent
                    v.BackgroundTransparency = 0.85
                    v.BorderSizePixel = 0
                    v.ZIndex = 502
                    v.Parent = gridHolder
                    x += 16
                end
                local y = 0
                while y < h do
                    local hline = Instance.new("Frame")
                    hline.Size = UDim2.new(1, 0, 0, 1)
                    hline.Position = UDim2.new(0, 0, 0, y)
                    hline.BackgroundColor3 = Accent
                    hline.BackgroundTransparency = 0.85
                    hline.BorderSizePixel = 0
                    hline.ZIndex = 502
                    hline.Parent = gridHolder
                    y += 14
                end
                if not segsBuilt then
                    segsBuilt = true
                    for i = 1, maxN do
                        local seg = Instance.new("Frame")
                        seg.AnchorPoint = Vector2.new(0.5, 0.5)
                        seg.BackgroundColor3 = Accent
                        seg.BorderSizePixel = 0
                        seg.Size = UDim2.new(0, 4, 0, 2)
                        seg.Visible = false
                        seg.ZIndex = 503
                        local stroke = Instance.new("UIStroke")
                        stroke.Color = Accent
                        stroke.Thickness = 2
                        stroke.Transparency = 0.55
                        stroke.Parent = seg
                        seg.Parent = wave
                        segs[i] = seg
                    end
                end
            end
            --
            -- 本游戏移动为 CFrame 驱动（AssemblyLinearVelocity 恒 0）→ 位置差分测速
            HUDRun.RenderStepped:Connect(function(dt)
                if not visible then return end
                local ok, err = pcall(function()
                    buildStatic()
                    local char = HUDPlayers.LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local sp = 0
                    if root then
                        local p = root.Position
                        if lastPos and dt > 0 then
                            local flat = (p - lastPos) * Vector3.new(1, 0, 1)
                            sp = flat.Magnitude / dt
                        end
                        lastPos = p
                    else
                        lastPos = nil
                    end
                    smooth += (sp - smooth) * math.clamp(dt * 8, 0, 1)
                    value.Text = string.format("%.1f st/s", smooth)
                    acc += dt
                    if acc < 0.06 then return end
                    acc = 0
                    history[#history + 1] = smooth
                    while #history > maxN do
                        table.remove(history, 1)
                    end
                    local w = wave.AbsoluteSize.X
                    local h = wave.AbsoluteSize.Y
                    local step = w / (maxN - 1)
                    for i = 1, maxN do
                        local seg = segs[i]
                        if i == 1 or i > #history then
                            seg.Visible = false
                        else
                            local x0 = (i - 2) * step
                            local x1 = (i - 1) * step
                            local v0 = history[i - 1]
                            local v1 = history[i]
                            local y0 = h - math.clamp(v0 / 40, 0, 1) * (h - 6) - 3
                            local y1 = h - math.clamp(v1 / 40, 0, 1) * (h - 6) - 3
                            local dx = x1 - x0
                            local dy = y1 - y0
                            local len = math.sqrt(dx * dx + dy * dy)
                            if len < 0.5 then
                                seg.Visible = false
                            else
                                seg.Visible = true
                                seg.Size = UDim2.new(0, len + 2, 0, 2)
                                seg.Position = UDim2.new(0, (x0 + x1) / 2, 0, (y0 + y1) / 2)
                                seg.Rotation = math.deg(math.atan2(dy, dx))
                            end
                        end
                    end
                end)
            end)
            --
            return {
                Frame = Border,
                SetVisible = function(v)
                    visible = v
                    Border.Visible = v
                    if not v then lastPos = nil end
                end,
                SetAppearance = function(bgColor, borderColor, trans)
                    pcall(function()
                        Background.ImageColor3 = bgColor
                        Background.ImageTransparency = trans
                        Border.BackgroundColor3 = borderColor
                        Border.BorderColor3 = borderColor
                    end)
                end,
            }
        end
        --
        function Library:CreateHotkeyHUD()
            if not MainUI then return nil end
            local Border, Background = hudSquareFrame("Hotkeys", UDim2.fromOffset(232, 180))
            Border.Position = UDim2.fromOffset(24, 384)
            Border.Visible = false
            hudEnableDrag(Border)
            hudEnableResize(Border, 180, 120)
            --
            local title = Instance.new("TextLabel")
            title.Text = "Hotkey List"
            title.FontFace = Library.UI.NewFont
            title.TextSize = Library.UI.FontSize
            title.TextColor3 = Library.Theme.Default.Accent
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, -12, 0, 16)
            title.Position = UDim2.new(0, 6, 0, 4)
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 502
            title.Parent = Background
            --
            -- 标题分隔线：与内容区隔开
            local divider = Instance.new("Frame")
            divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            divider.BorderSizePixel = 0
            divider.Size = UDim2.new(1, -12, 0, 1)
            divider.Position = UDim2.new(0, 6, 0, 21)
            divider.ZIndex = 502
            divider.Parent = Background
            --
            local scroll = Instance.new("ScrollingFrame")
            scroll.Position = UDim2.new(0, 6, 0, 25)
            scroll.Size = UDim2.new(1, -12, 1, -31)
            scroll.BackgroundTransparency = 1
            scroll.BorderSizePixel = 0
            scroll.ScrollBarThickness = 2
            scroll.ScrollBarImageColor3 = Library.Theme.Default.Accent
            scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            scroll.ZIndex = 502
            scroll.Parent = Background
            --
            local layout = Instance.new("UIListLayout")
            layout.FillDirection = Enum.FillDirection.Vertical
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 2)
            layout.Parent = scroll
            --
            local rows = {}
            local visible = false
            local acc = 0
            --
            local function rebuild()
                for _, r in ipairs(rows) do
                    pcall(function() r:Destroy() end)
                end
                rows = {}
                for _, v in ipairs(Library.KeybindList or {}) do
                    -- 显示条件：已绑定键位 且 关联功能开关处于开启状态（状态/名称从 Owner 主开关本体取）
                    if typeof(v.Keybind) == "string" and v.Keybind ~= "[-]" and v.Owner then
                        local stateOn, name = false, "?"
                        pcall(function()
                            if v.Owner.GetState then
                                stateOn = v.Owner:GetState() == true
                            elseif v.Owner.State ~= nil then
                                stateOn = v.Owner.State == true
                            end
                        end)
                        pcall(function()
                            if v.Owner.GetName then name = tostring(v.Owner:GetName() or "?") end
                        end)
                        if stateOn then
                            local row = Instance.new("Frame")
                            row.BackgroundTransparency = 1
                            row.Size = UDim2.new(1, -4, 0, 16)
                            row.ZIndex = 503
                            row.Parent = scroll
                            local label = Instance.new("TextLabel")
                            label.Text = name
                            label.FontFace = Library.UI.NewFont
                            label.TextSize = Library.UI.FontSize
                            label.TextColor3 = Library.Theme.Default.TextColor
                            label.BackgroundTransparency = 1
                            label.Size = UDim2.new(1, -48, 1, 0)
                            label.Position = UDim2.new(0, 0, 0, 0)
                            label.TextXAlignment = Enum.TextXAlignment.Left
                            label.TextTruncate = Enum.TextTruncate.AtEnd
                            label.ZIndex = 503
                            label.Parent = row
                            local key = Instance.new("TextLabel")
                            key.Text = "[" .. v.Keybind .. "]"
                            key.FontFace = Library.UI.NewFont
                            key.TextSize = Library.UI.FontSize
                            key.TextColor3 = Library.Theme.Default.Accent
                            key.BackgroundTransparency = 1
                            key.Size = UDim2.new(0, 46, 1, 0)
                            key.Position = UDim2.new(1, -46, 0, 0)
                            key.TextXAlignment = Enum.TextXAlignment.Right
                            key.ZIndex = 503
                            key.Parent = row
                            rows[#rows + 1] = row
                        end
                    end
                end
            end
            --
            HUDRun.RenderStepped:Connect(function(dt)
                if not visible then return end
                acc += dt
                if acc >= 0.4 then
                    acc = 0
                    pcall(rebuild)
                end
            end)
            --
            return {
                Frame = Border,
                SetVisible = function(v)
                    visible = v
                    Border.Visible = v
                    if v then
                        pcall(rebuild)
                    end
                end,
                SetAppearance = function(bgColor, borderColor, trans)
                    pcall(function()
                        Background.ImageColor3 = bgColor
                        Background.ImageTransparency = trans
                        Border.BackgroundColor3 = borderColor
                        Border.BorderColor3 = borderColor
                    end)
                end,
            }
        end
        --
        function Library:Init()
            Library.UI.Initialized = true
            --
            Library:CreateWatermark()
            --
            Library:Connection(Camera:GetPropertyChangedSignal("ViewportSize"), function()
                Viewport = Camera.ViewportSize
                --
                Outline.Position = UDim2.fromOffset((Viewport.X / 2) - (Outline.Size.X.Offset / 2), (Viewport.Y / 2) - (Outline.Size.Y.Offset / 2))
            end)
        end
        --
        function Library:Unload()
            -- 恢复相机：角色模型可能没有 Humanoid，直接索引会 error 并中断整个卸载流程
            -- （表现为"点卸载脚本没反应+左上角报错"）
            pcall(function()
                local Char = Client.Character
                local Humanoid = Char and Char:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Camera.CameraSubject = Humanoid
                end
            end)
            --
            for Index, Value in Library.Connections do
                Value:Disconnect()
            end
            --
            for _, Objects in Library.Objects do
                Objects[1]:Destroy()
            end
            --
            MainUI:Destroy()
        end
        --
        function Library:Disable()
            for Index, Value in Library.Flags do
                if Value.Set then
                    Value:Set(false)
                end
            end
        end
        --
        return setmetatable(Window, Library)
    end
end
--
