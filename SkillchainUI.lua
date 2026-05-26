-- SkillchainUI.lua
-- Shared ImGui UI helpers for SkillchainCalc.

local imgui = require('imgui');

local SkillchainUI = {};

-- Styled button helper: handles primary (blue) and ghost (transparent) button styles.
-- label     : button label string
-- size      : {width, height} table passed to imgui.Button
-- isPrimary : true for blue fill, false for transparent ghost style
function SkillchainUI.styledButton(label, size, isPrimary)
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding, 6.0);

    if isPrimary then
        -- Primary button style (blue)
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.25, 0.40, 0.85, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 0.30, 0.48, 0.95, 1.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 0.18, 0.32, 0.70, 1.00 });
    else
        -- Ghost button style (transparent)
        imgui.PushStyleColor(ImGuiCol_Button,        { 0.00, 0.00, 0.00, 0.00 });
        imgui.PushStyleColor(ImGuiCol_ButtonHovered, { 1.00, 1.00, 1.00, 0.12 });
        imgui.PushStyleColor(ImGuiCol_ButtonActive,  { 1.00, 1.00, 1.00, 0.20 });
    end

    local clicked = imgui.Button(label, size);

    imgui.PopStyleColor(3);
    imgui.PopStyleVar(1);

    return clicked;
end

-- Gradient header: renders a left-solid-to-transparent blue band behind text.
-- text  : header label string
-- width : available pixel width of the containing column/window
function SkillchainUI.drawGradientHeader(text, width)
    local drawlist = imgui.GetWindowDrawList();
    local x, y     = imgui.GetCursorScreenPos();
    local lineH    = imgui.GetTextLineHeightWithSpacing();

    local fadeFraction = 0.75;
    local gradWidth    = width * fadeFraction;

    local colLeft      = {0.25, 0.40, 0.85, 1.00};
    local colLeftU32   = imgui.GetColorU32(colLeft);
    local colRight     = {colLeft[1], colLeft[2], colLeft[3], 0.00};
    local colRightU32  = imgui.GetColorU32(colRight);

    drawlist:AddRectFilledMultiColor(
        {x, y},
        {x + gradWidth, y + lineH},
        colLeftU32,
        colRightU32,
        colRightU32,
        colLeftU32
    );

    local padX = 4;
    local padY = 2;
    imgui.SetCursorScreenPos({ x + padX, y + padY });
    imgui.Text(text);

    local _, newY = imgui.GetCursorScreenPos();
    imgui.SetCursorScreenPos({ x, newY });
    imgui.Spacing();
end

return SkillchainUI;
