#!/usr/bin/env python3
"""Print Robbie's iMessage notes-to-self since the last "done" marker.

  self_messages.py                       notes since the most recent marker
  self_messages.py --since "2026-10-06"  notes since a local date/time instead
  self_messages.py --markers             list the last 10 markers and exit
  self_messages.py --mark-done           send a new marker to the self-chat

Reads ~/Library/Messages/chat.db read-only, so the terminal needs Full Disk Access.
"""

import argparse
import datetime
import os
import re
import sqlite3
import subprocess

DB_PATH = os.path.expanduser("~/Library/Messages/chat.db")
APPLE_EPOCH_OFFSET = 978307200  # message.date is nanoseconds since 2001-01-01 UTC
# iOS autocorrects "--" to an em dash, so a marker is a run of any dash type around "done".
MARKER_RE = re.compile(r"(?=.*[-–—]{3,})(?=.*\bdone\b)", re.IGNORECASE | re.DOTALL)
MARKER_MAX_LEN = 120
# A note to self is stored twice (sent copy + received copy), a second or two apart.
DUPLICATE_WINDOW_SECONDS = 120


def decode_attributed_body(blob):
    """Pull the plain text out of message.attributedBody.

    Recent macOS leaves message.text NULL and keeps the text in an NSArchiver typedstream. The
    text is the first NSString payload: 5 bytes of type info, then a length (1 byte, or 0x81 + 2
    bytes little-endian, or 0x82 + 4 bytes), then UTF-8.
    """
    if not blob:
        return ""
    marker_index = blob.find(b"NSString")
    if marker_index < 0:
        return ""
    rest = blob[marker_index + len(b"NSString") + 5 :]
    if not rest:
        return ""
    if rest[0] == 0x81:
        length, start = int.from_bytes(rest[1:3], "little"), 3
    elif rest[0] == 0x82:
        length, start = int.from_bytes(rest[1:5], "little"), 5
    else:
        length, start = rest[0], 1
    return rest[start : start + length].decode("utf-8", "replace")


def load_self_messages(db):
    """Every message in the chats Robbie has with his own number or Apple ID, oldest first."""
    rows = db.execute(
        """
        SELECT m.ROWID, m.date / 1000000000 + ?, c.chat_identifier, m.text, m.attributedBody,
               (SELECT group_concat(a.filename, ' | ')
                  FROM message_attachment_join maj JOIN attachment a ON a.ROWID = maj.attachment_id
                 WHERE maj.message_id = m.ROWID
                   AND a.filename NOT LIKE '%.pluginPayloadAttachment')  -- link previews
          FROM message m
          JOIN chat_message_join cmj ON cmj.message_id = m.ROWID
          JOIN chat c ON c.ROWID = cmj.chat_id
         WHERE c.chat_identifier IN (SELECT DISTINCT destination_caller_id FROM message
                                      WHERE is_from_me = 1 AND destination_caller_id IS NOT NULL)
           AND m.associated_message_type = 0  -- skip tapbacks
         ORDER BY m.date
        """,
        (APPLE_EPOCH_OFFSET,),
    ).fetchall()
    messages = []
    last_seen = {}  # (text, attachments) -> unix time of the copy we kept
    for rowid, unix_time, chat_identifier, text, body, attachments in rows:
        text = (text or decode_attributed_body(body)).replace("￼", "").strip()
        if not text and not attachments:
            continue
        key = (text, attachments)
        if key in last_seen and unix_time - last_seen[key] <= DUPLICATE_WINDOW_SECONDS:
            continue
        last_seen[key] = unix_time
        messages.append((rowid, unix_time, chat_identifier, text, attachments))
    return messages


def is_marker(text):
    return len(text) <= MARKER_MAX_LEN and bool(MARKER_RE.search(text))


def format_time(unix_time):
    return datetime.datetime.fromtimestamp(unix_time).strftime("%Y-%m-%d %H:%M")


def mark_done(messages):
    # Send to whichever self-chat was used most recently, so the handle never lives in this repo.
    handle = messages[-1][2]
    today = datetime.date.today()
    marker = f"—————done as of {today.month}/{today.day}/{today:%y}—————"
    script = (
        'tell application "Messages" to send (item 1 of argv) to '
        "buddy (item 2 of argv) of (1st service whose service type = iMessage)"
    )
    subprocess.run(
        ["osascript", "-e", "on run argv", "-e", script, "-e", "end run", marker, handle],
        check=True,
    )
    print(f"sent: {marker}")


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--since", help='local "YYYY-MM-DD" or "YYYY-MM-DD HH:MM" instead of the marker'
    )
    parser.add_argument("--markers", action="store_true", help="list the last 10 markers and exit")
    parser.add_argument("--mark-done", action="store_true", help="send a new done marker and exit")
    args = parser.parse_args()

    db = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    messages = load_self_messages(db)
    markers = [m for m in messages if is_marker(m[3])]

    if args.mark_done:
        mark_done(messages)
        return
    if args.markers:
        for _, unix_time, _, text, _ in markers[-10:]:
            print(f"{format_time(unix_time)}  {text}")
        return

    if args.since:
        since_format = "%Y-%m-%d %H:%M" if " " in args.since else "%Y-%m-%d"
        cutoff = datetime.datetime.strptime(args.since, since_format).timestamp()
        print(f"since {args.since} (--since)")
    elif markers:
        cutoff = markers[-1][1]
        print(f"last marker: {format_time(cutoff)}  {markers[-1][3]}")
    else:
        raise SystemExit("no done marker found; pass --since")

    notes = [m for m in messages if m[1] > cutoff]
    print(f"{len(notes)} notes since then\n")
    for _, unix_time, _, text, attachments in notes:
        print(
            f"[{format_time(unix_time)}] {text}"
            + (f"\n    ATTACHMENT: {attachments}" if attachments else "")
        )


if __name__ == "__main__":
    main()
