param([string]$Url='http://localhost:8333/index.html',[string]$Name='live',[int]$W=1470,[int]$H=1000,[int]$Wait=6)
$edge='C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
if(-not (Test-Path $edge)){$edge='C:\Program Files\Microsoft\Edge\Application\msedge.exe'}
$scratch='C:\Users\marky\AppData\Local\Temp\claude\C--Users-marky-NOVA\ba8f388d-00f7-41b5-bf30-ffc652080b43\scratchpad'
$profile=Join-Path $scratch 'rg-live'
$outdir='C:\Users\marky\NOVA\rabbit-grill\_qa\shots'
New-Item -ItemType Directory -Force -Path $outdir,$profile | Out-Null
$out=Join-Path $outdir "$Name.png"
if(Test-Path $out){Remove-Item $out -Force}
& $edge --headless=new --disable-gpu --no-first-run --no-default-browser-check `
  --user-data-dir="$profile" --hide-scrollbars --force-device-scale-factor=1 `
  --virtual-time-budget=$($Wait*1000) --window-size="$W,$H" --screenshot="$out" $Url 2>$null | Out-Null
if(Test-Path $out){Write-Output ("{0}  ({1:n0} KB)" -f $out,((Get-Item $out).Length/1KB))}else{Write-Output "FAILED"}
