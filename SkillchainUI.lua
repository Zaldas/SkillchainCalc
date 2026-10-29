-- SkillchainUI.lua
-- Shared ImGui UI helpers for SkillchainCalc.

local imgui = require('imgui');
local uiTheme = require('libs/uiTheme');
local SkillchainRenderer = require('SkillchainRenderer');

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

-- Draws the "Results Window" settings section (drag toggle + X/Y anchor
-- sliders). Slider moves update the renderer live; returns true when a
-- change should be saved (drag toggled, or a slider released).
function SkillchainUI.drawResultsWindowSettings(settings)
    uiTheme.header('Results Window');
    imgui.Spacing();

    imgui.Indent(uiTheme.indent);
    local changed = false;
    if settings and settings.anchor then
        local anchor = settings.anchor;
        local limits = SkillchainRenderer.CalculateAnchorLimits(settings);

        local enableDrag = { settings.enableDrag == true };
        if imgui.Checkbox('Enable mouse drag', enableDrag) then
            settings.enableDrag = enableDrag[1];
            changed = true;
        end
        uiTheme.helpMarker('When enabled, click and drag the results window to move it.');

        local x = { anchor.x or 0 };
        if imgui.SliderInt('X', x, limits.minX, limits.maxX) then
            anchor.x = x[1];
            SkillchainRenderer.UpdateAnchor(settings);
        end
        changed = imgui.IsItemDeactivatedAfterEdit() or changed;

        local y = { anchor.y or 0 };
        if imgui.SliderInt('Y', y, limits.minY, limits.maxY) then
            anchor.y = y[1];
            SkillchainRenderer.UpdateAnchor(settings);
        end
        changed = imgui.IsItemDeactivatedAfterEdit() or changed;
    else
        imgui.TextDisabled('Settings not available.');
    end
    imgui.Unindent(uiTheme.indent);

    return changed;
end

-- Set while a window move is in progress and not yet reported.
local positionDirty = false;

-- Tracks the current ImGui window's position and writes it back into guiPos
-- in place when it changes. Returns true once per move, after the mouse is
-- released; the caller requests settings.save().
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
        positionDirty = true;
    end

    if positionDirty and not imgui.IsMouseDown(0) then
        positionDirty = false;
        return true;
    end

    return false;
end

return SkillchainUI;
