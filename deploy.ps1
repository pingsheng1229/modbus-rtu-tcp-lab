# Modbus RTU/TCP Lab deploy script
param(
    [ValidateSet("netlify", "github")]
    [string]$Method = "github"
)

$SiteDir = $PSScriptRoot
$ZipPath = Join-Path (Split-Path $SiteDir) "modbus-rtu-tcp-lab-deploy.zip"

function New-DeployZip {
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    $tempDir = Join-Path $env:TEMP "modbus-rtu-tcp-lab-deploy"
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Copy-Item "$SiteDir\index.html", "$SiteDir\styles.css", "$SiteDir\script.js", "$SiteDir\.nojekyll" $tempDir
    Copy-Item "$SiteDir\assets" "$tempDir\assets" -Recurse
    Compress-Archive -Path "$tempDir\*" -DestinationPath $ZipPath -Force
    Remove-Item $tempDir -Recurse -Force
    return $ZipPath
}

Write-Host ""
Write-Host "=== Modbus RTU/TCP Lab Deploy ===" -ForegroundColor Cyan
Write-Host ""

$zip = New-DeployZip
Write-Host "[OK] ZIP created: $zip" -ForegroundColor Green

if ($Method -eq "netlify") {
    Write-Host ""
    Write-Host "Netlify Drop steps:" -ForegroundColor Yellow
    Write-Host "1. Login at https://app.netlify.com"
    Write-Host "2. Drag the ZIP file to the Drop zone"
    Write-Host "3. You will get a URL like https://xxxxx.netlify.app"
    Write-Host ""
    Start-Process "https://app.netlify.com/drop"
    Start-Process explorer.exe -ArgumentList "/select,`"$zip`""
    exit 0
}

Set-Location $SiteDir

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Install GitHub CLI: winget install GitHub.cli" -ForegroundColor Red
    exit 1
}

gh auth status 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[LOGIN] Opening browser for GitHub login..." -ForegroundColor Yellow
    gh auth login --web --git-protocol https
}

if (-not (Test-Path ".git")) {
    git init
    git config user.email "deploy@local"
    git config user.name "Modbus Lab Deploy"
}

git add index.html styles.css script.js .nojekyll assets deploy.ps1 deploy.bat README.md
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
    git commit -m "Update Modbus RTU TCP learning site"
}
git branch -M main

$repoName = "modbus-rtu-tcp-lab"
Write-Host ""
Write-Host "[WORKING] Creating GitHub repository..." -ForegroundColor Yellow

gh repo view $repoName 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    $remoteUrl = gh repo view $repoName --json url -q .url
    Write-Host "Repository exists: $remoteUrl"
    $hasOrigin = git remote get-url origin 2>$null
    if (-not $hasOrigin) {
        $owner = gh api user -q .login
        git remote add origin "https://github.com/$owner/$repoName.git"
    }
    git push -u origin main
} else {
    gh repo create $repoName --public --source=. --remote=origin --push
}

$owner = gh api user -q .login
Write-Host ""
Write-Host "[WORKING] Enabling GitHub Pages..." -ForegroundColor Yellow
gh api -X POST "/repos/$owner/$repoName/pages" -f build_type=legacy -f "source[branch]=main" -f "source[path]=/" 2>$null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Enable Pages manually: Settings > Pages > main / root" -ForegroundColor Yellow
}

$pagesUrl = "https://$owner.github.io/$repoName/"
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " Site URL (live in 1-2 minutes):" -ForegroundColor Green
Write-Host " $pagesUrl" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Start-Process $pagesUrl
