client
	script="<style>\
	body { \
		font-family: 'Open Sans', 'fantasy'; \
	} \
	IMG.icon {width: 64px; height: 64px; float: left;};\
	\
	.gray{color: darkgray;}\
	}</style>"
	var/run_intent = 2
	var/speeding = 0

	proc/switch_rintent()
		if(run_intent == 4)
			run_intent = 2
			return
		if(run_intent == 2)
			run_intent = 4
			return

	Move()
		if(speeding <= 0)
			speeding = 1
			..()
			sleep(run_intent)
			speeding = 0
		else
			return

	New()
		if(src.ckey in admins)
			src.verbs += admin_verbs
		return ..()

	Topic(href,list/href_list,hsrc)
		if(hsrc == src)
			if(href_list["admin"])
				if(usr.client != src)
					return
				var/mob/target
				if(href_list["target"])
					target = locate(href_list["target"])
				switch(href_list["admin"])
					if("pm")
						if(!(src.ckey in admins) && !(target.ckey in admins))
							return
						src.pm(target, input("Enter message:", "Private Message") as text)
					if("kick")
						if(!(src.ckey in admins))
							return
						src.kick(target)
					if("ban")
						if(!(src.ckey in admins))
							return
						src.ban(target)
		else ..()