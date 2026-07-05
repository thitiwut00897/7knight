# Design: ปรับ Workflow ตาม Lifecycle (Define → Plan → Build → Verify → Review → Ship)

**วันที่:** 2026-07-05
**สถานะ:** Approved (รอรีวิวเอกสารรอบสุดท้าย)
**แทนที่บางส่วนของ:** [`2026-07-05-claude-code-plugin-migration-design.md`](2026-07-05-claude-code-plugin-migration-design.md) — โครงสร้าง plugin ของเอกสารนั้น (โครง agents/skills/commands/hooks, กลไก marketplace) ยังใช้เหมือนเดิม เอกสารนี้แทนที่แค่ **เนื้อหา** ของ workflow PO/Tester/Senior/Refactor ที่เอกสารนั้นบรรยายไว้

## เป้าหมาย

แทนที่ระบบ Master-Test-Case แบบเดิมที่ PO เป็น orchestrator ด้วย workflow แบบ lifecycle stage (`Define → Plan → Build → Verify → Review → Ship`) โดยอ้างอิงจาก `addyosmani/agent-skills` พร้อมทั้งเก็บส่วนที่เป็นจุดแข็งจริงของ flow เดิมไว้ (การ traceability ของ AC ที่เข้มงวด, การแยกบทบาทเขียน test ออกจากบทบาท implement) แก้ปัญหาการ hardcode React Native ที่เจอตอนย้าย plugin และเพิ่มการเชื่อมต่อ Jira + git ที่ flow เดิมไม่มี

## ทำไมต้องเปลี่ยน

จากการเทียบ `addyosmani/agent-skills` กับ flow ของเราเอง (`po-agent`/`tester-agent`/`senior-full-stack-agent`/`refactor-agent`) พบว่า:

- Define/Plan/Build/Verify ของเรา "หนักกว่า" (มี Master TC ↔ Task TC traceability) แต่ hardcode ไว้เฉพาะ React Native/JS — ใช้กับงาน backend หรือ stack อื่นไม่ได้
- เรา**ไม่มี Review stage เลย** (ไม่มี 5-axis review, ไม่มี security/performance check) และ**ไม่มี Ship stage** (ไม่มี GO/NO-GO decision, ไม่มี rollback plan) — ของ addyosmani มีทั้งสองอย่าง
- การแบ่ง task ของ addyosmani เป็น vertical slice ที่ไม่ผูก stack ส่วนของเรา (`No-API Workflow` แบบ mock แล้วค่อยสวอป) เป็น horizontal และเจาะจง RN

การปรับครั้งนี้เก็บจุดแข็งเรื่อง traceability/แยกบทบาทไว้ ตัดสมมติฐานที่ผูกกับ RN ออก และเติม gap ของ Review/Ship ด้วยการปรับ persona เฉพาะทาง 3 ตัวจาก addyosmani มาใช้

## รายชื่อ Agent (รวม 7 ตัว — ใหม่ 3 ตัว)

| Agent | สถานะ | บทบาท |
|---|---|---|
| `po-agent` | เขียนใหม่ | orchestrate ทั้ง 6 stage ครบวงจรเมื่อเรียกผ่าน `/po-workflow` (ยังเป็น opt-in — ไม่รันอัตโนมัติทุก session) |
| `tester-agent` | เขียนใหม่ | เขียน test ที่ต้อง fail จาก AC ของ task ก่อน implement (RED); รัน regression check ตอน Verify |
| `senior-full-stack-agent` | เขียนใหม่ | Implement ให้ผ่าน test (GREEN) — ทำ backend ก่อนแล้วค่อย frontend ไม่จำกัด stack ตาม `project-blueprint.md`; รายละเอียดที่เจาะจง RN (styled-components, testID) ย้ายไปอยู่ใน skill ที่มีอยู่แล้ว อ้างอิงแบบมีเงื่อนไข |
| `refactor-agent` | เขียนใหม่ | แก้ปัญหาจาก Verify/Review โดยไม่เปลี่ยน behavior — ไม่จำกัดแค่ JS/ESLint อีกต่อไป อ่านเครื่องมือ lint/test จริงของโปรเจกต์จาก `project-blueprint.md` |
| `code-reviewer` | **ใหม่** | Review 5 มุมมอง (correctness, readability, architecture, security, performance) — ปรับจาก `addyosmani/agent-skills` ให้ไม่ผูก stack |
| `security-auditor` | **ใหม่** | ตรวจแบบ OWASP-style (secrets, auth/authz, dependency CVE) — ปรับจาก `addyosmani/agent-skills` |
| `test-engineer` | **ใหม่** | วิเคราะห์ gap ของ test coverage (happy path, edge case, error path, concurrency) — ใช้ตอน fan-out ของ Ship; แยกจากบทบาทเขียน test (RED) ต่อ task ของ `tester-agent` |

## Commands

- `/po-workflow` — เขียนใหม่ให้รันครบ 6 stage ด้านล่างนี้ แทนพฤติกรรมแบบ Master-TC เดิม ยังเป็น opt-in เหมือนเดิม
- `/spec`, `/plan`, `/build` (มี mode `auto`), `/verify`, `/review`, `/ship` — command แยกใหม่ ต่อ 1 stage ใช้แยกจาก `/po-workflow` ได้
- `/init-project-docs` — กลไกไม่เปลี่ยน; template `project-blueprint.md` เพิ่ม 2 field ใหม่ (ดู Template updates ด้านล่าง)

## รายละเอียดแต่ละ Stage

### 1. Define

- ถ้าไม่มีการ์ด Jira มาให้: ถามก่อนว่ามีการ์ดไหม ถ้า user ไม่มีให้ไปต่อจากคำขอที่พูดตรงๆ ได้เลย — ไม่ block งาน
- ถ้ามีการ์ด: อ่านให้ครบทั้งหมด — description, รูปภาพ/attachment, comment **ทุกอัน** — ผ่าน Atlassian MCP หรือเนื้อหาที่ paste มา ส่วนนี้เป็นการ**ขยาย** (ไม่ใช่แทนที่) กฎ **Jira Card Read Gate** ที่ทำงานอยู่แล้วแบบ always-on: กฎเดิม block การแก้โค้ดถ้าอ่านการ์ดที่ลิงก์มาไม่ได้อยู่แล้ว; stage นี้เพิ่มว่าหลังอ่านสำเร็จแล้ว agent ต้อง **สรุปความเข้าใจและให้ user confirm ชัดเจนก่อน** จึงเขียน `SPEC.md` ได้ — ห้ามอ่านจบแล้วเขียนสเปกต่อทันที
- จุดไหนใน Jira ที่คลุมเครือ/ขาดข้อมูล: ต้องถาม user ห้ามเติมด้วยการสมมติเอง
- ส่วนสเปกด้านเทคนิค (tech stack, project structure, code style, testing strategy, boundaries): ดึงค่า baseline จาก `docs/codebase-docs/project-blueprint.md` ก่อน (ถ้าโปรเจกต์รัน `/init-project-docs` แล้ว) ถามเฉพาะส่วนที่ blueprint ไม่ครอบคลุมหรือเจาะจงกับงานนี้
- ผลลัพธ์: `SPEC.md` ที่ root โปรเจกต์

### 2. Plan

- อ่าน `SPEC.md` + `project-blueprint.md` + code ที่เกี่ยวข้อง เข้า plan mode (read-only ไม่แก้ไฟล์)
- แบ่งงานเป็น **vertical slice แบบ fullstack** แต่ละ task เรียงลำดับภายในตัวเองเป็น:
  1. วิเคราะห์ว่า frontend ต้องการข้อมูล/flag อะไรจริงๆ
  2. ทำ backend ให้ตรงตามที่วิเคราะห์ไว้
  3. ทำ frontend + integrate กับ backend จริงที่ทำเสร็จในตัว task เดียวกัน (ไม่ mock ไม่รอ)
  4. จบด้วยให้ user เช็ค UI ว่าตรงกับที่ต้องการไหม
- แต่ละ task มี AC + verification step (ตัด Master-TC-ID mapping ออก — ดูหัวข้อ "สิ่งที่ตัดออกจาก flow เก่า")
- ถ้ามีการ์ด Jira: สร้าง **subtask ใต้การ์ดหลัก** ใน Jira ตาม task ที่วางแผนไว้ 1 subtask ต่อ 1 task
- เสนอ plan ให้ user approve ก่อนไปต่อ
- Save เป็นไฟล์จริง `tasks/plan.md` + `tasks/todo.md` (เพื่อให้ plan อยู่ข้าม session ได้)

### 3. Build

- ก่อนเริ่ม task แรก: สร้าง git branch จาก `develop` ชื่อ `feature/{JIRA-KEY}/{short-name}` (หรือ `feature/{short-name}` ถ้าไม่มีการ์ด Jira) — commit ของทุก task ใน plan นี้เข้า branch เดียวกันนี้ทั้งหมด (1 branch ต่อ 1 plan ไม่ใช่ต่อ task)
- ต่อ task:
  1. `@tester-agent` เขียน test ที่ต้อง fail จาก AC ของ task (RED) — เริ่มจากฝั่ง backend
  2. `@senior-full-stack-agent` implement backend ให้ผ่าน (GREEN)
  3. `@tester-agent` เขียน test สำหรับ frontend/integration
  4. `@senior-full-stack-agent` implement frontend + integrate กับ backend จริง
  5. รัน full test suite (regression) + build/compile check (คำสั่งอ่านจาก `project-blueprint.md` ทั้ง frontend และ backend)
  6. Commit เข้า feature branch พร้อมข้อความอ้างถึงการ์ด Jira
  7. ถ้ามีการ์ด Jira: mark **subtask** ของ task นั้นเป็น done และอัปเดต status ของ**การ์ดหลัก**
  8. Mark task complete
- `/build` (ค่าเริ่มต้น): ทำ 1 task แล้วหยุด
- `/build auto`: ขอ approve ครั้งเดียวสำหรับ plan ทั้งหมด แล้วรันทุก task ต่อเนื่องตาม dependency order — ยังผ่าน RED→GREEN→regression→commit ครบทุก task หยุดเฉพาะเมื่อ test/build แก้ไม่ได้ชัดเจน, spec คลุมเครือ, หรือ task ที่ high-risk/irreversible (auth, migration ทำลายข้อมูล, payment, deploy, secrets)

### 4. Verify

- รันครั้งเดียวหลัง task ทุกตัวใน plan เสร็จแล้ว (ไม่ใช่ต่อ task) — เทียบเท่า Final Regression ของ flow เดิม
- `@tester-agent` รัน full test suite ทั้งโปรเจกต์ (frontend + backend) พร้อม build/compile check เต็มรูปแบบ
- User เช็ค UI ของฟีเจอร์ทั้งหมดเทียบกับ `SPEC.md`/การ์ด Jira ต้นฉบับ
- FAIL → `@refactor-agent` แก้โดยไม่เปลี่ยน behavior → verify ซ้ำ
- PASS → ไป Review

### 5. Review

- `@code-reviewer` รีวิว 5 มุมมอง (correctness, readability, architecture, security, performance) โดยส่งมุม security ให้ `@security-auditor` ตรวจแบบ OWASP-style
- จัด severity ของ finding เป็น Critical / Important / Suggestion พร้อม file:line
- Critical ต้องแก้ก่อน (ส่งกลับ `@senior-full-stack-agent` หรือ `@refactor-agent`) แล้ว review ซ้ำก่อนไปต่อ
- Important/Suggestion แจ้งไว้ในรายงานแต่ไม่ block การไป Ship

### 6. Ship

- Fan-out พร้อมกัน: `@code-reviewer`, `@security-auditor`, `@test-engineer` รันพร้อมกัน แต่ละตัวออกรายงานอิสระ
- รวมผลใน main session: Code Quality, Security (finding Critical/High ด้าน security → กลายเป็น launch blocker), Performance, Accessibility, Infrastructure (env vars, migration, monitoring, feature flags), Documentation
- สรุปเป็น **GO / NO-GO** เดียว พร้อม Blockers, Recommended fixes, Acknowledged risks และ **rollback plan (บังคับ)** (trigger condition, ขั้นตอน, recovery target) ก่อน GO ทุกครั้ง
- Skip fan-out ได้เฉพาะ diff ที่แตะไม่เกิน 2 ไฟล์, ไม่เกิน 50 บรรทัด, และไม่แตะ auth/payment/data/config — นอกนั้น fan-out เสมอ

## การเชื่อมต่อ Jira

- **อ่าน** (Define): ใช้ always-on gate ที่มีอยู่แล้ว เพิ่มให้ต้องสรุปความเข้าใจและ confirm ก่อนเขียนสเปก
- **เขียน** (Plan): สร้าง Jira subtask 1 อันต่อ 1 task ที่วางแผนไว้ ใต้การ์ดหลัก
- **ซิงค์ status** (Build): อัปเดตทั้ง subtask ของ task นั้นและ status ของการ์ดหลักตามความคืบหน้า
- ถ้าไม่มีการ์ดมาตั้งแต่ต้น (ตามที่ Define ตัดสินใจ "ถามแล้วไม่มีก็ไปต่อ") ขั้นตอนเขียน/ซิงค์ทั้งหมดนี้จะไม่เกิดขึ้น — ทุกอย่างอยู่ใน `tasks/plan.md` ในเครื่องเท่านั้น

## Git Branching

- 1 feature branch ต่อ 1 plan สร้างจาก `develop` ก่อน task แรกของ Build ไม่ใช่ 1 branch ต่อ 1 task
- ชื่อ: `feature/{JIRA-KEY}/{short-name}` หรือ `feature/{short-name}` ถ้าไม่มีการ์ด Jira
- Commit ทั้งหมดของ plan นั้นเข้า branch เดียวกัน; ชื่อ branch และ commit message อ้างถึงการ์ด Jira เมื่อมีการ์ดอยู่

## การอัปเดต Template

`docs/templates/project-blueprint.md` (และ `project-blueprint.md` ที่ scaffold ไปแต่ละโปรเจกต์) เพิ่ม 2 field ใหม่ เพื่อไม่ให้ agent hardcode คำสั่งเครื่องมือเอง:

- **Commands** — คำสั่ง lint / test / build จริงของโปรเจกต์นี้ (แยก frontend/backend ถ้าต่างกัน)
- **Git workflow** — ชื่อ base branch (ค่าเริ่มต้นที่สมมติไว้: `develop`) และ convention การตั้งชื่อ branch เผื่อโปรเจกต์ไม่ได้ใช้ default `feature/{JIRA-KEY}/{name}`

## สิ่งที่ตัดออกจาก flow เก่า

- ระบบ Master Test Case ID (`TC-01`, `TC-T01`, template รายงาน PASS/FAIL แบบ emoji) — แทนที่ด้วย AC + verification step ธรรมดาต่อ task
- `No-API Workflow` (mock-contract, ทำ UI ก่อนแล้วค่อยสวอปเป็น API จริงทีหลัง) — แทนที่ด้วย vertical slice แบบทำ backend ก่อนใน Plan/Build เพราะ fullstack agent ไม่ต้องรอการส่ง API แยกต่างหากอีกแล้ว
- Syntax การมอบหมายงานแบบตายตัว (`@tester-agent: เตรียม Task Test Cases สำหรับ Task [N] ...`) — ถูกแทนที่ด้วย flow แบบ stage ด้านบน; agent ยังคุยกันผ่าน `@mention` แต่ไม่ใช้รูปแบบข้อความที่ผูกกับ TC-ID แบบเดิม

## ผลกระทบต่อไฟล์เดิม

- เขียนใหม่: `agents/po-agent.md`, `agents/tester-agent.md`, `agents/senior-full-stack-agent.md`, `agents/refactor-agent.md`
- ใหม่: `agents/code-reviewer.md`, `agents/security-auditor.md`, `agents/test-engineer.md`
- เขียนใหม่: `commands/po-workflow.md`
- ใหม่: `commands/spec.md`, `commands/plan.md`, `commands/build.md`, `commands/verify.md`, `commands/review.md`, `commands/ship.md`
- อัปเดต: `docs/templates/project-blueprint.md` (เพิ่ม field Commands + Git workflow)
- อัปเดต: `hooks/always-on-rules.md` (ส่วน Jira Card Read Gate — เพิ่มข้อบังคับ "สรุปและ confirm ก่อนเขียนสเปก")
- ไม่ต้องแก้: กลไก `commands/init-project-docs.md`, skill ต่างๆ (`ui-guide-template`, `codeing-guide` ฯลฯ คงเดิม ยังเป็น trigger-based)

## Testing / Rollout Plan

1. Dry-run `/spec` → `/plan` → `/build` กับฟีเจอร์เล็กจริง 1 อันที่มีการ์ด Jira จริง ในโปรเจกต์ทดลอง ตรวจ: gate อ่านการ์ด+สรุป-confirm, การสร้าง subtask, การสร้าง branch จาก `develop`, การซิงค์ status subtask/การ์ดต่อ task
2. Dry-run flow เดิม**ไม่มี**การ์ด Jira ยืนยันว่า Define ไปต่อได้โดยไม่ block และไม่มีการเรียก Jira write ใดๆ
3. รัน `/build auto` กับ plan ที่มีหลาย task ยืนยันว่าหยุดที่ task high-risk ที่ตั้งใจใส่ไว้ (เช่น migration) และ resume ถูกต้องหลัง approve
4. รัน `/verify` → `/review` → `/ship` กับฟีเจอร์ที่เสร็จแล้ว ยืนยันว่า fan-out 3 ทางของ Ship รันพร้อมกันจริง (ไม่ใช่ทีละตัว) และออก GO/NO-GO เดียวพร้อม rollback plan
5. ยืนยันว่า `refactor-agent` และ agent ตรวจ/audit ดึงคำสั่ง lint/test จาก `project-blueprint.md` ถูกต้อง ไม่ได้สมมติว่าเป็น ESLint/Jest เสมอ — ทดสอบกับโปรเจกต์ที่ไม่ใช่ JS ถ้ามี

## สิ่งที่ไม่อยู่ในสโคปนี้ชัดเจน

- กลยุทธ์ branch หลายอันต่อ task (มีแค่ 1 branch ต่อ plan เท่านั้น)
- การเปลี่ยน status Jira อัตโนมัติเกินกว่า In Progress / Done (ไม่มี custom workflow state)
- การเปลี่ยนแปลงกลไกการแจกจ่าย plugin เอง (marketplace/plugin.json) — เอกสารเรื่องนี้อยู่ใน migration design doc ฉบับก่อนแล้ว
