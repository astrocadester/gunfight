# Gun Fight — technical debt and verification

The original ROM is the source of truth; never exchange an exact build for a similar implementation.

| ID | Issue | Exit evidence |
|---|---|---|
| GF-RE-001 | Additional native paths named and given headers; remaining generic labels and full register/call contracts incomplete | Proven caller/callee analysis and readable function headers |
| GF-RE-002 | Detailed player movement, fire, hit and score behavior not yet completely documented | Native control/data trace linked to script dispatch and ROM |
| GF-RE-003 | Ten 8×10 numeric font glyphs now decoded inline; other packed sprite/object boundaries remain | Native decoder, remaining pointers, dimensions, inline rendered row documentation |
| GF-RE-004 | Rooted packet analysis spans earlier bounded scans and later extended traversal | Reconcile safe boundaries, operand layouts and all script roots |
| GF-RE-005 | Source generator remains a separate research tool and can overwrite maintained ASM if invoked manually | Preserve source edits; update deliberate research workflow and reconcile generated data before adoption |
| GF-RE-006 | New direct-build scripts and revised source not yet run against zmac/MAME here | Linux and Windows native build, four SHA-1 checks, MAME launch and execution results |
| GF-RE-007 | WB runtime comparison depends on verified source relationships | Update WB document after proven Gun Fight RE and cross-references |

## v20261108-0001 verification record

- GitHub source and documentation edits: committed.
- Original ROM verification against rebuilt chips: **not executed**.
- Linux and Windows build scripts: **not executed**.
- MAME execution: **not executed**.
- Physical original board: **not executed**.
- No new implementation of gameplay or interpreter introduced.

## v20261108-0002 follow-up

Sea Wolf II README format and memory-map implementation committed. Native 8080 handlers, bitmap coordinate conversion, text drawing, input-event tables, player fire and ten score-font glyphs reviewed and annotated. This is static reverse engineering; local assembly, ROM hashes, MAME and Windows execution are still not performed in this session.
