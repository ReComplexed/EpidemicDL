#!/usr/bin/env zsh
zparseopts -D -E -F - -help=help h=help -no-stems=NoStems N=NoStems -full-search=FullSearch F=FullSearch T=top -top-result=top -no-metadata=NoMetadata M=NoMetadata -no-picture=NoPicture P=NoPicture -artist=Artist A=Artist -search=Search S=Search -skip-confirm=SkipConfirm C=SkipConfirm -remove-metadata=RemoveMetadata R=RemoveMetadata K=KeepPicture -keep-picture=KeepPicture

if [[ $help == "--help" ]] || [[ $help == "-h" ]] || [[ $1 == "" ]]
then
	echo "-----------------------------------------------------"
	echo "                      URL Mode"
	echo "-----------------------------------------------------"
	echo " Usage: ./EpidemicDownload.sh [Options] <URL>"
	echo ""
	echo "-----------------------------------------------------"
	echo "                    Manual Mode"
	echo "-----------------------------------------------------"
	echo " Usage: ./EpidemicDownload.sh [Options] <Search Option> <Search Term>"
	echo ""
	echo " --search / -S                  Search for the Music Name"
	echo " --artist / -A                  Enter an Artist Name"
	echo ""
	echo "-----------------------------------------------------"
	echo "                  Download Options"
	echo "-----------------------------------------------------"
	echo " --help / -h                    Prints out this help"
	echo " --full-search / -F             Dowloads all Search Results"
	echo " --no-stems / -N                Skip Stem Downloads"
	echo " --no-metadata / -M             Do not write additional Metadata"
	echo " --remove-metadata / -R         Remove Metadata already added by Epidemic"
	echo " --top-result / -T              Download only Top Result"
	echo " --skip-confirm / -C            Skip Asking the User if Search Result is correct"
	echo " --no-picture / -P              Skip Downloading and Adding the Picture"
	echo " --keep-picture / -K            Do not Delete Picture after adding it to the Audio Metadata"
	exit
fi

if [[ $Artist == "--artist" ]] || [[ $Artist == "-A" ]] || [[ $Search == "--search" ]] || [[ $Search == "-S" ]]
then
	if [[ $Search == "--search" ]] || [[ $Search == "-S" ]]
	then
		1=${1// /%20}
		1=https://www.epidemicsound.com/music/search/?term=$1
	elif [[ $Artist == "--artist" ]] || [[ $Artist == "-A" ]]
	then
		1=${1// /-}
		1=https://www.epidemicsound.com/artists/$1/
	fi
fi

if ! command -v eyeD3 &> /dev/null
then
	eyeD3=false
    echo "eyeD3 could not be found. Skipping Metadata Changes."
else
	eyeD3=true
fi

if ! command -v wget &> /dev/null
then
    echo "wget could not be found."
    exit
fi
if ! command -v jq &> /dev/null
then
    echo "jq could not be found."
    exit
fi
if ! command -v curl &> /dev/null
then
    echo "curl could not be found."
    exit
fi


if [[ "$1" == "https://www.epidemicsound.com/artists/"* ]]
then
	JSONURL=${1/artists/"json/releases"}
	declare -l JSONURL
	if [[ $(curl -s $JSONURL) == "" ]]
	then
		echo "URL Not Found, Exiiting..."
		exit
	fi
	ENTITIES=$(curl -s $JSONURL | jq -M -r '.entities.tracks')
elif [[ "$1" == "https://www.epidemicsound.com/music/search/"* ]]
then
	TERM=${1##*term=}
	SEARCH=true
	JSONURL=${1/music\/search/"json/search/tracks"}
	if [[ $(curl -s $JSONURL) == "" ]]
	then
		echo "URL Not Found, Exiiting..."
		exit
	fi
	META=$(curl -s $JSONURL | jq -M -r '.meta.hits')
	ID=${META:21}
	ID=${ID%%,*}
	if [[ $FullSearch == "--full-search" ]] || [[ $FullSearch == "-F" ]]
	then
		ENTITIES=$(curl -s $JSONURL | jq -M -r '.entities.tracks')
	else
		ENTITIES=$(curl -s $JSONURL | jq -M -r '.entities.tracks["'$ID'"]')
	fi
elif [[ "$1" == "https://www.epidemicsound.com/track/"* ]]
then
	JSONURL=${1/track/"json/track"}
	if [[ "${JSONURL: -1}" == "/" ]]
	then
		JSONURL=${JSONURL::-1}
	fi
	if [[ $(curl -s $JSONURL) == "" ]]
	then
		echo "URL Not Found, Exiiting..."
		exit
	fi
	ENTITIES=$(curl -s $JSONURL | jq -M -r '.')
fi
AUDIO=$(echo $ENTITIES | grep 'lqMp3Url\|baseUrl\|title\|"L":')
if [[ $NoMetadata != "--no-metadata" ]] && [[ $NoMetadata != "-M" ]] && [[ $RemoveMetadata != "--remove-metadata" ]] && [[ $RemoveMetadata != "-R" ]]
then
	MAINARTIST=$(echo $ENTITIES | grep -A 1 "main_artist\|title" | grep "name\|title")
fi

while [[ ! -z "$AUDIO" ]]
do
	TITLE=$(echo $AUDIO | head -n +1)
	TITLE=${TITLE%\"*}
	TITLE=${TITLE##*\"}

	MAINARTIST=$(echo $MAINARTIST | tail +2)
	ARTIST=$(echo $MAINARTIST | head -1)
	ARTIST=${ARTIST%\"*}
	ARTIST=${ARTIST##*\"}
	MAINARTIST=${MAINARTIST#*\"title\":}

	if [[ $SEARCH == "true" ]] && [[ $FullSearch != "--full-search" ]] && [[ $FullSearch != "-F" ]] && [[ $SkipConfirm != "-C" ]] && [[ $SkipConfirm != "--skip-confirm" ]]
	then
		read "?Track \"$TITLE\", made by \"$ARTIST\" was the top result. Is this correct? [Y/n] " USERin
		if [[ $USERin == "N" ]] || [[ $USERin == "n" ]]
		then
			exit
		elif [[ $USERin == "Y" ]] || [[ $USERin == "y" ]]
		then
			# Do Nothing
		else
			echo "You have Not entered anything..."
			exit
		fi
	fi
	AUDIO=$(echo $AUDIO | tail +2)

	URL=$(echo $AUDIO | head -n +1)
	URL=${URL%\"*}
	URL=${URL##*\"}
	wget "$URL" -q --show-progress -O "$TITLE.mp3"

	AUDIO=$(echo $AUDIO | tail +2)
	if [[ $NoStems != "--no-stems" ]] && [[ $NoStems != "-N" ]]
	then
		STEMS=$(echo $AUDIO | head -n +4)
		STEMS=${STEMS%baseUrl*}
		BASS=$(echo $STEMS | grep %20STEMS%20BASS.mp3)
		if [[ $BASS == "" ]]
		then
			echo "Bass Stem not found, skipping..."
		else
			BASS=${BASS%\"*}
			BASS=${BASS##*\"}
			wget "$BASS" -q --show-progress -O "$TITLE - Bass.mp3"
			BASS=true
		fi

		DRUMS=$(echo $STEMS | grep %20STEMS%20DRUMS.mp3)
		if [[ $DRUMS == "" ]]
		then
			echo "Drums Stem not found, skipping..."
		else
			DRUMS=${DRUMS%\"*}
			DRUMS=${DRUMS##*\"}
			wget "$DRUMS" -q --show-progress -O "$TITLE - Drums.mp3"
			DRUMS=true
		fi

		INSTRUMENTS=$(echo $STEMS | grep %20STEMS%20INSTRUMENTS.mp3)
		if [[ $INSTRUMENTS == "" ]]
		then
			echo "Instruments Stem not found, skipping..."
		else
			INSTRUMENTS=${INSTRUMENTS%\"*}
			INSTRUMENTS=${INSTRUMENTS##*\"}
			wget "$INSTRUMENTS" -q --show-progress -O "$TITLE - Instruments.mp3"
			INSTRUMENTS=true
		fi

		MELODY=$(echo $STEMS | grep %20STEMS%20MELODY.mp3)
		if [[ $MELODY == "" ]]
		then
			echo "Melody Stem not found, skipping..."
		else
			MELODY=${MELODY%\"*}
			MELODY=${MELODY##*\"}
			wget "$MELODY" -q --show-progress -O "$TITLE - Melody.mp3"
			MELODY=true
		fi
	fi

	AUDIO=${AUDIO#*\"baseUrl\":}

	if [[ $NoMetadata != "--no-metadata" ]] && [[ $NoMetadata != "-M" ]] && [[ $NoPicture != "--no-picture" ]] && [[ $NoPicture != "-P" ]] && [[ $RemoveMetadata != "--remove-metadata" ]] && [[ $RemoveMetadata != "-R" ]]
	then
		COVER=$(echo $AUDIO | head -1)
		COVER=${COVER%\"*}
		COVER=${COVER##*\"}
	fi

	AUDIO=$(echo $AUDIO | tail +2)

	if [[ $NoMetadata != "--no-metadata" ]] && [[ $NoMetadata != "-M" ]] && [[ $NoPicture != "--no-picture" ]] && [[ $NoPicture != "-P" ]] && [[ $RemoveMetadata != "--remove-metadata" ]] && [[ $RemoveMetadata != "-R" ]]
	then
		SIZE=$(echo $AUDIO | head -1)
		SIZE=${SIZE%\"*}
		SIZE=${SIZE##*\"}

		wget "$COVER$SIZE" -q --show-progress -O "$TITLE.jpg"
	fi

	AUDIO=$(echo $AUDIO | tail +2)

	if [[ $RemoveMetadata == "--remove-metadata" ]] || [[ $RemoveMetadata == "-R" ]]
	then
		if [[ $BASS == "true" ]]
		then
			eyeD3 --remove-all "$TITLE - Bass.mp3" &> /dev/null
		fi
		if [[ $DRUMS == "true" ]]
		then
			eyeD3 --remove-all "$TITLE - Drums.mp3" &> /dev/null
		fi
		if [[ $INSTRUMENTS == "true" ]]
		then
			eyeD3 --remove-all "$TITLE - Instruments.mp3" &> /dev/null
		fi
		if [[ $MELODY == "true" ]]
		then
			eyeD3 --remove-all "$TITLE - Melody.mp3" &> /dev/null
		fi
	elif [[ $NoMetadata == "--no-metadata" ]] || [[ $NoMetadata == "-M" ]]
	then
		# Do Nothing
	elif [[ $NoPicture == "--no-picture" ]] || [[ $NoPicture == "-P" ]]
	then
		eyeD3 -t "$TITLE" -a "$ARTIST" "$TITLE.mp3" &> /dev/null
		if [[ $BASS == "true" ]]
		then
		eyeD3 -t "$TITLE" -a "$ARTIST" --add-comment "Bass" "$TITLE - Bass.mp3" &> /dev/null
		fi
		if [[ $DRUMS == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-comment "Drums" "$TITLE - Drums.mp3" &> /dev/null
		fi
		if [[ $INSTRUMENTS == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-comment "Instruments" "$TITLE - Instruments.mp3" &> /dev/null
		fi
		if [[ $MELODY == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-comment "Melody" "$TITLE - Melody.mp3" &> /dev/null
		fi
	else
		eyeD3 -t "$TITLE" -a "$ARTIST" --add-image "$TITLE.jpg":FRONT_COVER "$TITLE.mp3" &> /dev/null
		if [[ $BASS == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-image "$TITLE.jpg":FRONT_COVER --add-comment "Bass" "$TITLE - Bass.mp3" &> /dev/null
		fi
		if [[ $DRUMS == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-image "$TITLE.jpg":FRONT_COVER --add-comment "Drums" "$TITLE - Drums.mp3" &> /dev/null
		fi
		if [[ $INSTRUMENTS == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-image "$TITLE.jpg":FRONT_COVER --add-comment "Instruments" "$TITLE - Instruments.mp3" &> /dev/null
		fi
		if [[ $MELODY == "true" ]]
		then
			eyeD3 -t "$TITLE" -a "$ARTIST" --add-image "$TITLE.jpg":FRONT_COVER --add-comment "Melody" "$TITLE - Melody.mp3" &> /dev/null
		fi
	fi
	if [[ $NoMetadata != "--no-metadata" ]] && [[ $NoMetadata != "-M" ]] && [[ $NoPicture != "--no-picture" ]] && [[ $NoPicture != "-P" ]] && [[ $KeepPicture != "-K" ]] && [[ $KeepPicture != "--keep-picture" ]]
	then
		rm $TITLE.jpg
	fi
	if [[ $top == "--top" ]] || [[ $top == "-T" ]]
	then
	AUDIO=""
	fi
done
