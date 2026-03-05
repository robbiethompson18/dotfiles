# Incorporate Feedback

You're processing bug reports or QA feedback. Follow these guidelines:

## Process

1. **Triage first** - Read all feedback before fixing anything. Prioritize:
   - P0: Broken core functionality (auth, data loss, security)
   - P1: Important but not blocking
   - P2/P3: Nice-to-haves, skip unless trivial

2. **Fix issues** - Work through P0s first, then P1s. Skip low-priority issues that don't affect core UX.

3. **Commit to git** - After fixing, always commit your changes with a descriptive message. Don't batch multiple sessions without committing.

4. **Deploy** - After committing, deploy to production:
   - API: Build, push to ECR, update ECS service
   - Web: Build, sync to S3, invalidate CloudFront

5. **Reply/close** - If feedback came via email, reply confirming fixes. Mark issues resolved in any tracking system.

## Limitations

- **npm**: Cannot publish - requires MFA/OTP that can't be automated. Note this in replies and move on.
- **Pulumi secrets**: If adding new secrets, use `pulumi config set --secret`

## Low-Priority Issues to Skip

These are real concerns but not worth fixing during QA loops:
- Cosmetic improvements (UI polish, formatting)
- "Would be nice" features not affecting core flow
- Performance optimizations without measured impact
- Documentation gaps
- Test coverage increases

## Checklist Before Finishing

- [ ] All P0/P1 issues addressed
- [ ] Code committed to git
- [ ] Deployed to production
- [ ] Replied to feedback source (email, DB, etc.)
- [ ] Noted any issues you couldn't fix (npm, etc.)
