# =============================================================
#  Thai copy inventory — every user-facing Thai string on the
#  site, with the element that carries it and its English twin,
#  so copy can be reviewed in context rather than string by string.
#  Writes _qa/thai-inventory.tsv
#  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$files = @('index.html', 'menu.html', 'fire.html', 'visit.html')

$rows = New-Object System.Collections.Generic.List[string]
$rows.Add("file`trole`tthai`tenglish")

# opening tag carrying data-th, then the element's inner content up to the
# next closing tag of the same name (good enough — these are all leaf-ish)
$re = [regex]'(?s)<(?<tag>\w+)(?<attrs>[^>]*?data-th="(?<th>[^"]*)"[^>]*?)>(?<inner>.*?)</\k<tag>>'

foreach ($f in $files) {
  $t = [System.IO.File]::ReadAllText((Join-Path $root $f), [System.Text.Encoding]::UTF8)
  foreach ($m in $re.Matches($t)) {
    $tag   = $m.Groups['tag'].Value
    $attrs = $m.Groups['attrs'].Value
    $th    = $m.Groups['th'].Value
    $inner = $m.Groups['inner'].Value

    $cls = ''
    $cm = [regex]::Match($attrs, 'class="([^"]*)"')
    if ($cm.Success) { $cls = '.' + ($cm.Groups[1].Value -replace '\s+', '.') }

    # english = inner text, tags stripped, entities loosened, whitespace collapsed
    $en = [regex]::Replace($inner, '<[^>]+>', ' ')
    $en = $en -replace '&nbsp;', ' ' -replace '&mdash;', '—' -replace '&ndash;', '–' `
              -replace '&ldquo;', '"' -replace '&rdquo;', '"' -replace '&rsquo;', "'" `
              -replace '&amp;', '&' -replace '&minus;', '-'
    $en = ($en -replace '\s+', ' ').Trim()

    $thFlat = ($th -replace '\s+', ' ').Trim()
    $rows.Add(("{0}`t{1}{2}`t{3}`t{4}" -f $f, $tag, $cls, $thFlat, $en))
  }
}

$out = Join-Path $root '_qa\thai-inventory.tsv'
[System.IO.File]::WriteAllLines($out, $rows, (New-Object System.Text.UTF8Encoding($true)))

Write-Output ("{0} Thai strings inventoried -> {1}" -f ($rows.Count - 1), $out)
foreach ($f in $files) {
  $n = ($rows | Where-Object { $_ -like ($f + "`t*") }).Count
  Write-Output ("  {0,-12} {1}" -f $f, $n)
}
$uniq = ($rows | Select-Object -Skip 1 | ForEach-Object { ($_ -split "`t")[2] } | Sort-Object -Unique).Count
Write-Output ("  unique Thai strings: {0}" -f $uniq)
