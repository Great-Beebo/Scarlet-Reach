/obj/effect/proc_holder/spell/self/enthrall
	name = "Enthrall"
	desc = "Compels up to one victim to obey by means of a hypnotic charm. Widely considered an evil and taboo spell."
	school = "enchantment"
	charge_type = "recharge"
	recharge_time = 2 MINUTES
	movement_interrupt = TRUE
	clothes_req = FALSE
	cost = 7
	spell_tier = 2
	cooldown_min = 2 MINUTES
	associated_skill = /datum/skill/magic/arcane
	xp_gain = TRUE
	action_icon_state = "spell0"

	var/enthrall_delay = 20 SECONDS
	var/mob/living/current_victim = null  // Track current enthralled victim

/obj/effect/proc_holder/spell/self/enthrall/cast(mob/user = usr)
	if(!istype(user, /mob/living))
		return

	var/mob/living/M = user.pulling

	// Must be grabbing a living target
	if(!M)
		to_chat(user, span_warning("You must be grabbing your target to enthrall them."))
		start_recharge()
		revert_cast()
		return

	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, span_warning("Only the living can be enthralled."))
		start_recharge()
		revert_cast()
		return

	if(user == M)
		to_chat(user, span_warning("You cannot enthrall yourself."))
		start_recharge()
		revert_cast()
		return

	// If there's already a victim enthralled by this user, free them first
	if(current_victim && current_victim != M && current_victim.has_status_effect(STATUS_EFFECT_INLOVE))
		current_victim.remove_status_effect(STATUS_EFFECT_INLOVE)
		to_chat(current_victim, "<style>@keyframes flash { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } } @keyframes shimmer { 0% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } 50% { text-shadow: 0 0 5px #ff0000, 0 0 10px #ff3333, 0 0 15px #ffffff; color:#ff0000; } 100% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } }</style>")
		to_chat(current_victim, "<span style='font-size:28px; font-weight:bold; animation: shimmer 2s infinite, flash 1.5s infinite;'>Your mind is clear -- the spell is broken, and you are no longer bound to the whims of your controller</span>")
		to_chat(user, span_notice("[current_victim] stops for a moment, a foul magic lifted from their mind."))
		playsound(current_victim, 'sound/magic/eora_bless.ogg', 50, TRUE)
		current_victim = null

	if(M.has_status_effect(STATUS_EFFECT_INLOVE))
		// Remove the effect and notify with flashy large font message and glow effect
		M.remove_status_effect(STATUS_EFFECT_INLOVE)
		to_chat(M, "<style>@keyframes flash { 0%, 100% { opacity: 1; } 50% { opacity: 0.3; } } @keyframes shimmer { 0% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } 50% { text-shadow: 0 0 5px #ff0000, 0 0 10px #ff3333, 0 0 15px #ffffff; color:#ff0000; } 100% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } }</style>")
		to_chat(M, "<span style='font-size:28px; font-weight:bold; animation: shimmer 2s infinite, flash 1.5s infinite;'>Your mind is clear -- the spell is broken, and you are no longer bound to the whims of your controller</span>")
		to_chat(user, span_notice("[M] stops for a moment, a foul magic lifted from their mind."))
		playsound(M, 'sound/magic/eora_bless.ogg', 50, TRUE)
		start_recharge()
		revert_cast()
		return

	// Begin channeling
	user.visible_message(span_danger("[user]'s eyes gleam with a vile magic, no doubt a hypnotic charm -- how sinister!"))
	if(do_after(user, enthrall_delay, target = user, progress = TRUE))
		// Success
		M.visible_message(span_danger("[user]'s waves their hand, a hypnotic charm falling upon [M]..."),
			"<span style='font-size:23px; font-weight:bold; color:#9933cc; animation: shimmer 2s infinite;'>My mind is unwinding  -- Oh Gods, what magick is this? What is happening? I can't -- think -- I can't...</span>")

		to_chat(user, span_notice("You complete the spell, laying an enchantment upon [M]"))

		// Shimmering purple & red hypnotic message with reduced glow intensity
		to_chat(M, "<style>@keyframes shimmer { 0% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } 50% { text-shadow: 0 0 5px #ff0000, 0 0 10px #ff3333, 0 0 15px #ffffff; color:#ff0000; } 100% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } }</style>")
		to_chat(M, "<span style='font-size:23px; font-weight:bold; animation: shimmer 2s infinite;'>... Oh, I remember now. I must obey [user]. It is my compulsion; to follow their every command...</span>")

		to_chat(M, "<style>@keyframes shimmer { 0% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } 50% { text-shadow: 0 0 5px #ff0000, 0 0 10px #ff3333, 0 0 15px #ffffff; color:#ff0000; } 100% { text-shadow: 0 0 1.5px #9933cc, 0 0 5px #9933cc, 0 0 10px #ff0000; color:#9933cc; } }</style>")
		to_chat(M, "<span style='font-size:23px; font-weight:bold; animation: shimmer 2s infinite;'>...  However, my brain is fogged, clouded -- it is hard to think. Recalling any information or locations outside of my immediate surroundings is impossible...</span>")

		playsound(M, 'sound/magic/eora_bless.ogg', 50, TRUE)

		if(M.mind)
			M.mind.store_memory("I am entralled by means of a magic charm, and I must obey the commands of [user]. I am bound to their will utterly and totally -- a fogged veil upon my mind. The nature of my charm has stunted my memory, and I am incapable of revealing sensitive information (such as the location of hidden bases or treasures.)")
			M.mind.add_special_person(user, "#CCCCFF")

		M.faction |= "[REF(user)]"
		M.apply_status_effect(STATUS_EFFECT_INLOVE, user)

		current_victim = M  // Track the new victim

	else
		to_chat(user, span_warning("Your concentration was broken!"))

	start_recharge()
