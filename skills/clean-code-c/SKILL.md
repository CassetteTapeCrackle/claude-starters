---
name: clean-code-c
description: Use when writing or reviewing C — deeper idioms (ownership discipline, bounded string ops, allocation checking, linkage, initialization) beyond clang-tidy.
---

# Clean-code C (depth)

On top of the base rules (C11, CMake, clang-tidy, ASan+UBSan, Unity/CMocka).

## Memory & ownership
- Document ownership at every allocating function: who frees, when. One owner; transfer explicitly.
- Check every `malloc`/`realloc`/`calloc` return. Free on every path (goto-cleanup pattern for multi-resource functions).
- Set freed pointers to `NULL` if reused. Never return pointers to stack locals.

## Safety
- No VLAs; no unbounded `strcpy`/`strcat`/`sprintf` — use `snprintf` and bounded copies with explicit sizes.
- `sizeof(*ptr)` (variable) over `sizeof(Type)` so it survives type changes. Initialize every variable at declaration.

## Structure
- `static` for internal-linkage functions/globals; expose the minimum in headers.
- `const`-correct parameters; `size_t` for sizes/indices. Small functions; early returns; one responsibility per file.

## Smells
- An allocation whose free path isn't obvious → add the ownership comment or restructure with goto-cleanup.
- `sprintf`/`strcpy` into a fixed buffer → bounded call.
- Uninitialized variable read (UBSan will catch it) → initialize at declaration.
