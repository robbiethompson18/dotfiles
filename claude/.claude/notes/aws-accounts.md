# Robbie's AWS accounts

Last audited: Sept 1, 2026.

There are three AWS accounts tied to Robbie. Two matter.

## 996434433218 — personal (root: rob0the0nerd@gmail.com)

Account name is `robbie_burner_for_ralph_loop`. Despite the name, this is the **active personal
account**. All personal-project AWS lives here:

- `vf-exercises` — IAM user `vf-exercises-recordings-uploader`, bucket
  `vf-exercises-recordings-996434433218-us-east-2-an` (us-east-2). `~/.aws` profile `vf-exercises`.
- `genome-analysis` — IAM user `genome-archive-rw`, bucket `robbie-genome-wgs-archive` (us-west-1).
  `~/.aws` profile `genome-archive`.

Root has passkey MFA (1Password) and no access keys. Billing alerts go to rob0the0nerd@gmail.com,
**not** robbiethompson2018, so check that inbox for AWS mail about this account.

## 216213517865 — Usebits / work

`~/.aws` `[default]` profile is IAM user `robbie` here (login_session, expires; re-run `aws login`).
Silkworm data bucket `usebits-silkworm-data-216213517865-us-west-1` and sapient DB backups
`s3://sapient-db-backups` live here.

## 435966167852 — dead 2020 account (root: robbiethompson2018@gmail.com)

Account name `robbiethompson`. Created March 24, 2020 for an Elastic Beanstalk experiment. As of
Sept 1, 2026 it contains:

- one S3 bucket `elasticbeanstalk-us-east-2-435966167852` with ~20 KB of 2020 deploy zips
- zero IAM users, zero Beanstalk envs, zero Route 53 domains
- $0 spend, $0 outstanding, default payment method is an **expired** Amex ····1016

AWS periodically emails robbiethompson2018@gmail.com "Action Required: AWS Account Alert" about
the expired card. **Ignore these.** Nothing is owed and nothing is running. Decision (Sept 2026):
not worth the root re-auth + captcha hassle to close it or move the email. If AWS eventually
suspends it for nonpayment, fine.

If you ever do want to close it: change root email to `robbiethompson2018+oldaws@gmail.com` first
(email stays reserved for 90 days after closure), then Billing → Account → Close account. Both
steps require a fresh root sign-in.

## Console login gotchas

- Root sign-in to a second account in a Chrome profile that already has an AWS session gives
  "Bad request ... clear your cookies". Use an incognito window.
- The signin captcha widget showing "Something went wrong, reload" is an extension blocking the
  captcha script, not a wrong answer. Incognito (extensions off) fixes it.
