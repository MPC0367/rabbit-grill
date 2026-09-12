# =============================================================
#  Harvest the restaurant's own photographs from their public
#  Facebook page.  MUST BE SAVED UTF-8 WITH BOM.
#
#  Recipe (works without login): the page's /photo/?fbid=... URLs
#  render in a real browser even when logged out, and the <img>
#  there is the full 2048px original.  fetch() does NOT work - it
#  returns the login shell - so these URLs were read off the DOM
#  after a real navigation.
#
#  DO NOT EDIT THE URLs.  Every query parameter is part of the
#  signature; dropping _nc_oc / _nc_gid / _nc_ss / oh returns 403.
#  They expire after a few hours - to refresh, reopen each
#  /photo/?fbid=... permalink and copy img.src verbatim.
# =============================================================
$ErrorActionPreference = 'Continue'
$out = 'C:\Users\marky\NOVA\rabbit-grill\img\raw'
New-Item -ItemType Directory -Force -Path $out | Out-Null

$shots = @(
  @{ n='fb-fire-hearth'; d='Steak, fire and hearth - the grill in use'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/782144700_122121519920734122_7094039995724135404_n.jpg?stp=dst-jpg_tt6&cstp=mx1638x2048&ctp=s1638x2048&_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_ohc=evEoRaf20gIQ7kNvwGEXtEh&_nc_oc=AdocxznlQb2tuDgMromX_wx4Fmm5WHZAf9whrPPEWgQND_7yYucNL9EzIcDrbJuKxxo&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=rfxSz0pFnKwp7H2m5GwqOg&_nc_ss=79289&oh=00_AQIfixsch73cZxpuqoZupX9OhRHBFaN3XABHApSOhaS3ew&oe=6A989B76' }

  @{ n='fb-people-1'; d='One or more people at the table'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/774242113_122120583026734122_4703354407681027876_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x2048&ctp=s2048x2048&_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_ohc=FySEUjpM9ZcQ7kNvwEJFpU0&_nc_oc=AdpWH3lIlSlZK7OTjEQ-QtTrgfcSeaXzzULUlo9pQkCzH4RVPezcl8VCzbrwjqq5tAs&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=Mzg5zfkUga5zXJYyYKrsng&_nc_ss=79289&oh=00_AQLHMk5lmwQaD2cIGgUgGbJyIVXisNKpTt_mC1gV0e8lJg&oe=6A98A3A5' }

  @{ n='fb-steak'; d='Steak on the board'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/774033511_122120583014734122_3036583476553223858_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x2048&ctp=s2048x2048&_nc_cat=111&ccb=1-7&_nc_sid=127cfc&_nc_ohc=FeFxRynb0b4Q7kNvwGSEC__&_nc_oc=AdpjxM6Ztjz8_-zCJU-sPhhIrY9oNhNjSOG6eh8ED9DIlZh-H7HQb2L0QRC1QcPFijU&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=lU0aQQ_Br67uzHMRT9Ddqw&_nc_ss=79289&oh=00_AQL7czZx4aYoFjZ0btNsQmZdpuxrC9wbR7h2sDakRKkhtw&oe=6A98A4DC' }

  @{ n='fb-people-2'; d='One or more people'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/772586197_122120583020734122_9073042706066957682_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x2048&ctp=s2048x2048&_nc_cat=106&ccb=1-7&_nc_sid=127cfc&_nc_ohc=T3zDky0m5VoQ7kNvwE6ZcWB&_nc_oc=AdqAgEnG1trYL1G4GZFCpB8U6S9Jp8P37V7_Z6ZMQu74makf_0N7DWkstEsDXcsThj0&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=DcJqyI7DW_Wovi-a_p85Aw&_nc_ss=79289&oh=00_AQLw5t-Uz31hO-uxfgKbMfbbrVhn4l84SNp1XKWG-WzB-g&oe=6A98C8B2' }

  @{ n='fb-rawcare'; d='Raw cuts - "Every great dish begins with raw care"'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/771757190_122120387690734122_4081172603532561898_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x2048&ctp=s2048x2048&_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_ohc=rPyXd1MUjgAQ7kNvwFkGGoO&_nc_oc=AdqnoBvrC-VCyLcWI9gUqwU6f85j1izpY7F9xLHFuLyS13oiWC592dA676ucNMY9PI4&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=Qf3RN8EFAZz_svRk70dEiw&_nc_ss=79289&oh=00_AQJTa3Z9vWUqh1wWauLeo674A0GbZQkcS1D-O12VJoY5BA&oe=6A98B990' }

  @{ n='fb-closed-wed'; d='THEIR OWN NOTICE: closed every Wednesday'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/771909289_122120344286734122_5513755625756409610_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x1638&ctp=s2048x1638&_nc_cat=100&ccb=1-7&_nc_sid=833d8c&_nc_ohc=Dg4Us5N_b4YQ7kNvwGPWxr2&_nc_oc=AdqU9a9l7elAKLH4zZIYFINwakijN-zyFr57uIN6x1lBi8SgLMs4xaL75W2Io5wlPF8&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=E4GyRYl_FSdR0nCfnSfP8A&_nc_ss=79289&oh=00_AQI0BC1f7Q1sBHF88E4g33kjOHijDVb1XVoLjDBjPknPCw&oe=6A98CCBE' }

  @{ n='fb-steak-fire'; d='Steak and fire'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/764817900_122119437980734122_7922922557373218227_n.jpg?stp=dst-jpg_tt6&cstp=mx2048x2048&ctp=s2048x2048&_nc_cat=110&ccb=1-7&_nc_sid=127cfc&_nc_ohc=_G-EzDfL3FgQ7kNvwGlZgud&_nc_oc=Adqzl-IsRbznPeOgKqBhbrh09UpkBchVXd9uHbw9h7Z_fWb4P5OxWyz7q5jqcykSqvE&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=sV1ER5b2b1rF7FGsYOj8-A&_nc_ss=79289&oh=00_AQLlmX4CmJ0vJWK11LczgdVEECFbPBYjCdYYgBFUD0xvNQ&oe=6A98C267' }

  @{ n='fb-charcoal'; d='"Crafted by Fire, Elevated by Charcoal"'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/763831740_122119437956734122_2504262682220793293_n.jpg?stp=dst-jpg_tt6&cstp=mx1989x2048&ctp=s1989x2048&_nc_cat=103&ccb=1-7&_nc_sid=127cfc&_nc_ohc=DFD87VybLWkQ7kNvwHvmbKl&_nc_oc=AdrEIPe3tr0HZXL7wG-PY84q9lC4Z2wzyco1uEUFQYlwk8uoFr5jQycXyEuBljokgYA&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=j3OGHBE-xIHTwOLgbVMGLQ&_nc_ss=79289&oh=00_AQKsSR4tBnj4wFGU0jpN3UOcauHCroJP0MR7MKdVmP8I3A&oe=6A98BB7E' }

  @{ n='fb-cover'; d='Page cover banner (3283x1276)'
     u='https://scontent.fnak3-1.fna.fbcdn.net/v/t39.30808-6/688800057_122107039028734122_820723085860697032_n.jpg?stp=dst-jpg_tt6&cstp=mx3283x1276&ctp=s3283x1276&_nc_cat=100&ccb=1-7&_nc_sid=cc71e4&_nc_ohc=9fkEryLutdUQ7kNvwHQ7Dq1&_nc_oc=Adp84MRmubwmbw-IvMh-86WFU2Vv-IRV-bhrplSd8mUHK-PaQ__s60yOLDw8-xLLALE&_nc_zt=23&_nc_ht=scontent.fnak3-1.fna&_nc_gid=7Zg8ckPPkq2kNkPZx_0qSA&_nc_ss=79289&oh=00_AQLBPIvFV8eDZxZLujAJSACWqHnfcuhDeLc_8taIbEyllw&oe=6A98AAB7' }
)

$hdr = @{
  'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36'
  'Accept'     = 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8'
  'Referer'    = 'https://www.facebook.com/'
}

foreach ($s in $shots) {
  $p = Join-Path $out ($s.n + '.jpg')
  try {
    Invoke-WebRequest -Uri $s.u -OutFile $p -Headers $hdr -UseBasicParsing -TimeoutSec 60
    $len = (Get-Item $p).Length
    if ($len -lt 5000) {
      Write-Output ('{0,-16} TOO SMALL {1} bytes' -f $s.n, $len)
    } else {
      Write-Output ('{0,-16} {1,7:n0} KB   {2}' -f $s.n, ($len/1KB), $s.d)
    }
  } catch {
    Write-Output ('{0,-16} FAILED   {1}' -f $s.n, $_.Exception.Message)
  }
}
