#!/bin/bash
# Validate that the Gemini CLI SDLC scaffolding template is correctly set up.
# Run this after cloning the template to verify everything works.
#
# Usage: ./scripts/validate-template.sh

PASS=0
FAIL=0
WARN=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  WARN: $1"; WARN=$((WARN + 1)); }

echo "=== Gemini CLI SDLC Template Validation ==="
echo ""

# ---- 1. Core files exist ----
echo "1. Core files"
for f in GEMINI.md Makefile .gitignore; do
  if [[ -f "$f" ]]; then pass "$f exists"; else fail "$f missing"; fi
done
echo ""

# ---- 2. GEMINI.md enforcement ----
echo "2. GEMINI.md enforcement"
if grep -q "MANDATORY SDLC Workflow" GEMINI.md; then
  pass "MANDATORY SDLC Workflow section found"
else
  fail "MANDATORY SDLC Workflow section missing — GEMINI.md won't enforce the process"
fi
if grep -q "BLOCKING REQUIREMENT" GEMINI.md; then
  pass "BLOCKING REQUIREMENT directive found"
else
  fail "BLOCKING REQUIREMENT directive missing — Gemini may skip steps"
fi
if grep -q "GATE.*Do NOT proceed" GEMINI.md; then
  pass "Phase gates found"
else
  fail "Phase gates missing — no enforcement between phases"
fi
if grep -q "Anti-Bypass Rules" GEMINI.md; then
  pass "Anti-Bypass Rules section found"
else
  fail "Anti-Bypass Rules section missing — bypass protections not documented"
fi
if grep -q "CRITICAL TRANSITION RULE" GEMINI.md; then
  pass "Brainstorm-to-implementation transition rule found"
else
  fail "Brainstorm-to-implementation transition rule missing"
fi
echo ""

# ---- 3. Hooks exist and are executable ----
echo "3. Hooks"
for hook in .gemini/hooks/sdlc-gate.sh .gemini/hooks/branch-guard.sh .gemini/hooks/lint-python.sh .gemini/hooks/bash-file-guard.sh .gemini/hooks/lint-frontend.sh; do
  if [[ -f "$hook" ]]; then
    pass "$hook exists"
    if [[ -x "$hook" ]]; then
      pass "$hook is executable"
    else
      fail "$hook is NOT executable — run: chmod +x $hook"
    fi
  else
    fail "$hook missing"
  fi
done
echo ""

# ---- 4. Hook wiring (settings.json) ----
echo "4. Hook wiring (settings.json)"
if [[ -f ".gemini/settings.json" ]]; then
  pass ".gemini/settings.json exists"
  if grep -q "BeforeTool" .gemini/settings.json; then
    pass "BeforeTool hooks configured"
  else
    fail "BeforeTool hooks missing — SDLC gates won't fire"
  fi
  if grep -q "AfterTool" .gemini/settings.json; then
    pass "AfterTool hooks configured"
  else
    warn "AfterTool hooks missing — lint-on-save won't work"
  fi
  if grep -q "sdlc-gate.sh" .gemini/settings.json; then
    pass "sdlc-gate.sh wired in settings"
  else
    fail "sdlc-gate.sh not referenced in settings — gate won't fire"
  fi
  if grep -q "branch-guard.sh" .gemini/settings.json; then
    pass "branch-guard.sh wired in settings"
  else
    fail "branch-guard.sh not referenced in settings — branch protection off"
  fi
  if grep -q "bash-file-guard.sh" .gemini/settings.json; then
    pass "bash-file-guard.sh wired in settings"
  else
    fail "bash-file-guard.sh not referenced in settings — shell redirect bypass not blocked"
  fi
  if grep -q "mcpServers" .gemini/settings.json; then
    pass "mcpServers configured in settings.json"
  else
    warn "mcpServers not found in settings.json — MCP servers not configured"
  fi
  if grep -q "enableAgents" .gemini/settings.json; then
    pass "experimental.enableAgents configured"
  else
    warn "experimental.enableAgents not found in settings.json"
  fi
else
  fail ".gemini/settings.json missing"
fi
echo ""

# ---- 5. SDLC config sidecar ----
echo "5. SDLC config sidecar"
if [[ -f ".gemini/sdlc-config.json" ]]; then
  pass ".gemini/sdlc-config.json exists"
  SDLC_MODE=$(jq -r '.SDLC_MODE // "not set"' .gemini/sdlc-config.json 2>/dev/null)
  if [[ "$SDLC_MODE" == "full" || "$SDLC_MODE" == "lite" ]]; then
    pass "SDLC_MODE set to '$SDLC_MODE' in sdlc-config.json"
  else
    fail "SDLC_MODE has invalid value '$SDLC_MODE' (must be 'full' or 'lite')"
  fi
else
  fail ".gemini/sdlc-config.json missing — SDLC mode config not available"
fi
echo ""

# ---- 6. Custom commands exist (TOML format) ----
echo "6. Custom commands"
for cmd in gogogo interview decompose test-plan implement parallel-manual pr review diagnose wrapup spike create-prompt; do
  if [[ -f ".gemini/commands/$cmd.toml" ]]; then
    pass "/$cmd command exists (.toml)"
  else
    fail "/$cmd command missing (.toml)"
  fi
done
echo ""

# ---- 7. Rules exist ----
echo "7. Rules"
for rule in security error-handling code-style testing git-workflow react-patterns; do
  if [[ -f ".gemini/rules/$rule.md" ]]; then
    pass "$rule rule exists"; else fail "$rule rule missing"; fi
done
echo ""

# ---- 8. Agents exist (MD with YAML frontmatter) ----
echo "8. Agents"
for agent in test-writer code-reviewer architect performance-reviewer; do
  if [[ -f ".gemini/agents/$agent.md" ]]; then
    pass "$agent agent exists (.md)"
  else
    fail "$agent agent missing (.md)"
  fi
done
echo ""

# ---- 9. Skills exist ----
echo "9. Skills"
for skill in api-design database-patterns testing deployment langgraph-agents react-frontend; do
  if [[ -f ".gemini/skills/$skill/SKILL.md" ]]; then
    pass "$skill skill exists"
  else
    fail "$skill skill missing"
  fi
done
echo ""

# ---- 10. Prerequisites ----
echo "10. Prerequisites"
if command -v jq &>/dev/null; then
  pass "jq installed (required by hooks)"
else
  fail "jq not installed — hooks will fail. Install: brew install jq"
fi
if command -v ruff &>/dev/null; then
  pass "ruff installed"
else
  warn "ruff not installed — lint hook won't work. Install: pip install ruff"
fi
if command -v mypy &>/dev/null; then
  pass "mypy installed"
else
  warn "mypy not installed — type check hook won't work. Install: pip install mypy"
fi
echo ""

# ---- 11. SDLC gate simulation ----
echo "11. SDLC gate simulation (what would happen if Gemini tries to write code now)"
if [[ ! -f "docs/requirements.md" ]]; then
  pass "Gate 1 would BLOCK: docs/requirements.md missing (correct — forces /interview)"
else
  warn "Gate 1 would PASS: docs/requirements.md exists"
fi

STORY_COUNT=$(find docs/backlog -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$STORY_COUNT" -eq 0 ]]; then
  pass "Gate 2 would BLOCK: no stories in docs/backlog/ (correct — forces /decompose)"
else
  warn "Gate 2 would PASS: $STORY_COUNT stories found"
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  pass "Gate 3 would BLOCK: on $BRANCH branch (correct — forces feature branch)"
else
  warn "Gate 3 would PASS: on branch '$BRANCH'"
fi
echo ""

# ---- 12. MCP and Playwright configuration ----
echo "12. MCP and Playwright configuration"
if grep -q "playwright" .gemini/settings.json 2>/dev/null; then
  pass "Playwright MCP server configured in settings.json"
else
  warn "Playwright MCP server not found in settings.json — E2E test automation unavailable"
fi
if grep -q "@playwright/mcp" .gemini/settings.json 2>/dev/null; then
  pass "@playwright/mcp package referenced in settings.json"
else
  warn "@playwright/mcp package not referenced"
fi
if [[ -f ".gemini/commands/test-plan.toml" ]]; then
  pass "/test-plan command exists"
else
  fail "/test-plan command missing — test plans won't be generated from stories"
fi
if grep -q "E2E" .gemini/commands/implement.toml 2>/dev/null; then
  pass "/implement includes E2E test phase"
else
  warn "/implement does not reference E2E tests"
fi
if grep -q "Playwright" .gemini/skills/testing/SKILL.md 2>/dev/null; then
  pass "Testing skill includes Playwright E2E patterns"
else
  warn "Testing skill missing Playwright E2E patterns"
fi
if grep -q "e2e" .gemini/agents/test-writer.md 2>/dev/null; then
  pass "Test-writer agent supports E2E tests"
else
  warn "Test-writer agent does not reference E2E tests"
fi
echo ""

# ---- 13. Hardened gate validation ----
echo "13. Hardened SDLC gates"

# Check sdlc-gate.sh has content validation
if grep -q "REQ_LINE_COUNT" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh validates requirements content length"
else
  fail "sdlc-gate.sh does NOT validate requirements content — stubs can bypass"
fi
if grep -q "SECTION_COUNT" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh validates requirements section headings"
else
  fail "sdlc-gate.sh does NOT validate section headings — stubs can bypass"
fi
if grep -q "VALID_STORY_FOUND" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh validates story file content"
else
  fail "sdlc-gate.sh does NOT validate story content — stubs can bypass"
fi

# Check expanded path coverage
if grep -q '\.py.*\.ts.*\.tsx.*\.js.*\.jsx' .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh gates all code file types (.py/.ts/.tsx/.js/.jsx)"
else
  fail "sdlc-gate.sh does NOT gate all code file types"
fi

# Check conditional __init__.py
if grep -q 'LINE_COUNT.*-le 5' .gemini/hooks/sdlc-gate.sh 2>/dev/null || \
   grep -q '__init__.py.*tests/' .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh has conditional __init__.py handling"
else
  fail "sdlc-gate.sh blanket-allows __init__.py — no content check"
fi

# Check bash-file-guard.sh
if [[ -f ".gemini/hooks/bash-file-guard.sh" ]]; then
  pass "bash-file-guard.sh exists"
  if [[ -x ".gemini/hooks/bash-file-guard.sh" ]]; then
    pass "bash-file-guard.sh is executable"
  else
    fail "bash-file-guard.sh is NOT executable"
  fi
  if grep -q "docs/requirements" .gemini/hooks/bash-file-guard.sh 2>/dev/null; then
    pass "bash-file-guard.sh blocks redirects to docs/requirements.md"
  else
    fail "bash-file-guard.sh does NOT block redirects to requirements"
  fi
  if grep -q "docs/backlog" .gemini/hooks/bash-file-guard.sh 2>/dev/null; then
    pass "bash-file-guard.sh blocks redirects to docs/backlog/"
  else
    fail "bash-file-guard.sh does NOT block redirects to backlog"
  fi
  if grep -q "docs/test-plans" .gemini/hooks/bash-file-guard.sh 2>/dev/null; then
    pass "bash-file-guard.sh blocks redirects to docs/test-plans/"
  else
    fail "bash-file-guard.sh does NOT block redirects to test-plans"
  fi
fi

# Check test plan gate for src/
if grep -q "test-plans.*STORY" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh requires test plan for src/ writes"
else
  fail "sdlc-gate.sh does NOT require test plan for src/ writes"
fi

# Check implement has pre-flight
if grep -q "Pre-flight Verification" .gemini/commands/implement.toml 2>/dev/null; then
  pass "/implement has Phase 0 pre-flight verification"
else
  fail "/implement missing Phase 0 pre-flight — prerequisites not checked"
fi
echo ""

# ---- 14. Spike exploration mode ----
echo "14. Spike exploration mode"
if [[ -f ".gemini/commands/spike.toml" ]]; then
  pass "/spike command exists"
else
  fail "/spike command missing"
fi
if grep -q "spike/" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh has spike branch exemption"
else
  fail "sdlc-gate.sh missing spike branch exemption — spike branches will be blocked"
fi
if grep -q "merge.*spike" .gemini/hooks/branch-guard.sh 2>/dev/null; then
  pass "branch-guard.sh blocks merging spike branches"
else
  fail "branch-guard.sh does NOT block spike merges — spike code could reach main"
fi
if grep -q 'spike/\*' .gemini/hooks/branch-guard.sh 2>/dev/null && grep -q 'gh.*pr.*create' .gemini/hooks/branch-guard.sh 2>/dev/null; then
  pass "branch-guard.sh blocks PR creation from spike branches"
else
  fail "branch-guard.sh does NOT block PR creation from spike branches"
fi
if grep -q "spike" GEMINI.md 2>/dev/null; then
  pass "GEMINI.md references spike mode"
else
  fail "GEMINI.md does not mention spike mode"
fi
echo ""

# ---- 15. Performance reviewer agent ----
echo "15. Performance reviewer agent"
if [[ -f ".gemini/agents/performance-reviewer.md" ]]; then
  pass "performance-reviewer.md exists"
  if grep -q "name: performance-reviewer" .gemini/agents/performance-reviewer.md 2>/dev/null; then
    pass "performance-reviewer.md has correct name field"
  else
    fail "performance-reviewer.md missing name field"
  fi
  if grep -q "N+1\|N.1" .gemini/agents/performance-reviewer.md 2>/dev/null; then
    pass "performance-reviewer.md checks N+1 queries"
  else
    fail "performance-reviewer.md missing N+1 query check"
  fi
  if grep -q "pagination\|Pagination" .gemini/agents/performance-reviewer.md 2>/dev/null; then
    pass "performance-reviewer.md checks pagination"
  else
    fail "performance-reviewer.md missing pagination check"
  fi
else
  fail "performance-reviewer.md missing"
fi
if grep -q "performance-reviewer" GEMINI.md 2>/dev/null; then
  pass "GEMINI.md references performance-reviewer agent"
else
  fail "GEMINI.md does not reference performance-reviewer agent"
fi
echo ""

# ---- 16. SDLC Lite mode support ----
echo "16. SDLC Lite mode support"

# Check sdlc-gate.sh reads SDLC_MODE
if grep -q "SDLC_MODE" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh reads SDLC_MODE for mode-dependent thresholds"
else
  fail "sdlc-gate.sh does NOT read SDLC_MODE — lite mode thresholds not applied"
fi

if grep -q "REQ_MIN_LINES" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh uses parameterized requirement thresholds"
else
  fail "sdlc-gate.sh does NOT use parameterized thresholds"
fi

if grep -q "STORY_MIN_LINES" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh uses parameterized story thresholds"
else
  fail "sdlc-gate.sh does NOT use parameterized story thresholds"
fi

if grep -q "REQUIRE_TEST_PLAN" .gemini/hooks/sdlc-gate.sh 2>/dev/null; then
  pass "sdlc-gate.sh has conditional test plan gate"
else
  fail "sdlc-gate.sh does NOT have conditional test plan gate"
fi

# Check GEMINI.md documents lite mode
if grep -q "SDLC Mode.*Full vs Lite\|SDLC_MODE" GEMINI.md 2>/dev/null; then
  pass "GEMINI.md documents SDLC lite mode"
else
  fail "GEMINI.md does not document SDLC lite mode"
fi

# Check commands reference lite mode
if grep -q "lite\|SDLC_MODE" .gemini/commands/gogogo.toml 2>/dev/null; then
  pass "gogogo references lite mode"
else
  fail "gogogo does NOT reference lite mode"
fi

if grep -q "lite\|Lite Mode\|SDLC_MODE" .gemini/commands/interview.toml 2>/dev/null; then
  pass "interview references lite mode"
else
  fail "interview does NOT reference lite mode"
fi

if grep -q "lite\|Lite Mode\|SDLC_MODE" .gemini/commands/decompose.toml 2>/dev/null; then
  pass "decompose references lite mode"
else
  fail "decompose does NOT reference lite mode"
fi

if grep -q "lite\|Lite Mode\|SDLC_MODE" .gemini/commands/implement.toml 2>/dev/null; then
  pass "implement references lite mode"
else
  fail "implement does NOT reference lite mode"
fi
echo ""

# ---- 17. No stale Claude references ----
echo "17. No stale Claude references"
STALE_CLAUDE=$(grep -rl "\.claude/" .gemini/ GEMINI.md 2>/dev/null | head -5)
if [[ -z "$STALE_CLAUDE" ]]; then
  pass "No .claude/ references found in .gemini/ or GEMINI.md"
else
  fail "Stale .claude/ references found in: $STALE_CLAUDE"
fi

STALE_CLAUDEMD=$(grep -rl "CLAUDE\.md" .gemini/ GEMINI.md 2>/dev/null | head -5)
if [[ -z "$STALE_CLAUDEMD" ]]; then
  pass "No CLAUDE.md references found in .gemini/ or GEMINI.md"
else
  fail "Stale CLAUDE.md references found in: $STALE_CLAUDEMD"
fi

STALE_HOOKS=$(grep -rl "PreToolUse\|PostToolUse" .gemini/ 2>/dev/null | head -5)
if [[ -z "$STALE_HOOKS" ]]; then
  pass "No PreToolUse/PostToolUse references found in .gemini/"
else
  fail "Stale PreToolUse/PostToolUse references found in: $STALE_HOOKS"
fi
echo ""

# ---- Summary ----
echo "=== Summary ==="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "  WARN: $WARN"
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Template is correctly configured. All SDLC gates are in place."
else
  echo "Template has $FAIL issue(s) that need fixing. See FAIL items above."
  exit 1
fi