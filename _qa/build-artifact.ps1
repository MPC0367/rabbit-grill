# =============================================================
#  Rabbit Grill — single-file artifact build
#
#  Folds the four pages into one shareable document:
#    index.html  -> chrome + #top
#    menu.html   -> #menu
#    fire.html   -> #fire
#    visit.html  -> #visit
#  Inlines both stylesheets, all three scripts, and every
#  photograph as a data URI, so the page needs nothing but
#  Google Fonts to render anywhere.
#
#  Images are re-encoded down for transport: the artifact has a
#  16 MB ceiling and base64 costs another third on top of the
#  bytes, so the big three get 1400-1600px and everything else
#  760px.  Run _qa\build.ps1 first if the menu data changed.
#
#  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$out  = Join-Path $root 'rabbit-grill-artifact.html'
$enc  = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }

# ---------- image -> data URI ----------
$big = @{ 'hero-plate' = 1600; 'primerib-board' = 1600; 'venue-exterior' = 1800;
          'fire-steak' = 1500; 'fire-hearth' = 1300; 'venue-counter' = 1400;
          'primerib-full' = 1000; 'venue-pass' = 1200; 'venue-chef' = 1200 }

$dataUri = @{}
$totalBytes = 0

function To-DataUri([string]$name) {
  if ($dataUri.ContainsKey($name)) { return $dataUri[$name] }
  $path = Join-Path $root ("img\" + $name + ".jpg")
  if (-not (Test-Path $path)) { Write-Output ("  MISSING img: " + $name); return $null }

  $maxW = 880; $q = 72
  if ($big.ContainsKey($name)) { $maxW = $big[$name]; $q = 74 }

  $img = [System.Drawing.Image]::FromFile($path)
  try {
    $w = $img.Width; $h = $img.Height
    $scale = 1.0
    if ($w -gt $maxW) { $scale = $maxW / $w }
    $nw = [int]($w * $scale); $nh = [int]($h * $scale)
    $bmp = New-Object System.Drawing.Bitmap $nw, $nh
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img, 0, 0, $nw, $nh)
    $g.Dispose()
    $ps = New-Object System.Drawing.Imaging.EncoderParameters 1
    $ps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([int]$q)
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, $enc, $ps)
    $bytes = $ms.ToArray()
    $ms.Dispose(); $bmp.Dispose()
    $script:totalBytes += $bytes.Length
    $uri = 'data:image/jpeg;base64,' + [Convert]::ToBase64String($bytes)
    $dataUri[$name] = $uri
    return $uri
  } finally { $img.Dispose() }
}

# ---------- read the pages ----------
function Get-Main([string]$file) {
  $t = [System.IO.File]::ReadAllText((Join-Path $root $file), [System.Text.Encoding]::UTF8)
  $a = $t.IndexOf('<main id="main">')
  $b = $t.LastIndexOf('</main>')
  if ($a -lt 0 -or $b -lt 0) { throw "no <main> in $file" }
  $a += '<main id="main">'.Length
  return $t.Substring($a, $b - $a)
}

$index = [System.IO.File]::ReadAllText((Join-Path $root 'index.html'), [System.Text.Encoding]::UTF8)
$menuM  = Get-Main 'menu.html'
$fireM  = Get-Main 'fire.html'
$visitM = Get-Main 'visit.html'

# index's own "visit strip" would collide with the visit page's anchor
$index = $index.Replace('style="--bg:var(--paper-2)" id="visit"', 'style="--bg:var(--paper-2)" id="visit-strip"')

# ---------- assemble one <main> ----------
# Each page becomes a .page block the router shows one at a time, so the nav
# switches instead of scrolling 30,000px. The anchor <section>s stay inside
# their page so router.pageOf() can resolve any deep link by closest('.page').
$merged = @"
<div class="page" data-page="top" id="top-page">
$(Get-Main 'index.html')
</div>

<div class="page" data-page="menu" id="menu" hidden>
$menuM
</div>

<div class="page" data-page="fire" id="fire" hidden>
$fireM
</div>

<div class="page" data-page="visit" id="visit" hidden>
$visitM
</div>
"@

$a = $index.IndexOf('<main id="main">')
$b = $index.LastIndexOf('</main>')
$html = $index.Substring(0, $a + '<main id="main">'.Length) + $merged + $index.Substring($b)
$html = $html.Replace('style="--bg:var(--paper-2)" id="visit"', 'style="--bg:var(--paper-2)" id="visit-strip"')

# ---------- inline css + js ----------
$css = ([System.IO.File]::ReadAllText((Join-Path $root 'css\base.css'), [System.Text.Encoding]::UTF8)) + "`n" +
       ([System.IO.File]::ReadAllText((Join-Path $root 'css\site.css'), [System.Text.Encoding]::UTF8)) + @"

/* ---- artifact-only: the four pages are now one scroll ---- */
/* Smooth scrolling is pleasant across a section; across the 30,000px this
   merged document runs to it is an interminable animated crawl, and a capture
   or a fast click lands mid-flight. Jump instead. */
html { scroll-behavior: auto; }
.artsec { display: block; height: 0; scroll-margin-top: calc(var(--nav-h) + 8px); }
.page[hidden] { display: none !important; }
.mhead { padding-top: clamp(40px, 6vw, 84px); }
"@

$html = $html.Replace('<link rel="stylesheet" href="css/base.css">' + "`r`n" + '<link rel="stylesheet" href="css/site.css">', "<style>`n$css`n</style>")
$html = $html.Replace('<link rel="stylesheet" href="css/base.css">' + "`n" + '<link rel="stylesheet" href="css/site.css">', "<style>`n$css`n</style>")

$js = ([System.IO.File]::ReadAllText((Join-Path $root 'js\carve.js'),   [System.Text.Encoding]::UTF8)) + "`n" +
      ([System.IO.File]::ReadAllText((Join-Path $root 'js\dishpop.js'), [System.Text.Encoding]::UTF8)) + "`n" +
      ([System.IO.File]::ReadAllText((Join-Path $root 'js\app.js'),     [System.Text.Encoding]::UTF8))

$html = $html.Replace('<script src="js/shot.js"></script>', '')
$html = $html.Replace('<script src="js/carve.js" defer></script>', '')
$html = $html.Replace('<script src="js/dishpop.js" defer></script>', '')
$html = $html.Replace('<script src="js/app.js" defer></script>', "<script>`n$js`n</script>")

# strip the leftover script tags the inner pages carried in
$html = [System.Text.RegularExpressions.Regex]::Replace($html, '<script src="js/[^"]+"[^>]*></script>', '')

# ---------- rewrite links to in-page anchors ----------
$html = $html.Replace('href="visit.html#directions"', 'href="#directions"')
$html = $html.Replace('href="menu.html#', 'href="#')
$html = $html.Replace('href="menu.html"', 'href="#menu"')
$html = $html.Replace('href="fire.html"', 'href="#fire"')
$html = $html.Replace('href="visit.html"', 'href="#visit"')
$html = $html.Replace('href="index.html"', 'href="#top"')
$html = $html.Replace('href="#main"', 'href="#top"')
$html = $html.Replace('<main id="main">', '<main id="top">')
$html = $html.Replace('<body class="has-bar">', '<body class="has-bar" data-spa data-page="top">')
foreach ($pair in @(@('#menu','menu'), @('#fire','fire'), @('#visit','visit'), @('#top','top'))) {
  $html = $html.Replace(('href="{0}"' -f $pair[0]), ('href="{0}" data-nav-to="{1}"' -f $pair[0], $pair[1]))
}

# only the first nav/sheet/footer/action-bar survive; the inner pages brought copies
function Drop-Extra([string]$doc, [string]$startMark, [string]$endMark) {
  $first = $doc.IndexOf($startMark)
  if ($first -lt 0) { return $doc }
  $searchFrom = $first + $startMark.Length
  while ($true) {
    $i = $doc.IndexOf($startMark, $searchFrom)
    if ($i -lt 0) { break }
    $j = $doc.IndexOf($endMark, $i)
    if ($j -lt 0) { break }
    $j += $endMark.Length
    $doc = $doc.Remove($i, $j - $i)
    $searchFrom = $i
  }
  return $doc
}
$html = Drop-Extra $html '<footer class="foot">' '</footer>'
$html = Drop-Extra $html '<nav class="bar" aria-label="Quick actions">' '</nav>'
$html = Drop-Extra $html '<header class="nav">' '</header>'
$html = Drop-Extra $html '<div class="sheet" id="sheet"' '</div>
</div>'

# The gallery shows the <title> as the artifact's name, so trim the SEO tail —
# the explanation belongs in the publish description, not the title.
$html = [System.Text.RegularExpressions.Regex]::Replace($html, '<title>.*?</title>', '<title>Rabbit Grill Khao Yai</title>')

# a second JSON-LD block would be a duplicate
$parts = [System.Text.RegularExpressions.Regex]::Matches($html, '(?s)<script type="application/ld\+json">.*?</script>')
if ($parts.Count -gt 1) {
  for ($i = $parts.Count - 1; $i -ge 1; $i--) {
    $html = $html.Remove($parts[$i].Index, $parts[$i].Length)
  }
}

# ---------- inline every photograph ----------
# Two sources of image names: <img src="img/x.jpg"> in the markup, and
# data-img="x" on the menu rows, whose paths dishpop.js builds at runtime.
$fromSrc = [System.Text.RegularExpressions.Regex]::Matches($html, 'img/([a-z0-9\-]+)\.jpg') |
           ForEach-Object { $_.Groups[1].Value }
$fromRow = [System.Text.RegularExpressions.Regex]::Matches($html, 'data-img="([a-z0-9\-]+)"') |
           ForEach-Object { $_.Groups[1].Value }
$imgNames = @($fromSrc + $fromRow) | Sort-Object -Unique
Write-Output ("inlining {0} photographs..." -f $imgNames.Count)
foreach ($n in $imgNames) { [void](To-DataUri $n) }

# Each blob is stored EXACTLY ONCE, in window.RG_IMG. Pasting the data URI at
# every <img src> instead made the file 14.5 MB, because several photographs
# appear three or four times across the merged pages. The markup keeps only a
# name and a 1x1 placeholder; hydrate() fills them in on load.
$dot = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'
$html = [System.Text.RegularExpressions.Regex]::Replace(
  $html, 'src="img/([a-z0-9\-]+)\.jpg"', ('data-img-src="$1" src="' + $dot + '"'))

# these two would each embed a whole photograph again
$html = [System.Text.RegularExpressions.Regex]::Replace($html, '<link rel="preload" as="image"[^>]*>', '')
$html = [System.Text.RegularExpressions.Regex]::Replace($html, '<meta property="og:image"[^>]*>', '')

# the favicon is a tiny svg — inline it too
$fav = [System.IO.File]::ReadAllText((Join-Path $root 'img\favicon.svg'), [System.Text.Encoding]::UTF8)
$favUri = 'data:image/svg+xml;base64,' + [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fav))
$html = $html.Replace('img/favicon.svg', $favUri)

# dishpop + carve resolve names through this map when there are no files
$map = ($dataUri.Keys | ForEach-Object { '"' + $_ + '":"' + $dataUri[$_] + '"' }) -join ','
# String.Replace has no count overload, so seed the map at the first <script>
$firstScript = $html.IndexOf('<script>')
if ($firstScript -lt 0) { throw 'no inline <script> to seed the image map into' }
$hydrate = 'window.RG_IMG={' + $map + '};' +
  '(function(){function h(){var n=document.querySelectorAll("[data-img-src]");' +
  'for(var i=0;i<n.length;i++){var k=n[i].getAttribute("data-img-src");' +
  'if(window.RG_IMG[k]){n[i].src=window.RG_IMG[k];n[i].removeAttribute("data-img-src");}}}' +
  'if(document.readyState==="loading"){document.addEventListener("DOMContentLoaded",h);}else{h();}' +
  'h();})();'
$html = $html.Insert($firstScript + '<script>'.Length, $hydrate)

[System.IO.File]::WriteAllText($out, $html, (New-Object System.Text.UTF8Encoding($false)))

$size = (Get-Item $out).Length
Write-Output ('')
Write-Output ('artifact : {0}' -f $out)
Write-Output ('images   : {0} files, {1:n1} MB re-encoded' -f $imgNames.Count, ($totalBytes/1MB))
Write-Output ('page     : {0:n2} MB  (ceiling is 16 MB)' -f ($size/1MB))
