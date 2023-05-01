param(
  [String]$clientid,
  [String]$secret
)
$Uri = 'https://id.twitch.tv/oauth2/token?client_id=' + $clientid + '&client_secret=' + $secret + '&grant_type=client_credentials'
$Output = Invoke-WebRequest -Uri $Uri -Method POST
$Output.Content
$strOutput = "`$ClientID = `'" + $clientid + "`'`n`$OAuthToken = `'" + ($Output.Content | ConvertFrom-Json).access_token + "`'"
$strOutput | Out-File $PSScriptRoot\.tokens.ps1
