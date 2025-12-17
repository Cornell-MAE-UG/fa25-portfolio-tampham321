param(
    [string]$Message = "",
    [switch]$Timestamp
)

function Write-Info($s) { Write-Output "[info] $s" }
function Write-Err($s) { Write-Error "[error] $s" }

if (-not $Message) {
    $Message = "Update site content - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
} elseif ($Timestamp) {
    $Message = "$Message - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

Write-Info "Running update-and-push with message: $Message"

$branch = (git rev-parse --abbrev-ref HEAD 2>&1).ToString().Trim()
if ($LASTEXITCODE -ne 0) {
    Write-Err "Failed to determine current branch: $branch"
    exit 1
}
Write-Info "Current branch: $branch"

git add -A

$commitOutput = git commit -m "$Message" 2>&1
if ($LASTEXITCODE -ne 0) {
    # Common non-fatal message: nothing to commit
    if ($commitOutput -match "nothing to commit" -or $commitOutput -match "no changes added to commit") {
        Write-Info "No changes to commit. (Nothing staged or all files unchanged)"
    } else {
        Write-Err $commitOutput
        exit 1
    }
} else {
    Write-Info $commitOutput
}

Write-Info "Pushing to origin/$branch..."
$pushOutput = git push origin $branch 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Err "Push failed: $pushOutput"
    Write-Output "If this is an authentication error, authenticate using the GitHub CLI (gh auth login) or set a Personal Access Token for Git over HTTPS."
    exit 1
}

Write-Info $pushOutput
Write-Info "Push successful."

exit 0
