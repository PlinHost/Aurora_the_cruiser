/turf/space
	icon = 'space.dmi'
	name = "space"
	icon_state = "placeholder"
	layer = 0.5

	temperature = 0
	oxygen = 0
	nitrogen = 0
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/New()
	icon_state = "[((x + y) ^ ~(x * y) + z) % 25]"