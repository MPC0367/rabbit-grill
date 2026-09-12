# =============================================================
#  Thai copy pass — replaces the direct-translation strings with
#  copy written to read as Thai first.
#
#  A Thai designer reviewing the site said the Thai "might be too
#  direct instead of storytelling". They were right. The tells
#  were structural, not vocabulary: คือที่ทางของ (a calque of
#  "is a place for"), ถูก+verb passives, ส่วนหนึ่งของความสนุกคือ
#  translated word for word, จึงขอให้สอบถามโดยตรง officialese, and
#  Facebook/Instagram transliterated when Thai brands leave them
#  in Latin.
#
#  Every FACT is unchanged: 490 บาท / 100 กรัม, 11:00–21:00 น.,
#  ปิดวันพุธ, the address, the Google/Wongnai sourcing caveat,
#  39 จาน. Their own lines ตัดทำได้หมด and ทุกเพศทุกวัย are
#  deliberately left alone.
#
#  MUST BE SAVED UTF-8 WITH BOM.
# =============================================================
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$pairs = @(
  # --- hero ---
  @{ old = 'โรงย่างเนื้อกลางเขาใหญ่ ครัวเปิดที่คุณนั่งชิดได้ กลิ่นถ่าน เสียงไฟ และไพร์มริบที่หั่นตามน้ำหนักที่คุณอยากกินจริง ๆ'
     new = 'โรงย่างเนื้อกลางเขาใหญ่ ครัวเปิดโล่ง นั่งชิดได้เลย กลิ่นถ่าน เสียงคุยเต็มร้าน ส่วนไพร์มริบ โต๊ะคุณอยากกินเท่าไหร่ เราหั่นให้เท่านั้น' }

  # --- the idea ---
  @{ old = '<span><span>ของอร่อย</span></span><span><span>เกิดขึ้น</span></span><span><span>รอบกองไฟ</span></span>'
     new = '<span><span>เรื่องดี ๆ</span></span><span><span>มักเริ่มต้น</span></span><span><span>รอบกองไฟ</span></span>' }
  @{ old = 'Rabbit Grill คือที่ทางของอาหารย่าง จานใหญ่ที่แบ่งกันกิน และมื้อที่ไม่ต้องรีบ กลางเขาใหญ่ ไม่ใช่ห้องอาหารเงียบ ๆ แต่เป็นครัวที่คุณได้ยิน ได้กลิ่น และนั่งอยู่ข้าง ๆ'
     new = 'Rabbit Grill เป็นร้านอาหารย่างกลางเขาใหญ่ จานใหญ่ แบ่งกันกิน มื้อที่ไม่ต้องรีบ ที่นี่ไม่ใช่ห้องอาหารเงียบ ๆ แต่เป็นครัวที่ได้ยินเสียง ได้กลิ่น และนั่งอยู่ข้าง ๆ ได้' }

  # --- the room ---
  @{ old = 'นั่งชิดกองไฟ'; new = 'ขยับเข้ามาใกล้ไฟ' }
  @{ old = 'ครัวเปิดอยู่ตรงหน้า โคมความร้อนทองแดง เสียงคุยกัน และคนที่ยืนย่างอยู่ห่างจากโต๊ะคุณไม่กี่ก้าว'
     new = 'ครัวอยู่ตรงหน้า โคมทองแดงให้ความร้อน โต๊ะเต็มทั้งร้าน คนย่างยืนห่างจากโต๊ะคุณไม่กี่ก้าว' }
  @{ old = 'ครัวเปิด ห้องที่มีชีวิต'; new = 'ครัวเปิด ห้องที่มีชีวิต' }

  # --- the counter ---
  @{ old = "หั่นตามที่สั่ง<span class='hand'>ตัดทำได้หมด</span>"
     new = "หั่นตามสั่ง<span class='hand'>ตัดทำได้หมด</span>" }
  @{ old = 'ไพร์มริบที่นี่ไม่ได้ขายเป็นจาน แต่ขายตามน้ำหนัก 490 บาทต่อ 100 กรัม ลากเพื่อหั่น แล้วดูว่าโต๊ะของคุณกำลังสั่งเท่าไหร่จริง ๆ'
     new = 'ไพร์มริบที่นี่ไม่ขายเป็นจาน แต่ขายเป็นน้ำหนัก 100 กรัม 490 บาท ลากมีดไปบนชิ้นเนื้อ แล้วดูว่าโต๊ะคุณสั่งไปเท่าไหร่' }

  # --- from the grill ---
  @{ old = '<span><span>ปล่อยให้ไฟ</span></span><span><span>เป็นคนพูด</span></span>'
     new = '<span><span>ปล่อยให้ไฟ</span></span><span><span>เล่าเอง</span></span>' }

  # --- the house ---
  @{ old = 'ร้านบอกว่าตัวเองคือ “โรงย่างเนื้อที่คัดเฉพาะเนื้อคุณภาพดี ถูกย่างด้วยไฟอย่างพิถีพิถัน” — และคุมครัวโดยเชฟที่ร้านแนะนำว่าเป็นผู้เชี่ยวชาญด้านเนื้อ'
     new = 'ร้านแนะนำตัวเองว่าเป็น “โรงย่างเนื้อที่คัดเฉพาะเนื้อคุณภาพดี ย่างด้วยไฟอย่างพิถีพิถัน” และบอกว่าคนคุมเตาคือเชฟผู้เชี่ยวชาญด้านเนื้อ' }

  # --- Khao Yai ---
  @{ old = '<span><span>ออกจากกรุงเทพฯ</span></span><span><span>เข้าสู่เขาใหญ่</span></span>'
     new = '<span><span>ออกจากกรุงเทพฯ</span></span><span><span>มุ่งหน้าเขาใหญ่</span></span>' }
  @{ old = 'ส่วนหนึ่งของความสนุกคือการได้ขับรถมา ร้านอยู่ที่ 339 หมู่ 11 ตำบลหนองน้ำแดง อำเภอปากช่อง ในพื้นที่เดียวกับ Rosebay Homecooking Cafe'
     new = 'สนุกตั้งแต่ทางมาแล้ว เราอยู่ที่ 339 หมู่ 11 ตำบลหนองน้ำแดง อำเภอปากช่อง พื้นที่เดียวกับ Rosebay Homecooking Cafe' }
  @{ old = 'เสน่ห์อย่างหนึ่งคือการได้ขับรถมา'; new = 'สนุกตั้งแต่ทางมาแล้ว' }

  # --- pets ---
  @{ old = '<span><span>ขับรถมา</span></span><span><span>พร้อมน้องหมา?</span></span>'
     new = '<span><span>พาน้องหมา</span></span><span><span>มาด้วยไหม</span></span>' }
  @{ old = 'โทรหาเราก่อนออกเดินทาง แล้วเราจะบอกได้ว่าวันนั้นเราดูแลคุณได้แค่ไหน'
     new = 'โทรมาก่อนออกเดินทาง เดี๋ยวเราบอกได้ว่าวันนั้นดูแลกันได้แค่ไหน' }
  # the editor flagged a bare "โทรมาถามเร็วที่สุด" as readable two ways;
  # the จะ makes it unambiguously "calling is the fastest way to ask"
  @{ old = 'เรายังไม่ได้ประกาศนโยบายสัตว์เลี้ยงแบบตายตัว จึงขอให้สอบถามโดยตรงดีกว่าเดา — ทางโทรศัพท์เร็วที่สุด'
     new = 'เรายังไม่ได้ประกาศกฎเรื่องสัตว์เลี้ยงแบบตายตัว ถามมาตรง ๆ ดีกว่าเดา โทรมาถามจะเร็วที่สุด' }

  # --- menu ---
  @{ old = 'ราคาทั้งหมดเป็นเงินบาท คัดมาจากเมนูจริงของร้าน จานที่มีเครื่องหมาย ● คือจานที่ร้านถ่ายภาพไว้เอง เมนูอาจเปลี่ยนแปลงได้ กรุณาสอบถามหน้าร้าน'
     new = 'ราคาทั้งหมดเป็นเงินบาท ถอดมาจากเมนูจริงของร้าน จานที่มีจุด ● คือจานที่ร้านถ่ายรูปไว้เอง เมนูมีเปลี่ยนบ้าง เช็กที่หน้าร้านอีกทีได้เลย' }

  # --- the fire page ---
  @{ old = 'ร้านเรียกตัวเองว่า “โรงย่างเนื้อสไตล์ Fire Cooking” หน้านี้รวบรวมสิ่งที่ Rabbit Grill พูดถึงตัวเอง — คำของร้าน ไม่ใช่คำของเรา'
     new = 'Rabbit Grill เรียกตัวเองว่า “โรงย่างเนื้อสไตล์ Fire Cooking” จากนี้คือสิ่งที่ร้านเล่าถึงตัวเอง เป็นคำของร้าน ไม่ใช่คำของเรา' }

  # --- visit ---
  # ชัวร์ is normal spoken Thai but is the one loan a conservative client
  # might flag on an official page, so the plainer close is used
  @{ old = 'วันพุธปิด เป็นประกาศของร้านเอง ส่วนเวลา 11:00–21:00 น. มาจากข้อมูล Google และ Wongnai ไม่ใช่จากร้านโดยตรง โทรเช็กก่อนขับรถไกล'
     new = 'ปิดวันพุธ เป็นประกาศจากร้านเอง ส่วนเวลา 11:00–21:00 น. มาจาก Google กับ Wongnai ไม่ได้มาจากร้านโดยตรง ถ้าขับรถมาไกล โทรเช็กก่อนอีกทีดีกว่า' }
  @{ old = 'ยังไม่มีระบบจองออนไลน์ ติดต่อทางโทรศัพท์ หรือทักมาทางเฟซบุ๊ก / อินสตาแกรม'
     new = 'ยังไม่มีระบบจองออนไลน์ โทรมาได้เลย หรือทักมาทาง Facebook / Instagram' }
  @{ old = 'วันพุธปิด ตามประกาศของร้านเอง เวลาอ้างอิงจากข้อมูล Google และ Wongnai'
     new = 'ปิดวันพุธ เป็นประกาศจากร้านเอง เวลามาจาก Google กับ Wongnai' }
  @{ old = 'ร้านปิดทุกวันพุธ อย่าขับรถมาเสียเที่ยว'; new = 'ปิดทุกวันพุธ อย่าขับรถมาเสียเที่ยว' }

  # --- wayfinding ---
  @{ old = '39 จาน ราคาจริงทุกจาน พร้อมรูปถ่ายของร้านเอง'; new = '39 จาน ราคาครบ รูปครบ' }
  @{ old = 'ถ่าน ครัวเปิด และคนที่ยืนอยู่หน้าเตา';          new = 'ถ่าน ครัวเปิด คนที่ยืนอยู่หน้าเตา' }
  @{ old = 'ร้านอยู่ที่ไหน เปิดกี่โมง และเดินทางมายังไง';    new = 'เราอยู่ตรงไหน เปิดกี่โมง ติดต่อยังไง' }
)

$files = @('index.html', 'menu.html', 'fire.html', 'visit.html')
$hits = 0; $miss = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
  $p = Join-Path $root $f
  $t = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
  $before = $t
  foreach ($pair in $pairs) {
    if ($t.Contains($pair.old)) { $t = $t.Replace($pair.old, $pair.new); $script:hits++ }
  }
  if ($t -ne $before) {
    [System.IO.File]::WriteAllText($p, $t, (New-Object System.Text.UTF8Encoding($false)))
    Write-Output ("{0}: updated" -f $f)
  } else {
    Write-Output ("{0}: no change" -f $f)
  }
}

# report any line that never matched anywhere, so a silent miss cannot hide
$all = ($files | ForEach-Object { [System.IO.File]::ReadAllText((Join-Path $root $_), [System.Text.Encoding]::UTF8) }) -join "`n"
foreach ($pair in $pairs) {
  if (-not $all.Contains($pair.new)) { $miss.Add($pair.new.Substring(0, [Math]::Min(52, $pair.new.Length))) }
}

Write-Output ''
Write-Output ("replacements applied : {0}" -f $hits)
if ($miss.Count) {
  Write-Output ("NOT PRESENT AFTERWARDS ({0}):" -f $miss.Count)
  $miss | ForEach-Object { Write-Output ("  - " + $_) }
} else {
  Write-Output 'every new line is present in the output'
}
