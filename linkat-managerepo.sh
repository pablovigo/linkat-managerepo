#!/bin/bash

source linkat-managerepo.conf

function createrepo {

  cd "$FOLDER"/"$LINKATDIST"/"$REPO"/

  #-- build Packages file
  apt-ftparchive packages . > Packages
  bzip2 -kf Packages

  #-- signed Release file
  apt-ftparchive release . > Release
  gpg --yes -abs -o Release.gpg Release

  cd $FOLDER
}

function syncrepo {
  echo "----------Inici del rsync--------------"
  echo "Inici Sync "$ORIGEN" a "$TARGET" de "$LINKATDIST""
  echo "Visualitza "$DAY_LOG" per veure els logs"
  date
  rsync -avh --delete "$ORIGEN" "$TARGET" > "$DAY_LOG"
  cat "$DAY_LOG" >> "$LOG"

  echo "======================================="
  echo "SyncRepo "$ORIGEN" -> "$TARGET" finalitzat"
  date >> $LOG
  echo -en "------------Fi del rsync---------------\n\n"
  echo -en "Visualitza els logs a "$LOG"\n\n"
}

#function sendrepo {
#
#  echo -en "******* START *******\n" >> "$LOG"
#  date >> "$LOG"
#  rsync -avh --delete "$TARGET"/ "$DESTIPRO"/ >> "$LOG"
#  echo -en "*******  END  *******\n" >> "$LOG"
#  echo -en "Visualitza els logs a "$LOG"\n\n"
#}


if [ "$ACTIONREPO" == create ]; then
	##
	## Protecció per generar sempre test primer
	if [ "$REPO" == main ] || [ "$REPO" == extres ]; then
		echo -en "Acció prohibida: No es permet generar els repos de producció directament.\n"
		exit 1
	fi
	##
	##
	createrepo
fi

if [ "$ACTIONREPO" == sync ]; then
	case "$REPO" in

	main)	ORIGEN="$FOLDER"/"$LINKATDIST"/test/
	;;

	extres)	ORIGEN="$FOLDER"/"$LINKATDIST"/test-extres/
	;;

	test) ORIGEN="$FOLDER"/"$LINKATDIST"/dev/
	;;

	test-extres) ORIGEN="$FOLDER"/"$LINKATDIST"/dev-extres/
	;;

	*)	echo -en "Error de sistaxis: El repo "$REPO" no es pot sincronitzar.\n"
		exit 1
	;;

	esac
	syncrepo
fi
