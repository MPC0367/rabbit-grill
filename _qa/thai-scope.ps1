# =============================================================
#  Split the Thai inventory into what MAY be rewritten and what
#  must not be.
#
#  PROTECTED (facts / their own words — never reworded):
#   * every dish and drink name in data/menu.json  (their menu card)
#   * the restaurant's own quoted lines
#   * the street address and its components
#  REWRITABLE: everything else — nav, headlines, body, CTAs,
#   captions, labels, notes.
#
#  Writes _qa/thai-rewritable.tsv and _qa/thai-protected.tsv
#  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$menu = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'data\menu.json') | ConvertFrom-Json
$protectedSet = New-Object System.Collections.Generic.HashSet[string]

foreach ($c in $menu.categories) {
  [void]$protectedSet.Add($c.th)
  foreach ($i in $c.items) { if ($i.th) { [void]$protectedSet.Add($i.th) } }
}
foreach ($d in $menu.drinks) {
  [void]$protectedSet.Add($d.th)
  foreach ($i in $d.items) { if ($i.th) { [void]$protectedSet.Add($i.th) } }
}

# their own words, quoted on the site — not ours to polish
@(
  'ตัดทำได้หมด'
  'ทุกเพศทุกวัย'
  'ทุกเพศทุกวัย — คำของร้านเอง'
  '“โรงย่างเนื้อแห่งเขาใหญ่ ที่ยึดความคลาสสิกของการย่างแบบดั้งเดิม คัดเฉพาะเนื้อคุณภาพดี ถูกย่างด้วยไฟอย่างพิถีพิถัน”'
  '“โดยเชฟผู้เชี่ยวชาญด้านเนื้อ เชฟบัส Top Chef Thailand”'
  '“Rabbit Grill โรงย่างเนื้อเขาใหญ่ สไตล์ Home Cooking โดยเชฟผู้เชี่ยวชาญด้านเนื้อ เชฟบัส Top Chef Thailand”'
  '“พอครัวเริ่มยุ่ง Rabbit Grill ก็มีชีวิตขึ้นมา”'
  '“ทุกรายละเอียดเริ่มต้นจากสองมือ และทุกจานมีเรื่องราวของฝีมือที่อยู่เบื้องหลัง”'
  '“ทุกจานที่ดีเริ่มจากการดูแลตั้งแต่ยังดิบ”'
  '“ทุกรายละเอียดเริ่มจากสองมือ”'
  '“มุมมองต่างกัน แต่ Rabbit Grill เดียวกัน”'
  'โรงย่างเนื้อสไตล์ Fire Cooking'
) | ForEach-Object { [void]$protectedSet.Add($_) }

$lines = [System.IO.File]::ReadAllLines((Join-Path $root '_qa\thai-inventory.tsv'), [System.Text.Encoding]::UTF8)
$rewrite = New-Object System.Collections.Generic.List[string]
$prot    = New-Object System.Collections.Generic.List[string]
$seen    = New-Object System.Collections.Generic.HashSet[string]

$rewrite.Add("role`tTHAI (current)`tENGLISH (reference)")
$prot.Add("role`tTHAI (protected)")

foreach ($ln in ($lines | Select-Object -Skip 1)) {
  $p = $ln -split "`t"
  if ($p.Count -lt 4) { continue }
  $role = $p[1]; $th = $p[2]; $en = $p[3]
  if (-not $seen.Add($th)) { continue }                      # unique strings only
  # an address line is factual; so is anything that is only digits/punctuation
  $isAddress = $th -match '339 หมู่ 11|ตำบลหนองน้ำแดง|อำเภอปากช่อง|จังหวัดนครราชสีมา|JCJ3'
  if ($protectedSet.Contains($th) -or $isAddress) { $prot.Add("$role`t$th") }
  else { $rewrite.Add("$role`t$th`t$en") }
}

[System.IO.File]::WriteAllLines((Join-Path $root '_qa\thai-rewritable.tsv'), $rewrite, (New-Object System.Text.UTF8Encoding($true)))
[System.IO.File]::WriteAllLines((Join-Path $root '_qa\thai-protected.tsv'),  $prot,    (New-Object System.Text.UTF8Encoding($true)))

Write-Output ("rewritable : {0}" -f ($rewrite.Count - 1))
Write-Output ("protected  : {0}  (menu dish names, their own quotes, address)" -f ($prot.Count - 1))
