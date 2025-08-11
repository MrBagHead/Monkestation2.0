/datum/martial_art/slasher_grab //martial art that exists so slasher can aggro grab like a real evil dude
	name = "Slasher Grabbing"
	id = MARTIALART_SLASHER_GRAB
	COOLDOWN_DECLARE(grabby_cd)

/datum/martial_art/slasher_grab/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender)
		return FALSE

	if(!COOLDOWN_FINISHED(src, grabby_cd))
		return FALSE

	var/old_grab_state = attacker.grab_state

	defender.grabbedby(attacker, 1)

	if(old_grab_state == GRAB_PASSIVE)
		attacker.setGrabState(GRAB_AGGRESSIVE)

		log_combat(attacker, defender, "grabbed", addition="aggressively")

		attacker.balloon_alert(attacker, "You grab them aggressively by the neck!")
		defender.balloon_alert(defender, "You are grabbed aggressively by the neck!")
		defender.drop_all_held_items()

		defender.stop_pulling()

		defender.visible_message(span_warning("[attacker] violently grabs [defender]!"), \
			span_userdanger("You're violently grabbed by [attacker]!"),
			span_hear("You hear sounds of aggressive fondling!"),
			null, attacker)

		to_chat(attacker, span_danger("You violently grab [defender]!"))

		COOLDOWN_START(src, grabby_cd, 15 SECONDS)
		return TRUE
