#!/usr/bin/env bash
# setup-cursor.sh — ติดตั้ง .cursor + docs จาก my-cursor-rules
#
# วิธีใช้ (ต้องมี bash -s -- ก่อน arguments):
#   curl -fsSL .../setup-cursor.sh | bash -s -- --create --project .

REPO_URL="https://github.com/thitiwut00897/my-cursor-rules.git"
REPO_BRANCH="main"
REPO_SLUG="thitiwut00897/my-cursor-rules"
ZIP_FOLDER="my-cursor-rules-main"

PROJECT="."
MODE=""
USE_LOCAL=""
LOCAL_REPO=""
SKIP_DOCS=""
FORCE_DOCS=""
OVERWRITE=""

log() { printf '%s\n' "$*"; }

die() {
  log ""
  log "❌ ERROR: $*"
  exit 1
}

usage() {
  cat <<'EOF'

my-cursor-rules — setup-cursor.sh

  --create --project <path>   ติดตั้ง .cursor + สร้าง docs (สแกน + AI prompt)
  --update --project <path>   ติดตั้ง .cursor อย่างเดียว
  --local <repo-path>         ใช้ repo บนเครื่องแทน download

ตัวอย่าง (รันในโฟลเดอร์โปรเจกต์):

  curl -fsSL https://raw.githubusercontent.com/thitiwut00897/my-cursor-rules/main/scripts/setup-cursor.sh | bash -s -- --create --project .

⚠️  ต้องมี  bash -s --  ก่อน --create  มิฉะ arguments จะไม่ถูกส่งเข้าสคริปต์

EOF
}

# --- parse args ---
while [ $# -gt 0 ]; do
  case "$1" in
    --create) MODE="create"; OVERWRITE="1"; FORCE_DOCS="1"; shift ;;
    --update) MODE="update"; OVERWRITE="1"; SKIP_DOCS="1"; shift ;;
    --local)  USE_LOCAL="1"; shift ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --overwrite) OVERWRITE="1"; shift ;;
    --skip-docs) SKIP_DOCS="1"; shift ;;
    --regenerate-docs) FORCE_DOCS="1"; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*)
      if [ -n "$USE_LOCAL" ] && [ -z "$LOCAL_REPO" ] && [ "${1#-}" = "$1" ]; then
        LOCAL_REPO="$1"; shift
      else
        die "Unknown option: $1 (ดู --help)"
      fi
      ;;
    *)
      if [ -n "$USE_LOCAL" ] && [ -z "$LOCAL_REPO" ]; then
        LOCAL_REPO="$1"; shift
      else
        die "Unknown argument: $1"
      fi
      ;;
  esac
done

# ไม่มี args = มักลืม bash -s --
if [ -z "$MODE" ]; then
  log ""
  log "⚠️  ไม่พบ --create หรือ --update"
  usage
  die "ลืม bash -s -- ?  ใช้: curl ... | bash -s -- --create --project ."
fi

[ -d "$PROJECT" ] || die "ไม่พบโฟลเดอร์โปรเจกต์: $PROJECT (cd เข้าโปรเจกต์ก่อน)"
PROJECT="$(cd "$PROJECT" && pwd)"

log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "  my-cursor-rules setup — mode: $MODE"
log "  project: $PROJECT"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""

# --- download config repo ---
SRC=""

if [ -n "$USE_LOCAL" ]; then
  if [ -z "$LOCAL_REPO" ]; then
    _dir="$(dirname "$0")"
    if [ -f "$_dir/setup-cursor.sh" ] && [ "$_dir" != "." ] && [ "$_dir" != "bash" ]; then
      LOCAL_REPO="$(cd "$_dir/.." && pwd)"
    fi
  fi
  [ -n "$LOCAL_REPO" ] && [ -d "$LOCAL_REPO" ] || die "ใช้ --local ต้องระบุ path ของ my-cursor-rules"
  SRC="$LOCAL_REPO"
  log "[1/4] ใช้ local repo: $SRC"
else
  WORK="$(mktemp -d)"
  cleanup() { rm -rf "$WORK"; }
  trap cleanup EXIT

  log "[1/4] ดาวน์โหลด my-cursor-rules จาก GitHub ..."
  SRC=""

  if command -v git >/dev/null 2>&1; then
  log "      git clone ..."
    if git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$WORK/repo"; then
      SRC="$WORK/repo"
    else
      log "      git clone ไม่สำเร็จ → ลอง zip"
    fi
  fi

  if [ -z "$SRC" ]; then
    ZIP_URL="https://github.com/${REPO_SLUG}/archive/refs/heads/${REPO_BRANCH}.zip"
    log "      curl zip ..."
    if [ -n "${GITHUB_TOKEN:-}" ]; then
      curl -fsSL -L -H "Authorization: Bearer ${GITHUB_TOKEN}" -o "$WORK/z.zip" "$ZIP_URL" \
        || die "ดาวน์โหลด zip ไม่ได้"
    else
      curl -fsSL -L -o "$WORK/z.zip" "$ZIP_URL" \
        || die "ดาวน์โหลด zip ไม่ได้ — ตรวจ internet หรือใส่ GITHUB_TOKEN"
    fi
    command -v unzip >/dev/null 2>&1 || die "ไม่มี unzip — ติดตั้ง: brew install unzip"
    unzip -q "$WORK/z.zip" -d "$WORK"
    SRC="$WORK/$ZIP_FOLDER"
    [ -d "$SRC" ] || die "แตก zip ไม่พบ $ZIP_FOLDER — ได้: $(ls "$WORK" 2>/dev/null || echo empty)"
  fi
fi

log "      OK: $SRC"

# --- prepare .cursor source ---
log "[2/4] เตรียม .cursor ..."
CURSOR_SRC=""
if [ -d "$SRC/.cursor/rules" ] && [ -d "$SRC/.cursor/skills" ]; then
  CURSOR_SRC="$SRC/.cursor"
elif [ -d "$SRC/rules" ] && [ -d "$SRC/skills" ]; then
  CURSOR_SRC="$(mktemp -d)/.cursor"
  mkdir -p "$CURSOR_SRC"
  cp -R "$SRC/rules" "$CURSOR_SRC/"
  cp -R "$SRC/skills" "$CURSOR_SRC/"
  [ -d "$SRC/agents" ] && cp -R "$SRC/agents" "$CURSOR_SRC/"
  [ -f "$SRC/cursor.md" ] && cp "$SRC/cursor.md" "$CURSOR_SRC/"
  [ -f "$SRC/.cursor/.cursorrules" ] && cp "$SRC/.cursor/.cursorrules" "$CURSOR_SRC/"
else
  die "repo ไม่มี .cursor/ หรือ rules/+skills/"
fi

# --- install .cursor ---
TARGET="$PROJECT/.cursor"
if [ -e "$TARGET" ]; then
  if [ -n "$OVERWRITE" ]; then
    log "      ลบ .cursor เดิม"
    rm -rf "$TARGET"
  else
    BAK="$PROJECT/.cursor.backup.$(date +%Y%m%d_%H%M%S)"
    log "      backup → $(basename "$BAK")"
    mv "$TARGET" "$BAK"
  fi
fi

mkdir -p "$TARGET"
cp -R "$CURSOR_SRC/." "$TARGET/"
find "$TARGET" -name '.DS_Store' -delete 2>/dev/null || true
RULES_COUNT="$(find "$TARGET/rules" -name '*.mdc' 2>/dev/null | wc -l | tr -d ' ')"
log "      OK: $TARGET ($RULES_COUNT rules)"

# --- docs ---
log "[3/4] docs ..."
mkdir -p "$PROJECT/docs/work-summary"
touch "$PROJECT/docs/work-summary/.gitkeep"

DOCS_OK="no"
if [ -z "$SKIP_DOCS" ]; then
  GEN="$SRC/scripts/generate-codebase-docs.mjs"
  if [ ! -f "$GEN" ]; then
    log "      WARN: ไม่พบ $GEN"
  elif ! command -v node >/dev/null 2>&1; then
    log "      WARN: ไม่มี node — ติดตั้ง Node.js 18+ แล้วรัน:"
    log "      node $GEN $PROJECT --force"
  else
    log "      node generate-codebase-docs.mjs (สแกน + ไฟล์คู่มือ copy prompt) ..."
    if node "$GEN" "$PROJECT" "--force"; then
      DOCS_OK="yes"
    else
      log "      WARN: generate docs ล้มเหลว (code=$?) — .cursor ติดตั้งแล้ว"
    fi
  fi
else
  log "      ข้าม (--update)"
  DOCS_OK="skipped"
fi

# --- verify ---
log "[4/4] ตรวจผล ..."
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "  ✅ เสร็จแล้ว"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log ""
log "  โปรเจกต์:     $PROJECT"
log "  .cursor:       $([ -d "$TARGET/rules" ] && echo OK || echo MISSING)"
log "  rules:         ${RULES_COUNT:-0} ไฟล์"
log "  docs:          $DOCS_OK"

if [ -f "$PROJECT/docs/codebase-docs/HOW-TO-GENERATE-DOCS.md" ]; then
  log ""
  log "  📄 สร้าง HTML docs (ทำมือ — copy prompt เอง):"
  log "     1. เปิด $PROJECT/docs/codebase-docs/HOW-TO-GENERATE-DOCS.md"
  log "     2. Copy docs/codebase-docs/prompts/phase1-copy.txt → วางใน Cursor Agent"
  log "     3. บันทึก OUTLINE-PHASE1.md แล้ว copy phase2-copy.txt"
elif [ "$DOCS_OK" = "no" ]; then
  log ""
  log "  ⚠️  ยังไม่มี docs — ติดตั้ง node แล้วรัน:"
  log "     node $SRC/scripts/generate-codebase-docs.mjs $PROJECT --force"
fi

log ""
log "  ตรวจ Rules: Cursor → Settings → Rules, Commands"
log ""

exit 0
