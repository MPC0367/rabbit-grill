# =============================================================
#  Rabbit Grill - venue photography
#
#  Source: the restaurant's OWN Facebook photographs, harvested
#  at full resolution by _qa\fetch-fb-photos.ps1 into img\raw\.
#  These are the pictures of the place itself - the exterior at
#  night, the open kitchen, guests at the counter, the fire on
#  the grate - which the menu PDFs could never provide.
#
#  Several carry a small RABBIT GRILL wordmark or a marketing
#  line burned into the top of the frame; the rectangles below
#  crop underneath those.  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
Add-Type -AssemblyName System.Drawing
$raw = 'C:\Users\marky\NOVA\rabbit-grill\img\raw'
$out = 'C:\Users\marky\NOVA\rabbit-grill\img'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }

function Crop-Save($srcPath, $x, $y, $w, $h, $maxW, $quality, $name) {
  $img = [System.Drawing.Image]::FromFile($srcPath)
  try {
    if ($x -lt 0) { $x = 0 }
    if ($y -lt 0) { $y = 0 }
    if (($x + $w) -gt $img.Width)  { $w = $img.Width  - $x }
    if (($y + $h) -gt $img.Height) { $h = $img.Height - $y }
    $rect = New-Object System.Drawing.Rectangle $x, $y, $w, $h
    $crop = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($crop)
    $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0,0,$w,$h), $rect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    $scale = 1.0
    if ($w -gt $maxW) { $scale = $maxW / $w }
    $nw = [int]($w * $scale); $nh = [int]($h * $scale)
    $final = New-Object System.Drawing.Bitmap $nw, $nh
    $g2 = [System.Drawing.Graphics]::FromImage($final)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g2.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g2.DrawImage($crop, 0, 0, $nw, $nh)
    $g2.Dispose()
    $ps = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int]$quality)
    $dest = Join-Path $out ($name + '.jpg')
    $final.Save($dest, $enc, $ps)
    $final.Dispose(); $crop.Dispose()
    Write-Output ('{0,-22} {1,4}x{2,-4} {3,6:n0} KB' -f ($name + '.jpg'), $nw, $nh, ((Get-Item $dest).Length/1KB))
  } finally { $img.Dispose() }
}

# ---- the building, at night, with their own sign ----
Crop-Save "$raw\fb-cover.jpg"        0    0 3283 1276 2000 84 'venue-exterior'
Crop-Save "$raw\fb-cover.jpg"     1450  250 1350  900 1200 85 'venue-sign'

# ---- the open kitchen, and guests sitting right at it ----
Crop-Save "$raw\fb-people-1.jpg"     0  380 2048 1360 1600 84 'venue-counter'
Crop-Save "$raw\fb-people-1.jpg"   180  260 1300 1620 1000 85 'venue-host'
Crop-Save "$raw\fb-people-2.jpg"     0  300 2048 1400 1600 84 'venue-pass'
Crop-Save "$raw\fb-steak.jpg"        0  780 2048 1268 1600 84 'venue-chef'

# ---- the fire itself ----
Crop-Save "$raw\fb-fire-hearth.jpg"  0  200 1638 1848 1400 86 'fire-hearth'
Crop-Save "$raw\fb-steak-fire.jpg"   0  120 2048 1928 1600 86 'fire-steak'

# ---- prep and plate ----
Crop-Save "$raw\fb-rawcare.jpg"      0  700 2048 1348 1600 84 'prep-raw'
Crop-Save "$raw\fb-charcoal.jpg"     0  430 1989 1618 1400 84 'plate-ribs'

# ---- the dining room, cropped out from under their Wednesday notice ----
# venue-room dropped: the only crop clear of their CLOSED notice was a dark, empty counter strip
