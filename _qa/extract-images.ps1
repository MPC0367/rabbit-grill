# =============================================================
#  Rabbit Grill — photography extraction
#
#  Every dish photograph on this site comes out of the restaurant
#  own menu PDFs. Each PDF page is a single embedded JPEG, so the
#  pages were carved out byte-wise into doc\pages\*.jpg and the
#  individual plates are cropped from those here.
#
#  IMPORTANT: the menu artwork has a handwritten dish name and
#  price sitting in a corner of nearly every photograph. Those
#  are duplicated by the site typography, so every rectangle
#  below is tuned to crop INSIDE the label. If you re-cut these,
#  check the contact sheet (_qa\contact.ps1) before shipping.
# =============================================================
Add-Type -AssemblyName System.Drawing
$src = 'C:\Users\marky\NOVA\rabbit-grill\doc\pages'
$avo = 'C:\Users\marky\NOVA\rabbit-grill\doc\menu-avocado.jpg'
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
    $g2.InterpolationMode  = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.PixelOffsetMode    = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g2.SmoothingMode      = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g2.DrawImage($crop, 0, 0, $nw, $nh)
    $g2.Dispose()

    $ps = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int]$quality)
    $dest = Join-Path $out "$name.jpg"
    $final.Save($dest, $enc, $ps)
    $final.Dispose(); $crop.Dispose()
    Write-Output ("{0,-26} {1,4}x{2,-4} {3,6:n0} KB" -f "$name.jpg", $nw, $nh, ((Get-Item $dest).Length/1KB))
  } finally { $img.Dispose() }
}

# ---- hero: the cover photograph. Its band is clean of type. ----
Crop-Save "$src\food-01.jpg"    0  690 2067 1760 1800 82 'hero-plate'
Crop-Save "$src\food-01.jpg"  330  700 1400 1500 1000 82 'apron-portrait'

# ---- the carving board ----
Crop-Save "$src\food-09.jpg"   44 1140 1929 1198 1800 86 'primerib-board'
Crop-Save "$src\food-09.jpg"  100  400 1867 2000 1200 82 'primerib-full'

# ---- beef ----
Crop-Save "$src\food-10.jpg"  100  700 1400  800 1200 82 'striploin'
Crop-Save "$src\food-10.jpg"  300 1750 1500  780 1200 82 'wagyu-tenderloin'
Crop-Save "$src\food-11.jpg"    0  400 1500 1134 1200 82 'grilled-tongue'
Crop-Save "$src\food-11.jpg"    0 1830 1018 1093  900 82 'tongue-stew'
Crop-Save "$src\food-11.jpg" 1030 1830 1037 1093  900 82 'lamb-rack'

# ---- from the grill ----
Crop-Save "$src\food-06.jpg"    0  409 1450 1125 1200 82 'baby-chicken'
Crop-Save "$src\food-06.jpg"    0 1850 1008 1073  900 82 'grilled-pork'
Crop-Save "$src\food-06.jpg" 1023 1850 1044 1073  900 82 'pork-ribs'
Crop-Save "$src\food-07.jpg"  450  409 1617 1206 1200 82 'fish-chips'
Crop-Save "$src\food-07.jpg"    0 1615 2067  985 1200 82 'river-prawns'
Crop-Save "$src\food-08.jpg"  450  409 1617 1151 1200 82 'grilled-squid'
Crop-Save "$src\food-08.jpg"    0 2000 2067  923 1200 82 'grilled-fish'

# ---- appetizers ----
Crop-Save "$src\food-02.jpg"  400  409 1667 1286 1200 82 'corn-rib'
Crop-Save "$src\food-02.jpg"    0 1950 1008  973  900 82 'nashville-chicken'
Crop-Save "$src\food-02.jpg" 1008 1950 1059  973  900 82 'sweet-potato'
Crop-Save "$src\food-04.jpg"    0  700 1400  995 1200 82 'bone-marrow'
Crop-Save "$src\food-04.jpg"    0 1695 1500  855 1200 82 'calamari'

# ---- salads ----
Crop-Save "$src\food-03.jpg"  550  409 1517 1206 1200 82 'caesar'
Crop-Save "$src\food-03.jpg"    0 1900 2067 1023 1200 82 'greenbean-peas'
Crop-Save "$src\food-05.jpg"    0  409 2067 1041 1200 82 'green-salad'
Crop-Save "$src\food-05.jpg"    0 1695 1018  925  900 82 'tomato-salad'
Crop-Save "$src\food-05.jpg" 1030 1695 1037  925  900 82 'burrata-tomato'

# ---- sides ----
Crop-Save "$src\food-12.jpg"    0  387  690  623  700 82 'mashed-potato'
Crop-Save "$src\food-12.jpg"  690  387  680  623  700 82 'sauteed-potato'
Crop-Save "$src\food-12.jpg" 1370  387  697  623  700 82 'french-fries'
Crop-Save "$src\food-12.jpg"    0 1184 1023  666  800 82 'greenbeans-bacon'
Crop-Save "$src\food-12.jpg" 1023 1184 1044  666  800 82 'garlic-confit'
Crop-Save "$src\food-12.jpg"    0 2046 1023  654  800 82 'mini-broccoli'
Crop-Save "$src\food-12.jpg" 1023 2046 1044  654  800 82 'mushrooms'

# ---- rice + dessert ----
Crop-Save "$src\food-13.jpg"    0  740 1038  890  900 82 'basil-beef-rice'
Crop-Save "$src\food-13.jpg" 1049  650 1018  980  900 82 'american-fried-rice'
Crop-Save "$src\food-13.jpg"    0 1980 2067  943 1200 82 'beef-fried-rice'
Crop-Save "$src\food-14.jpg"    0  400 1400 1230 1200 82 'creme-brulee'
Crop-Save "$src\food-14.jpg"    0 1950 1700  973 1200 82 'tiramisu'

# ---- seasonal avocado ----
Crop-Save $avo    0  880 1236 1190  900 82 'fried-avocado'
Crop-Save $avo 1245  880 1235 1190  900 82 'corn-avocado-salad'
Crop-Save $avo    0 2330 1236 1178  900 82 'corn-fritters'
Crop-Save $avo 1245 2330 1235 1178  900 82 'burrata-guacamole'
