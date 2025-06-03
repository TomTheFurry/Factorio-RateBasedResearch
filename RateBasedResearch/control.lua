require("libs.utils")


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
            local data
            if (r.prototype.research_unit_count_formula~=nil) then
                data = RuntimeInfDataMake(r)
            else
                if r.prototype.research_unit_count==nil then goto continue end
                data = RuntimeMake(r)
            end
            if data==nil then goto continue end
            local progress = force.research_progress
            if storage.RBRData~=nil
                and storage.RBRData[force.index]~=nil
                and storage.RBRData[force.index].research.prototype.name==r.prototype.name
            then
                local rsdOld = storage.RBRData[force.index]
                local progChange = (progress - rsdOld.prog) * 60 -- to sec
                local progRequired = data.sciPerSec / data.sciCost -- how much progress is needed per sec to complete the research
                game.print("Progress change: "..tostring(progChange), printSetting)
                game.print("Progress required: "..tostring(progRequired), printSetting)
                if progChange + 0.00001 >= progRequired then
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