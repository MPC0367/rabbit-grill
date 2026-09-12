# =============================================================
#  One-shot patch: give every display heading a Thai counterpart.
#
#  The English stays in the markup and is captured off the DOM at
#  runtime (see js/app.js -> i18n), so only the Thai is authored
#  here as a data-th attribute. Headings built with the .lines
#  reveal need their span scaffold repeated inside the attribute.
#
#  Safe to re-run: it skips any heading that already has data-th.
# =============================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Add-Th {
  param([string]$Html, [string]$Anchor, [string]$Thai, [switch]$Lines)

  $a = [regex]::Escape($Anchor)
  if ($Lines) {
    $pattern = '(?s)(<h[12](?![^>]*data-th)[^>]*class="[^"]*lines[^"]*"[^>]*?)(>)(\s*<span><span>' + $a + ')'
  } else {
    $pattern = '(<h[1-3](?![^>]*data-th)[^>]*?)(>)(\s*' + $a + ')'
  }
  $re = [regex]$pattern
  # Write-Output inside a function becomes part of its RETURN VALUE in PowerShell.
  # This used to say Write-Output, so a miss returned @("MISS ...", $Html) and the
  # caller wrote both into the page — putting text before <!DOCTYPE> and silently
  # dropping the document into quirks mode. Diagnostics must go to the host.
  if (-not $re.IsMatch($Html)) { Write-Host ("  MISS  " + $Anchor); return $Html }
  return $re.Replace($Html, ('$1 data-th="' + $Thai + '"$2$3'), 1)
}

# ---------------------------------------------------------------
$f = Join-Path $root 'index.html'
$h = [System.IO.File]::ReadAllText($f)
Write-Output 'index.html'
$h = Add-Th $h 'Fire does'      "<span><span>ให้<span class='fire'>ไฟ</span></span></span><span><span>เป็นคนปรุง</span></span>" -Lines
$h = Add-Th $h 'Good things'    '<span><span>ของอร่อย</span></span><span><span>เกิดขึ้น</span></span><span><span>รอบกองไฟ</span></span>' -Lines
$h = Add-Th $h 'Fire does'      '<span><span>ปล่อยให้ไฟ</span></span><span><span>เป็นคนพูด</span></span>' -Lines
$h = Add-Th $h 'Meat.'          '<span><span>เนื้อ</span></span><span><span>ไฟ</span></span><span><span>เวลา</span></span>' -Lines
$h = Add-Th $h 'Out of Bangkok.' '<span><span>ออกจากกรุงเทพฯ</span></span><span><span>เข้าสู่เขาใหญ่</span></span>' -Lines
$h = Add-Th $h 'Driving up'     '<span><span>ขับรถมา</span></span><span><span>พร้อมน้องหมา?</span></span>' -Lines
$h = Add-Th $h 'Cut to order.'  "หั่นตามที่สั่ง<span class='hand'>ตัดทำได้หมด</span>"
$h = Add-Th $h 'The latest from Khao Yai.' 'อัปเดตล่าสุดจากเขาใหญ่'
[System.IO.File]::WriteAllText($f, $h, (New-Object System.Text.UTF8Encoding($false)))

# ---------------------------------------------------------------
$f = Join-Path $root 'menu.html'
$h = [System.IO.File]::ReadAllText($f)
Write-Output 'menu.html'
$h = Add-Th $h 'Everything' '<span><span>ทุกอย่าง</span></span><span><span>ที่ผ่านไฟ</span></span>' -Lines
$h = Add-Th $h 'The bar and the matcha counter.' 'บาร์ และเคาน์เตอร์มัทฉะ'
$h = Add-Th $h 'Ready to order?' 'พร้อมสั่งแล้วหรือยัง'
[System.IO.File]::WriteAllText($f, $h, (New-Object System.Text.UTF8Encoding($false)))

# ---------------------------------------------------------------
$f = Join-Path $root 'fire.html'
$h = [System.IO.File]::ReadAllText($f)
Write-Output 'fire.html'
$h = Add-Th $h 'Meat.' '<span><span>เนื้อ</span></span><span><span>ไฟ</span></span><span><span>เวลา</span></span>' -Lines
$h = Add-Th $h 'Beef, bird, pork,' '<span><span>เนื้อ ไก่ หมู</span></span><span><span>และของจากแม่น้ำ</span></span>' -Lines
$h = Add-Th $h 'A chef who works in beef.' 'เชฟที่ทำงานกับเนื้อ'
[System.IO.File]::WriteAllText($f, $h, (New-Object System.Text.UTF8Encoding($false)))

# ---------------------------------------------------------------
$f = Join-Path $root 'visit.html'
$h = [System.IO.File]::ReadAllText($f)
Write-Output 'visit.html'
$h = Add-Th $h 'Out of Bangkok.' '<span><span>ออกจากกรุงเทพฯ</span></span><span><span>เข้าสู่เขาใหญ่</span></span>' -Lines
$h = Add-Th $h 'Driving up'      '<span><span>ขับรถมา</span></span><span><span>พร้อมน้องหมา?</span></span>' -Lines
$h = Add-Th $h 'Part of the pleasure is the drive.' 'เสน่ห์อย่างหนึ่งคือการได้ขับรถมา'
$h = Add-Th $h 'Worth a phone call.' 'โทรถามไว้ก่อนดีที่สุด'
[System.IO.File]::WriteAllText($f, $h, (New-Object System.Text.UTF8Encoding($false)))

Write-Output 'done'
