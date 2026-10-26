class_name LootTiers extends Node

enum Tiers {BRONZE, SILVER, GOLD, DIAMOND}

const TIER : Dictionary = {
	Tiers.BRONZE: {
		"coins" : {"min" : 50, "max" : 100},
		"equipments" : {"min" : 0, "max" : 2},
		"eligible_rarity" : {
			"common" : 10,
			"uncommon" : 1,
		}
	},
	Tiers.SILVER: {
		"coins" : {"min" : 100, "max" : 200},
		"equipments" : {"min" : 1, "max" : 2},
		"eligible_rarity" : {
			"common" : 5,
			"uncommon" : 5,
			"rare" : 1,
		}
	},
	Tiers.GOLD: {
		"coins" : {"min" : 300, "max" : 400},
		"equipments" : {"min" : 2, "max" : 4},
		"eligible_rarity" : {
			"uncommon" : 10,
			"rare" : 6,
			"legendary" : 1,
		}
	},
	Tiers.DIAMOND: {
		"coins" : {"min" : 500, "max" : 750},
		"equipments" : {"min" : 3, "max" : 6},
		"eligible_rarity" : {
			"uncommon" : 3,
			"rare" : 10,
			"legendary" : 5,
		}
	},
}
