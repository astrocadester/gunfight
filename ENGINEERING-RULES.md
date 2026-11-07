# Engineering rules — ORIGINAL SOFTWARE FIRST

1. **Authority:** Use and preserve original source, original languages, interpreter, native compiler/XC, runtime, DATA, graphics, algorithms and control flow whenever available.
2. **Complete native programs:** Feed complete original-style programs/source screens to the original native loader and compiler. TERSE word definitions, compilation order, dictionaries, token semantics and allocation are owned by TERSE/XC, not host JavaScript/Python.
3. **Host boundaries:** Node, Python, shell may launch original tools, transport untouched source, package their output, hash and verify independently. They shall NOT parse original source definitions, synthesize dictionary/word address maps, recreate gameplay/artwork, or rewrite compiler output tokens.
4. **Hardware adaptations:** Native assembly is allowed only for necessary hardware-specific interfaces with traceable original source behavior. Never introduce fabricated behavior in lieu of original code.
5. **No unauthorized shortcuts:** If blocked, STOP and investigate the original method. Obtain explicit user approval before any alternate toolchain, parser, translation, implementation, or workaround. Passing tests does NOT grant approval.
6. **Verification:** Source audit, native compiler build, ROM byte equality, MAME/emulator execution and hardware tests are separate gates. Never claim something passed without actually running it.
7. **Documents:** README describes actual project/build/architecture; approved work in docs/SPRINT-PLAN.md; issues and deviations in docs/TECHNICAL-DEBT.md. Preserve previous docs and work.
8. **PR gate:** Document original source/toolchain, hardware-specific deviations, their approval, executed tests and pending tasks. Block unapproved architectural substitutions regardless of passing tests.

Mandatory for all contributors and coding assistants. Assistants cannot approve their own deviations.
