#!/usr/bin/env python3
"""Export Apple Notes from iCloud into Markdown files for use with Obsidian."""
from __future__ import annotations
import argparse
import getpass
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional, Sequence
from pyicloud import PyiCloudService
from pyicloud.exceptions import PyiCloudFailedLoginException
def slugify(value: str, fallback: str = "untitled") -> str:
    """Create a filesystem-safe slug for folder and file names."""
    cleaned = value.strip().replace("\0", "")
    cleaned = cleaned.replace("/", "-").replace("\\", "-")
    cleaned = cleaned.replace(":", " -").replace("*", "-")
    cleaned = cleaned.replace("?", "").replace("\"", "'")
    cleaned = cleaned.replace("<", "").replace(">", "").replace("|", "-")
    cleaned = " ".join(cleaned.split())
    trimmed = cleaned[:120]
    return trimmed or fallback
def ensure_folder(base_path: Path, folder_parts: Sequence[str]) -> Path:
    """Create nested directories that mirror the Notes folder hierarchy."""
    path = base_path
    for part in folder_parts:
        slug = slugify(part)
        path = path / slug
        path.mkdir(parents=True, exist_ok=True)
    return path
def unique_file_path(directory: Path, preferred_name: str) -> Path:
    """Generate a unique file path within *directory* using *preferred_name*."""
    path = directory / preferred_name
    if not path.exists():
        return path
    stem = path.stem
    suffix = path.suffix
    counter = 1
    while True:
        candidate = directory / f"{stem}_{counter}{suffix}"
        if not candidate.exists():
            return candidate
        counter += 1
def folder_components(note) -> List[str]:
    """Return the folder hierarchy for a note."""
    components: List[str] = []
    folder = getattr(note, "folder", None)
    if not folder:
        return components
    # Try multiple common attribute names exposed by pyicloud
    title = getattr(folder, "title", None) or getattr(folder, "name", None)
    if title:
        components.append(str(title))
    parent = getattr(folder, "parent", None)
    while parent:
        parent_title = getattr(parent, "title", None) or getattr(parent, "name", None)
        if parent_title:
            components.insert(0, str(parent_title))
        parent = getattr(parent, "parent", None)
    return components
def render_markdown(note_title: str, note_text: str, updated: Optional[datetime]) -> str:
    """Render a Markdown representation of the note."""
    normalized_text = (note_text or "").replace("\r\n", "\n")
    lines = normalized_text.splitlines()
    if lines and note_title and lines[0].strip() == note_title.strip():
        normalized_text = "\n".join(lines[1:]).lstrip("\n")
    header = f"# {note_title.strip()}\n\n" if note_title else ""
    body = normalized_text.rstrip() + "\n"
    metadata_lines: List[str] = []
    if updated:
        metadata_lines.append(f"last_updated: {updated.astimezone(timezone.utc).isoformat()}")
    metadata = "\n".join(metadata_lines)
    if metadata:
        return f"---\n{metadata}\n---\n\n{header}{body}"
    return f"{header}{body}"
def handle_two_factor(api: PyiCloudService) -> None:
    """Handle both Apple two-factor authentication flows."""
    if api.requires_2fa:
        print("Two-factor authentication required. Check your trusted device.")
        code = input("Enter the 6-digit code: ").strip()
        if not api.validate_2fa_code(code):
            raise RuntimeError("Invalid 2FA code.")
        api.trust_session()
    elif api.requires_2sa:
        devices = api.trusted_devices
        print("Two-step authentication required. Choose a device:")
        for index, device in enumerate(devices):
            name = device.get("deviceName", f"Device {index}")
            print(f"  [{index}] {name}")
        choice = input("Device number: ").strip()
        try:
            device_index = int(choice)
        except ValueError as exc:
            raise RuntimeError("Invalid device selection") from exc
        device = devices[device_index]
        if not api.send_verification_code(device):
            raise RuntimeError("Failed to send verification code")
        code = input("Verification code: ").strip()
        if not api.validate_verification_code(device, code):
            raise RuntimeError("Invalid verification code.")
def export_notes(api: PyiCloudService, destination: Path, dry_run: bool = False) -> int:
    """Export each iCloud note to a Markdown file and return the count."""
    destination.mkdir(parents=True, exist_ok=True)
    exported = 0
    notes_service = api.notes
    for note in notes_service.all():
        title = getattr(note, "title", None) or "Untitled"
        text = getattr(note, "text", "")
        if not isinstance(text, str):
            text = str(text or "")
        updated = getattr(note, "last_modified", None) or getattr(note, "modified", None)
        folder_parts = folder_components(note)
        note_dir = ensure_folder(destination, folder_parts)
        filename = slugify(title) + ".md"
        file_path = unique_file_path(note_dir, filename)
        if dry_run:
            print(f"Would export '{title}' -> {file_path}")
        else:
            file_path.write_text(render_markdown(title, text, updated), encoding="utf-8")
        exported += 1
    return exported
def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Export iCloud Notes to Markdown files.")
    parser.add_argument("apple_id", help="Apple ID email used for iCloud")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path.cwd() / "icloud-notes-export",
        help="Directory to write Markdown files into (default: ./icloud-notes-export)",
    )
    parser.add_argument(
        "--cookie-dir",
        type=Path,
        default=Path.home() / ".pyicloud",
        help="Location for cached authentication cookies to speed up future runs.",
    )
    parser.add_argument(
        "--password",
        help="Apple ID password. Omit to be prompted securely (recommended).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="List the files that would be created without writing them.",
    )
    return parser.parse_args(argv)
def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    output_dir = args.output.expanduser()
    try:
        output_dir = output_dir.resolve()
    except FileNotFoundError:
        # `resolve()` may fail on Windows for paths that do not yet exist. Fall back to
        # creating an absolute path manually.
        output_dir = (Path.cwd() / output_dir).resolve()
    cookie_dir = args.cookie_dir.expanduser()
    try:
        cookie_dir = cookie_dir.resolve()
    except FileNotFoundError:
        cookie_dir = (Path.cwd() / cookie_dir).resolve()
    password = args.password or getpass.getpass(prompt=f"Password for {args.apple_id}: ")
    try:
        api = PyiCloudService(args.apple_id, password, cookie_directory=str(cookie_dir))
    except PyiCloudFailedLoginException as exc:
        print(f"Failed to authenticate with iCloud: {exc}", file=sys.stderr)
        return 1
    try:
        handle_two_factor(api)
    except RuntimeError as exc:
        print(f"Authentication error: {exc}", file=sys.stderr)
        return 1
    try:
        count = export_notes(api, output_dir, dry_run=args.dry_run)
    except Exception as exc:  # pragma: no cover - bubble unexpected errors to the user
        print(f"Export failed: {exc}", file=sys.stderr)
        return 1
    print(f"Exported {count} notes to {output_dir}")
    return 0
if __name__ == "__main__":
    raise SystemExit(main())