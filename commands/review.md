---
description: Review stage (สุดท้ายของ lifecycle) — 6-axis code review + security audit บน diff ปัจจุบัน (Critical ต้องแก้ก่อนถือว่าจบงาน)
model: opus
---

เริ่ม Review stage (ต้องผ่าน `/verify` มาแล้ว):

1. `@code-reviewer` รีวิว diff/commit ทั้งหมดของ feature branch นี้ (เทียบกับ base branch) ครบ 6 มุมมอง — correctness, readability, architecture, security (pass แรกแบบผิวๆ), performance, simplicity (ponytail)

2. `@security-auditor` รัน OWASP-style audit บน diff เดียวกัน (แนวลึกกว่า pass แรกของ code-reviewer)

3. รวมผลลัพธ์ทั้งสองเป็นรายงานเดียว จัด severity: Critical / Important / Suggestion พร้อม file:line

4. **Critical finding**: ส่งกลับ `@senior-full-stack-agent` ให้แก้ → รัน `/review` ซ้ำ — **ห้าม commit** ระหว่างวนรอบนี้ ไม่ว่าจะวนกี่รอบ จนกว่าจะไม่มี Critical เหลือ

5. **Important/Suggestion**: แสดงในรายงาน ไม่ block — แจ้ง user ว่ามีแต่ไม่บังคับแก้

6. เมื่อไม่มี Critical เหลือ: **commit ครั้งเดียว** รวมทุกการแก้ที่สะสมมาจากข้อ 4 (ถ้ามี) เข้า feature branch เดิม แล้วแจ้ง user ว่า lifecycle เสร็จสมบูรณ์แล้ว

7. **ถาม user ว่าต้องการเปิด PR เข้า base branch เลยไหม** (base branch ตาม `project-blueprint.md` § 7 — ปกติคือ `develop`)
   - user ตอบไม่ / ยังไม่เปิด → จบ workflow ไว้แค่นี้ ห้ามเปิด PR เอง
   - user ตอบให้เปิด → เปิด PR จาก feature branch นี้เข้า base branch โดย **PR description ต้องมี**:
     - สรุปสิ่งที่ทำในฟีเจอร์นี้ (อ้างจาก `tasks/{feature}/SPEC.md` และ task ที่ทำใน `tasks/{feature}/plan.md`)
     - สรุปผล test จาก test case แบบย่อ (ผ่าน/ไม่ผ่านกี่รายการ อ้างจากผลรอบล่าสุดของ `/verify` รวมถึง test case จาก QA ถ้ามี)
