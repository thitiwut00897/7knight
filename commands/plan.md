---
description: Plan stage — แบ่ง SPEC.md เป็น vertical-slice task แบบ fullstack (backend ก่อน, frontend ทีหลัง) แล้ว save เป็น tasks/plan.md + tasks/todo.md
---

เริ่ม Plan stage:

1. อ่าน `SPEC.md` + `docs/codebase-docs/project-blueprint.md` + code ที่เกี่ยวข้องในโปรเจกต์ — **ห้ามแก้ไฟล์ใดๆ ใน stage นี้** (read-only planning)

2. แบ่งงานเป็น task แบบ **vertical slice fullstack** แต่ละ task เรียงลำดับภายในตัวเองเป็น:
   - วิเคราะห์ว่า frontend ของ task นี้ต้องการข้อมูล/flag อะไรจาก backend
   - ทำ backend ให้ตรงตามที่วิเคราะห์ไว้
   - ทำ frontend + integrate กับ backend จริงที่ทำเสร็จในตัว task เดียวกัน (ไม่ mock ไม่รอ)
   - จบด้วยให้ user เช็ค UI ปิด task
   - (ถ้า task เป็น backend-only หรือ frontend-only ให้ข้ามขั้นที่ไม่เกี่ยวข้อง)

3. แต่ละ task ต้องมี: ชื่อ task, AC ที่ต้องผ่าน (map กลับ `SPEC.md`), verification step ที่วัดผลได้, dependency (ถ้ามี) — **ไม่ใช้ ID แบบ TC-01/TC-T01**

4. **ถ้ามีการ์ด Jira** (จาก `/spec` ที่ผ่านมา): สร้าง Jira subtask 1 อันต่อ 1 task ใต้การ์ดหลัก ชื่อ subtask ตรงกับชื่อ task ในแผน

5. แสดง plan ทั้งหมดให้ user ดู — รอ approve ก่อนไปต่อ

6. เมื่อ approve แล้ว save:
   - `tasks/plan.md` — รายละเอียดเต็มของแต่ละ task (AC, verification step, dependency, Jira subtask key ถ้ามี)
   - `tasks/todo.md` — checklist สั้นๆ ของ task ทั้งหมด (สำหรับ track ความคืบหน้าข้าม session)

7. แจ้ง user ว่าพร้อมไป `/build` แล้ว
