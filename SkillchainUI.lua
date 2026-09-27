-- SkillchainUI.lua
-- Shared ImGui UI helpers for SkillchainCalc.

local imgui = require('imgui');

local SkillchainUI = {};

-- Standard window setup shared by both input windows: size constraints,
-- restore a saved position (or an optional fallback), and the common flag
-- set. Returns the flags for the caller's own imgui.Begin call (window
-- titles differ per caller, so imgui.Begin itself stays in the caller).
-- guiPos      : cache.settings.guiPosition table, or nil/false if unavailable
-- fallbackPos : {x, y} to use when guiPos is nil, or nil to leave unset
function SkillchainUI.setupWindow(guiPos, fallbackPos)
    imgui.SetNextWindowSizeConstraints({ 380, 0 }, { 380, 9999 });

    if guiPos then
        imgui.SetNextWindowPos({ guiPos.x, guiPos.y }, ImGuiCond_Once);
    elseif fallbackPos then
        imgui.SetNextWindowPos(fallbackPos, ImGuiCond_Once);
    end

    return bit.bor(
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoDocking or 0,
        ImGuiWindowFlags_AlwaysAutoResize
    );
end

-- Tracks the current ImGui window's position and writes it back into guiPos
-- in place when it changes. Returns true if it changed this frame -- the
-- caller sets its own request.*PositionChanged field (name differs per
-- caller) and is responsible for calling settings.save().
-- guiPos : cache.settings.guiPosition table, or nil/false if unavailable
function SkillchainUI.trackWindowPosition(guiPos)
    if not guiPos then
        return false;
    end

    local curPosX, curPosY = imgui.GetWindowPos();
    if not curPosX then
        return false;
    end

    local cx = curPosX - (curPosX % 1);
    local cy = curPosY - (curPosY % 1);
    if cx ~= guiPos.x or cy ~= guiPos.y then
        guiPos.x = cx;
        guiPos.y = cy;
        return true;
    end

    return false;
end

return SkillchainUI;
