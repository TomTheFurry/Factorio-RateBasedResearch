require("libs.utils")

local technologies=data.raw.technology

for _,technology in pairs(technologies) do
	if (technology.unit == nil and technology.research_trigger == nil) then
		__DebugAdapter.print("skipping tech " .. technology.name .. " with no unit data")
		goto continue
	end
	if (technology.unit == nil and technology.research_trigger ~= nil) then
		-- Just a trigger based research. Skip
		goto continue
	end
	if (technology.unit ~= nil and technology.unit.count_formula ~= nil) then
		local num = tonumber(technology.unit.count_formula) -- try see if formula is just a constant value
		if (num ~= nil) then
			technology.unit.count = num
			technology.unit.count_formula = nil -- remove formula
			__DebugAdapter.print("Converted tech " .. technology.name .. " with formula to constant value: " .. num)
		else
			-- we can't resolve any numbers yet. So instead, mutate the formula
			ImplInfDataModification(technology)
			__DebugAdapter.print("Mutated tech " .. technology.name .. " with formula: " .. technology.unit.count_formula)
			AddPrePostfix(technology, "[font=count-font](TODO: Unable to show numbers for formula-cost-based research)[/font]\n", "")
			goto continue
		end
	end
	local techData = DataMake(technology)
	technology.unit.count = techData.sciCost
	technology.unit.time = techData.sciSpeed
	local descAdd = FormatDesc(techData)
	AddPrePostfix(technology, descAdd.prefix, descAdd.posfix)
	::continue::
end