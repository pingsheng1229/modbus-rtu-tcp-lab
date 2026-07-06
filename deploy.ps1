# CL-213-WF 學習網頁上架腳本
# 用法：在 PowerShell 中執行 .\deploy.ps1

$SiteDir = $PSScriptRoot
$ZipPath = Join-Path (Split-Path $SiteDir) "cl213-web-deploy.zip"

Write-Host "=== CL-213-WF 學習網頁部署 ===" -ForegroundColor Cyan
Write-Host ""

# 建立部署用 ZIP
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
$tempDir = Join-Path $env:TEMP "cl213-deploy"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null
Copy-Item "$SiteDir\index.html" $tempDir
Copy-Item "$SiteDir\styles.css" $tempDir
Copy-Item "$SiteDir\script.js" $tempDir
Copy-Item "$SiteDir\.nojekyll" $tempDir
Copy-Item "$SiteDir\assets" "$tempDir\assets" -Recurse
Compress-Archive -Path "$tempDir\*" -DestinationPath $ZipPath -Force
Remove-Item $tempDir -Recurse -Force
Write-Host "[完成] 部署 ZIP：$ZipPath" -ForegroundColor Green
Write-Host ""

Write-Host "請選擇上架方式：" -ForegroundColor Yellow
Write-Host ""
Write-Host "【方式 A】Netlify Drop（最快，約 30 秒）"
Write-Host "  1. 瀏覽器開啟 https://app.netlify.com/drop"
Write-Host "  2. 將 ZIP 檔拖曳到頁面中"
Write-Host "  3. 立即取得網址，例如 https://xxxxx.netlify.app"
Write-Host ""
Write-Host "【方式 B】GitHub Pages（永久免費）"
Write-Host "  1. 到 https://github.com/new 建立新 repository（名稱如 cl213-web）"
Write-Host "  2. 在本資料夾執行以下指令："
Write-Host "     git init"
Write-Host "     git add ."
Write-Host "     git commit -m `"Add CL-213-WF learning site`""
Write-Host "     git branch -M main"
Write-Host "     git remote add origin https://github.com/你的帳號/cl213-web.git"
Write-Host "     git push -u origin main"
Write-Host "  3. GitHub repo → Settings → Pages → Source 選 Deploy from branch → main / root"
Write-Host "  4. 網址：https://你的帳號.github.io/cl213-web/"
Write-Host ""

$open = Read-Host "是否現在開啟 Netlify Drop 頁面？(Y/N)"
if ($open -eq 'Y' -or $open -eq 'y') {
    Start-Process "https://app.netlify.com/drop"
    Start-Process "explorer.exe" -ArgumentList "/select,`"$ZipPath`""
}