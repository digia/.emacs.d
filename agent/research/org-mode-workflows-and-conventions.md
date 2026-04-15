# Org-mode Workflows, Conventions, and Expert Practices

Research compiled for comparing against existing Markdown/Obsidian daily note conventions
before committing to an Org-mode second brain setup.

---

## Table of Contents

- [Part 1: Core Philosophy and Terminology](#part-1-core-philosophy-and-terminology)
- [Part 2: The Daily Note Problem — Why You Don't Need Carry-Forward](#part-2-the-daily-note-problem)
- [Part 3: Named Expert Workflows](#part-3-named-expert-workflows)
- [Part 4: Multi-Project and Leadership Patterns](#part-4-multi-project-and-leadership-patterns)
- [Part 5: Common Anti-Patterns](#part-5-common-anti-patterns)
- [Part 6: Obsidian → Org-mode Mapping Table](#part-6-obsidian-to-org-mode-mapping-table)
- [Sources](#sources)

---

## Part 1: Core Philosophy and Terminology

### The Philosophy: "Plain Text with Structure"

Org-mode is not an application. It is a plain-text markup format combined with a major mode
in Emacs that deeply understands that format. Your `.org` files are just text files — no
database, no proprietary sync, no electron app.

**Everything is an outline.** The atomic unit is the *headline* (a line starting with `*`).
Every Org file is an outline tree, and the entire system — tasks, notes, scheduling, time
tracking, properties — hangs off that tree structure.

**The org file IS the system.** In Obsidian, the app provides task management, graph view,
backlinks — the files are passive containers. In Org-mode, the files themselves contain all
metadata (TODO states, priorities, tags, scheduled dates, deadlines, clock entries,
properties). Emacs reads this structured plain text and generates dynamic views (the agenda)
on the fly. If Emacs disappeared tomorrow, your files would still be fully readable.

### How This Differs from Obsidian / Markdown

| Concept           | Obsidian / Markdown                    | Org-mode                                              |
|-------------------|----------------------------------------|-------------------------------------------------------|
| Basic unit        | The note (one file)                    | The headline (within a file)                          |
| Navigation        | Links between files, graph view        | Outline folding, agenda, sparse trees, links          |
| Task management   | Checkbox `- [ ]`, plugin-dependent     | First-class TODO system with states, dates, clocking  |
| Metadata          | YAML frontmatter, limited              | Property drawers on any headline, unlimited key-value |
| Views             | Plugin-dependent (Dataview, Tasks)     | Built-in agenda, column view, sparse trees            |
| Structure         | Flat files linked together             | Hierarchical outlines, deep nesting in single files   |
| Code execution    | None natively                          | Babel — execute code in 50+ languages inline          |
| Export            | Limited, plugin-dependent              | Built-in: HTML, LaTeX/PDF, ODT, iCal, ASCII, more    |

### Core Terminology

#### Headlines / Headings
The backbone of every Org file. Stars followed by a space:
```org
* Top-level headline (level 1)
** Sub-headline (level 2)
*** Sub-sub-headline (level 3)
    Body text lives here, under its parent headline.
```
`TAB` on a headline cycles visibility: FOLDED → CHILDREN → SUBTREE.
`S-TAB` cycles the entire buffer: OVERVIEW → CONTENTS → SHOW ALL.

Unlike Markdown headings, these are *active* — you can move them (`M-UP/DOWN`),
promote/demote them (`M-LEFT/RIGHT`), refile them, and every headline can carry TODO state,
priority, tags, properties, timestamps, and clock data.

#### TODO Keywords and State Sequences
Any headline becomes a task by adding a TODO keyword:
```org
* TODO Write the quarterly report
* DONE File taxes
```

Custom state sequences are defined with `org-todo-keywords`:
```elisp
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
```
The `|` separates "active" states (left) from "completed" states (right). The letters in
parens are fast-access keys — press `C-c C-t` then a single key to set state.

**Common states and what they mean in practice:**
- **TODO** — Needs to be done, not yet started
- **NEXT** — The very next physical action (GTD concept)
- **WAITING** — Blocked on someone/something
- **DONE** — Completed
- **CANCELLED** — Won't do, but keeping the record

#### Properties and Property Drawers
Arbitrary key-value metadata on any headline:
```org
* TODO Call the plumber
  :PROPERTIES:
  :PHONE:    555-1234
  :EFFORT:   0:15
  :CATEGORY: home
  :END:
```
Used for: effort estimates, categories, custom IDs, any arbitrary data. Queryable in
agenda views, column view, and programmatically.

#### Tags
Appear at the end of a headline, in colons:
```org
* TODO Call the plumber                                      :home:urgent:
```

**Tag inheritance**: If a parent has a tag, all children inherit it. If a file has
`#+FILETAGS: work`, every headline inherits `:work:`. This is extremely powerful for
filtering — tag a project `:client_acme:` and every sub-task automatically belongs to that
project in agenda views.

**Tag groups**: Hierarchical — a group tag matches any member tag.
**Mutually exclusive tags**: Only one from a group can be active at a time.

#### Priority Levels
```org
* TODO [#A] Fix production bug
* TODO [#B] Update documentation
* TODO [#C] Clean up old branches
```
Default: A (highest), B (default), C (lowest). Agenda sorts by priority.

#### Scheduling vs. Deadlines (These Are Different!)

**SCHEDULED** (`C-c C-s`): The date you *plan to start working on* a task. Once that date
arrives, the task appears in your agenda every day until DONE.
```org
* TODO Write project proposal
  SCHEDULED: <2026-04-15 Wed>
```

**DEADLINE** (`C-c C-d`): The date by which the task *must be finished*. Org warns you in
advance (default: 14 days before). After the deadline passes, it shows as overdue.
```org
* TODO Submit grant application
  DEADLINE: <2026-04-30 Thu>
```

**Plain timestamps** are for appointments/events at a specific time:
```org
* Meeting with design team
  <2026-04-16 Thu 14:00-15:00>
```

**Inactive timestamps** use square brackets `[2026-04-14 Tue]` and do NOT appear in the
agenda. Use for recording when something happened.

Important: "Scheduling" does NOT mean "this is a meeting at 2pm." That is a plain timestamp.
Scheduling means "I plan to start working on this task on this date."

#### Clocking (Time Tracking)
Built-in time tracking on any headline:
- `C-c C-x C-i` — Clock in (start timing)
- `C-c C-x C-o` — Clock out (stop timing)

```org
* DONE Review pull requests
  :LOGBOOK:
  CLOCK: [2026-04-14 Tue 09:15]--[2026-04-14 Tue 10:30] =>  1:15
  CLOCK: [2026-04-13 Mon 14:00]--[2026-04-13 Mon 14:45] =>  0:45
  :END:
```

Generate clock reports with `org-clock-report` for time summaries across projects.

#### Refiling
`C-c C-w` moves a headline (and subtree) from one location to another — within the same
file or to a different file. This is how you process your inbox: capture fast, refile later.

#### Archiving
`C-c C-x C-a` moves completed items to `<filename>_archive`. Still plain text, still
searchable — just out of your daily view. Keeps working files lean and agenda fast.

#### Capture
`org-capture` is the quick-entry system. Pops up a template buffer, you type, `C-c C-c`
files it away. Designed to be *fast and non-disruptive* — capture now, organize later.

#### Agenda Views
The killer feature. A *live, read-only view* that collects information from across your
Org files. Built-in views:
- **Daily/weekly agenda** (`a`): Scheduled, deadlines, timestamps for today/this week
- **TODO list** (`t`): All TODO entries across all agenda files
- **Tag/property match** (`m`): Find entries matching a query
- **Search** (`s`): Full-text search across agenda files

Custom agenda commands combine multiple blocks into dashboards.

Key point for Obsidian users: In Obsidian, you install Dataview and write queries. In Org,
the agenda is built-in, understands all metadata natively, and updates in real time.

#### Other Features
- **Sparse trees** (`C-c /`): In-buffer filter showing only matching headlines
- **Column view** (`C-c C-x C-c`): Spreadsheet-like overlay on your outline
- **Babel**: Execute code blocks in 50+ languages, literate programming
- **Export** (`C-c C-e`): HTML, LaTeX/PDF, ODT, iCalendar, ASCII, Markdown, Texinfo

### GTD (Getting Things Done) in Org-mode

Org is the most natural digital implementation of GTD. The methodology maps 1:1:

| GTD Step    | Org Feature                                                        |
|-------------|--------------------------------------------------------------------|
| **Capture** | `org-capture` — inbox file, minimal friction                       |
| **Clarify** | Set TODO states, add tags, define next actions during review       |
| **Organize**| `org-refile` — move to project files, someday/maybe, reference     |
| **Review**  | Agenda views — daily, stuck projects, waiting items, weekly review |
| **Engage**  | Agenda daily view filtered by context tags                         |

**GTD concepts mapped:**
- **Inbox**: `inbox.org` — capture dumps here, processed in review
- **Next Actions**: `NEXT` TODO keyword — the immediate physical action
- **Projects**: Any heading with sub-tasks; "stuck" if no NEXT action defined
- **Contexts**: Tags like `@office`, `@home`, `@phone` — filter NEXT actions by where you are
- **Waiting For**: `WAITING` state with a note about who/what
- **Someday/Maybe**: Separate file or section — reviewed weekly
- **Weekly Review**: Recurring task with checklist, custom agenda views

---

## Part 2: The Daily Note Problem

### Why You Don't Need Carry-Forward

This is the single biggest paradigm shift from Obsidian/Markdown daily notes.

**In Obsidian** (your current workflow):
```markdown
<!-- 2026-04-13.md -->
- [ ] Review Q2 budget

<!-- 2026-04-14.md — you manually copied this -->
- [ ] Review Q2 budget
```

**In Org-mode:**
```org
;; In ~/org/work.org (this task lives here permanently)
* TODO Review Q2 budget
  SCHEDULED: <2026-04-13 Sun>
```

On April 13, the agenda shows it. You don't finish it. On April 14, the agenda shows it
again automatically with `Sched. 1x:` (one day overdue). April 15: `Sched. 2x:`. It never
goes away until you:
- **Complete it**: Mark DONE
- **Reschedule it**: Pick a new date
- **Cancel it**: Change state to CANCELLED

**The core mental model shift**: Stop thinking "what file does this task live in today" and
start thinking "this task exists once, the agenda shows it when it's relevant."

### How Tasks, Views, and Daily Files Relate

In Obsidian, a daily note is both the **container** for tasks and the **view** of your day.
In Org-mode, these are separated:
- **Containers**: `work.org`, `personal.org`, `project-foo.org` (tasks live here permanently)
- **View**: `org-agenda` (dynamically shows what is relevant right now)

### Three Approaches to "Daily Notes" in Org-mode

**Approach A: No daily files — use agenda views (most common among long-time users)**
Tasks live in project files, agenda surfaces today's items. Bernt Hansen, Wai Hon Law, and
most GTD-focused users do this. The agenda IS your daily note.

**Approach B: org-journal (sequential journaling)**
One file per day/week/month. Has automatic TODO carry-over between entries. Closest analog
to Obsidian daily notes. Does NOT integrate with org-roam linking.

**Approach C: org-roam-dailies (linked daily notes)**
Each day gets an org-roam node with backlink integration. Best if you want to connect daily
notes to your knowledge base. Used by Zettelkasten-focused practitioners.

**The consensus**: If managing tasks is primary, use the agenda (Approach A). If journaling/
reflection is important, add org-journal or org-roam-dailies alongside the agenda. Many
users combine: agenda for tasks, daily files for prose.

### How Experienced Users Start Their Day

1. Open the agenda: `C-c a a`
2. Scan overdue items (automatically surfaced)
3. Triage: reschedule (`C-c C-s`), set priorities, mark DONE
4. Check WAITING items (custom agenda view)
5. Pick NEXT actions and start working

### Bulk Rescheduling

Monday morning, 15 overdue items from last week:
1. `m` on each item to mark (or `*` prefix for regex/category select)
2. `B` for bulk action
3. `s` for schedule
4. Type new date, or `++1d` to shift each forward by one day

### Habits (Repeating Tasks)

```org
* TODO Exercise
  SCHEDULED: <2026-04-14 Mon .+1d>
  :PROPERTIES:
  :STYLE:    habit
  :END:
```

Repeater syntax:
- `+1w` — exactly one week from scheduled date (even if completed late)
- `.+1w` — one week from when you actually mark it done
- `++1w` — advance to the next future occurrence (skips past dates)

### Mapping Your Obsidian Daily Workflow

| Obsidian Pattern                | Org-mode Equivalent                                       |
|---------------------------------|-----------------------------------------------------------|
| Open today's daily note         | `C-c a a` (open agenda for today)                         |
| Copy incomplete tasks forward   | Automatic — overdue items persist in agenda               |
| Check a task as done            | `C-c C-t` in file, or `t` in agenda                      |
| Add a new task for today        | `org-capture` with scheduled-today template               |
| Write meeting notes             | `org-capture` meeting template with `:clock-in`           |
| Jot down a thought              | `org-capture` journal template into datetree              |
| Move a task to tomorrow         | `C-c C-s` then `+1d` (or `S-s` in agenda)                |
| Review what you did today       | `l` in agenda to toggle log mode                          |
| See all open priority tasks     | Custom agenda command filtering by priority               |
| Weekly review                   | Custom agenda command showing all states + stuck projects |

---

## Part 3: Named Expert Workflows

### Bernt Hansen — The Gold Standard GTD Workflow
**URL**: http://doc.norang.ca/org-mode.html

The most comprehensive publicly documented Org-mode workflow. Stable for over a decade.

**File organization**: Multiple files by domain — one per client/area. `refile.org` as
universal capture bucket with `#+FILETAGS: REFILE`.

**Task states**: `TODO → NEXT → DONE` with `WAITING`, `HOLD`, `CANCELLED` as secondary.
Tags auto-added/removed on state transitions.

**Capture**: Deliberately minimal templates — found that many templates was counterproductive.
Capture fast to `refile.org`, refile once to the correct location.

**Templates**:
```elisp
(setq org-capture-templates
  '(("t" "todo" entry (file "~/git/org/refile.org")
     "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
    ("n" "note" entry (file "~/git/org/refile.org")
     "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
    ("m" "Meeting" entry (file "~/git/org/refile.org")
     "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
    ("j" "Journal" entry (file+datetree "~/git/org/diary.org")
     "* %?\n%U\n" :clock-in t :clock-resume t)
    ("h" "Habit" entry (file "~/git/org/refile.org")
     "* NEXT %?\nSCHEDULED: %(format-time-string \"<%Y-%m-%d %a .+1d/3d>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n")))
```

**Block agenda**: Single "super agenda" showing: today's agenda, items to refile, stuck
projects, all projects, NEXT tasks, standalone tasks, waiting items, and items to archive.

**Daily workflow**: Punch in → review agenda → read email/capture → check refile → work on
tasks → clock each task → journal for interruptions → batch refile → mark habits → punch out.

**Weekly review**: Recurring NEXT task every Monday with checklist: check follow-up folder,
review weekly agenda, check clock data, review clock report, review all projects.

---

### Sacha Chua — The Prolific Documenter
**URL**: https://sachachua.com/blog/

Consultant, developer, weekly "Emacs News" curator. 15+ years of documented evolution.

**File organization (6 main files, ~1.3MB total)**:
- `organizer.org` — catch-all (notes, open loops, projects, someday, weekly review sections)
- `business.org` — by activity type (Earn/Build/Connect), sub-sections per client
- `people.org` — by relationship type (family, friends, meetups)
- `routines.org` — recurring tasks by frequency + "In case of..." scenarios
- `sharing/index.org` — blog post outlines by topic
- `decisions.org` — by status (Pending, Current, For Review, Someday/Maybe, Archive)

**Weekly review**: Custom function `sacha/org-prepare-weekly-review` extracts upcoming tasks,
completed tasks (log mode), and time summaries. Publishes weekly blog post.

---

### Nicolas Rougier — Clean-Slate GTD
**URL**: https://www.labri.fr/perso/nrougier/GTD/index.html
**GitHub**: https://github.com/rougier/emacs-GTD

Built up from vanilla Emacs step by step. Exceptional documentation.

**File structure (3 files)**:
- `inbox.org` — capture bucket
- `projects.org` — organized projects
- `agenda.org` — calendar events, meetings, recurring items

**Capture (2 templates only)**:
```elisp
(setq org-capture-templates
  `(("i" "Inbox" entry (file "inbox.org")
     ,(concat "* TODO %?\n" "/Entered on/ %U"))
    ("@" "Inbox [mu4e]" entry (file "inbox.org")
     ,(concat "* TODO Process \"%a\" %?\n" "/Entered on/ %U"))))
```

Inbox items are deliberately short (verb + subject). Daily review provides context.

---

### Jethro Kuan — Org-roam Creator
**URL**: https://blog.jethro.dev/posts/how_to_take_smart_notes_org/

Critical design decision: **separates task management (GTD) from knowledge management
(Zettelkasten)**. They operate on different modes of thinking.

Completed 3,478 TODOs and wrote 29,000+ lines in his knowledge base.

---

### Karl Voit — Tagging and File Management Expert
**URL**: https://karl-voit.at/orgmode/

Key insight: **categories and tags serve fundamentally different purposes**:
- **Categories** = single classification per heading (file-level default). For agenda margin.
- **Tags** = multiple labels per heading. Keep the tag set small — hundreds of tags loses advantage.

Each contact gets an `@FirstnameLastname` tag for meeting prep and filtering.

---

### Boris Buliga (d12frosted) — Org-roam for People
**URL**: https://www.d12frosted.io/posts/2021-05-21-task-management-with-roam-vol7

7-part series on task management with org-roam.

**People as notes**: Each person has an org-roam note with a `Meetings` heading. 1:1 notes
auto-filed under the correct person via dynamic capture templates.

**Performance trick**: Tag notes containing TODOs with `project`, only load those into
agenda. Reduced agenda loading from 50+ seconds to under 1 second.

---

### Wai Hon Law — PARA Method in Org-mode
**URL**: https://whhone.com/posts/org-mode-task-management/

**Single `todo.org`** with PARA categories. Uses org categories (not tags) for PARA top-level
so agenda shows priority immediately. Tags for specific areas (controlled vocabulary, small).

**Task states**: `TODO → NEXT → PROG → DONE` (with `INTR` for interruptions).
Uses SCHEDULED as "snooze" — hides until that date, not a commitment.

**Daily routine**: Review scheduled-for-today, update/clear dates, work top-down:
INTR first → PROG → NEXT.

---

### Juan Reyero — Engineering Manager Team Tracking
**URL**: http://juanreyero.com/article/emacs/org-teams/

Managed 12 engineers at HP R&D. Uses `TASK` (separate keyword) for team members' tasks.
Each member gets a personal tag. Before meetings, tells Emacs who he's meeting with — custom
command filters agenda to that person's items. Became `org-secretary.el` in org-contrib.

---

### Howard Abrams — Literate DevOps
**URL**: https://howardism.org/Technical/Emacs/capturing-content.html

Primary org file is his current Sprint page. All capture flows to the currently clocked task.

**Innovation**: Templates targeting the current clock:
```elisp
("c" "Item to Current Clocked Task" item (clock) "%i%?" :empty-lines 1)
("K" "Kill-ring to Clocked Task" plain (clock) "%c" :immediate-finish t)
("C" "Selected Region to Clocked Task" plain (clock) "%i" :immediate-finish t)
```
Also captures code snippets with metadata (file, line, function) wrapped in `#+BEGIN_SRC`.

---

### Rainer Konig — Accessible GTD
**YouTube/Udemy course, 3,600+ subscribers**

Deliberately uses out-of-the-box config with minimal customization. Each morning: build plan
with 3 most important tasks first. Proves Org works well without heavy customization.

---

## Part 4: Multi-Project and Leadership Patterns

### File Organization for Multiple Projects

**The hybrid approach (recommended for engineering leadership)**:
- `work.org` — main work tasks, top-level headings per team/area
- `people/` directory — one file per direct report (1:1 notes, career dev, feedback)
- `meetings.org` — captured meeting notes
- `refile.org` — capture inbox, processed daily/weekly
- `projects/` — one file per large initiative when it outgrows a heading
- `personal.org` — non-work items
- `someday.org` — GTD someday/maybe list

### Tags for Cross-Cutting Concerns

Use multiple tag dimensions simultaneously:
- **Team**: `:alpha:`, `:beta:`, `:platform:`
- **Context** (GTD): `:@office:`, `:@laptop:`, `:@phone:`
- **People**: `:@sarah:`, `:@mike:` — who owns/blocks what
- **Type**: `:review:`, `:incident:`, `:debt:`, `:hiring:`

`#+FILETAGS` applies tags to everything in a file automatically.

### Custom Agenda Commands for Dashboards

```elisp
(setq org-agenda-custom-commands
      '(("d" "Dashboard"
         ((agenda "" ((org-agenda-span 'day)))
          (tags-todo "+PRIORITY=\"A\""
                     ((org-agenda-overriding-header "High Priority")))
          (tags-todo "+refile"
                     ((org-agenda-overriding-header "To Refile")))
          (todo "WAITING"
                ((org-agenda-overriding-header "Blocked/Waiting")))
          (todo "NEXT"
                ((org-agenda-overriding-header "Next Actions")))))
        ("a" "Team Alpha" tags-todo "+alpha")
        ("b" "Team Beta" tags-todo "+beta")
        ("p" "All People" tags-todo "+1on1")))
```

`org-super-agenda` is the most recommended package for grouping items visually in the
agenda — by tag, category, priority, parent heading, or auto-group by property.

### 1:1 Meeting Notes

**Recommended pattern for your scale**:
```org
;; people/sarah.org
#+TITLE: Sarah Chen - Senior Engineer, Team Alpha
#+FILETAGS: :sarah:alpha:

* 1:1 Notes
** [2026-04-14 Mon] 1:1
   - Discussed promotion timeline
   - Blocked on platform team for GPU quota
   - TODO Follow up with platform lead about quota      :@jonathon:
** [2026-04-07 Mon] 1:1
   - Sprint going well, on track for auth v2

* Career Development
** Goals for H1 2026
   ...

* Feedback Log
** [2026-03-15] Great incident handling on DB outage
```

### Sprint/Iteration Tracking

```org
* Sprint 2026-Q2-W3                                     :sprint:
  :PROPERTIES:
  :CATEGORY: sprint
  :END:
** TODO [#A] Deploy auth service v2                       :alpha:
   :PROPERTIES:
   :Effort: 3d
   :ASSIGNEE: sarah
   :END:
** TODO [#B] Fix flaky integration tests                  :beta:debt:
   :PROPERTIES:
   :Effort: 1d
   :END:
```

Column view with `%ASSIGNEE %Effort{:} %CLOCKSUM` gives spreadsheet-like sprint views.

### Architecture Decision Records

```org
* ADR-0042: Use gRPC for inter-service communication
  :PROPERTIES:
  :ADR_STATUS: Accepted
  :ADR_DATE:   [2026-03-15]
  :ADR_DECIDERS: sarah, mike, jonathon
  :END:
** Context
   Services currently communicate via REST. Latency is...
** Decision
   We will use gRPC with Protocol Buffers for all new...
** Consequences
   - Teams need protobuf tooling in CI
   - Existing REST endpoints maintained until migrated
```

### Technical Debt Tracking

```org
#+TODO: DEBT(d) PLANNED(p) | RESOLVED(r) WONTFIX(w)

* Technical Debt                                          :debt:
** DEBT [#B] Migrate auth tokens to JWT                   :alpha:security:
   :PROPERTIES:
   :Effort: 2w
   :IMPACT:  high
   :END:
```

### OKR/Goal Tracking

```org
* Q2 2026 OKRs                                           :okr:
** Objective: Improve platform reliability
   :PROPERTIES:
   :SCORE: 0.6
   :END:
*** KR1: Reduce P1 incidents from 4/month to 1/month [75%]
    :PROPERTIES:
    :TARGET:  1
    :CURRENT: 1.5
    :BASELINE: 4
    :END:
*** KR2: Achieve 99.95% uptime [60%]
*** KR3: All services have runbooks [2/7]
```

### Context Switching with Clocking

1. Clock into a task (`C-c C-x C-i`)
2. Interruption arrives — fire `org-capture`
3. Capture template with `:clock-in t :clock-resume t` auto-clocks the interruption
4. Finish capture (`C-c C-c`) — resumes previous clock automatically
5. End-of-day clock report shows exact time split

### Weekly Review

The non-negotiable habit. Template that resets each week:

```org
* TODO Weekly Review [0/8]                                 :review:
  SCHEDULED: <2026-04-20 Sun +1w>
  :PROPERTIES:
  :RESET_CHECK_BOXES: t
  :END:
  - [ ] Process refile.org inbox to zero
  - [ ] Review calendar for past week (missed commitments?)
  - [ ] Review calendar for next 2 weeks
  - [ ] Review WAITING items — ping if stale
  - [ ] Review active projects — does each have a NEXT action?
  - [ ] Review stuck projects list (C-c a #)
  - [ ] Review someday/maybe — promote or kill
  - [ ] Brain dump: capture anything floating in head
```

### Stuck Projects

Built-in: `org-agenda-list-stuck-projects` (`C-c a #`):
```elisp
(setq org-stuck-projects
      '("+PROJECT/-DONE-CANCELLED"  ; How to identify a project
        ("NEXT" "TODO")              ; Keywords that mean NOT stuck
        nil nil))
```
Automatically surfaces projects missing a next action during weekly review.

### External Tool Integration

**Jira/Linear**: Keep it manual. Link to the ticket in your org heading, manage workflow in
org, update the external system when status changes. The sync tools (org-jira, ejira) are
fragile and the manual approach is more reliable.

```org
** TODO [#A] PLATFORM-1234: Migrate to new GPU scheduler  :platform:
   [[https://company.atlassian.net/browse/PLATFORM-1234][Jira: PLATFORM-1234]]
   DEADLINE: <2026-04-30 Wed>
```

**Calendar**: org-caldav syncs active timestamps (events) to CalDAV (Google Calendar, etc.).
Keep a separate `calendar.org` for synced events.

**Mobile**: beorg (iOS) reads/writes `.org` files via iCloud/Dropbox. Give it its own
`refile-beorg.org` — process like any other inbox source.

---

## Part 5: Common Anti-Patterns

### Over-engineering capture templates
**Trap**: 15 templates with different targets, auto-tags, prompted properties on day one.
**Fix**: Start with 1-2 templates. Inbox TODO and a simple note. Add more as you learn what
you actually need. Rougier's entire GTD runs on 2 templates.

### Too many TODO states
**Trap**: `TODO NEXT STARTED IN-PROGRESS BLOCKED WAITING DELEGATED ON-HOLD DEFERRED...`
**Fix**: Start with `TODO` and `DONE`. Add `NEXT` for GTD. Add `WAITING` when needed. Most
experienced users settle on 3-5 states.

### Treating Org like a wiki instead of using the agenda
**Trap**: Coming from Obsidian, you create dozens of interlinked files and browse between
them, never setting up the agenda.
**Fix**: The agenda is the heart of Org's productivity system. Set it up and use it daily.

### Trying to learn everything at once
**Trap**: Reading the 200+ page manual, configuring Babel, column view, clock tables, and
publishing on day one.
**Fix**: Start with headlines and folding. Add TODO items. Set up the agenda. That is enough
for weeks. Add features as you need them. Nobody uses all of Org-mode.

### Too many files too early
**Trap**: A file per project, per area, per context. Suddenly 30 files, overwhelming refile.
**Fix**: Start with 1-3 files. The outline structure means one file can hold a lot.

### Ignoring the weekly review
**Trap**: Beautiful Org system, religious capture, no review. Inbox grows, projects stall.
**Fix**: Block time for it. Process inbox to zero. Review every project. This is non-optional.

### Not trusting the system
**Trap**: Capturing some things but keeping "important" ones in your head.
**Fix**: Capture everything. Use SCHEDULED and DEADLINE. Once the agenda reliably surfaces
what you need, you stop keeping things in your head. That mental relief is the actual payoff.

---

## Part 6: Obsidian to Org-mode Mapping Table

### Format Differences

| Feature    | Obsidian                          | Org-roam                                               |
|------------|-----------------------------------|--------------------------------------------------------|
| Links      | `[[Note Title]]`                  | `[[id:UUID][Description]]`                             |
| Tags       | `#tag` or YAML `tags:`            | `#+filetags: :tag1:tag2:` or `:TAG:` on headings       |
| Metadata   | YAML frontmatter                  | `:PROPERTIES:` drawer                                  |
| File format| Markdown (`.md`)                  | Org (`.org`)                                           |
| Headings   | `# ## ###`                        | `* ** ***`                                             |
| Bold/Italic| `**bold** *italic*`               | `*bold* /italic/`                                      |
| Code blocks| `` ```lang ``` ``                 | `#+begin_src lang ... #+end_src`                       |
| Embeds     | `![[note]]`                       | `#+include:` directive                                 |
| Checkboxes | `- [ ] task`                      | `- [ ] task` (same!) or full TODO headlines             |

### Migration Tools

- **pandoc**: `pandoc -f markdown -t org` handles most syntax conversion
- **obs2org**: Python script for batch vault conversion with daily notes support
- **obsidian-to-org**: Focused on preserving links and structure

### Recommended Migration Approach

1. Set up org-roam, get comfortable creating new notes in it
2. Batch-convert Obsidian vault with pandoc + cleanup script
3. Add `:PROPERTIES:` drawers with `:ID:` UUIDs to each file
4. Convert `[[wiki-links]]` to `[[id:...][title]]` format
5. Run `org-roam-db-sync` to rebuild the database
6. Spend a few sessions fixing links and tags manually

---

## Sources

### Primary Workflow References
- [Bernt Hansen — Org Mode: Organize Your Life In Plain Text](http://doc.norang.ca/org-mode.html)
- [Sacha Chua — How I Organize My Org Files](https://sachachua.com/blog/2013/08/emacs-how-i-organize-my-org-files/)
- [Nicolas Rougier — Get Things Done with Emacs](https://www.labri.fr/perso/nrougier/GTD/index.html)
- [Jethro Kuan — How to Take Smart Notes with Org-mode](https://blog.jethro.dev/posts/how_to_take_smart_notes_org/)
- [Karl Voit — UOMF Series](https://karl-voit.at/orgmode/)
- [Boris Buliga — Task Management with Roam (7-part)](https://www.d12frosted.io/posts/2021-05-21-task-management-with-roam-vol7)
- [Wai Hon Law — Org-mode Task Management](https://whhone.com/posts/org-mode-task-management/)
- [Juan Reyero — Org-mode for Team Management](http://juanreyero.com/article/emacs/org-teams/)
- [Howard Abrams — Capturing Content](https://howardism.org/Technical/Emacs/capturing-content.html)
- [Daryl Manning — Emacs GTD Flow Evolved](https://daryl.wakatara.com/emacs-gtd-flow-evolved/)

### Official Documentation
- [Org Mode Manual](https://orgmode.org/org.html)
- [Org Mode Compact Guide](https://orgmode.org/orgguide.html)
- [Worg — Community Wiki](https://orgmode.org/worg/)

### Tools and Packages
- [org-roam](https://github.com/org-roam/org-roam) — Linked notes with backlinks
- [org-roam-ui](https://github.com/org-roam/org-roam-ui) — Interactive graph visualization
- [org-super-agenda](https://github.com/alphapapa/org-super-agenda) — Grouped agenda views
- [org-journal](https://github.com/bastibe/org-journal) — Daily journaling
- [gptel](https://github.com/karthink/gptel) — LLM client for Emacs (Claude, GPT, etc.)
- [org-ql](https://github.com/alphapapa/org-ql) — SQL-like queries for org files

### Community and Tutorials
- [System Crafters — Build a Second Brain](https://systemcrafters.net/build-a-second-brain-in-emacs/getting-started-with-org-roam/)
- [System Crafters — Custom Org Agenda Views](https://systemcrafters.net/org-mode-productivity/custom-org-agenda-views/)
- [rougier/emacs-gtd (GitHub)](https://github.com/rougier/emacs-gtd)
- [EmacsConf Talks](https://emacsconf.org/)
