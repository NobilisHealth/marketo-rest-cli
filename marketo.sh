#!/bin/sh
#
# A simple script to automate inspection Marketo data via their REST API.
# Requirements:
#   * jq - https://stedolan.github.io/jq/
#   * cURL - https://curl.haxx.se/
#

# Whether or not to have cURL output.
VerboseSwitch="--silent"
#VerboseSwitch="-vvv"

AccessToken=""
Output=""

usage() {
	echo 
	echo "Usage: marketo <command> <munchkinId> <clientId> <clientSecret> <arg>"
	echo 
	echo "  Commands:"
	echo "    * get-by-id - <arg> would be a Marketo ID"
	echo "    * get-by-email - <arg> would be an email address of a Marketo lead"
	echo "    * add - <arg> would be a file name of a file with the JSON to be used in the request body.  The format of the JSON is described here: http://developers.marketo.com/documentation/rest/createupdate-leads/"
	echo 
	echo "If <arg> is a dash ("-") then the JSON string is read from STDIN"
	echo
}

if [ $# -lt 5 ]; then
	echo "Error: Too few arguments."
	usage
	exit 1
fi

MunchkinId="$2"
ClientId="$3"
ClientSecret="$4"
Arg="$5"
if [ "$Arg" = "-" ]; then
	Arg=""
	while read line
	do
		Arg="$Arg$line"
	done < /dev/stdin
fi


accessToken() {
	AccessToken=`curl --insecure $VerboseSwitch "https://$MunchkinId.mktorest.com/identity/oauth/token?grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret" | jq '. | .access_token' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')`
	AccessToken="${AccessToken%\"}"
	AccessToken="${AccessToken#\"}"
}

getById() {
	accessToken 

	Output=`curl --insecure $VerboseSwitch "https://$MunchkinId.mktorest.com/rest/v1/lead/$Arg.json?access_token=$AccessToken"`
}

getByEmail() {
	accessToken
	Output=`curl --insecure $VerboseSwitch "https://$MunchkinId.mktorest.com/rest/v1/leads.json?access_token=$AccessToken&filterType=email&filterValues=$Arg"`
}


add() {
	accessToken
	Output=`curl --insecure $VerboseSwitch -X POST --data "@$Arg" "https://$MunchkinId.mktorest.com/rest/v1/leads.json?access_token=$AccessToken" -H "Content-Type: application/json"`
}


case "$1" in 
	"get-by-id")
		getById
		echo $Output
		;;
	"get-by-email")
		getByEmail
		echo $Output
		;;
	"add")
		add
		echo $Output
		;;
	*)
		echo "Error: Invalid command."
		usage
		exit 1
esac

