# my-cursor-rules

แพ็ก Cursor (`rules`, `skills`, `agents`) + สคริปต์ติดตั้งในโปรเจกต์อื่น

**Repo:** https://github.com/thitiwut00897/my-cursor-rules (Public)

---

## คำสั่งเดียว (copy ใช้ได้เลย)

**สำคัญ:** ต้อง `cd` เข้าโปรเจกต์ก่อน และต้องมี `bash -s --` ก่อน `--create` (มิฉะนั้นสคริปต์ไม่ได้รับ arguments)

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/thitiwut00897/my-cursor-rules/main/scripts/setup-cursor.sh | bash -s -- --create --project .
```

ถ้าสำเร็จจะเห็นข้อความประมาณ `my-cursor-rules setup`, `[1/4] ... [4/4]`, `✅ เสร็จแล้ว`

### `--create` — ติดตั้ง `.cursor` + สร้าง `docs/codebase-docs` ใหม่

```bash
curl -fsSL https://raw.githubusercontent.com/thitiwut00897/my-cursor-rules/main/scripts/setup-cursor.sh | bash -s -- --create --project .
```

### `--update` — อัปเดต `.cursor` อย่างเดียว (ไม่แตะ docs)

```bash
curl -fsSL https://raw.githubusercontent.com/thitiwut00897/my-cursor-rules/main/scripts/setup-cursor.sh | bash -s -- --update --project .
```

### ทางเลือก (clone ครั้งเดียว)

```bash
git clone https://github.com/thitiwut00897/my-cursor-rules.git ~/Github-Work/my-cursor-rules
cd /path/to/your-project
bash ~/Github-Work/my-cursor-rules/scripts/setup-cursor.sh --local --create --project .
```

---

## ต้องมีบนเครื่อง

| เครื่องมือ | ใช้เมื่อ |
|-----------|----------|
| `git` | ดึง config (แนะนำ) |
| `curl` + `unzip` | สำรองถ้าไม่มี git |
| `node` | `--create` (generate docs) |

---

## สคริปต์ทำอะไร

1. ดึง repo `my-cursor-rules` (git clone หรือ zip)
2. copy `.cursor/` เข้าโปรเจกต์
3. `--create` → **สแกนโปรเจกต์** + สร้างไฟล์คู่มือ — **ไม่รัน Cursor ให้** user **copy prompt เอง**

### หลัง `--create` (ทำมือใน Cursor)

| ไฟล์ | ทำอะไร |
|------|--------|
| `HOW-TO-GENERATE-DOCS.md` | คู่มือขั้นตอน + prompt สำรอง |
| `_template/HTML-TEMPLATE-GUIDE.md` | กฎโครงสร้าง HTML (Agent อ่านก่อนสร้างหน้า) |
| `_template/page-root.html` | แม่แบบหน้า root |
| `_template/page-feature.html` | แม่แบบหน้า `features/` |
| `prompts/phase1-copy.txt` | Copy → Agent → สารบัญ |
| `prompts/phase2-copy.txt` | Copy → Agent → สร้าง HTML ตาม template |
| `.scan/PROJECT-CONTEXT.md` | ข้อมูลสแกน |
| `styles.css` | CSS กลาง (ห้ามเปลี่ยน class หลัก) |

**Scaffold เก่า** (1 container = 1 html): `node scripts/generate-codebase-docs.mjs . --scaffold --force`

---

## แก้ปัญหา

| อาการ | วิธีแก้ |
|-------|---------|
| **วางคำสั่งแล้วไม่มีอะไรเกิดขึ้น** | มักลืม `bash -s --` — ใช้ `curl ... \| bash -s -- --create --project .` ไม่ใช่ `\| bash` อย่างเดียว |
| ขึ้น `ไม่พบ --create` | เหมือนด้านบน — ต้องมี `bash -s --` |
| ไม่เห็น log | อัปเดตสคริปต์ล่าสุดจาก `main` (log ออกทั้ง stdout) |
| `Downloaded repo missing .cursor` | ใช้สคริปต์ล่าสุดจาก `main` |
| `curl 404` | ตรวจว่า repo Public |
| ไม่มี docs / ไม่มี `HOW-TO-GENERATE-DOCS.md` | ติดตั้ง Node 18+ แล้วรัน `--create` อีกครั้ง |
| มี `.cursor` แต่ไม่มี HTML ครบ | **ปกติ** — เปิด `HOW-TO-GENERATE-DOCS.md` แล้ว copy `prompts/phase1-copy.txt` ไปวางใน Agent |

---

## โครงสร้าง repo

```text
my-cursor-rules/
├── .cursor/
├── docs-templates/
│   └── codebase-docs/
│       ├── styles.css
│       └── _template/   # HTML แม่แบบ + HTML-TEMPLATE-GUIDE.md
└── scripts/
    ├── setup-cursor.sh
    ├── prompts/phase1-copy.txt, phase2-copy.txt
    └── generate-codebase-docs.mjs
```
