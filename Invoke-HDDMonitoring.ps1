<#
.SYNOPSIS
    Script to monitor physical hard drive status and report it to a URI

.PARAMETER GoodURI
    Send the good status to there

.PARAMETER BadURI
    Send the bad status to there

.EXAMPLE
    .\Invoke-HDDMonitoring.ps1

.EXAMPLE
    .\Invoke-HDDMonitoring.ps1 -GoodURI 'https://path.to.uri/api?status=good' -BadURI 'https://path.to.uri/api?status=bad'
#>

param(
    [string]$GoodURI = 'https://path.to.uri/api?status=good',
    [string]$BadURI = 'https://path.to.uri/api?status=bad'
)

if (Get-PhysicalDisk | Where-Object HealthStatus -eq 'Healthy') {
    Invoke-WebRequest -Uri $GoodURI
} else {
    Invoke-WebRequest -Uri $BadURI
}