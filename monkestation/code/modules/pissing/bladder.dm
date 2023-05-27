/datum/reagent/ammonia/urine
	name = "Urine"
	description = "Exactly what you think. Should be useful."
	color = "#c0d121"
	taste_description = "piss"

/obj/item/organ/internal/bladder
	name = "bladder"
	desc = "This is where the pee is stored"

	icon = 'monkestation/icons/obj/organs.dmi'
	icon_state = "bladder"

	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_BLADDER

	///the reagent we piss
	var/datum/reagent/pissin_reagent = /datum/reagent/ammonia/urine
	///the amount of liquid we create per piss
	var/piss_amount = 10
	///max amount of piss we can stoer
	var/max_piss_storage = 300
	///amount of piss we generate per process
	var/per_process_piss = 1
	///current amount of stored piss
	var/stored_piss = 0
	///per usage piss base is 20 pisses per full tank
	var/per_piss_usage = 15
	///the temperature the piss comes out as
	var/piss_temperature = 340
	///last notification of having a full bladder
	COOLDOWN_DECLARE(piss_notification)


/obj/item/organ/internal/bladder/proc/consume_act(datum/reagents/consumed_reagents, amount)
	stored_piss = min(stored_piss + amount, max_piss_storage)

	if(COOLDOWN_FINISHED(src, piss_notification) && stored_piss == max_piss_storage)
		to_chat(owner, span_warning("Your bladder if feeling full."))
		COOLDOWN_START(src, piss_notification, 5 MINUTES)



/obj/item/organ/internal/bladder/process(seconds_per_tick, times_fired)
	. = ..()
	stored_piss = min(stored_piss + per_process_piss, max_piss_storage)

/obj/item/organ/internal/bladder/proc/urinate()
	if(stored_piss < per_piss_usage)
		to_chat(owner, span_notice("Try as you might you fail to piss."))
		return

	var/valid_toilet = FALSE
	var/turf/open/owner_turf = get_turf(owner)
	for(var/atom/movable/listed_atom in owner_turf)
		if(istype(listed_atom, /obj/structure/toilet))
			valid_toilet = TRUE
			break


	var/obj/item/reagent_containers/held_container
	if(owner.held_items[owner.active_hand_index] != null)
		var/obj/item/listed_item = owner.held_items[owner.active_hand_index]
		if(istype(listed_item, /obj/item/reagent_containers))
			held_container = listed_item

	if(held_container)
		if(attempt_piss_into(held_container))
			return

	if(valid_toilet)
		owner.visible_message(span_notice("[owner] pisses into the toilet."))
		return

	owner.visible_message(span_warning("[owner] pisses all over the floor!"))
	stored_piss -= per_piss_usage
	owner_turf.add_liquid(pissin_reagent, piss_amount, FALSE, piss_temperature)


/obj/item/organ/internal/bladder/proc/attempt_piss_into(obj/item/reagent_containers/piss_holder)
	var/space_left = piss_holder.volume - piss_holder.reagents.total_volume
	if(!space_left)
		return FALSE
	piss_holder.reagents.add_reagent(pissin_reagent, piss_amount, reagtemp = piss_temperature)
	return TRUE


/obj/item/organ/internal/bladder/clown
	name = "clown bladder"
	desc = "How does this even work?"

	pissin_reagent = /datum/reagent/lube
