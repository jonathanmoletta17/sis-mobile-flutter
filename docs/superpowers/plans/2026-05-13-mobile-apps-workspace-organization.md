# Mobile Apps Workspace Organization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Organize SIS Mobile and DTIC Mobile as clearly governed mobile products under `/home/jonathan/projects/work/mobile` without breaking the current Flutter runtime.

**Architecture:** Treat the current repository as the consolidation source first, because it is the only Flutter mobile codebase found under `/home/jonathan/projects/work`. Split only after contracts, validation, and artifact ownership are explicit. The target structure should separate app ownership while preserving shared Flutter foundation deliberately.

**Tech Stack:** Flutter, Dart, Android product flavors, Widgetbook, PowerShell Android release scripts, Cloudflare Workers for external access.

---

## Current Facts

- Canonical current repo: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- SIS entrypoint: `lib/main.dart`.
- DTIC entrypoint: `lib/main_dtic.dart`.
- DTIC app code: `lib/dtic/`.
- Android DTIC flavor resources: `android/app/src/dtic/`.
- DTIC Worker: `tool/external-access/workers-vpc-dtic/`.
- There is no second Flutter `pubspec.yaml` for DTIC under `/home/jonathan/projects/work`.
- Several DTIC files are currently untracked in Git, so the first risk is governance/versioning, not physical folder layout.

## Target Workspace Shape

Recommended top-level shape:

```text
/home/jonathan/projects/work/mobile/
  sis-mobile-flutter/          # current source of truth until migration is proven
  sis-mobile/                  # future product folder, if split is approved
  dtic-mobile/                 # future product folder, if split is approved
  mobile-shared-flutter/       # future shared package only if duplication justifies it
```

Do not create `sis-mobile/`, `dtic-mobile/`, or `mobile-shared-flutter/` until the current DTIC line is committed, validated, and its dependency boundary is mapped.

## Preferred Strategy

Use a staged migration:

1. Stabilize current monorepo/flavor model.
2. Rename or document it as a temporary consolidation repo.
3. Extract shared contracts only if the split has clear operational value.
4. Create product folders after the apps are independently buildable.
5. Keep release artifacts and Workers attached to the product they serve.

Avoid a direct file move as the first action. It would make imports, Android resources, Widgetbook goldens, release scripts, docs, and build evidence harder to reason about at the same time.

## Task 1: Baseline Inventory

**Files:**
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/README.md`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/RUNTIME_CANONICO_E_VALIDACAO.md`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/DTIC_MOBILE_V1.md`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/PADRONIZACAO_APPS_SIS_DTIC.md`
- Create: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/MOBILE_WORKSPACE_ORGANIZATION.md`

- [ ] **Step 1: Capture the actual tree**

Run:

```bash
find /home/jonathan/projects/work/mobile -maxdepth 3 -type d | sort
find /home/jonathan/projects/work -maxdepth 5 -name pubspec.yaml -print | sort
git status --short
```

Expected:

```text
Only sis-mobile-flutter and widgetbook expose Flutter pubspec.yaml files.
DTIC mobile files are inside sis-mobile-flutter.
Git status shows whether DTIC files are tracked or still untracked.
```

- [ ] **Step 2: Write the workspace decision note**

Create `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/MOBILE_WORKSPACE_ORGANIZATION.md` with:

```markdown
# Mobile Workspace Organization

## Current State

The canonical Flutter mobile workspace is `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.

SIS Mobile is the default line:

- entrypoint: `lib/main.dart`
- Android flavor: `sis`
- package id: `br.gov.rs.casacivil.sismobile`

DTIC Mobile is currently an isolated line inside the same Flutter repository:

- entrypoint: `lib/main_dtic.dart`
- app code: `lib/dtic/`
- Android flavor: `dtic`
- package id: `br.gov.rs.casacivil.dticmobile`
- Worker: `tool/external-access/workers-vpc-dtic/`

## Decision

The repository must not be split by moving files directly before the current
SIS and DTIC lines are committed, validated, and mapped by ownership.

The approved target is staged:

1. stabilize current flavor model;
2. document app boundaries;
3. decide whether shared Flutter foundation becomes a package;
4. split into `/home/jonathan/projects/work/mobile/sis-mobile` and
   `/home/jonathan/projects/work/mobile/dtic-mobile` only after independent
   build and validation are proven.

## Directory Policy

Do not use Windows paths, `/mnt/c`, build mirrors, or generated APK folders as
canonical source roots.
```

- [ ] **Step 3: Commit the inventory document**

Run:

```bash
git add docs/MOBILE_WORKSPACE_ORGANIZATION.md
git commit -m "docs: document mobile workspace organization"
```

Expected: one docs-only commit.

## Task 2: Stabilize Current App Boundaries

**Files:**
- Modify: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/README.md`
- Modify: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/README.md`
- Modify: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/BOOTSTRAP.md`
- Modify: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/AGENTS.md`

- [ ] **Step 1: Add explicit boundary language**

Update the docs to state:

```text
SIS and DTIC are product lines in the current Flutter repository. Physical
separation into product folders is a future migration, not the current runtime.
```

- [ ] **Step 2: Verify docs consistency**

Run:

```bash
rg -n "sis-mobile-flutter|main_dtic|flavor dtic|DTIC Mobile|Mobile Workspace" README.md BOOTSTRAP.md AGENTS.md docs
```

Expected:

```text
No document says DTIC has a separate Flutter root today.
No document points to /mnt/c or Windows mirrors as canonical source.
```

- [ ] **Step 3: Commit boundary docs**

Run:

```bash
git add README.md BOOTSTRAP.md AGENTS.md docs/README.md docs/MOBILE_WORKSPACE_ORGANIZATION.md
git commit -m "docs: clarify sis and dtic mobile boundaries"
```

Expected: docs commit only.

## Task 3: Validate Existing Flavor Model

**Files:**
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/android/app/build.gradle.kts`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/android/build_release.ps1`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/main.dart`
- Read: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/main_dtic.dart`

- [ ] **Step 1: Run static validation**

Run:

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Expected:

```text
Both commands pass before any folder split is attempted.
```

- [ ] **Step 2: Validate DTIC-specific tests**

Run:

```bash
/opt/flutter/bin/flutter test test/dtic_formcreator_models_test.dart
```

Expected:

```text
DTIC model and client behavior remains covered in the current repository.
```

- [ ] **Step 3: Validate Widgetbook if visual boundaries changed**

Run:

```bash
cd widgetbook
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web
```

Expected:

```text
SIS and DTIC previews still build from the current shared UI foundation.
```

## Task 4: Decide Split Model

**Files:**
- Modify: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/MOBILE_WORKSPACE_ORGANIZATION.md`

- [ ] **Step 1: Record the decision matrix**

Add:

```markdown
## Split Decision Matrix

| Option | Use When | Cost |
| --- | --- | --- |
| Keep one Flutter repo with flavors | Shared UI and release cadence remain dominant | App boundaries rely on discipline and tests |
| Split into two Flutter repos | SIS and DTIC need independent lifecycle, ownership, stores, or release cadence | Shared UI must become package or duplicated |
| Monorepo with `apps/sis`, `apps/dtic`, `packages/mobile_shared` | Both apps need separate roots but shared code remains first-class | More tooling and package management |

Preferred next step: keep the current flavor model until validation and Git
ownership are clean. Revisit split after both APKs are independently buildable.
```

- [ ] **Step 2: Commit decision matrix**

Run:

```bash
git add docs/MOBILE_WORKSPACE_ORGANIZATION.md
git commit -m "docs: add mobile split decision matrix"
```

Expected: explicit architectural decision recorded.

## Task 5: Prepare Extraction Only If Approved

**Files:**
- Potential create: `/home/jonathan/projects/work/mobile/mobile-shared-flutter/`
- Potential create: `/home/jonathan/projects/work/mobile/sis-mobile/`
- Potential create: `/home/jonathan/projects/work/mobile/dtic-mobile/`

- [ ] **Step 1: Map imports before extraction**

Run:

```bash
rg -n "package:sis_mobile_flutter|\\.\\./|dtic/|screens/|widgets/ui|theme/" lib test widgetbook
```

Expected:

```text
Every cross-boundary dependency is visible before files move.
```

- [ ] **Step 2: Extract shared package only if needed**

Create a shared package only for code used by both apps:

```text
theme/
widgets/ui/
GLPI-neutral mappers
DTO-neutral visual components
```

Do not move SIS-specific state, SIS catalog, DTIC FormCreator state, or Worker logic into shared code.

- [ ] **Step 3: Create app folders only after shared package compiles**

Target:

```text
/home/jonathan/projects/work/mobile/sis-mobile/
/home/jonathan/projects/work/mobile/dtic-mobile/
/home/jonathan/projects/work/mobile/mobile-shared-flutter/
```

Each app must have its own:

```text
pubspec.yaml
lib/main.dart
android/app/build.gradle.kts
.env.example
README.md
AGENTS.md
tool/android/build_release.ps1
test/
```

- [ ] **Step 4: Validate each app independently**

Run from each app root:

```bash
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Expected:

```text
SIS and DTIC both pass without importing from the old consolidation repo.
```

## Stop Criteria

Stop before physical extraction if any of these are true:

- DTIC files are still untracked or not committed.
- `flutter analyze` or `flutter test` fails in the current repo.
- The shared UI boundary is not explicit.
- Android flavor builds cannot be proven from the current repo.
- The split would require copying secrets, `.env`, keystores, build outputs, or Windows mirror files.

## Recommended First Execution

Start with Tasks 1 through 4 only. They create governance and evidence without moving source code. Task 5 is a separate migration project.
