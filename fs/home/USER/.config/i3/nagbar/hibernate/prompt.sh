pkill i3-nagbar; i3-nagbar -t warning -m "Are you sure you want to initiate hibernation? This process can take several minutes." \
	-b "Yes, hibernate" "~/.scripts/nagbar/hibernate/hibernate.sh"
