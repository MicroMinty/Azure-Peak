/obj/item/assembly/igniter
	name = "igniter"
	desc = ""
	icon_state = "igniter"
	custom_materials = list(/datum/material/iron=500, /datum/material/glass=50)
	var/datum/effect_system/spark_spread/sparks
	heat = 1000

/obj/item/assembly/igniter/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is trying to ignite [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.IgniteMob()
	return FIRELOSS

/obj/item/assembly/igniter/Initialize()
	. = ..()
	sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)

/obj/item/assembly/igniter/Destroy()
	if(sparks)
		qdel(sparks)
	sparks = null
	. = ..()

/obj/item/assembly/igniter/activate()
	if(!..())
		return FALSE//Cooldown check
	var/turf/location = get_turf(loc)
	if(location)
		location.hotspot_expose(1000,1000)
	sparks.start()
	return TRUE

/obj/item/assembly/igniter/attack_self(mob/user)
	activate()
	add_fingerprint(user)

/obj/item/assembly/igniter/ignition_effect(atom/A, mob/user)
	. = "<span class='notice'>[user] fiddles with [src], and manages to \
		light [A].</span>"
	activate()
	add_fingerprint(user)