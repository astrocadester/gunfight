# Technical debt — architecture audit

This baseline does not assert these defects are present. Keep existing issue registers elsewhere intact.

| ID | Status | Exit evidence |
| --- | --- | --- |
| ENG-001 | Audit | Find host-language source parsers, dictionary/word mappings and token patches; replace with native tooling. |
| ENG-002 | Audit | Verify original-style native source load and genuine compiler/runtime image generation. |
| ENG-003 | Audit | Trace required hardware adaptations to original behavior; obtain prior approvals for deviations. |
| ENG-004 | Audit | Document actual compiler, ROM, emulator and physical hardware test results separately. |

Close with source/commit/testing evidence. See ENGINEERING-RULES.md.
