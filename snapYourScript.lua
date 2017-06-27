-- Global vars
-- ---------------------------------------
TRUE = true
--
ROOT = scriptPath()
--
VARS_LIST = {}
REG = {}
LOC = {}
COL = {}
IMG = {}

-- Local vars
-- ---------------------------------------
local OBJ = {}

-- commonLib
-- ---------------------------------------
commonLib = loadstring(httpGet("https://raw.githubusercontent.com/AnkuLua/commonLib/master/commonLib.lua"))
commonLib()

-- luaLib
-- ---------------------------------------
luaLib = loadstring(httpGet("https://raw.githubusercontent.com/mercobots/luaLib/master/luaLib.min.lua"))
luaLib()

-- Dialogs
-- ---------------------------------------
dialogs = {
    config = function()
        dialogInit()
        --
        addTextView("\n\t GENERAL \n\t----------------------------------")
        newRow()
        --
        addTextView("\t Folder Name: ") addEditText("CFG_FOLDER_NAME", "")
        newRow()
        --
        addTextView("\t Time between each new capture \t\t") addEditNumber("CFG_CAPTURE_WAIT", 3)
        newRow()
        --
        addTextView("\t Immersive mode \t\t") addCheckBox("CFG_IMMERSIVE", "", false)
        --
        newRow()
        addTextView("")
        addSeparator()
        addTextView("")
        newRow()
        --
        addTextView("\t IMAGES \n\t----------------------------------")
        newRow()
        --
        addTextView("\t How many pixels to expand in searching region \t\t") addEditNumber("CFG_IMG_REG", 20)
        --
        newRow()
        addTextView("")
        addSeparator()
        addTextView("")
        newRow()
        --
        addTextView("\t COLORS \n\t----------------------------------")
        newRow()
        --
        addTextView("\t How many colors for each click \t\t") addEditNumber("CFG_COL_CLICK", 10)
        newRow()
        --
        addTextView("\t Time between each color capture \t\t") addEditNumber("CFG_COL_CLICK_TIME", 0.1)
        newRow()
        --
        addTextView("\t Calculate Diff \t\t") addCheckBox("CFG_COL_DIFF", "", true)
        newRow()
        --
        dialogShowFullScreen("Config")
    end,
    new_record = function()
        dialogInit()
        addTextView("")
        newRow()
        --
        addTextView("\t Variable Name: ") addEditText("NEW_REC_VAR_NAME", "")
        --
        newRow()
        addTextView("")
        --
        addSeparator()
        addTextView("")
        newRow()
        --
        addRadioGroup("NEW_REC_OP", 1)
        addRadioButton("New Image", 1)
        addRadioButton("New Region", 2)
        addRadioButton("New Location", 3)
        addRadioButton("New Color", 4)
        addRadioButton("\n Stop 3 seconds \n", 5)
        addRadioButton("\n← EXIT \n", 6)
        --
        newRow()
        addTextView("")
        --
        dialogShowFullScreen("")
    end,
    obj_options = function()
        dialogInit()
        --
        addTextView("")
        newRow()
        --
        addTextView("\t " .. OBJ.type .. " - " .. OBJ.name)
        --
        newRow()
        addTextView("")
        --
        addSeparator()
        addTextView("")
        newRow()
        --
        addRadioGroup("OBJ_OP", 1)
        addRadioButton("Save", 1)
        addRadioButton("Edit - Values", 2)
        if OBJ.type == "region" or OBJ.type == "image" then
            addRadioButton("Edit - Using dragDrop", 3)
        else
            addRadioButton("Edit - Using click", 3)
        end
        addRadioButton("Discard", 4)
        --
        newRow()
        addTextView("")
        --
        dialogShowFullScreen("")
    end,
    edit_values = function()
        local values = get_values(OBJ.data)
        --
        dialogInit()
        addTextView("")
        newRow()
        --
        addTextView("\t " .. OBJ.type .. " - " .. OBJ.name)
        --
        newRow()
        addTextView("")
        --
        addSeparator()
        addTextView("")
        newRow()
        --
        addTextView("\t X ")
        addEditNumber("EDIT_VAL_X", values.x)
        newRow()
        --
        addTextView("\t Y ")
        addEditNumber("EDIT_VAL_Y", values.y)
        newRow()
        --
        if OBJ.type == "region" or OBJ.type == "image" then
            --
            addTextView("\t Width ")
            addEditNumber("EDIT_VAL_W", values.w)
            newRow()
            --
            addTextView("\t Height ")
            addEditNumber("EDIT_VAL_H", values.h)
            newRow()
        end
        --
        addTextView("")
        --
        dialogShowFullScreen("")
    end,
}

local function getDiff()
    OBJ.data_color.diff = { max = { r = 0, g = 0, b = 0 }, min = { r = 255, g = 255, b = 255 } }
    for i, v in ipairs(OBJ.data_color) do

        if v.r > OBJ.data_color.diff.max.r then OBJ.data_color.diff.max.r = v.r end
        if v.g > OBJ.data_color.diff.max.g then OBJ.data_color.diff.max.g = v.g end
        if v.b > OBJ.data_color.diff.max.b then OBJ.data_color.diff.max.b = v.b end
        --
        if v.r < OBJ.data_color.diff.min.r then OBJ.data_color.diff.min.r = v.r end
        if v.g < OBJ.data_color.diff.min.g then OBJ.data_color.diff.min.g = v.g end
        if v.b < OBJ.data_color.diff.min.b then OBJ.data_color.diff.min.b = v.b end
        --
    end
    --
    OBJ.data_color.diff.max.r = OBJ.data_color.diff.max.r - OBJ.data_color[1].r
    OBJ.data_color.diff.max.g = OBJ.data_color.diff.max.g - OBJ.data_color[1].g
    OBJ.data_color.diff.max.b = OBJ.data_color.diff.max.b - OBJ.data_color[1].b
    --
    OBJ.data_color.diff.min.r = OBJ.data_color[1].r - OBJ.data_color.diff.min.r
    OBJ.data_color.diff.min.g = OBJ.data_color[1].g - OBJ.data_color.diff.min.g
    OBJ.data_color.diff.min.b = OBJ.data_color[1].b - OBJ.data_color.diff.min.b
    --
    --
end

-- Save data to file
-- ---------------------------------------
local function saveData()
    local folder = ROOT .. CFG_FOLDER_NAME .. "/"
    local file = OBJ.type .. ".luar"
    local full_path = "" .. folder .. file .. ""
    --
    if not mkdir(folder) then simpleDialog("ERROR", "\n\t Cannot create new folder \n\n\t " .. folder) end
    --
    local fPointer = assert(io.open(full_path, "w+"))
    fPointer:write(OBJ.type .. " = ")
    --
    if OBJ.type == "location" then
        LOC[OBJ.name] = OBJ.data
        fPointer:write(table_to_string(LOC))
    elseif OBJ.type == "region" then
        REG[OBJ.name] = OBJ.data
        fPointer:write(table_to_string(REG))
    elseif OBJ.type == "image" then
        IMG[OBJ.name .. "_region"] = OBJ.data_img
        OBJ.data:save(OBJ.name .. ".png")
        fPointer:write(table_to_string(IMG))
    elseif OBJ.type == "color" then
        if CFG_COL_DIFF then getDiff() end
        COL[OBJ.name] = clone_table(OBJ.data_color)
        COL[OBJ.name].location = OBJ.data
        fPointer:write(table_to_string(COL))
    end
    io.close(fPointer)

    --
    table.insert(VARS_LIST, OBJ.name)
    OBJ = clone_table({})
end

-- obj Highlight
-- ---------------------------------------
local hl = {}
local function objHighlight(pointer)
    wait(0.1)
    setHighlightStyle(0x66ff0000, true)
    wait(0.1)
    if OBJ.type == "region" then
        OBJ.data:highlight(2)
    elseif OBJ.type == "image" then
        toast("image")
        wait(0.1)
        setHighlightStyle(0x66ff0000, false)
        wait(0.1)
        OBJ.data_img:highlight()
        wait(0.1)
        setHighlightStyle(0x66ff0000, true)
        wait(0.1)
        OBJ.data:highlight()
        --
        wait(2)
        --
        OBJ.data:highlightOff()
        OBJ.data_img:highlightOff()
        setHighlightStyle(0x66ff0000, true)
        wait(0.1)
    elseif OBJ.type == "location" or OBJ.type == "color" then
        local loc = get_values(OBJ.data)
        local size = 7
        wait(0.1)
        setHighlightStyle(0x66ff0000, false)
        wait(0.1)
        if pointer == "on" then
            hl.c = Region(loc.x - size, loc.y - size, size * 2, size * 2)
            hl.h1 = Region(loc.x - (size * 3), loc.y - 1, size * 2, 2)
            hl.h2 = Region(loc.x + size, loc.y - 1, size * 2, 2)
            hl.v1 = Region(loc.x - 1, loc.y - (size * 3), 2, size * 2)
            hl.v2 = Region(loc.x - 1, loc.y + size, 2, size * 2)

            hl.c:highlight()
            hl.h1:highlight()
            hl.h2:highlight()
            hl.v1:highlight()
            hl.v2:highlight()
        elseif pointer == "off" then
            if OBJ.type == "location" then wait(2) end
            hl.c:highlightOff()
            hl.h1:highlightOff()
            hl.h2:highlightOff()
            hl.v1:highlightOff()
            hl.v2:highlightOff()
            hl = {}
        end
    end
end

--
-- ---------------------------------------
local function eventListener()
    while TRUE do
        --
        local action, locTable, touchTable = getTouchEvent()
        --
        if OBJ.type == "region" or OBJ.type == "image" then
            --
            if action == "dragDrop" or action == "swipe" then
                --
                local loc_1 = get_values(locTable[1])
                local loc_2 = get_values(locTable[2])
                local x, y, w, h
                --
                x = loc_1.x < loc_2.x and loc_1.x or loc_2.x
                y = loc_1.y < loc_2.y and loc_1.y or loc_2.y
                w = math.abs(loc_1.x - loc_2.x)
                h = math.abs(loc_1.y - loc_2.y)
                --
                OBJ.data = Region(x, y, w, h)
                if OBJ.type == "image" then OBJ.data_img = Region(x - CFG_IMG_REG, y - CFG_IMG_REG, w + (CFG_IMG_REG * 2), h + (CFG_IMG_REG * 2)) end
                --
                objHighlight()
                --
                break
            else
                simpleDialog("", "Invalid action : " .. action)
            end

        elseif OBJ.type == "location" or OBJ.type == "color" then
            if action == "click" or action == "longClick" then
                --
                OBJ.data = locTable
                objHighlight("on")
                --
                if OBJ.type == "color" then
                    local timer = Timer()
                    local colors = {}
                    for i = 1, CFG_COL_CLICK do
                        colors[i] = {}
                        colors[i].r, colors[i].g, colors[i].b = getColor(OBJ.data)

                        if not is_timeout(timer, CFG_COL_CLICK_TIME) then wait(CFG_COL_CLICK_TIME - timer:set()) end
                    end
                    OBJ.data_color = clone_table(colors)
                end
                --
                objHighlight("off")
                break
            else
                simpleDialog("", "Invalid action : " .. action)
            end
            --
        end
        --
    end
    --
end

-- Edit Values
-- ---------------------------------------
local function editValues()
    removePreference("EDIT_VAL_X")
    removePreference("EDIT_VAL_Y")
    removePreference("EDIT_VAL_W")
    removePreference("EDIT_VAL_H")
    --
    dialogs.edit_values()
    --
    if OBJ.type == "region" then
        OBJ.data = Region(EDIT_VAL_X, EDIT_VAL_Y, EDIT_VAL_W, EDIT_VAL_H)
        objHighlight()
    elseif OBJ.type == "image" then
        OBJ.data = Region(EDIT_VAL_X, EDIT_VAL_Y, EDIT_VAL_W, EDIT_VAL_H)
        OBJ.data_img = Region(EDIT_VAL_X - CFG_IMG_REG, EDIT_VAL_Y - CFG_IMG_REG, EDIT_VAL_W + (CFG_IMG_REG * 2), EDIT_VAL_H + (CFG_IMG_REG * 2))
        objHighlight()
    elseif OBJ.type == "location" or OBJ.type == "color" then
        OBJ.data = Location(EDIT_VAL_X, EDIT_VAL_Y)
        objHighlight("start")
        --
        if OBJ.type == "color" then
            local timer = Timer()
            local colors = {}
            for i = 1, CFG_COL_CLICK do
                colors[i] = {}
                colors[i].r, colors[i].g, colors[i].b = getColor(OBJ.data)

                if not is_timeout(timer, CFG_COL_CLICK_TIME) then wait(CFG_COL_CLICK_TIME - timer:set()) end
            end
            OBJ.data_color = clone_table(colors)
        end
        --
        objHighlight("end")
    end
end

-- New obj menu
-- ---------------------------------------
local function menuObj()
    local obj
    local listener = true
    while TRUE do
        removePreference("OBJ_OP")
        --
        if listener then eventListener() end

        dialogs.obj_options()

        if OBJ_OP == 1 then
            saveData()
            break
        elseif OBJ_OP == 2 then
            editValues()
            listener = false
        elseif OBJ_OP == 3 then
            listener = true
            -- continue loop
        elseif OBJ_OP == 4 then
            OBJ = {}
            break
        end
    end
end

-- check name
-- -- exists,
-- -- no white spaces
-- -- special characters
-- ---------------------------------------
local function varName(name)
    name = trim(name)
    if name:len() <= 0 then
        simpleDialog("", "\n\t Name must be provided \n") return false
    elseif not name:match("^[a-zA-Z0-9_]*$") then
        simpleDialog("", "\n\t Name must only contain alphanumeric characters,\"_\" underscore and no spaces \n") return false
    elseif in_table(VARS_LIST, name) then
        simpleDialog("", "\n\t [" .. name .. "] - This Name already exists\n") return false
    else return true
    end
end

-- Start config
-- ---------------------------------------
while TRUE do
    dialogs.config()
    if varName(CFG_FOLDER_NAME) then break end
end


-- Ankulua settings
-- ---------------------------------------
setImmersiveMode(CFG_IMMERSIVE)
SCRIPT_DIMENSION = CFG_IMMERSIVE and getRealScreenSize():getX() or getAppUsableScreenSize():getX()
--
Settings:setScriptDimension(true, SCRIPT_DIMENSION)
Settings:setCompareDimension(true, SCRIPT_DIMENSION)
--
mkdir(ROOT .. CFG_FOLDER_NAME .. "/images/")
setImagePath(ROOT .. CFG_FOLDER_NAME .. "/images/")
--


-- Preference reset
-- ---------------------------------------
removePreference("NEW_REC_OP")
removePreference("NEW_REC_VAR_NAME")


while TRUE do
    --
    dialogs.new_record()
    --
    if NEW_REC_OP == 6 then scriptExit() end
    --
    if NEW_REC_OP == 5 then
        wait(3)
    elseif varName(NEW_REC_VAR_NAME) then
        --
        OBJ.name = NEW_REC_VAR_NAME
        --
        if NEW_REC_OP == 1 then
            OBJ.type = "image"
            menuObj()
        elseif NEW_REC_OP == 2 then
            OBJ.type = "region"
            menuObj()
        elseif NEW_REC_OP == 3 then
            OBJ.type = "location"
            menuObj()
        elseif NEW_REC_OP == 4 then
            OBJ.type = "color"
            menuObj()
        end
        --
        removePreference("NEW_REC_VAR_NAME")
        wait(CFG_CAPTURE_WAIT)
    end
end
