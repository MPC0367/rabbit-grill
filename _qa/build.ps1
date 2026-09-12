# =============================================================
#  Rabbit Grill — menu generator
#
#  data/menu.json is the single source of truth. This writes the
#  menu markup straight into menu.html between the markers, so
#  the prices are real static HTML for search engines and for
#  anyone with JavaScript off — while still living in one file
#  the restaurant can edit.
#
#  THIS FILE MUST STAY UTF-8 WITH BOM or PowerShell 5.1 mangles
#  every Thai string in it.
#
#  Run:  powershell -NoProfile -ExecutionPolicy Bypass -File _qa\build.ps1
# =============================================================
$ErrorActionPreference = 'Stop'
$rootDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$dataFile = Join-Path $rootDir 'data\menu.json'
$pageFile = Join-Path $rootDir 'menu.html'

$data = Get-Content -Raw -Encoding UTF8 $dataFile | ConvertFrom-Json

function Esc([string]$s) {
  if ($null -eq $s) { return '' }
  $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;')
}
function Money($n) { return ('{0:n0}' -f [int]$n) }

# ---------- sticky category nav ----------
$navParts = New-Object System.Collections.Generic.List[string]
foreach ($c in $data.categories) {
  $navParts.Add(('    <a href="#{0}" data-th="{1}">{2}</a>' -f $c.id, (Esc $c.th), (Esc $c.en)))
}
$navParts.Add('    <a href="#drinks" data-th="เครื่องดื่ม">Drinks</a>')
$mnav = @"
  <div class="mnav">
    <div class="wrap"><div class="mnav__in">
$($navParts -join "`n")
    </div></div>
  </div>
"@

# ---------- food categories ----------
$secs = New-Object System.Collections.Generic.List[string]
foreach ($c in $data.categories) {
  $rows = New-Object System.Collections.Generic.List[string]
  foreach ($it in $c.items) {

    $star = ''
    if ($it.star) { $star = '<span class="star" aria-hidden="true">●</span>' }

    $price = Money $it.price
    if ($it.price2) { $price = ('{0} / {1}' -f (Money $it.price), (Money $it.price2)) }

    $unit = ''
    if ($it.unit_en) {
      $unit = ('<span class="mrow__u" data-th="{0}">{1}</span>' -f (Esc $it.unit_th), (Esc $it.unit_en))
    }

    $thai = ''
    if ($it.th) { $thai = ('<span class="mrow__th">{0}</span>' -f (Esc $it.th)) }

    # data-img drives BOTH the desktop hover plate and the mobile spotlight.
    # The picture itself is injected lazily by js/dishpop.js, so a 39-row
    # menu still costs one HTTP request until you actually point at something.
    $imgAttr = ''
    if ($it.img) { $imgAttr = (' data-img="{0}" data-name="{1}"' -f $it.img, (Esc $it.en)) }

    $rows.Add(@"
        <li class="mrow"$imgAttr>
          <span class="mrow__n">$(Esc $it.en)$star</span>
          $thai
          <span class="mrow__p num">$price&nbsp;฿</span>
          $unit
        </li>
"@)
  }

  # a strip of plates for the categories with enough photographed dishes
  $shot = @($c.items | Where-Object { $_.star -and $_.img })
  $plates = ''
  if ($shot.Count -ge 2) {
    $figs = New-Object System.Collections.Generic.List[string]
    foreach ($s in ($shot | Select-Object -First 3)) {
      $figs.Add(@"
        <figure data-reveal="mask">
          <div class="media media--live"><img src="img/$($s.img).jpg" loading="lazy" alt="$(Esc $s.en) at Rabbit Grill Khao Yai."></div>
          <figcaption>$(Esc $s.en)</figcaption>
        </figure>
"@)
    }
    $plates = @"
      <div class="mplates">
$($figs -join "`n")
      </div>
"@
  }

  $note = ''
  if ($c.note_en) {
    $note = ('      <p class="mcat__note" data-th="{0}">{1}</p>' -f (Esc $c.note_th), (Esc $c.note_en))
  }

  $cls = 'mcat'
  $badge = ''
  if ($c.seasonal) {
    $cls = 'mcat mseason'
    $badge = '<span class="mbadge" data-th="ตามฤดูกาล">Seasonal</span>'
  }

  $secs.Add(@"
    <section class="$cls" id="$($c.id)">
      <div class="mcat__head">
        <h2 data-th="$(Esc $c.th)">$(Esc $c.en)</h2>
        <span class="th">$(Esc $c.th)</span>
        $badge
      </div>
$note
      <ul class="mlist">
$($rows -join "`n")
      </ul>
$plates
    </section>
"@)
}

# ---------- drinks ----------
$dsecs = New-Object System.Collections.Generic.List[string]
foreach ($d in $data.drinks) {
  $rows = New-Object System.Collections.Generic.List[string]
  $head = ''

  if ($d.twocol) {
    # the column headers are localisable too — colA_th / colB_th in menu.json
    $aTh = $d.colA; if ($d.colA_th) { $aTh = $d.colA_th }
    $bTh = $d.colB; if ($d.colB_th) { $bTh = $d.colB_th }
    $head = @"
      <div class="mcols"><span data-th="$(Esc $aTh)">$(Esc $d.colA)</span><span data-th="$(Esc $bTh)">$(Esc $d.colB)</span></div>
"@
  }

  foreach ($it in $d.items) {
    $thai = ''
    if ($it.th) { $thai = ('<span class="mrow__th">{0}</span>' -f (Esc $it.th)) }

    if ($d.twocol) {
      $a = if ($it.a -and $it.a -gt 0) { Money $it.a } else { '&mdash;' }
      $b = if ($it.b -and $it.b -gt 0) { Money $it.b } else { '&mdash;' }
      $rows.Add(@"
        <li class="mrow mrow--two">
          <span class="mrow__n">$(Esc $it.en)</span>
          $thai
          <span class="mrow__a num">$a</span>
          <span class="mrow__b num">$b</span>
        </li>
"@)
    } else {
      $rows.Add(@"
        <li class="mrow">
          <span class="mrow__n">$(Esc $it.en)</span>
          $thai
          <span class="mrow__p num">$(Money $it.price)&nbsp;฿</span>
        </li>
"@)
    }
  }

  $promo = ''
  if ($d.promo_en) {
    $promo = ('      <p><span class="mpromo" data-th="{0}">{1}</span></p>' -f (Esc $d.promo_th), (Esc $d.promo_en))
  }
  $foot = ''
  if ($d.footnote_en) {
    $foot = ('      <p class="mfoot" data-th="{0}">{1}</p>' -f (Esc $d.footnote_th), (Esc $d.footnote_en))
  }

  $dsecs.Add(@"
    <section class="mcat" id="drink-$($d.id)">
      <div class="mcat__head">
        <h2 data-th="$(Esc $d.th)">$(Esc $d.en)</h2>
        <span class="th">$(Esc $d.th)</span>
      </div>
$promo
$head
      <ul class="mlist">
$($rows -join "`n")
      </ul>
$foot
    </section>
"@)
}

# ---------- splice ----------
$html = Get-Content -Raw -Encoding UTF8 $pageFile

function Splice([string]$doc, [string]$key, [string]$body) {
  $a = "<!--$key`:START-->"
  $b = "<!--$key`:END-->"
  $i = $doc.IndexOf($a)
  $j = $doc.IndexOf($b)
  if ($i -lt 0 -or $j -lt 0) { throw "markers for $key not found" }
  return $doc.Substring(0, $i + $a.Length) + "`n" + $body + "`n" + $doc.Substring($j)
}

$html = Splice $html 'MNAV'   $mnav
$html = Splice $html 'MENU'   ($secs  -join "`n")
$html = Splice $html 'DRINKS' ($dsecs -join "`n")

# UTF-8 without BOM for the HTML itself
$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($pageFile, $html, $enc)

$foodCount  = ($data.categories | ForEach-Object { $_.items.Count } | Measure-Object -Sum).Sum
$drinkCount = ($data.drinks     | ForEach-Object { $_.items.Count } | Measure-Object -Sum).Sum
Write-Output ("menu.html rebuilt — {0} categories / {1} dishes, {2} drink groups / {3} drinks" -f `
  $data.categories.Count, $foodCount, $data.drinks.Count, $drinkCount)
