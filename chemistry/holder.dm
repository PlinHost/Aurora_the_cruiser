//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

var/const/TOUCH = 1
var/const/INGEST = 2

///////////////////////////////////////////////////////////////////////////////////

/atom/proc/on_reagent_change()
	return

datum
	reagents
		var/list/datum/reagent/reagent_list = new/list()
		var/total_volume = 0
		var/maximum_volume = 100
		var/mob/my_atom = null

		New(maximum=100)
			maximum_volume = maximum

		proc

			remove_any(var/amount=1)
				var/total_transfered = 0
				var/current_list_element = 1

				current_list_element = rand(1,reagent_list.len)

				while(total_transfered != amount)
					if(total_transfered >= amount) break
					if(total_volume <= 0 || !reagent_list.len) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]

					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()

			//	handle_reactions() this proc only removes reagents from src, no reason to check for reactions since they wont happen
				return total_transfered

			get_master_reagent_name()
				var/the_name = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_name = A.name

				return the_name

			get_master_reagent_id()
				var/the_id = null
				var/the_volume = 0
				for(var/datum/reagent/A in reagent_list)
					if(A.volume > the_volume)
						the_volume = A.volume
						the_id = A.id

				return the_id

			trans_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
				if (!target )
					return
				if (!target.reagents || src.total_volume<=0)
					return
				var/datum/reagents/R = target.reagents
				amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
				var/part = amount / src.total_volume
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					var/current_reagent_transfer = current_reagent.volume * part
					if(preserve_data)
						trans_data = current_reagent.data
					R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, 0)
					src.remove_reagent(current_reagent.id, current_reagent_transfer)

				src.update_total()
				R.update_total()
				R.handle_reactions()
			//	src.handle_reactions() this proc only removes reagents from src, no reason to check for reactions since they wont happen
				return amount

			copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)
				if(!target)
					return
				if(!target.reagents || src.total_volume<=0)
					return
				var/datum/reagents/R = target.reagents
				amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
				var/part = amount / src.total_volume
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					var/current_reagent_transfer = current_reagent.volume * part
					if(preserve_data)
						trans_data = current_reagent.data
					R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)

				src.update_total()
				R.update_total()
				R.handle_reactions()
			//	src.handle_reactions()
				return amount

			trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
				if (!target)
					return
				if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
					return

				var/datum/reagents/R = target.reagents
				if(src.get_reagent_amount(reagent)<amount)
					amount = src.get_reagent_amount(reagent)
				amount = min(amount, R.maximum_volume-R.total_volume)
				var/trans_data = null
				for (var/datum/reagent/current_reagent in src.reagent_list)
					if(current_reagent.id == reagent)
						if(preserve_data)
							trans_data = current_reagent.data
						R.add_reagent(current_reagent.id, amount, trans_data)
						src.remove_reagent(current_reagent.id, amount, 1)
						break

				src.update_total()
				R.update_total()
				R.handle_reactions()
				//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
				return amount

/*
				if (!target) return
				var/total_transfered = 0
				var/current_list_element = 1
				var/datum/reagents/R = target.reagents
				var/trans_data = null
				//if(R.total_volume + amount > R.maximum_volume) return 0

				current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

				while(total_transfered != amount)
					if(total_transfered >= amount) break //Better safe than sorry.
					if(total_volume <= 0 || !reagent_list.len) break
					if(R.total_volume >= R.maximum_volume) break

					if(current_list_element > reagent_list.len) current_list_element = 1
					var/datum/reagent/current_reagent = reagent_list[current_list_element]
					if(preserve_data)
						trans_data = current_reagent.data
					R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
					src.remove_reagent(current_reagent.id, 1)

					current_list_element++
					total_transfered++
					src.update_total()
					R.update_total()
				R.handle_reactions()
				handle_reactions()

				return total_transfered
*/

			metabolize(var/mob/M)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if(R.name != "blood")
						if(M && R)
							R.on_mob_life(M)
				update_total()

			conditional_update_move(var/atom/A, var/Running = 0)
				for(var/datum/reagent/R in reagent_list)
					R.on_move (A, Running)
				update_total()

			conditional_update(var/atom/A, )
				for(var/datum/reagent/R in reagent_list)
					R.on_update (A)
				update_total()

			handle_reactions(var/heated = 0)
				if(my_atom.flags & NOREACT) return //Yup, no reactions here. No siree.

				var/reaction_occured = 0
				do
					reaction_occured = 0
					for(var/A in typesof(/datum/chemical_reaction) - /datum/chemical_reaction)
						var/datum/chemical_reaction/C = new A()
						if(C.requires_heating && !heated)
							continue
						var/total_required_reagents = C.required_reagents.len
						var/total_matching_reagents = 0
						var/total_required_catalysts = C.required_catalysts.len
						var/total_matching_catalysts= 0
						var/matching_container = 0
						var/matching_other = 0
						var/list/multipliers = new/list()

						for(var/B in C.required_reagents)
							if(!has_reagent(B, C.required_reagents[B]))	break
							total_matching_reagents++
							multipliers += round(get_reagent_amount(B) / C.required_reagents[B])

						for(var/B in C.required_catalysts)
							if(!has_reagent(B, C.required_catalysts[B]))	break
							total_matching_catalysts++

						if(!C.required_container)
							matching_container = 1

						else
							if(my_atom.type == C.required_container)
								matching_container = 1

						if(!C.required_other)
							matching_other = 1

						if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
							var/multiplier = min(multipliers)

							var/preserved_data
							for(var/B in C.required_reagents)
								var/result = remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)
								if(result && result != 1)
									preserved_data = result

							var/created_volume = C.result_amount*multiplier
							if(C.result)
								multiplier = max(multiplier, 1) //this shouldnt happen ...
								add_reagent(C.result, C.result_amount*multiplier)
								for(var/secondary in C.secondary_results)
									add_reagent(secondary, C.secondary_results[secondary]*multiplier, preserved_data)

							//my_atom.message_for_mobs(5, "\blue \icon[my_atom] The solution begins to bubble.")

							C.on_reaction(src, created_volume)
							reaction_occured = 1
							break

				while(reaction_occured)
				update_total()
				return 0

			isolate_reagent(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id != reagent)
						del_reagent(R.id)
						update_total()

			del_reagent(var/reagent)
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						reagent_list -= A
						del(A)
						update_total()
						my_atom.on_reagent_change()
						return 0


				return 1

			update_total()
				total_volume = 0
				for(var/datum/reagent/R in reagent_list)
					if(R.volume < 0.1)
						del_reagent(R.id)
					else
						total_volume += R.volume

				return 0

			clear_reagents()
				for(var/datum/reagent/R in reagent_list)
					del_reagent(R.id)
				return 0

			reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=0)

				switch(method)
					if(TOUCH)
						for(var/datum/reagent/R in reagent_list)
							if(ismob(A))
								spawn(0)
									if(!R) return
									else R.reaction_mob(A, TOUCH, R.volume+volume_modifier)
							if(isturf(A))
								spawn(0)
									if(!R) return
									else R.reaction_turf(A, R.volume+volume_modifier)
							if(isobj(A))
								spawn(0)
									if(!R) return
									else R.reaction_obj(A, R.volume+volume_modifier)
					if(INGEST)
						for(var/datum/reagent/R in reagent_list)
							if(ismob(A) && R)
								spawn(0)
									if(!R) return
									else R.reaction_mob(A, INGEST, R.volume+volume_modifier)
							if(isturf(A) && R)
								spawn(0)
									if(!R) return
									else R.reaction_turf(A, R.volume+volume_modifier)
							if(isobj(A) && R)
								spawn(0)
									if(!R) return
									else R.reaction_obj(A, R.volume+volume_modifier)
				return

			add_reagent(var/reagent, var/amount, var/data=null, var/react = 1)
				if(!isnum(amount)) return 1
				update_total()
				if(total_volume + amount > maximum_volume) amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

				for(var/A in reagent_list)
					var/datum/reagent/R = A

					if (R.id == reagent)

						//handle snowflakes
						if(R.id == "blood")
							if(R.data && data)
								if(R.data["donor"] != data["donor"])
									continue

						R.volume += amount
						update_total()
						my_atom.on_reagent_change()

						// mix dem viruses
						if(R.id == "blood" && reagent == "blood")
							if(R.data && data)
								if(R.data && R.data["viruses"] || data && data["viruses"])
									var/list/this = R.data["viruses"]
									var/list/that = data["viruses"]
									this += that // combine the two

									/* -- Turns out this code was buggy and unnecessary ---- Doohl
									for(var/datum/disease/D in this) // makes sure no two viruses are in the reagent at the same time
										for(var/datum/disease/d in this)//Something in here can cause an inf loop and I am tired so someone else will have to fix it.
											if(d != D)
												D.cure(0)
									*/

						if(react)
							handle_reactions()
						return 0

				for(var/A in typesof(/datum/reagent) - /datum/reagent)
					var/datum/reagent/R = new A()
					if (R.id == reagent)
						reagent_list += R
						R.holder = src
						R.volume = amount
						R.data = data
						//debug
						//world << "Adding data"
						//for(var/D in R.data)
						//	world << "Container data: [D] = [R.data[D]]"
						//debug
						update_total()
						my_atom.on_reagent_change()
						if(react)
							handle_reactions()
						return 0

				if(react)
					handle_reactions()

				return 1


			remove_reagent(var/reagent, var/amount, var/safety)//Added a safety check for the trans_id_to

				if(!isnum(amount)) return 0

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						R.volume -= amount
						var/preserved_data = R.data
						update_total()
					//	if(!safety)//So it does not handle reactions when it need not to
					//		handle_reactions() this proc only removes reagents from src, no reason to check for reactions since they wont happen
						my_atom.on_reagent_change()
						return preserved_data ? preserved_data : 1

				return 0

			has_reagent(var/reagent, var/amount = -1)

				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						if(!amount) return R
						else
							if(R.volume >= amount) return R
							else return 0

				return 0

			get_reagent_amount(var/reagent)
				var/total = 0
				for(var/A in reagent_list)
					var/datum/reagent/R = A
					if (R.id == reagent)
						total += R.volume
				return total

			get_reagents()
				var/res = ""
				for(var/datum/reagent/A in reagent_list)
					if (res != "") res += ","
					res += A.name

				return res


///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src
