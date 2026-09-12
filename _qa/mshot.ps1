param(
  [string]$Page = 'index.html',
  [string]$Target = 'top',
  [string]$Name = '',
  [int]$Off = 0,
  [int]$DeviceW = 390,
  [int]$DeviceH = 844,
  [string]$Lang = '',
  [switch]$Sheet
)
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if (-not (Test-Path $edge)) { $edge = 'C:\Program Files\Microsoft\Edge\Application\msedge.exe' }
$scratch = 'C:\Users\marky\AppData\Local\Temp\claude\C--Users-marky-NOVA\ba8f388d-00f7-41b5-bf30-ffc652080b43\scratchpad'
$profile = Join-Path $scratch 'rg-edge-m'
$outdir  = 'C:\Users\marky\NOVA\rabbit-grill\_qa\shots'
New-Item -ItemType Directory -Force -Path $outdir, $profile | Out-Null
if (-not $Name) { $Name = 'm-' + ($Page -replace '\.html$','') + '-' + $Target }
$out = Join-Path $outdir "$Name.png"
if (Test-Path $out) { Remove-Item $out -Force }

# the iframe wrapper exists because headless Edge silently clamps its own
# window to ~492px wide; a 390px viewport is only reachable inside a frame
$url = "http://localhost:8333/_qa/mobile.html?page=$Page&shot=$Target&off=$Off&w=$DeviceW&h=$DeviceH"
if ($Lang) { $url += "&lang=$Lang" }
if ($Sheet) { $url += "&sheet=1" }
$winW = $DeviceW + 110
$winH = $DeviceH + 60

& $edge --headless=new --disable-gpu --no-first-run --no-default-browser-check `
  --user-data-dir="$profile" --hide-scrollbars --force-device-scale-factor=1 `
  --window-size="$winW,$winH" --screenshot="$out" $url 2>$null | Out-Null

if (Test-Path $out) { Write-Output ("{0}  ({1:n0} KB)" -f $out, ((Get-Item $out).Length/1KB)) }
else { Write-Output "FAILED: $Name" }
