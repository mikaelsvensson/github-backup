# Credits to 


# Download your GitHub repositories

This little Powershell does this:

* Clones the personal repositories you have access to into `LocalSourceDir` (URIs to repo list APIs defined in `BaseApiUris`)
* Compresses the repos into .zip files and puts them into `LocalArchiveTargetDir`

## Usage

Create `config.json` by copying `config.sample.json` and replacing the values.

Run with Powershell:

    > powershell.exe .\backup-repos.ps1

## Credits

The script is based on https://github.com/countzero/backup_github_repositories/blob/master/backup_github_repositories.ps1