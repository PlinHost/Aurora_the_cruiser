mob/var/list/pain_stored = list()
mob/var/last_pain_message = ""
mob/var/next_pain_time = 0

// partname is the name of a body part
// amount is a num from 1 to 100
mob/proc/pain(var/partname, var/amount, var/force)
	if(death != 0) return
	if(world.time < next_pain_time && !force)
		return
	if(amount > 50 && prob(amount / 5))
		src:drop_item()
	var/msg
	switch(amount)
		if(1 to 10)
			msg = "<b>Your [partname] hurts a bit."
		if(11 to 90)
			msg = "<b><font size=1>Ouch! Your [partname] hurts."
		if(91 to 10000)
			msg = "<b><font size=3>OH GOD! Your [partname] is hurting terribly!"
	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		src << msg
	next_pain_time = world.time + (100 - amount)

/mob/proc/handle_pain()
	// not when sleeping
	if(death != 0) return
	if(istype(src,/mob))
		var/maxdam = 0
		var/datum/organ/external/damaged_organ = null
		for(var/datum/organ/external/E in organs)
			var/dam = E.get_damage()
			// make the choice of the organ depend on damage,
			// but also sometimes use one of the less damaged ones
			if(dam > maxdam && (maxdam == 0 || prob(70)) )
				damaged_organ = E
				maxdam = dam
		if(damaged_organ)
			pain(damaged_organ.name, maxdam, 0)