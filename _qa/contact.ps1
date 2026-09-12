Add-Type -AssemblyName System.Drawing
$dir = 'C:\Users\marky\NOVA\rabbit-grill\img'
$files = Get-ChildItem $dir -Filter *.jpg | Sort-Object Name
$cols = 6
$cell = 300
$labelH = 26
$rows = [Math]::Ceiling($files.Count / $cols)
$W = $cols * $cell
$H = $rows * ($cell + $labelH)

$sheet = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(23,21,15))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$font = New-Object System.Drawing.Font('Segoe UI', 9)
$brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(243,236,221))

for ($i = 0; $i -lt $files.Count; $i++) {
  $c = $i % $cols; $r = [Math]::Floor($i / $cols)
  $x = $c * $cell; $y = $r * ($cell + $labelH)
  $im = [System.Drawing.Image]::FromFile($files[$i].FullName)
  try {
    # cover-fit into the cell
    $s = [Math]::Max($cell / $im.Width, $cell / $im.Height)
    $dw = $im.Width * $s; $dh = $im.Height * $s
    $dx = $x + ($cell - $dw) / 2; $dy = $y + ($cell - $dh) / 2
    $g.SetClip((New-Object System.Drawing.Rectangle $x, $y, $cell, $cell))
    $g.DrawImage($im, $dx, $dy, $dw, $dh)
    $g.ResetClip()
  } finally { $im.Dispose() }
  $g.DrawString($files[$i].BaseName, $font, $brush, ($x + 4), ($y + $cell + 5))
}
$g.Dispose()
$outFile = 'C:\Users\marky\NOVA\rabbit-grill\_qa\contact.png'
$sheet.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()
Write-Output ("contact sheet: {0} images -> {1}" -f $files.Count, $outFile)
