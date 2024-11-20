local function round(num)
  if math.abs(num) > 2^52 then
    return num
  end
  return num < 0 and num - 2^52 + 2^52 or num + 2^52 - 2^52
end

function roundAtPoint(exact, quantum)
    return round(exact/quantum)*quantum
end
function calDecPoint(value)
    local i = 0
    while value < 1 and i < 32 do
        i = i+1
        value = value * 10
    end
    return i
end
function roundAtPointOffset(exact, offset)
    return roundAtPoint(exact, 1/(10 ^ (calDecPoint(exact) + offset)))
end


local timeFactor = settings.startup["science-time-factor"].value
local rateRatioBase = settings.startup["science-rate-ratio-base"].value
local rateRatioExponent = settings.startup["science-rate-ratio-exponent"].value

printSetting = {skip=defines.print_skip.never, sound=defines.print_sound.never, game_state=false}

local researchStartFunc = function(event)
    local force = event.research.force
    local researchSpeedData = {research = event.research, prog = event.research.saved_progress}
    if storage.RBRData==nil then storage.RBRData = {} end
    storage.RBRData[force.index] = researchSpeedData
end

local researchEndFunc = function(force)
    if storage.RBRData~=nil then storage.RBRData[force.index] = nil end
end

script.on_event(defines.events.on_research_started, researchStartFunc)
script.on_event(defines.events.on_research_cancelled, function(event) researchEndFunc(event.force) end)
script.on_event(defines.events.on_research_finished, function(event) researchEndFunc(event.research.force) end)

script.on_event(defines.events.on_tick, function(event)
		for _,force in pairs(game.forces) do
			local r = force.current_research
			if r==nil then goto continue end
			if r.researched then goto continue end
			if r.prototype.research_unit_count==nil then goto continue end
            local force = r.force
            local progress = force.research_progress
            local shouldWork = storage.RBRData~=nil and storage.RBRData[force.index]~=nil
            if storage.RBRData~=nil
                and storage.RBRData[force.index]~=nil
                and storage.RBRData[force.index].research.prototype.name==r.prototype.name
            then
                local rsdOld = storage.RBRData[force.index]
                
                local cost = r.prototype.research_unit_count / timeFactor -- get back original cost
                
                local sciRequired = math.ceil(10 * rateRatioBase * cost ^ rateRatioExponent) / 10
                local progRequired = sciRequired/r.prototype.research_unit_count
                progRequired = roundAtPointOffset(progRequired, 3)
                local progChange = math.max(0, progress - rsdOld.prog) * 60
                progChange = roundAtPointOffset(progChange, 3)
                local sciChange = progChange*r.prototype.research_unit_count
                
                --game.print("Next!", printSetting)
                --game.print("sciRequired "..tostring(sciRequired), printSetting)
                --game.print("sciChange "..tostring(sciChange), printSetting)
                --game.print("progRequired "..tostring(progRequired), printSetting)
                --game.print("progChange "..tostring(progChange), printSetting)
                if progChange >= progRequired then
                    progress = rsdOld.prog + (progChange / 60)
                else
                    progress = rsdOld.prog - ((progRequired - progChange) / 60)
                end
                if progress <= 0 then progress = 0 end
                if progress >= 1 then progress = 1 end
                force.research_progress = progress
            end
            local rsd = {research=r, prog=progress}
            if storage.RBRData==nil then storage.RBRData = {} end
            storage.RBRData[force.index] = rsd
			::continue::
		end
  	end)