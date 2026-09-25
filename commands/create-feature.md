---
description: เริ่มเวิร์กโฟลว์เต็ม 5 stage (Define → Plan → Build → Verify → Review) ผ่าน @po-agent สำหรับงาน/ฟีเจอร์นี้ — opt-in
argument-hint: [ลิงก์/key การ์ด Jira หรือคำอธิบายงานถ้าไม่มีการ์ด]
---

เริ่มเวิร์กโฟลว์ opt-in แบบเต็มรูปแบบสำหรับงานนี้: $ARGUMENTS

`/create-feature` ใช้สำหรับ **สร้าง feature ใหม่เท่านั้น** ไม่ใช่ช่องทางแก้บั๊ก (แก้บั๊กใช้ Bug Fast Path ใน `/spec` โดยตรงแทน ไม่ต้องผ่าน `/create-feature`)

1. Invoke agent `po-agent` ให้เป็น orchestrator ของงานนี้ตั้งแต่ต้นจนจบ
2. `@po-agent` orchestrate ตามลำดับที่ระบุไว้ใน `agents/po-agent.md`: `/spec` → `/plan` → `/build` → `/verify` → `/review`
3. รอ user confirm/approve ตามจุดที่แต่ละ stage กำหนด — ห้ามข้ามไปเองโดยไม่ได้รับการยืนยัน

### ที่ stage `/spec` — ปรับ 2 ข้อจาก `/spec` ปกติ

1. **ห้ามเข้า "Bug Fast Path"** (ข้อ 3 ของ `/spec`) แม้การ์ดจะเป็นประเภท Bug ก็ตาม — `/create-feature` ถือว่าทุกงานเป็นการสร้าง feature เสมอ ให้ทำข้อ 4-7 ของ `/spec` เต็มรูปแบบ (ถ้างานนี้เป็นบั๊กจริงๆ แนะนำให้ user เรียก `/spec` ตรงๆ แทน เพื่อเข้า Bug Fast Path ได้)
2. **`SPEC.md` ต้องมีหัวข้อ diagram เพิ่ม 2 อัน** (เป็น mermaid diagram) ต่อจากหัวข้อปกติ:
   - **Flow diagram** — flowchart ของขั้นตอน/การตัดสินใจหลักในฟีเจอร์นี้
   - **Database diagram** — erDiagram ของ table/entity ที่เกี่ยวข้องและความสัมพันธ์ระหว่างกัน (ถ้าฟีเจอร์นี้ไม่แตะ database เลย ให้ข้ามหัวข้อนี้และระบุเหตุผลสั้นๆ แทน)

**หมายเหตุ:** คำสั่งนี้เป็นจุดเริ่มแบบ opt-in เท่านั้น — งานเล็กๆ ที่ไม่ต้องการผ่าน lifecycle เต็มรูปแบบ ไม่จำเป็นต้องใช้คำสั่งนี้ คุยงานตรงๆ หรือ mention agent ที่เกี่ยวข้อง หรือเรียก `/spec` `/plan` `/build` `/verify` `/review` แยกทีละ stage เองได้
