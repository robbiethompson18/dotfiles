# Mac Disk Usage - July 5, 2026

Snapshot from Robbie's Mac after cleanup on July 5, 2026 Pacific time.

## Cleanup Performed

- Docker cleanup used `docker system prune -a --volumes -f` and `docker builder prune -a -f`.
- Docker reported 32.84 GB reclaimed.
- Cleared regenerable cache contents from `~/Library/Caches`, `~/.cache`, and npm cache/npx dirs.
- Ran `brew cleanup -s`, which reported about 328 MB reclaimed.
- Ran `pnpm store prune`.
- Removed 29 old duplicate VS Code extension directories, mostly old `anthropic.claude-code` versions, reclaiming about 5.63 GiB.

## Current High-Level State

- `/System/Volumes/Data`: 251 GiB used, 172 GiB free, 60% full.
- `~/Library`: 78G.
- `~/repos`: 78G.

## Current Notable Buckets

- `~/Library/Application Support`: 29G.
- `~/Library/Messages`: 22G.
- `~/Library/pnpm`: 11G.
- `~/Library/Group Containers`: 4.5G.
- `~/Library/Containers/com.docker.docker`: 3.0G.
- `~/.vscode/extensions`: 826M.
- `~/Library/Caches`: 33M.
- `~/.cache`: 19M.
- `~/.npm`: 1.1M.

## Remaining Cleanup Candidates

- `~/Library/Application Support` is the next place to inspect before deleting anything. Earlier scan showed large subtrees for Chrome and Claude, but do not blindly remove this whole directory.
- `~/Library/Messages` is mostly attachments and should be reviewed from Messages/storage UI or with a focused attachment scan.
- `~/Library/pnpm` is still 11G. It may be useful local package cache/store data; prune intentionally if reclaiming space matters more than reinstall speed.
- `~/repos/vf-exercises/raw-video` was volatile during the scan. It measured about 46G after cleanup, with large `.mov` files. Treat as an archive/cloud-storage candidate, not a cache.
- Desktop and media project folders are smaller but good cloud/archive candidates: `~/Screen Studio Projects`, `~/Desktop/video_v2`, `~/Desktop/HN video`, `~/Desktop/random_videos`, and `~/Movies/CapCut`.

## Notes

- The disk usage changed while scanning: before cleanup, free space was about 106 GiB; after cleanup it was about 172 GiB.
- `du` and `df` do not perfectly agree on macOS because APFS sparse files, clones, purgeable data, local snapshots, and permission-limited directories affect accounting.
