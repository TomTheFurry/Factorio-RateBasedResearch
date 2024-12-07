require("libs.utils")

local technologies=data.raw.technology
local rateRatioBase = settings.startup["science-rate-ratio-base"].value
local rateRatioExponent = settings.startup["science-rate-ratio-exponent"].value
local timeFactor = settings.startup["science-time-factor"].value
local labSpeedExp = settings.startup["lab-speed-exponent"].value


for _,technology in pairs(technologies) do
	if (technology.unit ~= nil and technology.unit.count ~= nil and technology.unit.count_formula == nil) then
		local originalCost = technology.unit.count
        local originalTime = technology.unit.time
        technology.unit.count = technology.unit.count * timeFactor
        
		local rateNeeded = math.ceil(10 * rateRatioBase * originalCost ^ rateRatioExponent) / 10
        local spmNeeded = rateNeeded * 60
        
        local labSps = 1/originalTime
        local labNeeded = math.ceil(100 * rateNeeded/labSps) / 100
        local tweakedLabNeeded = Round(labNeeded^labSpeedExp)
        local tweakSpeed = tweakedLabNeeded/labNeeded
        technology.unit.time = math.max(1, Round(technology.unit.time * tweakSpeed))
        
        labSps = 1/technology.unit.time
        labNeeded = math.ceil(100 * rateNeeded/labSps) / 100
        
		local name = technology.name
        local minTimeNeeded = technology.unit.time*originalCost*timeFactor/labNeeded
        
        local val,qua = math.modf(minTimeNeeded/60)
        qua = qua * 60
        local labSpsFormated = Round(labSps*100)/100
        local timeFormated = ""
        if val > 0 then
            timeFormated = ""..val.." minutes and "
        end
        timeFormated = timeFormated..string.format("%.0f",qua).." seconds"
        
        local strInfo = "RateBaseResearch:\nNeeds "..rateNeeded.."sci/sec ("..spmNeeded.."sci/min)\n"..
            "Requires "..labNeeded.." basic labs ("..labSpsFormated.."sci/sec per lab) running for "..timeFormated.."\n\n"
		if (technology.localised_description == nil) then
			local level = -1
			local subPos = -1
			local c = string.len(name)
			for i=c,1,-1 do
				local char = string.byte(name, i)
				if char == string.byte("-") then
					subPos = i-1
					goto exit
				end
				if (char < string.byte("0") or char > string.byte("9")) then
					goto exit
				end
			end
			::exit::
			
			local locName = ""
			local isSpecial = false
			if subPos ~= -1 then
				level = string.sub(name, subPos+2) + 0
				name = string.sub(name, 1, subPos)
				locName = name
				isSpecial = true
			else
				locName = technology.name
			end
			if isSpecial then
				--__DebugAdapter.print("skipping tech " .. locName)
				--goto continue
			end
			
			local locTree = {"?",
				{"technology-description." .. locName},
				{"item-description." .. locName},
				{"entity-description." .. locName},
				"No description"
			}
			technology.localised_description = {"", strInfo, locTree}
		else
			local decs = technology.localised_description
			technology.localised_description = {"", strInfo, decs}
		end
		::continue::
	end
end