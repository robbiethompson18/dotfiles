#!/usr/bin/env python3
"""Direct AgentMail CLI for Codex's global inbox."""

import base64
import json
import mimetypes
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_FILE = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".env"))
API_BASE = "https://api.agentmail.to/v0"


def die(message):
    print(f"Error: {message}", file=sys.stderr)
    sys.exit(1)


def load_config():
    config = {}
    try:
        with open(CONFIG_FILE) as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                config[key] = value
    except FileNotFoundError:
        pass

    api_key = os.environ.get("AGENTMAIL_API_KEY") or config.get("AGENTMAIL_API_KEY")
    inbox = (
        os.environ.get("CODEX_AGENTMAIL_INBOX")
        or config.get("CODEX_AGENTMAIL_INBOX")
    )
    if not api_key:
        die(f"AGENTMAIL_API_KEY is missing. Add it to {CONFIG_FILE}.")
    if not inbox:
        die(f"CODEX_AGENTMAIL_INBOX is missing. Add it to {CONFIG_FILE}.")
    return api_key, inbox


def request(method, path, api_key, data=None):
    headers = {"Authorization": f"Bearer {api_key}"}
    body = None
    if data is not None:
        headers["Content-Type"] = "application/json"
        body = json.dumps(data).encode("utf-8")

    req = urllib.request.Request(
        f"{API_BASE}{path}",
        data=body,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(req) as response:
            return response.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        try:
            error_body = exc.read().decode("utf-8")
        except Exception:
            error_body = ""
        die(f"HTTP {exc.code}: {error_body}")
    except urllib.error.URLError as exc:
        die(f"Connection error: {exc.reason}")


def looks_like_html(text):
    return bool(re.search(r"<[a-zA-Z][^>]*>", text))


def parse_attachments(args):
    remaining = []
    attachments = []
    i = 0
    while i < len(args):
        if args[i] != "--attach":
            remaining.append(args[i])
            i += 1
            continue
        if i + 1 >= len(args):
            die("--attach requires a path")
        path = args[i + 1]
        try:
            with open(path, "rb") as f:
                raw = f.read()
        except OSError as exc:
            die(f"Cannot read attachment {path}: {exc}")
        content_type, _ = mimetypes.guess_type(path)
        attachments.append(
            {
                "filename": os.path.basename(path),
                "content_type": content_type or "application/octet-stream",
                "content": base64.b64encode(raw).decode("ascii"),
            }
        )
        i += 2
    return remaining, attachments


def parse_body(args, require_body=True):
    force_html = None
    body_parts = []
    for arg in args:
        if arg == "--html":
            force_html = True
        elif arg == "--text":
            force_html = False
        else:
            body_parts.append(arg)

    body = " ".join(body_parts)
    if not body and not sys.stdin.isatty():
        body = sys.stdin.read()
    if not body and require_body:
        die("No body provided. Pass text as an argument or pipe stdin.")

    is_html = force_html if force_html is not None else looks_like_html(body)
    return body, is_html


def body_payload(body, is_html):
    if not body:
        return {}
    return {"html" if is_html else "text": body}


def usage():
    print("Usage: agentmail.py <command> [args...]")
    print()
    print("Commands:")
    print("  inbox")
    print("  list [limit]")
    print("  threads [limit]")
    print("  thread <thread-id>")
    print("  read <message-id>")
    print("  send <to> <subject> [--html|--text] [--attach <path>]... [body]")
    print("  reply <message-id> [--html|--text] [--attach <path>]... [body]")
    print("  attachment <message-id> <attachment-id>")


def main():
    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    api_key, inbox = load_config()
    encoded_inbox = urllib.parse.quote(inbox, safe="")
    cmd = sys.argv[1]

    if cmd in ("inbox", "get-inbox"):
        print(request("GET", f"/inboxes/{encoded_inbox}", api_key))
    elif cmd in ("list", "list-messages"):
        limit = sys.argv[2] if len(sys.argv) > 2 else "10"
        print(request("GET", f"/inboxes/{encoded_inbox}/messages?limit={limit}", api_key))
    elif cmd in ("threads", "list-threads"):
        limit = sys.argv[2] if len(sys.argv) > 2 else "10"
        print(request("GET", f"/inboxes/{encoded_inbox}/threads?limit={limit}", api_key))
    elif cmd in ("thread", "get-thread"):
        if len(sys.argv) < 3:
            die("Usage: agentmail.py thread <thread-id>")
        thread_id = urllib.parse.quote(sys.argv[2], safe="")
        print(request("GET", f"/inboxes/{encoded_inbox}/threads/{thread_id}", api_key))
    elif cmd in ("read", "get-message"):
        if len(sys.argv) < 3:
            die("Usage: agentmail.py read <message-id>")
        message_id = urllib.parse.quote(sys.argv[2], safe="")
        print(request("GET", f"/inboxes/{encoded_inbox}/messages/{message_id}", api_key))
    elif cmd == "send":
        if len(sys.argv) < 4:
            die("Usage: agentmail.py send <to> <subject> [body]")
        rest, attachments = parse_attachments(sys.argv[4:])
        body, is_html = parse_body(rest, require_body=not attachments)
        payload = {"to": sys.argv[2], "subject": sys.argv[3], **body_payload(body, is_html)}
        if attachments:
            payload["attachments"] = attachments
        print(request("POST", f"/inboxes/{encoded_inbox}/messages/send", api_key, payload))
    elif cmd == "reply":
        if len(sys.argv) < 3:
            die("Usage: agentmail.py reply <message-id> [body]")
        message_id = urllib.parse.quote(sys.argv[2], safe="")
        rest, attachments = parse_attachments(sys.argv[3:])
        body, is_html = parse_body(rest, require_body=not attachments)
        payload = body_payload(body, is_html)
        if attachments:
            payload["attachments"] = attachments
        print(
            request(
                "POST",
                f"/inboxes/{encoded_inbox}/messages/{message_id}/reply",
                api_key,
                payload,
            )
        )
    elif cmd in ("attachment", "get-attachment"):
        if len(sys.argv) < 4:
            die("Usage: agentmail.py attachment <message-id> <attachment-id>")
        message_id = urllib.parse.quote(sys.argv[2], safe="")
        attachment_id = urllib.parse.quote(sys.argv[3], safe="")
        print(
            request(
                "GET",
                f"/inboxes/{encoded_inbox}/messages/{message_id}/attachments/{attachment_id}",
                api_key,
            )
        )
    else:
        usage()
        sys.exit(1)


if __name__ == "__main__":
    main()
