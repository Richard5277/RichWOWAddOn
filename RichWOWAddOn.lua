SLASH_RICHWOWFAR1 = "/far"
SlashCmdList.RICHWOWFAR = function()
    SetCVar("cameraDistanceMaxZoomFactor", 4)
    SetCVar("cameraDistanceMax", 50)
    print("|cff46bf72RichWOWAddOn:|r Camera distance set to far.")
end

SLASH_RICHWOWCLOSE1 = "/close"
SlashCmdList.RICHWOWCLOSE = function()
    SetCVar("cameraDistanceMaxZoomFactor", 1)
    SetCVar("cameraDistanceMax", 20)
    print("|cff46bf72RichWOWAddOn:|r Camera distance set to close.")
end

local SCALE_NORMAL = 1
local SCALE_HELD = 1.35
local scaleButtons = {}

local function CollectActionButtons()
    scaleButtons = {}

    for i = 1, 12 do
        local button = _G["ActionButton" .. i]
        if button then
            scaleButtons[#scaleButtons + 1] = button
        end
    end
end

local function ButtonIndex(binding)
    if not C_GamePad or type(C_GamePad.ButtonBindingToIndex) ~= "function" then
        return nil
    end

    local ok, index = pcall(C_GamePad.ButtonBindingToIndex, binding)
    if ok and type(index) == "number" then
        return index + 1
    end

    return nil
end

local function GamePadButtonHeld(binding)
    if not C_GamePad or type(C_GamePad.GetDeviceMappedState) ~= "function" then
        return false
    end

    local state
    local okDevice, deviceID = pcall(C_GamePad.GetActiveDeviceID)
    if okDevice and deviceID then
        local ok, result = pcall(C_GamePad.GetDeviceMappedState, deviceID)
        state = ok and result or nil
    else
        local ok, result = pcall(C_GamePad.GetDeviceMappedState)
        state = ok and result or nil
    end

    local index = ButtonIndex(binding)
    return index ~= nil
        and type(state) == "table"
        and type(state.buttons) == "table"
        and state.buttons[index] == true
end

local function SetActionButtonScale(scale)
    for _, button in ipairs(scaleButtons) do
        if button.SetScale then
            pcall(button.SetScale, button, scale)
        end
    end
end

CollectActionButtons()

local triggerFrame = CreateFrame("Frame")
local elapsed = 0
local currentlyHeld = false

triggerFrame:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 0.05 then return end
    elapsed = 0

    local held = GamePadButtonHeld("PADLTRIGGER") or GamePadButtonHeld("PADRTRIGGER")
    if held ~= currentlyHeld then
        currentlyHeld = held
        SetActionButtonScale(held and SCALE_HELD or SCALE_NORMAL)
    end
end)
