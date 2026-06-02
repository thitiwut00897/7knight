# my-cursor-rules

กฎ Cursor (`.mdc`) แบบ **generic** — ใช้ร่วมทุกโปรเจกต์ผ่าน **Remote Rule (GitHub)** ใน Cursor

## ไฟล์ใน repo นี้

| ไฟล์ | alwaysApply | หมายเหตุ |
|------|-------------|----------|
| `jira-card-read-gate.mdc` | ใช่ | ห้ามแก้ code ถ้าอ่าน Jira ไม่ได้ |
| `no-bulk-delete-working-files.mdc` | ใช่ | ห้าม bulk delete ไฟล์งาน |
| `simple-code.mdc` | ใช่ | KISS / แก้น้อยที่สุด |
| `sonarqube-mcp-connection.mdc` | ใช่ | Gate เมื่อ Sonar MCP ไม่ต่อ |
| `sonarqube_mcp_instructions.mdc` | ใช่ | วิธีใช้ Sonar MCP |
| `sonar-js-high-signal.mdc` | ไม่ (globs `src/**/*.{js,jsx}`) | SonarJS-style สำหรับ JS |
| `work-summary-output-format.mdc` | ใช่ | สรุปยาว → `docs/work-summary/` |

กฎที่ **ไม่อยู่ใน repo นี้** (เก็บในโปรเจกต์เฉพาะ เช่น Well Life): `architecture.mdc`, `po-agent.mdc`, `sync-codebase-docs.mdc`, ฯลฯ

---

## 1) Push repo ขึ้น GitHub (ครั้งแรก)

```bash
cd ~/Github-Work/my-cursor-rules
git init
git add .
git commit -m "Add shared Cursor rules for Remote Rule import"
# สร้าง repo บน GitHub ชื่อ my-cursor-rules (private แนะนำ) แล้ว:
git remote add origin git@github.com:<YOUR_USER>/my-cursor-rules.git
git branch -M main
git push -u origin main
```

---

## 2) Import ในแต่ละโปรเจกต์ (Cursor)

1. เปิดโปรเจกต์ใน Cursor
2. **Cursor Settings → Rules, Commands**
3. กด **+ Add Rule** ข้าง **Project Rules** → เลือก **Remote Rule (Github)**
4. วาง URL repo เช่น `https://github.com/<YOUR_USER>/my-cursor-rules`
5. Cursor จะดึง `.mdc` ไปที่ `.cursor/rules/imported/` (หรือ `imported/<subdir>/` ถ้ามีโฟลเดอร์ย่อย)

ตรวจใน Settings ว่า rules จาก remote แสดงสถานะ **enabled**

---

## 3) ลบ rule ซ้ำในโปรเจกต์ (สำคัญ)

หลัง import สำเร็จ ให้ **ลบไฟล์เดิม** ที่ root `.cursor/rules/` ที่ชื่อซ้ำกับ repo กลาง — ไม่งั้น Agent จะได้กฎเดียวกัน **สองชุด**

ตัวอย่างใน Well Life — ลบได้หลัง remote พร้อม:

- `jira-card-read-gate.mdc`
- `no-bulk-delete-working-files.mdc`
- `simple-code.mdc`
- `sonar-js-high-signal.mdc`
- `sonarqube-mcp-connection.mdc`
- `sonarqube_mcp_instructions.mdc`
- `work-summary-output-format.mdc`

**เก็บไว้ในโปรเจกต์:** `architecture.mdc`, `po-agent.mdc`, `tester-agent.mdc`, `refactor-agent.mdc`, `sync-codebase-docs.mdc`, ฯลฯ

---

## 4) อัปเดตกฎกลาง

แก้ไฟล์ใน repo `my-cursor-rules` → commit → push

ใน Cursor: เปิด Settings → Rules → remote rule → **Sync / Refresh** (ถ้ามี) หรือ re-import ตาม UI เวอร์ชันปัจจุบัน

---

## 5) Bootstrap โปรเจกต์ใหม่ (ทางเลือก)

Remote Rule ต้องตั้งใน UI ครั้งต่อโปรเจกต์ — ใช้ checklist ใน Settings  
หรือ copy โฟลเดอร์ `.cursor/rules/` เฉพาะโปรเจกต์จาก template repo ของทีม

---

## โครงสร้าง repo

```text
my-cursor-rules/
├── README.md
├── jira-card-read-gate.mdc
├── no-bulk-delete-working-files.mdc
├── simple-code.mdc
├── sonar-js-high-signal.mdc
├── sonarqube-mcp-connection.mdc
├── sonarqube_mcp_instructions.mdc
└── work-summary-output-format.mdc
```

ไฟล์ `.mdc` วางที่ **root** ของ repo เพื่อให้ Cursor scan ได้ตรงๆ
