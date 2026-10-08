---
description: Verify stage — full regression gate หลัง Build ครบทุก task ในแผน (ไม่ใช่ต่อ task) + เช็ค UI ของฟีเจอร์ทั้งหมดด้วย user confirm เอง
model: sonnet
---

เริ่ม Verify stage:

1. หา folder ฟีเจอร์ `tasks/{feature}/` (จาก `$ARGUMENTS` — ถ้ามีหลาย folder และไม่แน่ใจ ให้ถาม user) แล้วตรวจว่าทุก task ใน `tasks/{feature}/todo.md` ถูก mark complete แล้ว — ถ้ายังไม่ครบ แจ้ง user ว่ายังมี task ที่ยังไม่เสร็จ ถามว่าจะ verify เท่าที่มีอยู่หรือรอให้ Build ครบก่อน

2. **ถามหา test case จาก QA** — ถาม user ว่ามี test case ที่ QA เตรียมไว้ไหม (ไฟล์/เอกสาร/ข้อความ) ถ้ามี ให้รับมาและนำไปรวมเป็นส่วนหนึ่งของชุด test ที่จะรันในข้อ 3 ด้วย (นอกเหนือจาก test ที่ `@tester-agent` เขียนไว้ตั้งแต่ `/build`) ถ้าไม่มีก็ข้ามข้อนี้ไปตามปกติ

3. `@tester-agent` รัน:
   - Lint เต็มโปรเจกต์ (frontend + backend ตาม `project-blueprint.md` § 6)
   - Test suite เต็มชุด (ไม่ใช่แค่ไฟล์ที่แก้) — รวม test case จาก QA (ถ้ามีจากข้อ 2) เข้าไปในรอบนี้ด้วย
   - Build/compile check เต็มชุด

4. เช็ค UI ของฟีเจอร์ทั้งหมด (ไม่ใช่แค่ทีละ task) เทียบกับ `tasks/{feature}/SPEC.md` และการ์ด Jira ต้นฉบับ (ถ้ามี) — ให้ user เช็ค UI เองทั้งหมด

5. **FAIL** (lint/test/build หรือ test case QA ไม่ผ่าน หรือ user เห็นว่า UI ไม่ตรง): **ห้ามส่งไปแก้เอง** — สรุปปัญหาที่เจอทั้งหมดให้ user ดูก่อน (อะไร fail, file:line/error message) แล้วรอ user confirm ว่าจะให้แก้ไหม
   - user สั่งให้แก้ → ส่งให้ `@senior-full-stack-agent` แก้ตาม report → รัน `/verify` ซ้ำ — **ห้าม commit** ระหว่างวนรอบนี้ ไม่ว่าจะวนกี่รอบ (fail ซ้ำแล้วซ้ำอีกก็ยังไม่ commit)
   - user ยังไม่สั่งแก้ (เช่นขอดูเพิ่ม/พิจารณาก่อน) → หยุดรอ ห้ามส่งไปแก้เอง

6. **PASS** (lint/test/build ผ่าน + user confirm UI แล้ว): **commit ครั้งเดียว** รวมทุกการแก้ที่สะสมมาจากข้อ 5 (ถ้ามี) เข้า feature branch เดิม แล้วแจ้ง user ว่าพร้อมไป `/review` แล้ว
