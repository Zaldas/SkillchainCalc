-- SkillchainRenderer.lua
-- Handles all GDI rendering for skillchain results display

require('common');
local skills = require('Skills');

local SkillchainRenderer = {};

-- GDI object pool and state
local gdiObjects = {
    title = nil,
    background = nil,
    textPool = {},          -- Active text objects
    poolSize = 0,           -- Current pool size
    maxPoolSize = 150,      -- Hard cap
    minPoolSize = 20,       -- Minimum to keep alive
    lastUsedCount = 0,      -- Track last frame usage
    layoutData = nil,       -- Store layout data for anchor updates
};

local isVisible = false;
local gdi = nil;  -- Will be injected during initialization

-- Cache scaling module to avoid repeated requires
local scaling = require('scaling');

-- Drag state management
local dragState = {
    dragActive = false,
    dragPosition = { 0, 0 },
    mouseBlocked = false,
    limits = nil,           -- Cached limits during active drag
    objectsHidden = false,  -- Track if we've hidden objects
};

-- ============================================================================
-- Pool Management Helpers
-- ============================================================================

-- Create a single pool object with visibility set to false
local function createPoolObject(settings)
    local text = gdi:create_object(settings.font);
    text:set_visible(false);
    return text;
end

-- Add multiple objects to the pool
local function addObjectsToPool(count, settings)
    for i = 1, count do
        table.insert(gdiObjects.textPool, createPoolObject(settings));
        gdiObjects.poolSize = gdiObjects.poolSize + 1;
    end
end

-- Remove multiple objects from the pool
local function removeObjectsFromPool(count)
    local removed = 0;
    while removed < count and gdiObjects.poolSize > 0 do
        local text = table.remove(gdiObjects.textPool);
        if text then
            gdi:destroy_object(text);
            gdiObjects.poolSize = gdiObjects.poolSize - 1;
            removed = removed + 1;
        else
            break;
        end
    end
end

-- Hide a range of pool objects
local function hidePoolObjects(startIdx, endIdx)
    for i = startIdx, endIdx do
        if gdiObjects.textPool[i] then
            gdiObjects.textPool[i]:set_visible(false);
        end
    end
end

-- ============================================================================
-- Initialization and Cleanup
-- ============================================================================

function SkillchainRenderer.initialize(gdiLib, settings)
    gdi = gdiLib;

    gdiObjects.title = gdi:create_object(settings.title_font);
    gdiObjects.title:set_text('Skillchains');
    gdiObjects.title:set_position_x(settings.anchor.x + 5);
    gdiObjects.title:set_position_y(settings.anchor.y);

    gdiObjects.background = gdi:create_rect(settings.bg);
    gdiObjects.background:set_position_x(settings.anchor.x);
    gdiObjects.background:set_position_y(settings.anchor.y);

    -- Start with minimum pool size
    addObjectsToPool(gdiObjects.minPoolSize, settings);

    -- Initially hidden
    SkillchainRenderer.clear();
end

function SkillchainRenderer.destroy()
    if gdiObjects.title then
        gdi:destroy_object(gdiObjects.title);
        gdiObjects.title = nil;
    end

    if gdiObjects.background then
        gdi:destroy_object(gdiObjects.background);
        gdiObjects.background = nil;
    end

    removeObjectsFromPool(gdiObjects.poolSize);
    gdiObjects.textPool = {};
    gdiObjects.lastUsedCount = 0;
end

function SkillchainRenderer.clear()
    isVisible = false;
    if gdiObjects.background then
        gdiObjects.background:set_visible(false);
    end
    if gdiObjects.title then
        gdiObjects.title:set_visible(false);
    end

    -- Only hide objects that were previously used
    hidePoolObjects(1, gdiObjects.lastUsedCount);
    gdiObjects.lastUsedCount = 0;
    gdiObjects.layoutData = nil;
end

function SkillchainRenderer.isVisible()
    return isVisible;
end

function SkillchainRenderer.getPoolInfo()
    return {
        poolSize = gdiObjects.poolSize,
        lastUsedCount = gdiObjects.lastUsedCount
    };
end

-- ============================================================================
-- Anchor Management
-- ============================================================================

function SkillchainRenderer.updateAnchor(settings)
    if gdiObjects.title then
        gdiObjects.title:set_position_x(settings.anchor.x + 5);
        gdiObjects.title:set_position_y(settings.anchor.y);
    end

    if gdiObjects.background then
        gdiObjects.background:set_position_x(settings.anchor.x);
        gdiObjects.background:set_position_y(settings.anchor.y);
    end

    -- Update all visible text objects to match new anchor position
    -- We need to recalculate their positions based on stored layout data
    if gdiObjects.layoutData then
        local textIndex = 1;
        for colIdx, column in ipairs(gdiObjects.layoutData.columns) do
            local columnOffset = (colIdx - 1) * settings.layout.columnWidth;
            local y_offset = 40;

            for _, item in ipairs(column.items) do
                if textIndex > gdiObjects.lastUsedCount then
                    break;
                end

                local textObj = gdiObjects.textPool[textIndex];
                if textObj then
                    textObj:set_position_x(settings.anchor.x + (item.type == 'header' and 10 or 20) + columnOffset);
                    textObj:set_position_y(settings.anchor.y + y_offset);
                    textObj:set_visible(true);
                end

                textIndex = textIndex + 1;
                y_offset = y_offset + settings.layout.entriesHeight;
            end
        end
    end
end

-- ============================================================================
-- Drag Functionality
-- ============================================================================

-- Calculate anchor position limits based on screen size and layout
local function calculateAnchorLimits(settings)
    local pad = 20;
    local layoutSettings = settings.layout;
    local colW = (layoutSettings and layoutSettings.columnWidth) or pad;
    local colH = (layoutSettings and layoutSettings.entriesPerColumn * layoutSettings.entriesHeight) or pad;

    local maxX = scaling.window.w - colW - pad;
    if maxX < pad then maxX = pad; end
    local maxY = scaling.window.h - colH - pad;
    if maxY < pad then maxY = pad; end

    return { minX = pad, maxX = maxX, minY = pad, maxY = maxY };
end

-- Export for use by GUI
SkillchainRenderer.calculateAnchorLimits = calculateAnchorLimits;

-- Check if mouse is over the draggable area (entire background)
local function dragHitTest(mouseX, mouseY, settings)
    -- Fast path: check enableDrag first (single boolean check)
    if not settings.enableDrag then
        return false;
    end

    if not isVisible or not gdiObjects.background then
        return false;
    end

    -- Use background's own dimensions directly
    local bg = gdiObjects.background.settings;
    local x = bg.position_x;
    local y = bg.position_y;
    local width = bg.width;
    local height = bg.height;

    return mouseX >= x and mouseX <= (x + width) and
           mouseY >= y and mouseY <= (y + height);
end

function SkillchainRenderer.handleMouse(e, settings)
    -- Early exit if drag is disabled and not currently dragging
    if not settings.enableDrag and not dragState.dragActive then
        return;
    end

    -- Handle active dragging
    if dragState.dragActive then
        local pos = settings.anchor;
        pos.x = pos.x + (e.x - dragState.dragPosition[1]);
        pos.y = pos.y + (e.y - dragState.dragPosition[2]);

        -- Use cached limits (calculated once on drag start)
        local limits = dragState.limits;
        if limits then
            if pos.x < limits.minX then pos.x = limits.minX; end
            if pos.x > limits.maxX then pos.x = limits.maxX; end
            if pos.y < limits.minY then pos.y = limits.minY; end
            if pos.y > limits.maxY then pos.y = limits.maxY; end
        end

        dragState.dragPosition[1] = e.x;
        dragState.dragPosition[2] = e.y;

        -- Only update title and background during drag (lightweight)
        if gdiObjects.title then
            gdiObjects.title:set_position_x(settings.anchor.x + 5);
            gdiObjects.title:set_position_y(settings.anchor.y);
        end
        if gdiObjects.background then
            gdiObjects.background:set_position_x(settings.anchor.x);
            gdiObjects.background:set_position_y(settings.anchor.y);
        end

        -- Hide text pool objects once at start of drag
        if not dragState.objectsHidden and gdiObjects.layoutData then
            hidePoolObjects(1, gdiObjects.lastUsedCount);
            dragState.objectsHidden = true;
        end

        -- Left mouse button released (message 514)
        if (e.message == 514) then
            dragState.dragActive = false;
            dragState.objectsHidden = false;
            dragState.limits = nil;
            -- Update ALL positions and show text when drag completes
            SkillchainRenderer.updateAnchor(settings);
        end
    -- Start dragging on left mouse button down (message 513)
    elseif (e.message == 513) then
        -- Pass coordinates directly to avoid table allocation
        if dragHitTest(e.x, e.y, settings) then
            dragState.dragActive = true;
            dragState.dragPosition[1] = e.x;
            dragState.dragPosition[2] = e.y;
            dragState.mouseBlocked = true;
            dragState.limits = calculateAnchorLimits(settings);  -- Cache limits once
            e.blocked = true;
            return;
        end
    end

    -- Block mouse up event if we blocked the down event
    if (e.message == 514) and (dragState.mouseBlocked) then
        e.blocked = true;
        dragState.mouseBlocked = false;
    end
end

-- ============================================================================
-- Object Pool Management
-- ============================================================================

local function ensurePoolSize(requiredSize, settings)
    if requiredSize > gdiObjects.maxPoolSize then
        requiredSize = gdiObjects.maxPoolSize;
    end

    -- Grow pool if needed
    local needed = requiredSize - gdiObjects.poolSize;
    if needed > 0 then
        addObjectsToPool(needed, settings);
    end
end

local function shrinkPool()
    -- Shrink pool if it's much larger than needed (keep buffer)
    local targetSize = math.max(gdiObjects.minPoolSize, gdiObjects.lastUsedCount + 20);
    local toRemove = gdiObjects.poolSize - targetSize;
    if toRemove > 0 then
        removeObjectsFromPool(toRemove);
    end
end

-- ============================================================================
-- Layout Calculation (Pass 1: Determine what goes where)
-- ============================================================================

-- Calculate the layout structure without rendering
-- Returns: array of columns, each containing layout items with positions
local function calculateLayout(sortedResults, orderedResults, layoutSettings, both, minResultsAfterHeader)
    local columns = {{items = {}, entriesCount = 0}};
    local currentColIdx = 1;

    for _, chainName in ipairs(orderedResults) do
        local openers = sortedResults[chainName];
        local chainInfo = skills.ChainInfo[chainName];
        local burstElements = chainInfo and chainInfo.burst or {};
        local elementsText = table.concat(burstElements, ', ');
        local color = skills.GetPropertyColor(chainName);

        -- Count total combo entries for this chain (excluding header)
        local totalComboCount = 0;
        for _, openerData in ipairs(openers) do
            totalComboCount = totalComboCount + #openerData.closers;
        end

        -- Check if we should start a new column before this chain
        local currentCol = columns[currentColIdx];
        local spaceLeft = layoutSettings.entriesPerColumn - currentCol.entriesCount;

        if spaceLeft > 0 and spaceLeft <= minResultsAfterHeader and currentCol.entriesCount > 0 then
            -- Not enough space for header + minimum results, start new column
            currentColIdx = currentColIdx + 1;
            columns[currentColIdx] = {items = {}, entriesCount = 0};
            currentCol = columns[currentColIdx];
        end

        -- Add header item to current column
        table.insert(currentCol.items, {
            type = 'header',
            chainName = chainName,
            text = string.format('%s [%s]', chainName, elementsText),
            color = color,
        });
        currentCol.entriesCount = currentCol.entriesCount + 1;

        -- Process combo entries for this chain
        local combosInCurrentCol = 0;
        local combosRemaining = totalComboCount;

        for _, openerData in ipairs(openers) do
            for _, closerData in ipairs(openerData.closers) do
                -- Check if we should split to a new column mid-chain
                local softCap = layoutSettings.entriesPerColumn;
                local hardCap = softCap + (layoutSettings.softOverflow or 0);

                local shouldSplitSoft = currentCol.entriesCount + 1 > softCap and
                                       combosInCurrentCol >= minResultsAfterHeader and
                                       combosRemaining >= 2;

                local shouldSplitHard = currentCol.entriesCount >= hardCap;

                if shouldSplitSoft or shouldSplitHard then
                    -- Start new column and repeat header
                    currentColIdx = currentColIdx + 1;
                    columns[currentColIdx] = {items = {}, entriesCount = 0};
                    currentCol = columns[currentColIdx];

                    table.insert(currentCol.items, {
                        type = 'header',
                        chainName = chainName,
                        text = string.format('%s [%s]', chainName, elementsText),
                        color = color,
                    });
                    currentCol.entriesCount = currentCol.entriesCount + 1;
                    combosInCurrentCol = 0;
                end

                -- Add combo item
                local isReversible = (chainName == 'Light' or chainName == 'Darkness');
                local arrow = (isReversible and both) and '↔' or '→';

                table.insert(currentCol.items, {
                    type = 'combo',
                    text = string.format('  %s %s %s', openerData.opener, arrow, closerData.closer),
                });
                currentCol.entriesCount = currentCol.entriesCount + 1;
                combosInCurrentCol = combosInCurrentCol + 1;
                combosRemaining = combosRemaining - 1;
            end
        end
    end

    return columns;
end

-- ============================================================================
-- Rendering (Pass 2: Draw the calculated layout)
-- ============================================================================

function SkillchainRenderer.render(sortedResults, orderedResults, settings, both, minResultsAfterHeader)
    isVisible = true;

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    -- Calculate layout structure
    local columns = calculateLayout(sortedResults, orderedResults, settings.layout, both, minResultsAfterHeader);

    -- Store layout data for anchor updates
    gdiObjects.layoutData = { columns = columns };

    -- Count total items needed for pool sizing
    local totalItems = 0;
    for _, col in ipairs(columns) do
        totalItems = totalItems + #col.items;
    end

    -- Ensure we have enough pool objects
    ensurePoolSize(math.min(totalItems, gdiObjects.maxPoolSize), settings);

    -- Render the layout
    local textIndex = 1;
    local maxColumnHeight = 0;
    local hitLimit = false;

    for colIdx, column in ipairs(columns) do
        local columnOffset = (colIdx - 1) * settings.layout.columnWidth;
        local y_offset = 40;

        for _, item in ipairs(column.items) do
            -- Check if we've hit the pool limit
            if textIndex > gdiObjects.poolSize then
                hitLimit = true;
                break;
            end

            local textObj = gdiObjects.textPool[textIndex];
            textObj:set_text(item.text);
            textObj:set_position_x(settings.anchor.x + (item.type == 'header' and 10 or 20) + columnOffset);
            textObj:set_position_y(settings.anchor.y + y_offset);
            textObj:set_font_color(item.color or settings.font.font_color);
            textObj:set_visible(true);

            textIndex = textIndex + 1;
            y_offset = y_offset + settings.layout.entriesHeight;
        end

        maxColumnHeight = math.max(maxColumnHeight, y_offset);

        if hitLimit then break; end
    end

    -- Track how many objects we actually used
    gdiObjects.lastUsedCount = textIndex - 1;

    -- Show truncation notice if we hit the limit
    if hitLimit and gdiObjects.poolSize > 0 then
        local errorString = ' !!! Results trimmed. Try: higher skillchain level or set element, fewer weapons, or favorite weaponskill';

        local notice = gdiObjects.textPool[gdiObjects.poolSize];
        notice:set_text(errorString);
        notice:set_font_color(0xFFFF5555);
        notice:set_position_x(settings.anchor.x + 5);
        notice:set_position_y(settings.anchor.y - 20);
        notice:set_visible(true);

        -- Also print to console
        print('[SkillchainCalc]' .. errorString);
    end

    -- Adjust background dimensions
    local totalWidth = #columns * settings.layout.columnWidth;
    local totalHeight = maxColumnHeight + 5;
    gdiObjects.background:set_height(totalHeight);
    gdiObjects.background:set_width(totalWidth);

    -- Shrink pool if oversized (do this after a delay to avoid thrashing)
    if gdiObjects.poolSize > gdiObjects.lastUsedCount + 50 then
        shrinkPool();
    end
end

return SkillchainRenderer;
