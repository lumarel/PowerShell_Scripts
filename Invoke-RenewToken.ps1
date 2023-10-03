#requires -version 6.0

<#
.SYNOPSIS
    Prepare tokens for Invoke-TwitchDownload.ps1

.PARAMETER AutopickFromTwitchCLI
    This parameter and path assumes that you already have run the twitch-cli and generated the user access token and refresh token.
    
.PARAMETER ClientID
    Passed to authorization endpoints to identify your application. You cannot change your application's client id.
    Please create a application on the Twitch dev page and fill it in here.

.PARAMETER Secret
    Application secret to your client id.
    This is needed to generate the app access tokens and user access tokens, the flow works as described in the docs:
    https://dev.twitch.tv/docs/authentication

.PARAMETER AutocreateUAT
    Let this script automatically create the user access token and refresh token with twitch-cli.
    This assumes you have the clientid and secret on the hand.

.PARAMETER UserAccessToken
    If you just want to get all variables in the correct place you can also insert them manually, this is for the user access token.

.PARAMETER RefreshToken
    If you just want to get all variables in the correct place you can also insert them manually, this is for the refreshs token.

.PARAMETER TwitchCLIexe
    Specifies the path to the twitch-cli executable.
    By default it is configured to find the executable in the user/system PATH variable.
    You can get the executable from here: https://github.com/twitchdev/twitch-cli/releases

.EXAMPLE
    .\Invoke-RenewToken.ps1 -AutopickFromTwitchCLI

.EXAMPLE
    .\Invoke-RenewToken.ps1 -ClientID 'uo6dggojyb8d6soh92zknwmi5ej1q2' -Secret 'au6dggojyb8d6soahh2zknwmi5ej111'
    
    This will just generate the OAuthToken and save them.

.EXAMPLE
    .\Invoke-RenewToken.ps1 -ClientID 'uo6dggojyb8d6soh92zknwmi5ej1q2' -Secret 'au6dggojyb8d6soahh2zknwmi5ej111' -AutocreateUAT

.EXAMPLE
    .\Invoke-RenewToken.ps1 -ClientID 'uo6dggojyb8d6soh92zknwmi5ej1q2' -Secret 'au6dggojyb8d6soahh2zknwmi5ej111' -AutocreateUAT -TwitchCLIexe 'C:\Program Files\twitch-cli\twitch.exe'
#>

param(
    [Parameter(Mandatory,ParameterSetName='twitch_cli')]
    [bool]$AutopickFromTwitchCLI,
    [Parameter(Mandatory,ParameterSetName='auto')]
    [Parameter(Mandatory,ParameterSetName='manual')]
    [string]$ClientID,
    [Parameter(Mandatory,ParameterSetName='auto')]
    [Parameter(Mandatory,ParameterSetName='manual')]
    [string]$Secret,
    [Parameter(Mandatory,ParameterSetName='auto')]
    [bool]$AutocreateUAT,
    [Parameter(ParameterSetName='manual')]
    [string]$UserAccessToken,
    [Parameter(ParameterSetName='manual')]
    [string]$RefreshToken,
    [string]$TwitchCLIexe = 'twitch'
)

Write-Verbose -Message "Making sure the twitch-cli config is picked for the correct platform, current platform: $($PSVersionTable.Platform)"
if ($PSVersionTable.Platform -eq 'Win32NT') {
    $TwitchCLIConfigPath = $env:APPDATA + '\twitch-cli\.twitch-cli.env'
} elseif ($PSVersionTable.Platform -eq 'Unix') {
    $TwitchCLIConfigPath = '~/.config/twitch-cli/.twitch-cli.env'
} else {
    Write-Error -Message 'Platform not supported'
    break
}

if ($AutopickFromTwitchCLI) {
    Write-Verbose -Message 'Gather tokens from twitch-cli config'
    if (Test-Path -Path $TwitchCLIConfigPath) {
        $TwitchCLIConfig = Get-Content -Path $TwitchCLIConfigPath | ConvertFrom-StringData
        $ClientID = $TwitchCLIConfig.GetEnumerator().CLIENTID
        $Secret = $TwitchCLIConfig.GetEnumerator().CLIENTSECRET
        $UserAccessToken = ''
        if ($TwitchCLIConfig.GetEnumerator().ACCESSTOKEN) {
            $UserAccessToken = $TwitchCLIConfig.GetEnumerator().ACCESSTOKEN
        }
        $RefreshToken = ''
        if ($TwitchCLIConfig.GetEnumerator().REFRESHTOKEN) {
            $RefreshToken = $TwitchCLIConfig.GetEnumerator().REFRESHTOKEN
        }
    } else {
        Write-Error -Message 'twitch-cli config does not exist, did you already run the token creation?'
        break
    }
}

Write-Verbose -Message 'Get OAuth token'
$Uri = 'https://id.twitch.tv/oauth2/token?client_id=' + $ClientID + '&client_secret=' + $Secret + '&grant_type=client_credentials'
$OAuthToken = ((Invoke-WebRequest -Uri $Uri -Method POST).Content | ConvertFrom-Json).access_token
$strOutput = @"
`$ClientID = `'$clientid`'
`$OAuthToken = `'$OAuthToken`'
`$UserAccessToken = `'$UserAccessToken`'
`$RefreshToken = `'$RefreshToken`'
"@
$strOutput | Out-File $PSScriptRoot\.tokens.ps1
