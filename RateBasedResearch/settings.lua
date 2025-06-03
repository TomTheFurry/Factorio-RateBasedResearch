data:extend({
	{
		type = "double-setting",
		name = "science-rate-ratio-base",
		setting_type = "startup",
		localised_name = "Science Rate Base Ratio",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 0.02\n"
            .."Hardcore: 0.04\n"
            .."Megabase: 0.06\n"
            .."\n"
            .."The minimium rate needed to research a science is calculated based on its original cost in this formula: 'SciencePerSecond = BaseRatio * OriginalCost^ExponentRatio'. This setting configures the value of 'BaseRatio'.",
		default_value = 0.04,
		minimum_value = 0.001,
		order="a",
	},
	{
		type = "double-setting",
		name = "science-rate-ratio-exponent",
		setting_type = "startup",
		localised_name = "Science Rate Exponent Ratio",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 0.6\n"
            .."Hardcore: 0.5\n"
            .."Megabase: 0.5\n"
            .."\n"
            .."The minimium rate needed to research a science is calculated based on its original cost in this formula: 'SciencePerSecond = BaseRatio * OriginalCost^ExponentRatio'. This setting configures the value of 'ExponentRatio'.",
		default_value = 0.5,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "science-cost-base",
		setting_type = "startup",
		localised_name = "Science Cost Multiplier",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 1\n"
            .."Hardcore: 20\n"
            .."Megabase: 100\n"
            .."\n"
            .."This is the replacement of science cost multiplier, as now the multiplier need to be applier on startup.",
		default_value = 20,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "science-cost-exponent",
		setting_type = "startup",
		localised_name = "Science Cost Exponent",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 1\n"
            .."Hardcore: 1\n"
            .."Megabase: 1\n"
            .."\n"
            .."",
		default_value = 1,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "lab-speed-base",
		setting_type = "startup",
		localised_name = "Lab Speed Base Factor",
		localised_description =
		"This tweaks the base lab consumsion speed. This adjust how much time each unit of research takes, and thus how many labs you need to build at minimium without adjusting cost nor min rate of the researches.",
		default_value = 1,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "lab-speed-exponent",
		setting_type = "startup",
		localised_name = "Lab Speed Exponent Factor",
		localised_description =
            "This tweaks the late-game-technology's lab consumsion speed. This may be needed for high difficulty settings just so that you don't have to spam 1000s of labs to get the consumsion rate above the minimum rate needed for late game technology.\n"
            .."The speed is calculated such that the required labs are 'newRequiredLabs = OriginalRequiredLabs^LabSpeedExponent'.",
		default_value = 1,
		minimum_value = 0.1,
		order="a",
	},
})


