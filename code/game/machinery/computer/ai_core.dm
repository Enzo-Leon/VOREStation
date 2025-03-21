/obj/structure/AIcore
	density = TRUE
	anchored = FALSE
	unacidable = TRUE
	name = "\improper AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/nanotrasen
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob)

	switch(state)
		if(0)
			if(P.has_tool_quality(TOOL_WRENCH))
				playsound(src, P.usesound, 50, 1)
				if(do_after(user, 20 * P.toolspeed))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = TRUE
					state = 1
			if(P.has_tool_quality(TOOL_WELDER))
				var/obj/item/weapon/weldingtool/WT = P.get_welder()
				if(!WT.isOn())
					to_chat(user, "The welder must be on for this task.")
					return
				playsound(src, WT.usesound, 50, 1)
				if(do_after(user, 20 * WT.toolspeed))
					if(!src || !WT.remove_fuel(0, user)) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					new /obj/item/stack/material/plasteel( loc, 4)
					qdel(src)
		if(1)
			if(P.has_tool_quality(TOOL_WRENCH))
				playsound(src, P.usesound, 50, 1)
				if(do_after(user, 20 * P.toolspeed))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = FALSE
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(P.has_tool_quality(TOOL_SCREWDRIVER) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(P.has_tool_quality(TOOL_CROWBAR) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(P.has_tool_quality(TOOL_SCREWDRIVER) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if (C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five coils of wire to add them to the frame.</span>")
					return
				to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20) && state == 2)
					if (C.use(5))
						state = 3
						icon_state = "3"
						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
				return
		if(3)
			if(P.has_tool_quality(TOOL_WIRECUTTER))
				if (brain)
					to_chat(user, "Get that brain out of there first")
				else
					playsound(src, P.usesound, 50, 1)
					to_chat(user, "<span class='notice'>You remove the cables.</span>")
					state = 2
					icon_state = "2"
					new /obj/item/stack/cable_coil(loc, 5)

			if(istype(P, /obj/item/stack/material) && P.get_material_name() == "rglass")
				var/obj/item/stack/RG = P
				if (RG.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of glass to put in the glass panel.</span>")
					return
				to_chat(user, "<span class='notice'>You start to put in the glass panel.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, 20) && state == 3)
					if(RG.use(2))
						to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
						state = 4
						icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/asimov))
				laws.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				laws.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/weapon/aiModule/nanotrasen))
				laws.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
				laws.add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/weapon/aiModule/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/weapon/aiModule/freeform))
				var/obj/item/weapon/aiModule/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				to_chat(usr, "Added a freeform law.")

			if(istype(P, /obj/item/device/mmi))
				var/obj/item/device/mmi/M = P
				if(!M.brainmob)
					to_chat(user, "<span class='warning'>Sticking an empty [P] into the frame would sort of defeat the purpose.</span>")
					return
				if(M.brainmob.stat == 2)
					to_chat(user, "<span class='warning'>Sticking a dead [P] into the frame would sort of defeat the purpose.</span>")
					return

				if(jobban_isbanned(M.brainmob, "AI"))
					to_chat(user, "<span class='warning'>This [P] does not seem to fit.</span>")
					return

				if(M.brainmob.mind)
					clear_antag_roles(M.brainmob.mind, 1)

				user.drop_item()
				P.loc = src
				brain = P
				to_chat(usr, "Added [P].")
				icon_state = "3b"

			if(P.has_tool_quality(TOOL_CROWBAR) && brain)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the brain.</span>")
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(P.has_tool_quality(TOOL_CROWBAR))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/material/glass/reinforced( loc, 2 )
				return

			if(P.has_tool_quality(TOOL_SCREWDRIVER))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				if(!brain)
					var/open_for_latejoin = tgui_alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", list("Yes", "No")) == "Yes"
					var/obj/structure/AIcore/deactivated/D = new(loc)
					if(open_for_latejoin)
						empty_playable_ai_cores += D
				else
					var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
					if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
						A.rename_self("ai", 1)
						for(var/datum/language/L in brain.brainmob.languages)
							A.add_language(L.name)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

GLOBAL_LIST_BOILERPLATE(all_deactivated_AI_cores, /obj/structure/AIcore/deactivated)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = TRUE
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/Destroy()
	if(src in empty_playable_ai_cores)
		empty_playable_ai_cores -= src
	return ..()

/obj/structure/AIcore/deactivated/proc/load_ai(var/mob/living/silicon/ai/transfer, var/obj/item/device/aicard/card, var/mob/user)

	if(!istype(transfer) || locate(/mob/living/silicon/ai) in src)
		return

	if(transfer.deployed_shell)
		transfer.disconnect_shell("Disconnected from remote shell due to core intelligence transfer.")
	transfer.aiRestorePowerRoutine = 0
	transfer.control_disabled = 0
	transfer.aiRadio.disabledAi = 0
	transfer.loc = get_turf(src)
	transfer.create_eyeobj()
	transfer.cancel_camera()
	to_chat(user, "<span class='notice'>Transfer successful:</span> [transfer.name] placed within stationary core.")
	to_chat(transfer, "You have been transferred into a stationary core. Remote device connection restored.")

	if(card)
		card.clear()

	qdel(src)

/obj/structure/AIcore/deactivated/proc/check_malf(var/mob/living/silicon/ai/ai)
	if(!ai) return
	for (var/datum/mind/malfai in malf.current_antagonists)
		if (ai.mind == malfai)
			return 1

/obj/structure/AIcore/deactivated/attackby(var/obj/item/weapon/W, var/mob/user)

	if(istype(W, /obj/item/device/aicard))
		var/obj/item/device/aicard/card = W
		var/mob/living/silicon/ai/transfer = locate() in card
		if(transfer)
			load_ai(transfer,card,user)
		else
			to_chat(user, "<span class='danger'>ERROR:</span> Unable to locate artificial intelligence.")
		return
	else if(W.has_tool_quality(TOOL_WRENCH))
		if(anchored)
			user.visible_message("<b>\The [user]</b> starts to unbolt \the [src] from the plating...")
			playsound(src, W.usesound, 50, 1)
			if(!do_after(user,40 * W.toolspeed))
				user.visible_message("<b>\The [user]</b> decides not to unbolt \the [src].")
				return
			user.visible_message("<b>\The [user]</b> finishes unfastening \the [src]!")
			anchored = FALSE
			return
		else
			user.visible_message("<b>\The [user]</b> starts to bolt \the [src] to the plating...")
			playsound(src, W.usesound, 50, 1)
			if(!do_after(user,40 * W.toolspeed))
				user.visible_message("<b>\The [user]</b> decides not to bolt \the [src].")
				return
			user.visible_message("<b>\The [user]</b> finishes fastening down \the [src]!")
			anchored = TRUE
			return
	else
		return ..()

/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Admin"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in all_deactivated_AI_cores)
		cores["[D] ([D.loc.loc])"] = D

	var/id = tgui_input_list(usr, "Which core?", "Toggle AI Core Latejoin", cores)
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in empty_playable_ai_cores)
		empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")
