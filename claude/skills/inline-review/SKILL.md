---
name: inline-review
description:
  Review the current diff for style and correctness, add review comments inline without changing
  executable behavior, then ship the comments immediately. Use only when Robbie explicitly asks
  for an inline review.
---

# Inline Review

1. Run `git diff` and review only the changes it shows.
2. Add concise, language-appropriate comments adjacent to style or correctness issues.
3. Do not change executable behavior; add only review comments.
4. Invoke the `ship` skill immediately after adding the comments.
