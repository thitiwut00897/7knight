---
description: Define stage — อ่านการ์ด Jira (ถ้ามี) ให้ครบ สรุปและ confirm ความเข้าใจ แล้วเขียน SPEC.md
argument-hint: [ลิงก์/key การ์ด Jira หรือคำอธิบายงานถ้าไม่มีการ์ด]
---

เริ่ม Define stage สำหรับ: $ARGUMENTS

ทำตามลำดับนี้ ห้ามข้ามขั้นตอนไหน:

1. **เช็คว่ามีการ์ด Jira ไหม**
   - ถ้า `$ARGUMENTS` ไม่ได้ระบุการ์ด/ลิงก์ Jira มา → **ถาม user ก่อน** ว่ามีการ์ด Jira/issue สำหรับงานนี้ไหม
   - ถ้า user บอกว่าไม่มี → ไปข้อ 3 ได้เลย (ใช้คำอธิบายจาก user ตรงๆ)
   - ถ้ามีการ์ด → ไปข้อ 2

2. **อ่านการ์ดให้ครบ** (บังคับตาม Jira Card Read Gate ใน always-on rules)
   - อ่าน description, รูปภาพ/attachment, comment **ทุกอัน** ผ่าน Atlassian MCP หรือเนื้อหาที่ user paste มา
   - ถ้าอ่านไม่ได้ (MCP error, ไม่มีสิทธิ์, ข้อมูลไม่ครบ) → หยุด แจ้ง user ว่าติดตรงไหน ห้ามเดาต่อ

3. **สรุปความเข้าใจ**
   - สรุป requirement, AC, edge case ที่เห็น (จาก description/comment/รูป ถ้ามีการ์ด หรือจากคำอธิบายของ user ถ้าไม่มีการ์ด)
   - จุดไหนคลุมเครือหรือขาดรายละเอียด → **ถาม user ตรงจุดนั้น** ห้ามเดาเติมเอง
   - เสนอสรุปให้ user **confirm ชัดเจน** ก่อนไปข้อ 4 — ถ้า user แก้ไข ให้ปรับสรุปแล้ว confirm ซ้ำ

4. **ดึง baseline ด้านเทคนิค**
   - อ่าน `docs/codebase-docs/project-blueprint.md` (ถ้ามี — ถ้าไม่มีแจ้ง user ว่าแนะนำให้รัน `/init-project-docs` ก่อน แต่ไม่บังคับ)
   - ใช้ค่าจาก blueprint เป็น baseline สำหรับ tech stack, code style, testing strategy, boundaries
   - ถามเฉพาะส่วนที่ blueprint ไม่ครอบคลุมหรือเจาะจงกับงานนี้เท่านั้น

5. **เขียน `SPEC.md`** ที่ root โปรเจกต์ ครอบคลุม: objective, AC (จากสรุปที่ user confirm แล้ว), tech stack + code style + testing strategy (จาก blueprint), boundaries (สิ่งที่ทำได้เสมอ / ต้องถามก่อน / ห้ามทำเด็ดขาด)

6. แสดงสรุป `SPEC.md` ให้ user ยืนยันอีกครั้งก่อนไปยัง `/plan`
