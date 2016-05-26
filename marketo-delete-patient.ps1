# Deletes a lead using Marketo's REST API.
#
# Requirements (must be in the path):
#   * jq - https://stedolan.github.io/jq/
#   * cURL - https://curl.haxx.se/
#
# Usage: marketo-delete-patient.ps1 <munchkinId> <clientId> <clientSecret> <the lead's Marketo ID>
#

$munchkinId = $args[0];
$clientId = $args[1];
$clientSecret = $args[2];
$leadMarketoId = $args[3];


$at = (curl -k -vvv "https://$munchkinId.mktorest.com/identity/oauth/token?grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret" | jq '. | .access_token'); 
$c = 'curl -k -vvv -H "Content-Type: application/json" -X DELETE "https://$munchkinId.mktorest.com/rest/v1/leads.json?id=$leadMarketoId&access_token=' + $at.Trim().Trim('"') + '"';
Invoke-Expression $c

