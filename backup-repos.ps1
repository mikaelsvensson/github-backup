$ConfigObject = Get-Content -Path .\config.json | ConvertFrom-Json

$GithubUsername = $ConfigObject.GithubUsername
$GithubAccessToken = $ConfigObject.GithubToken
$LocalArchiveTargetDir = $ConfigObject.LocalArchiveTargetDir
$LocalSourceDir = $ConfigObject.LocalSourceDir
$BaseApiUris = $ConfigObject.BaseApiUris

$basicAuthenticationCredentials = "${GithubUsername}:${GithubAccessToken}"
$encodedBasicAuthenticationCredentials = [System.Convert]::ToBase64String(
    [System.Text.Encoding]::ASCII.GetBytes($basicAuthenticationCredentials)
)
$requestHeaders = @{
    Authorization = "Basic $encodedBasicAuthenticationCredentials"
}

function ReadRepositories {
    param($uri)
    $repos = @()

    $pageNumber = 0
    Do {

        $pageNumber++
        $paginatedUri = "${uri}&per_page=20&page=${pageNumber}"

        $paginatedRepos = Invoke-WebRequest -Uri $paginatedUri -Headers $requestHeaders | `
            Select-Object -ExpandProperty Content | `
            ConvertFrom-Json
        $repos += $paginatedRepos

    } Until ($paginatedRepos.Count -eq 0)
    return $repos
}

$repositories = @()
foreach ($BaseApiUri in $BaseApiUris) {
    $repositories += ReadRepositories -Uri $BaseApiUri
}

Foreach ($repository in $repositories) {
    $githubPath = $repository.full_name
     
    $localPath = $githubPath.replace("/", ".")
    $repoLocalSourceDir = "$LocalSourceDir\$localPath"
    If (Test-Path -Path $repoLocalSourceDir) {
        git -C $repoLocalSourceDir pull
    }
    else {
        git clone "https://$GithubAccessToken@github.com/$githubPath.git" $repoLocalSourceDir
    }
    $commitId = git -C $repoLocalSourceDir rev-parse --short HEAD
    $repoLocalArchiveTargetDir = "$LocalArchiveTargetDir\$localPath.$commitId.zip"
    If (-Not (Test-Path -Path $repoLocalArchiveTargetDir)) {
        Remove-Item "$LocalArchiveTargetDir\$localPath.*.zip"
        Get-ChildItem -Path $repoLocalSourceDir -Force | Compress-Archive -Force -DestinationPath $repoLocalArchiveTargetDir
    }
}
