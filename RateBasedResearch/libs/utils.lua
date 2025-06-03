function Round(num)
    if math.abs(num) > 2 ^ 52 then
        return num
    end
    return num < 0 and num - 2 ^ 52 + 2 ^ 52 or num + 2 ^ 52 - 2 ^ 52
end

function RoundAtPoint(exact, quantum)
    return Round(exact / quantum) * quantum
end

function CalDecPoint(value)
    local i = 0
    while value < 1 and i < 32 do
        i = i + 1
        value = value * 10
    end
    return i
end

function RoundAtPointOffset(exact, offset)
    return RoundAtPoint(exact, 1 / (10 ^ (CalDecPoint(exact) + offset)))
end

function FormatNum(num, precision)
    local withTrailing = string.format("%."..precision.."f", num)
    return withTrailing:gsub("0+$", ""):gsub("%.$", "")
end

printSetting = {skip=defines.print_skip.never, sound=defines.print_sound.never, game_state=false}

-- Datatype for recipe
---@class RecipeData
---@field name string Name ID
---@field oriSciSpeed number Original science speed (sec per unit)
---@field oriSciCost number Original science amount (units)
---@field sciSpeed number New science speed, after the adjustment (sec per unit)
---@field sciCost number New science amount, after the adjustment (units)
---@field sciPerSec number Min required science per second (units per sec)

local rateRatioBase = settings.startup["science-rate-ratio-base"].value
local rateRatioExponent = settings.startup["science-rate-ratio-exponent"].value
local costBase = settings.startup["science-cost-base"].value
local costExp = settings.startup["science-cost-exponent"].value
local labSpeedBase = settings.startup["lab-speed-base"].value
local labSpeedExp = settings.startup["lab-speed-exponent"].value

---@param recipeData RecipeData
---@return {labs: number, time: number}
function CalculateMinRequirement(recipeData)
    return {
        labs = recipeData.sciPerSec * recipeData.sciSpeed, -- labs needed
        time = recipeData.sciCost / recipeData.sciPerSec, -- time needed for min speed
    }
end

---@param recipe {name: string, speed: number, cost: number}
---@return RecipeData
function ImplDataMake(recipe)
    local obj = {
        name = recipe.name,
        oriSciSpeed = recipe.speed,
        oriSciCost = recipe.cost,
    }
    obj.sciCost = (obj.oriSciCost * costBase) ^ costExp;
    obj.sciPerSec = RoundAtPoint(rateRatioBase * (obj.sciCost ^ rateRatioExponent), 0.1)
    obj.sciSpeed = obj.oriSciSpeed  -- temp for below cal
    local infoMin = CalculateMinRequirement(obj)
    local tweakLabNeeded = infoMin.labs ^ labSpeedExp * labSpeedBase
    local tweakRatio = tweakLabNeeded / infoMin.labs
    -- adjust speed based on target min required labs
    obj.sciSpeed = math.max(1, Round(obj.sciSpeed * tweakRatio))
    return obj
end

---@param tech data.TechnologyPrototype data.tech
function ImplInfDataModification(tech)
    assert(tech.unit ~= nil)
    assert(tech.unit.count_formula ~= nil)
    -- note: No support for tweaking the lab speed for those stuff yet.
    -- formula update: f(l) => (f(l) * costBase) ^ costExp
    tech.unit.count_formula = string.format(
        "((%s)*%s)^%s",
        tech.unit.count_formula, FormatNum(costBase,2), FormatNum(costExp,2)
    )
end

---@param tech LuaTechnology runtime tech
---@return RecipeData|nil
---@nodiscard
function RuntimeInfDataMake(tech)
    assert(tech.research_unit_count_formula ~= nil)
    local cost = tech.research_unit_count
    local obj = {
        name = tech.name,
        sciCost = cost,
        sciPerSec = RoundAtPoint(rateRatioBase * (cost ^ rateRatioExponent), 0.1)
    } -- any other field is invalid (and unused)
    game.print("Inf cost: " .. tostring(obj.sciCost)..", sciPerSec: " .. tostring(obj.sciPerSec), printSetting)
    return obj
end

---@param recipe data.TechnologyPrototype data.tech
---@return RecipeData
---@nodiscard
function DataMake(recipe)
    assert(recipe.unit ~= nil)
    assert(recipe.unit.count ~= nil) -- not supporting formula-based yet
    return ImplDataMake({
        name = recipe.name,
        speed = recipe.unit.time, -- time of units per second
        cost = recipe.unit.count, -- original cost in units
    })
end

function FormatTime(timeSec)
    local hour = math.floor(timeSec / 3600)
    local min = math.floor((timeSec % 3600) / 60)
    local sec = Round(timeSec % 60)
    local result = ""
    if hour > 0 then
        result = result .. string.format("%dh", hour)
    end
    if min > 0 then
        result = result .. string.format("%dm", min)
    end
    if sec > 0 then
        result = result .. string.format("%ds", sec)
    end
    return result
end

---@param recipeData RecipeData
---@return {prefix: string, posfix: string}
function FormatDesc(recipeData)
    -- $"<b>Decay: {sciPerSec}/sec ({secPerMin}/min)\n
    --   Min: {Labs} labs for {hour}h-{min}m-{sec}s</b>\n"
    local infoMin = CalculateMinRequirement(recipeData)
    -- local prefix = string.format(
    --     "Decay: [font=count-font]%s[/font]sci/sec ([font=count-font]%s[/font]sci/min) (Or [font=count-font]%s[/font] labs for[font=count-font]",
    --     FormatNum(recipeData.sciPerSec, 2),
    --     FormatNum(recipeData.sciPerSec * 60, 2),
    --     FormatNum(infoMin.labs, 2)
    -- );
    -- $"Minimum Rate: 1 labs for 50s, at 6sci/min (0.1sci/sec)"
    local prefix = string.format(
        "Rate: [font=count-font]%s[/font] labs for [font=count-font]%s[/font], at [font=count-font]%ssci/min[/font] ([font=count-font]%ssci/sec[/font])\n",
        FormatNum(infoMin.labs, 2),
        FormatTime(infoMin.time),
        FormatNum(recipeData.sciPerSec * 60, 2),
        FormatNum(recipeData.sciPerSec, 2)
    )

    -- $"\nOriginal[rate={oriSciSpeed}, cost={oriSciCost}]"
    local posfix = string.format(
        "\n[font=default-small]Original[rate=%d, cost=%d][/font]",
        recipeData.oriSciSpeed, recipeData.oriSciCost
    )
    return {prefix = prefix, posfix = posfix}
end

---@param name string Name id
---@param descString string
---@return RecipeData|nil
function ParseEmbeddedFromDesc(name, descString)
    -- Parse out the oriSciSpeed and oriSciCost from posfix of desc
    local oriSciSpeed, oriSciCost = descString:match(
        "Original%[rate=([%d%.]+), cost=([%d%.]+)%]"
    )
    if oriSciSpeed == nil or oriSciCost == nil then
        return nil
    end
    oriSciSpeed = tonumber(oriSciSpeed)
    oriSciCost = tonumber(oriSciCost)
    if oriSciSpeed == nil or oriSciCost == nil then
        return nil
    end
    return ImplDataMake({
        name = name,
        speed = oriSciSpeed,
        cost = oriSciCost,
    })
end

---@param recipe LuaTechnology runtime.tech
---@return RecipeData|nil
---@nodiscard
function RuntimeMake(recipe)
    local prot = recipe.prototype
    local locDesc = prot.localised_description ---@type string[]
    -- check if desc is an array, if not, return nil
    if type(locDesc) ~= "table" and #locDesc <= 2 then
        return nil
    end
    local obj = ParseEmbeddedFromDesc(prot.name, locDesc[#locDesc])
    return obj
end

---@param name string
---@return string, int|nil
function ParseTechName(name)
    -- Level is formatted like this:
    -- "Abc-def-1", "Abc-def-2", "Abc-def-3", etc.
    local subPos = name:match("-(%d+)$")
    if subPos == nil then
        return name, nil
    end
    local level = tonumber(subPos)
    if level == nil then
        return name, nil
    end
    local baseName = name:sub(1, -#subPos - 2) -- remove the "-level" part
    return baseName, level
end

---@param tech data.TechnologyPrototype
---@param prefix string
---@param posfix string
function AddPrePostfix(tech, prefix, posfix)
	local techBaseName, techLevel = ParseTechName(tech.name)
	if (tech.localised_description == nil) then
		local locTree = {"?",
			{"technology-description." .. techBaseName},
			{"item-description." .. techBaseName},
			{"entity-description." .. techBaseName},
			"No description"
		}
		tech.localised_description = {"", prefix, locTree, posfix}
	else
		local decs = tech.localised_description
		tech.localised_description = {"", prefix, decs, posfix}
	end
end