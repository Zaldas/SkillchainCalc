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
};

local isVisible = false;
local gdi = nil;  -- Will be injected during initialization

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
    for i = 1, gdiObjects.minPoolSize do
        local text = gdi:create_object(settings.font);
        text:set_visible(false);
        table.insert(gdiObjects.textPool, text);
    end
    gdiObjects.poolSize = gdiObjects.minPoolSize;

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

    for _, text in ipairs(gdiObjects.textPool) do
        gdi:destroy_object(text);
    end
    gdiObjects.textPool = {};
    gdiObjects.poolSize = 0;
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
    for i = 1, gdiObjects.lastUsedCount do
        gdiObjects.textPool[i]:set_visible(false);
    end
    gdiObjects.lastUsedCount = 0;
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
end

-- ============================================================================
-- Object Pool Management
-- ============================================================================

local function ensurePoolSize(requiredSize, settings)
    if requiredSize > gdiObjects.maxPoolSize then
        requiredSize = gdiObjects.maxPoolSize;
    end

    -- Grow pool if needed
    while gdiObjects.poolSize < requiredSize do
        local text = gdi:create_object(settings.font);
        text:set_visible(false);
        table.insert(gdiObjects.textPool, text);
        gdiObjects.poolSize = gdiObjects.poolSize + 1;
    end
end

local function shrinkPool()
    -- Shrink pool if it's much larger than needed (keep buffer)
    local targetSize = math.max(gdiObjects.minPoolSize, gdiObjects.lastUsedCount + 20);

    while gdiObjects.poolSize > targetSize do
        local text = table.remove(gdiObjects.textPool);
        if text then
            gdi:destroy_object(text);
            gdiObjects.poolSize = gdiObjects.poolSize - 1;
        else
            break;
        end
    end
end

-- ============================================================================
-- Rendering
-- ============================================================================

function SkillchainRenderer.render(sortedResults, orderedResults, settings, both, minResultsAfterHeader)
    isVisible = true;

    gdiObjects.background:set_visible(true);
    gdiObjects.title:set_visible(true);

    local layout = settings.layout;

    local y_offset = 40;
    local textIndex = 1;
    local columnOffset = 0;
    local entriesInColumn = 0;
    local maxColumnHeight = 0;

    -- Count required objects first
    -- Account for headers that may be repeated when splitting across columns
    local requiredObjects = 0;
    for _, result in ipairs(orderedResults) do
        local openers = sortedResults[result];
        local resultCount = 0;
        for _, openerData in ipairs(openers) do
            resultCount = resultCount + #openerData.closers;
        end

        -- Estimate how many times this skillchain's header might appear
        -- If results span multiple columns, we need multiple headers
        -- Worst case: header every (minResultsAfterHeader + 1) entries after the first header
        local headerCount = 1; -- At least one header
        if resultCount > layout.entriesPerColumn then
            -- Rough estimate: one header per column segment
            headerCount = math.ceil(resultCount / (layout.entriesPerColumn - 1));
        end

        requiredObjects = requiredObjects + headerCount + resultCount;
    end

    -- Ensure pool has enough objects
    ensurePoolSize(requiredObjects, settings);

    -- Track if we hit the limit
    local hitLimit = false;

    -- Helper function to display a skillchain header
    local function displayHeader(result, color, elementsText)
        if textIndex > gdiObjects.poolSize then
            return false;
        end

        local header = gdiObjects.textPool[textIndex];
        header:set_text(string.format('%s [%s]', result, elementsText));
        header:set_font_color(color);
        header:set_position_x(settings.anchor.x + 10 + columnOffset);
        header:set_position_y(settings.anchor.y + y_offset);
        header:set_visible(true);

        textIndex = textIndex + 1;
        y_offset = y_offset + layout.entriesHeight;
        entriesInColumn = entriesInColumn + 1;

        return true;
    end

    -- Render results
    for _, result in ipairs(orderedResults) do
        if textIndex > gdiObjects.poolSize then
            hitLimit = true;
            break;
        end

        local openers = sortedResults[result];
        local chainInfo = skills.ChainInfo[result];
        local burstElements = chainInfo and chainInfo.burst or {};
        local elementsText = table.concat(burstElements, ', ');
        local color = skills.GetPropertyColor(result);

        -- Count total entries for this skillchain (header + all combos)
        local totalEntries = 1; -- header
        for _, openerData in ipairs(openers) do
            totalEntries = totalEntries + #openerData.closers;
        end

        -- Soft cap logic: if we're near the column limit and adding this skillchain
        -- would only fit the header or very few results, move to next column instead
        local spaceLeft = layout.entriesPerColumn - entriesInColumn;

        if spaceLeft > 0 and spaceLeft <= minResultsAfterHeader then
            -- Not enough space for header + minimum results, move to next column
            maxColumnHeight = math.max(maxColumnHeight, y_offset);
            columnOffset = columnOffset + layout.columnWidth;
            y_offset = 40;
            entriesInColumn = 0;
        end

        -- Display initial header
        if not displayHeader(result, color, elementsText) then
            hitLimit = true;
            break;
        end

        -- Track how many results we've shown for this skillchain section
        local resultsShownInSection = 0;
        local totalResultsCount = 0; -- Total count of all results for this skillchain
        for _, openerData in ipairs(openers) do
            totalResultsCount = totalResultsCount + #openerData.closers;
        end

        -- Display each opener and closer
        for _, openerData in ipairs(openers) do
            for _, closerData in ipairs(openerData.closers) do
                if textIndex > gdiObjects.poolSize then
                    hitLimit = true;
                    break;
                end

                -- Calculate how many results remain (including this one)
                local resultsRemaining = totalResultsCount - resultsShownInSection;

                -- Check if we need to move to next column before displaying this entry
                -- Conditions:
                -- 1. We've exceeded the soft cap (30 entries)
                -- 2. We've shown at least minResultsAfterHeader (8) results after the last header
                -- 3. Remaining results would make a new column worthwhile
                --    New column needs: header (1) + at least minResultsAfterHeader (8) results = 9+ entries
                --    So we need resultsRemaining >= minResultsAfterHeader + 1
                local shouldSplit = entriesInColumn + 1 > layout.entriesPerColumn and
                                   resultsShownInSection >= minResultsAfterHeader and
                                   resultsRemaining >= minResultsAfterHeader + 1;

                if shouldSplit then
                    maxColumnHeight = math.max(maxColumnHeight, y_offset);
                    columnOffset = columnOffset + layout.columnWidth;
                    y_offset = 40;
                    entriesInColumn = 0;
                    -- NOTE: Do NOT reset resultsShownInSection here!
                    -- It needs to keep counting to properly calculate resultsRemaining

                    -- Re-display the header in the new column
                    if not displayHeader(result, color, elementsText) then
                        hitLimit = true;
                        break;
                    end
                end

                local comboText = gdiObjects.textPool[textIndex];

                -- Check for level 3 skillchains (Light or Darkness)
                local isReversible = (result == 'Light' or result == 'Darkness');
                local arrow = (isReversible and both) and '↔' or '→';

                comboText:set_text(string.format('  %s %s %s', openerData.opener, arrow, closerData.closer));
                comboText:set_font_color(settings.font.font_color);
                comboText:set_position_x(settings.anchor.x + 20 + columnOffset);
                comboText:set_position_y(settings.anchor.y + y_offset);
                comboText:set_visible(true);

                textIndex = textIndex + 1;
                y_offset = y_offset + layout.entriesHeight;
                entriesInColumn = entriesInColumn + 1;
                resultsShownInSection = resultsShownInSection + 1;
            end

            if hitLimit then break; end
        end

        if hitLimit then break; end
    end

    -- Track how many objects we actually used
    gdiObjects.lastUsedCount = textIndex - 1;

    -- Show truncation notice if we hit the limit
    if hitLimit and gdiObjects.poolSize > 0 then
        local notice = gdiObjects.textPool[gdiObjects.poolSize];
        notice:set_text('⚠ Results trimmed. Add filters such as job:weapon or limit number of weapons in job or level=2.');
        notice:set_font_color(0xFFFF5555);
        notice:set_position_x(settings.anchor.x + 5);
        notice:set_position_y(settings.anchor.y - 20);
        notice:set_visible(true);
    end

    -- Update max column height
    maxColumnHeight = math.max(maxColumnHeight, y_offset);

    -- Adjust background dimensions
    gdiObjects.background:set_height(maxColumnHeight + 5);
    gdiObjects.background:set_width(columnOffset + layout.columnWidth);

    -- Shrink pool if oversized (do this after a delay to avoid thrashing)
    if gdiObjects.poolSize > gdiObjects.lastUsedCount + 50 then
        shrinkPool();
    end
end

return SkillchainRenderer;
