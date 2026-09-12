# =============================================================
#  Apply the full Thai copy audit.
#
#  Reads _qa/thai-final.json — [{oldTh, newTh, changed}] — and
#  replaces each string everywhere it lives. That is deliberately
#  MORE than the HTML: several Thai strings originate in
#  data/menu.json and _qa/build.ps1, and patching only the markup
#  would let the next menu rebuild quietly revert them.
#
#  Every key that fails to match is reported. A silent miss is the
#  failure mode that matters here, so nothing is swallowed.
#
#  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$json = Get-Content -Raw -Encoding UTF8 (Join-Path $root '_qa\thai-final.json') | ConvertFrom-Json
$edits = @($json | Where-Object { $_.changed -and $_.oldTh -ne $_.newTh })
Write-Output ("{0} changed lines to apply (of {1} returned)" -f $edits.Count, @($json).Count)

# HTML keeps BOM-less UTF-8; the two PowerShell files must keep their BOM
$targets = @(
  @{ f = 'index.html';        bom = $false }
  @{ f = 'menu.html';         bom = $false }
  @{ f = 'fire.html';         bom = $false }
  @{ f = 'visit.html';        bom = $false }
  @{ f = 'data\menu.json';    bom = $false }
  @{ f = 'data\site.json';    bom = $false }
  @{ f = '_qa\build.ps1';     bom = $true  }
)

$applied = @{}
foreach ($t in $targets) {
  $p = Join-Path $root $t.f
  if (-not (Test-Path $p)) { continue }
  $txt = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
  $orig = $txt
  $n = 0
  foreach ($e in $edits) {
    if ($txt.Contains($e.oldTh)) {
      $txt = $txt.Replace($e.oldTh, $e.newTh)
      $n++
      $applied[$e.oldTh] = $true
    }
  }
  if ($txt -ne $orig) {
    [System.IO.File]::WriteAllText($p, $txt, (New-Object System.Text.UTF8Encoding($t.bom)))
    Write-Output ("  {0,-18} {1} replaced" -f $t.f, $n)
  }
}

$missed = @($edits | Where-Object { -not $applied.ContainsKey($_.oldTh) })
Write-Output ''
Write-Output ("matched : {0}" -f $applied.Count)
if ($missed.Count) {
  Write-Output ("UNMATCHED KEYS ({0}) — these did not exist verbatim anywhere:" -f $missed.Count)
  $missed | ForEach-Object {
    Write-Output ('  old: ' + $_.oldTh.Substring(0, [Math]::Min(70, $_.oldTh.Length)))
  }
} else {
  Write-Output 'every key matched'
}

# ---- fact guard: the numbers and hedges that must never move ----
Write-Output ''
Write-Output 'fact guard:'
$facts = @(
  '490', '100 กรัม', '1,990', '590', '990', '150', '11:00', '21:00',
  'ปิดทุกวันพุธ', '099 245 5444', '339 หมู่ 11', 'ตำบลหนองน้ำแดง',
  'อำเภอปากช่อง', '4.5', '58', 'Google', 'Wongnai', 'Rosebay Homecooking Cafe',
  'โรงย่างเนื้อ', 'ตัดทำได้หมด', 'ทุกเพศทุกวัย'
)
$all = ($targets | Where-Object { Test-Path (Join-Path $root $_.f) } |
        ForEach-Object { [System.IO.File]::ReadAllText((Join-Path $root $_.f), [System.Text.Encoding]::UTF8) }) -join "`n"
$lost = @()
foreach ($fct in $facts) { if (-not $all.Contains($fct)) { $lost += $fct } }
if ($lost.Count) { Write-Output ('  LOST: ' + ($lost -join ', ')) }
else { Write-Output '  all protected facts still present' }

# transliterated brand names must not come back
foreach ($bad in @('เฟซบุ๊ก', 'อินสตาแกรม', 'กูเกิ้ล', 'กูเกิล')) {
  if ($all.Contains($bad)) { Write-Output ('  STILL TRANSLITERATED: ' + $bad) }
}
