/obj/item/gun/ballistic/revolver/grenadelauncher/runelock
	name = "runelock"
	desc = "A deadly weapon that shoots a cluster of powder with terrifying power."
	icon = 'icons/roguetown/weapons/32.dmi'
	icon_state = "crossbow0"
	item_state = "crossbow"
	experimental_onhip = TRUE
	experimental_onback = TRUE
	possible_item_intents = list(/datum/intent/shoot/runelock, INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/runelock
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_BULKY
	randomspread = 1
	spread = 0
	can_parry = TRUE
	force = 20
	cartridge_wording = "runepowder"
	load_sound = 'sound/foley/nockarrow.ogg'
	fire_sound = 'sound/combat/Ranged/crossbow-small-shot-02.ogg'
	anvilrepair = /datum/skill/craft/weaponsmithing
	smeltresult = /obj/item/ingot/bronze
	resistance_flags = FIRE_PROOF
	obj_flags = UNIQUE_RENAME
	damfactor = 1
	accfactor = 1
	var/atom/movable/temp_runepowder = null
/obj/item/gun/ballistic/revolver/grenadelauncher/runelock/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/runelock/attackby(obj/item/A, mob/user, params) //thank u john sling
	if(istype(A, /obj/item/ammo_box) || istype(A, /obj/item/ammo_casing) || istype(A, /obj/item/magic/fairydust))
		if(temp_runepowder == null && istype(A, /obj/item/magic/fairydust)) //code of the damned. this must be done since regular FAIRYDUST objects cannot be loaded into the magazine and I did not want to change FAIRYDUST to be an ammo type
			temp_runepowder = A //storing the RUNEPOWDER
			user.transferItemToLoc(A, temp_runepowder) //off to POWDER purgatory you go
			A = new /obj/item/ammo_casing/caseless/rogue/runepowder //putting a temporary RUNELOCK bullet in its place. bonus force is kept on the RUNELOCK and set to 0 if shot or stone is ejected
		..()
		
/obj/item/gun/ballistic/revolver/grenadelauncher/runelock/attack_self(mob/user) //you may not unload it.
	to_chat(user, span_info("It's too dangerous to reach my arm down the barrel... I need to find another way to unload it."))
	return
/obj/item/ammo_box/magazine/internal/shot/runelock
	ammo_type = /obj/item/ammo_casing/caseless/rogue/runepowder
	caliber = "runepowder"
	max_ammo = 1
	start_empty = TRUE


/obj/item/gun/ballistic/revolver/grenadelauncher/runelock/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(user.get_num_arms(FALSE) < 2)
		return FALSE
	if(user.get_inactive_held_item())
		return FALSE
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB

		BB.accuracy += accfactor * (user.STAPER - 8) * 3 // 8+ PER gives +3 per level. Exponential.
		BB.bonus_accuracy += (user.STAPER - 8) // 8+ PER gives +1 per level. Does not decrease over range.
		BB.bonus_accuracy += (user.get_skill_level(/datum/skill/combat/crossbows) * 5) // +5 per XBow level.
		BB.damage *= damfactor
	if (temp_runepowder != null) //reseting after faedust ammo use
		temp_runepowder = null
	if(user.has_status_effect(/datum/status_effect/buff/clash) && ishuman(user))
		var/mob/living/carbon/human/H = user
		H.bad_guard(span_warning("I can't focus on my Guard and loose a charge! This drains me!"), cheesy = TRUE)
	..()


/datum/intent/shoot/runelock
	chargedrain = 0 //no drain to aim a crossbow

/datum/intent/shoot/runelock/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE


/datum/intent/shoot/runelock/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = chargetime
		//skill block
		newtime = newtime + 80
		newtime = newtime - (mastermob.get_skill_level(/datum/skill/combat/crossbows) * 4.25) // minus 4.25 per skill point
		newtime = newtime - ((mastermob.STAPER)) // minus 1 per perception
		if(newtime > 1)
			return newtime
		else
			return 1
	return chargetime
