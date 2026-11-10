---
name: sapient-add
description:
  Add a review item (a practice prompt with an answer key, for spaced repetition) to Robbie's
  Sapient deck at sapient.school. Use when Robbie says "add this to sapient", "add to my deck",
  "make a card for this", "sapient this", or asks to remember something he just learned. Works
  from any Claude Code session, no sapient checkout needed.
argument-hint: "[what to remember]"
---

# Add to Robbie's Sapient deck

Sapient is Robbie's personal spaced-repetition app. A deck item is a short title plus one or two
practice prompts, each with its own answer key. Review serves the prompt, Robbie answers from
memory, and Fable grades against the answer key. So the answer key is what makes an item useful.

## 1. Decide what the item is

One item = one fact or skill. If Robbie asked to remember several distinct things, make several
items (one request each). If it's unclear which fact he means, ask, don't guess.

Author from the conversation: use what Robbie actually just learned, in the framing he learned it.
Don't pad with background he didn't ask about.

## 2. Author the prompt and answer key

`facts` is an array of 1 to 5 `{question, idealAnswer}` variants of the *same* fact. Default to
one. Add a second only when a genuinely different framing helps ("define X" vs "explain X to
someone who knows Y"). Each variant has its own answer key matching its framing.

Rules for `question`:

- Atomic: one fact or task, no compound "and" questions.
- Standalone and timeless: no "as discussed above", no "in this file". It will be asked months
  from now with no context.
- No answer leakage in the wording.
- Concrete enough to grade: "What does X do?" beats "Tell me about X."

Rules for `idealAnswer`: the answer Robbie should be able to give, 1 to 3 sentences, specific
enough that a grader can tell right from wrong.

`startingMastery` is `"new"` (default), `"familiar"`, or `"easy"`. Use familiar/easy only when
Robbie said it's already easy; those still get a confirmation review tomorrow.

`title` is 3 to 8 words. `notes` and `quote` (a verbatim excerpt) are optional.

## 3. Pick a course, or none

```bash
TOKEN=$(cat ~/.claude/docs/sapient-api-token)
curl -s -H "Authorization: Bearer $TOKEN" https://sapient.school/api/courses
```

Returns `[{id, title, units: [{id, title, objectives, position}], completedAt, ...}]`. If the
item clearly belongs to an active (no `completedAt`) course, pass that `courseId` and the
best-fitting `unitId`. Otherwise omit both; unfiled items are fine and still get reviewed. Never
pass one without the other.

## 4. Create it

```bash
curl -s -X POST https://sapient.school/api/learning-items \
  -H "Authorization: Bearer $TOKEN" \
  -H 'content-type: application/json' \
  -d '{
    "title": "pnpm overrides semantics",
    "facts": [{
      "question": "In pnpm, what does a pnpm.overrides entry like \"dompurify\": \">=3.4.17\" do?",
      "idealAnswer": "Forces every resolution of dompurify in the graph, including transitive ones, to a version satisfying >=3.4.17."
    }],
    "startingMastery": "new"
  }'
```

Use a heredoc or a temp JSON file for anything with quotes in it. The response is the item plus a
`url`; a 400 carries a readable `error`. Fable rates difficulty server-side against sibling items,
so the call takes a few seconds.

## 5. Report

Reply with the `url` and the prompt text you authored, so Robbie can fix the wording if he
disagrees. Nothing else is needed.

## Notes

- The token is a long-lived Sapient session stored in dotfiles-private (`~/.claude/docs/` is a
  symlink into it). If it 401s, mint a new one from a sapient checkout with
  `pnpm --filter @sapient/api exec tsx scripts/create-api-token.ts <email>` against prod and
  replace the file.
- Items without a practice prompt can't exist; the route rejects them. Don't try to work around
  that with a placeholder question.
