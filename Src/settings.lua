data:extend({
	{
		type = "double-setting",
		name = "science-rate-ratio-base",
		setting_type = "startup",
		localised_name = "Science Rate Base Ratio",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 0.02\n"
            .."Hardcore: 0.03\n"
            .."Megabase: 0.04\n"
            .."\n"
            .."The minimium rate needed to research a science is calculated based on its original cost in this formula: 'SciencePerSecond = BaseRatio * OriginalCost^ExponentRatio'. This setting configures the value of 'BaseRatio'.",
		default_value = 0.02,
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
            .."Vanilla: 0.5\n"
            .."Hardcore: 0.6\n"
            .."Megabase: 0.8\n"
            .."\n"
            .."The minimium rate needed to research a science is calculated based on its original cost in this formula: 'SciencePerSecond = BaseRatio * OriginalCost^ExponentRatio'. This setting configures the value of 'ExponentRatio'.",
		default_value = 0.5,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "science-time-factor",
		setting_type = "startup",
		localised_name = "Science Time Factor",
		localised_description =
            "Recommended settings:\n"
            .."Normal speed: 0.5\n"
            .."Fast playthough: 0.25\n"
            .."Large multiplayer server: 1\n"
            .."\n"
            .."When supplied with the minimium rate needed, how much time is needed to complete a research, based on the rate. It is calculated in this formula: 'TotalSeconds = OriginalTimeCost * TimeFactor'. Note that you can complete a research faster if you provide even more science.",
		default_value = 0.5,
		minimum_value = 0.01,
		order="a",
	},
	{
		type = "double-setting",
		name = "lab-speed-exponent",
		setting_type = "startup",
		localised_name = "Lab Speed Exponent Factor",
		localised_description =
            "Recommended settings:\n"
            .."Vanilla: 1\n"
            .."Hardcore: 0.8\n"
            .."Megabase: 0.6\n"
            .."\n"
            .."This tweaks the late-game-technology's lab consumsion speed. This may be needed for high difficulty settings just so that you don't have to spam 1000s of labs to get the consumsion rate above the minimum rate needed for late game technology.\n"
            .."The speed is calculated such that the required labs are 'newRequiredLabs = OriginalRequiredLabs^LabSpeedExponent'.",
		default_value = 1,
		minimum_value = 0.1,
		order="a",
	}
})


