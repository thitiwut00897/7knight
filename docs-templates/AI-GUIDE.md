# AI Guide

> จุดเข้าหลักสำหรับ AI Agent ในโปรเจกต์นี้ — อัปเดตหลัง Phase 2 (HTML docs) เสร็จ  
> โฟลเดอร์ `docs/codebase-docs/` ควรเหลือเฉพาะ `.html`, `styles.css`, และไฟล์นี้

## ลำดับการอ่าน (เมื่อเริ่มงานใหม่)

1. **ไฟล์นี้** — เลือกแหล่งข้อมูลตามประเภทงาน (ตารางด้านล่าง)
2. **`docs/codebase-docs/index.html`** → เปิดใน browser หรืออ่าน source ตาม sidebar
3. **`.cursor/.cursorrules`** — กฎบังคับ + ภาพรวม stack (sync กับเนื้อหาใน HTML)
4. **`.cursor/rules/architecture.mdc`** — รายละเอียดเชิงลึก (routes, reducers, หน้าจอ) เมื่อต้องการความละเอียดสูง
5. **`.cursor/skills/`** — ui-guide, logic-guide, clean-code ตามประเภทงาน

## แผนที่ค้นหา — ต้องการหาอะไร อ่านที่ไหน

| ต้องการหา | อ่านก่อน | ลึกเพิ่ม |
|-----------|----------|----------|
| ภาพรวมโปรเจกต์ / stack | `index.html`, `overview.html` | `.cursor/.cursorrules` |
| โครงสร้างโฟลเดอร์ / data flow | `architecture.html` | `architecture.mdc` |
| Navigation / routes | `navigation.html` | `architecture.mdc` § routes |
| Redux / state | `state-management.html` | `src/store/` + `architecture.mdc` |
| API / services | `api-layer.html` | `src/apiService/`, `apiController/` |
| UI components แชร์ | `components.html` | `src/components/` |
| Theme / styling | `theme-styling.html` | `src/assets/` (theme) |
| Helpers / utils | `utilities.html` | `src/helpers/`, `src/utils/` |
| ฟีเจอร์เฉพาะ | `features/<slug>.html` | `src/containers/<name>/` |
| กฎ implement / convention | `.cursor/.cursorrules` | `.cursor/skills/` |
| งาน UI mockup | `.cursor/skills/ui-guide.md` | รูป design จาก PO |
| งาน API / hook / Redux | `.cursor/skills/logic-guide.md` | Postman MCP (ถ้ามี collection) |

## โฟลเดอร์โค้ดสำคัญ

| Path | ใช้เมื่อ |
|------|----------|
| `src/containers/` | หน้าจอ / ฟีเจอร์ |
| `src/components/` | UI ใช้ซ้ำ |
| `src/routes/` | navigation stacks |
| `src/store/` | Redux actions / reducers |
| `src/apiService/` | axios + apiController |
| `docs/work-summary/` | สรุปงานยาว (ตาม work-summary rule) |

## Sync กับ rules / skills

เมื่อแก้ **โครงสร้างหรือ behavior** ที่กระทบ docs:

1. อัปเดตหน้า HTML ที่เกี่ยวข้อง + วันที่ใน `index.html`
2. ถ้าเปลี่ยน convention ระดับโปรเจกต์ → อัปเดต `.cursor/.cursorrules` และ/หรือ `architecture.mdc` ให้สอดคล้อง
3. อัปเดตตารางใน **ไฟล์นี้** ถ้าเพิ่มหน้า HTML หรือ path ใหม่

ดู rule: `.cursor/rules/sync-codebase-docs.mdc`

## หมายเหตุ

- ไม่มี `project-blueprint.md` ในโฟลเดอร์นี้หลัง Phase 2 — ใช้ HTML + ไฟล์นี้แทน
- ไฟล์ setup (`prompts/`, `.scan/`, `_template/`, `HOW-TO-*`) ถูกลบหลังสร้าง HTML ครบแล้ว
