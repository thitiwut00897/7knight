# HTML Documentation Template Guide

> ใช้เมื่อสร้าง/อัปเดตไฟล์ใน `docs/codebase-docs/`  
> **ห้ามอ้างอิงโปรเจกต์อื่น** — อ่านไฟล์ในโฟลเดอร์นี้และ `.html` ที่มีอยู่แล้วใน `docs/codebase-docs/`

---

## ไฟล์ template

| ไฟล์ | ใช้เมื่อ |
|------|----------|
| `page-root.html` | หน้าใน root: `index.html`, `overview.html`, `architecture.html`, … |
| `page-feature.html` | หน้าใน `features/<slug>.html` |
| `../styles.css` | CSS กลาง — **ห้ามแก้ class หลัก** |

---

## โครงสร้างบังคับ (ทุกหน้า)

1. `<!DOCTYPE html>` + `lang="th"`
2. `<head>`: charset, viewport, `<title>… — {AppName} Documentation</title>`, `styles.css`, Google Fonts Inter
3. `<button class="menu-toggle">` สำหรับ mobile
4. `<div class="page-wrapper">` → `<aside class="sidebar">` + `<main class="main-content">`
5. Sidebar: `sidebar-header` (h1 + subtitle) + `<nav>` ลิงก์ครบทุกหน้า
6. Main: `page-header` (h1, breadcrumb, last-updated) + หลาย `<section>`

---

## Sidebar navigation

- ลิงก์หลัก: Home, Overview, Architecture, Navigation, State Management, API Layer, Components, Theme & Styling, Utilities
- `<div class="nav-section">Features</div>` แล้วลิงก์ `features/*.html`
- หน้าปัจจุบัน: `class="active"` ที่ `<a>` นั้นเท่านั้น
- ทุกหน้าใช้รายการ nav **ชุดเดียวกัน** (อัปเดตเมื่อเพิ่ม feature ใน Phase 2)

### Path

| ตำแหน่งไฟล์ | `styles.css` | ลิงก์ root | ลิงก์ feature |
|-------------|--------------|------------|---------------|
| root (`overview.html`) | `styles.css` | `overview.html` | `features/auth.html` |
| `features/*.html` | `../styles.css` | `../overview.html` | `authentication.html` |

---

## เนื้อหาใน `<main>` — class ที่ใช้ได้

| Class | ใช้เมื่อ |
|-------|----------|
| `page-header` | หัวหน้า + breadcrumb + `last-updated` |
| `breadcrumb` | `<a href="index.html">Home</a> / …` |
| `last-updated` | `<span class="dot"></span>อัปเดตล่าสุด: <strong>วันที่</strong>` |
| `section` | กลุ่มเนื้อหา — มี `h2`, บางที `h3` |
| `card` | กล่องขาวมี shadow — มักห่อ `table` |
| `card-grid` | กริดการ์ด (เช่น quick links ใน index) |
| `stats-row` + `stat-card` | ตัวเลขสรุป (index) |
| `file-tree` | โครงสร้างโฟลเดอร์ monospace |
| `table` | ตาราง — มี `thead`/`tbody` เมื่อเหมาะ |
| `code` | path, ชื่อไฟล์, API |

### file-tree convention

```html
<div class="file-tree">
<span class="folder">src/</span>
├── <span class="file">App.js</span>  <span class="comment">← คำอธิบาย</span>
</div>
```

---

## หน้า index.html

- `stats-row` 4 ช่อง (containers, components, reducers, features)
- `card-grid` ลิงก์ไปหน้าหลัก
- section สำหรับ AI: ลิงก์ `project-blueprint.md`, `AI-GUIDE.md`

---

## หน้า features/*.html

- breadcrumb: `Home / Features / {Feature Name}`
- มักมี: Overview, Related Containers (`<code>path</code>`), Screens/Flow, State/API ถ้ามี

---

## Checklist ก่อนส่งงาน

- [ ] ทุกหน้าใช้ sidebar เหมือนกัน (รายการลิงก์ตรงกัน)
- [ ] `class="active"` ถูกหน้า
- [ ] path `../` ถูกต้องใน `features/`
- [ ] ไม่แก้ `styles.css` ยกเว้น user สั่ง
- [ ] เนื้อหามาจากโค้ดจริง ไม่เดา
- [ ] เปิดใน browser แล้ว sidebar + mobile toggle ใช้ได้
