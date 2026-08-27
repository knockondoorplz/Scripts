#!/usr/bin/env python3
"""
make_font_codex.py

Usage:
    python make_font_codex.py --input-md fonts_md.txt --fonts-dir "C:\Windows\Fonts"

Outputs:
    - FontCodex.csv
    - FontCodex.xlsx
    - FontCodex.pdf

Notes:
    - Best-effort cleaning of annotations in the input markdown/text.
    - Uses fonttools to read font 'name' table and reportlab to register fonts for PDF rendering.
    - Skips system fonts (Windows system font dir) unless they appear in your codex list.
"""

import argparse
import os
import re
import csv
import sys
from pathlib import Path
from difflib import get_close_matches

import pandas as pd
from fontTools.ttLib import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont as RL_TTFont
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas

# -------------------------
# Configuration / Helpers
# -------------------------

# tokens/patterns that are annotations and should be removed when they appear at the end
ANNOTATION_TOKENS = [
    r"\by\b", r"\bt\b", r"\bz\b", r"\bw\b", r"\binstalled\b", r"\bcome back\b",
    r"\bno accents\b", r"\ball accents\b", r"\baccents\b", r"\bauto\b",
    r"\bhybrid\b", r"\binstalled\b", r"\buse 1st\b", r"\bhas upside down question marks\b"
]
ANNOTATION_RE = re.compile(
    r"(?:\s*(?:\*|[•\+\✓\u2713\u2714xX]))+$|"  # trailing punctuation markers * + • ✓ x
    + r"|(" + r"|".join(ANNOTATION_TOKENS) + r")\b.*$", re.IGNORECASE)

# remove stray notes in parentheses that are clearly annotations (heuristic):
PARENS_ANNOTATION_RE = re.compile(r"\s*\((?:no accents|all caps|installed|use 1st|all accents|no ¿|no ¿|no punctuation|no numbers|no accents|accents.*?)\)\s*$", re.IGNORECASE)

# heading detection (e.g. [Faves], [Tech])
HEADING_RE = re.compile(r"^\s*\[([^\]]+)\]\s*$")

# lines that clearly aren't font names (very long sentences) -> ignore
SENTENCE_LIKELY_RE = re.compile(r"[,:;].{5,}")

# file extensions to consider
FONT_EXTS = {".ttf", ".otf", ".ttc", ".woff", ".woff2"}

# system fonts dir (used to decide "system font" vs custom)
SYSTEM_FONTS_DIR = os.path.normcase(r"C:\Windows\Fonts")

def clean_font_name(raw: str) -> str:
    """
    Best-effort clean up of a font line from your markdown.
    Strips annotation tokens, trailing markers, extra punctuation.
    Returns a cleaned short font name.
    """
    s = raw.strip()

    # remove stray leading bullets or hyphens
    s = re.sub(r"^[\-\u2022\*]\s*", "", s)

    # if the line is too long and looks like a sentence, return empty (skip)
    if SENTENCE_LIKELY_RE.search(s) and len(s) > 60:
        return ""

    # remove common trailing parenthetical annotations we can detect
    s = PARENS_ANNOTATION_RE.sub("", s)

    # remove explicit trailing annotation tokens
    s = ANNOTATION_RE.sub("", s)

    # remove trailing stray punctuation
    s = s.strip(" \t\n\r:;-–—")

    # remove odd repeated markers at end (like 'y t', 'z t', 'y z')
    s = re.sub(r"\b(?:[ytzw]{1,2}\s*){1,3}$", "", s, flags=re.IGNORECASE).strip()

    # If the name contains quotes weirdness, strip them
    s = s.strip('"“”\'`')

    # Final cleanup whitespace
    s = re.sub(r"\s{2,}", " ", s).strip()

    return s

def read_fonts_dir(fonts_dir: Path):
    """
    Walk fonts_dir and return a mapping of discovered font names -> file path(s).
    We'll attempt to extract names from the font's 'name' table using fontTools.
    Returns: dict: lower_name -> list of filepaths
    """
    mapping = {}
    fonts_dir = Path(fonts_dir)
    for p in fonts_dir.glob("**/*"):
        if p.suffix.lower() not in FONT_EXTS:
            continue
        try:
            tt = TTFont(str(p), ignoreDecompileErrors=True)
            # nameID 1 = Font Family name, nameID 4 = Full Font Name (prefer 4 then 1)
            family = None
            fullname = None
            for record in tt["name"].names:
                try:
                    txt = record.toStr()
                except Exception:
                    continue
                if record.nameID == 4 and not fullname:
                    fullname = txt
                if record.nameID == 1 and not family:
                    family = txt
            chosen = fullname or family or p.stem
            if chosen:
                key = chosen.strip().lower()
                mapping.setdefault(key, []).append(str(p.resolve()))
            # also index by filename stem (helpful for slightly different names)
            mapping.setdefault(p.stem.lower(), []).append(str(p.resolve()))
        except Exception:
            # fallback: index by filename only
            mapping.setdefault(p.stem.lower(), []).append(str(p.resolve()))
    return mapping

# -------------------------
# Main processing
# -------------------------

def parse_input_md(md_path: Path):
    """
    Parse the provided Obsidian-style MD/text file.
    Returns: list of (category, fontname_raw) in the order found.
    """
    items = []
    current_cat = "Uncategorized"
    with open(md_path, "r", encoding="utf-8", errors="ignore") as fh:
        for raw in fh:
            line = raw.rstrip("\n")
            if not line.strip():
                continue
            h = HEADING_RE.match(line)
            if h:
                current_cat = h.group(1).strip()
                continue
            # some lists include lines like "###### Warp" as a subheading; ignore header marks
            if line.strip().startswith("#"):
                # normalize to heading text if short
                short = line.strip("# ").strip()
                if 1 <= len(short) <= 40:
                    current_cat = short
                    continue
                else:
                    continue
            # otherwise it's probably a font line
            items.append((current_cat, line.strip()))
    return items

def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-md", required=True, help="path to your exported obsidian/text file (fonts_md.txt)")
    parser.add_argument("--fonts-dir", required=False, help="path to fonts directory (defaults to C:\\Windows\\Fonts)")
    parser.add_argument("--output-prefix", default="FontCodex", help="output filename prefix")
    args = parser.parse_args(argv)

    input_md = Path(args.input_md)
    if not input_md.exists():
        print("ERROR: input file not found:", input_md)
        sys.exit(1)

    fonts_dir = Path(args.fonts_dir) if args.fonts_dir else Path(SYSTEM_FONTS_DIR)
    if not fonts_dir.exists():
        print("WARNING: fonts-dir does not exist, falling back to system fonts path:", SYSTEM_FONTS_DIR)
        fonts_dir = Path(SYSTEM_FONTS_DIR)

    print("Parsing input file:", input_md)
    raw_items = parse_input_md(input_md)
    print(f"Found {len(raw_items)} raw font lines (including duplicates & notes).")

    # Clean names and build category map
    cleaned = []
    for cat, raw in raw_items:
        cname = clean_font_name(raw)
        if not cname:
            continue
        cleaned.append((cat.strip() if cat else "Uncategorized", cname))

    # Deduplicate preserving order: last occurrence wins for category mapping
    seen = {}
    ordered = []
    for cat, name in cleaned:
        key = name.lower()
        if key not in seen:
            ordered.append((cat, name))
            seen[key] = cat

    print(f"Cleaned and deduped -> {len(ordered)} candidate font names.")

    # Read fonts dir and build installed font mapping
    print("Scanning fonts directory (this can take a few seconds)...")
    installed_map = read_fonts_dir(fonts_dir)
    installed_keys = set(installed_map.keys())

    # cross-reference
    results = []  # rows: dict {FontName,Category,Found,MatchedPath,MatchedName,Reason}
    for cat, fname in ordered:
        key = fname.lower()
        row = {"FontName": fname, "Category": cat, "Found": False, "MatchedPath": "", "MatchedName": "", "Reason": ""}
        # direct match
        if key in installed_map:
            row["Found"] = True
            row["MatchedPath"] = installed_map[key][0]
            row["MatchedName"] = key
            row["Reason"] = "exact match"
        else:
            # try close matches by name
            candidate_keys = get_close_matches(key, installed_keys, n=3, cutoff=0.75)
            if candidate_keys:
                chosen = candidate_keys[0]
                row["Found"] = True
                row["MatchedPath"] = installed_map[chosen][0]
                row["MatchedName"] = chosen
                row["Reason"] = f"fuzzy match -> {chosen}"
            else:
                row["Reason"] = "not installed"
        results.append(row)

    # Also include fonts that are in the fonts directory but not in the codex list IF they are not in system fonts dir
    # (i.e., include custom fonts the script found that you didn't list)
    include_extra = []
    for installed_name, paths in installed_map.items():
        # skip if already present in results (matched name)
        if any(r["MatchedName"] == installed_name for r in results if r["MatchedName"]):
            continue
        # determine if installed file is in system dir - if so, skip (we don't want Windows default junk)
        p0 = Path(paths[0])
        p0_norm = os.path.normcase(str(p0))
        is_system = os.path.commonpath([p0_norm, os.path.normcase(SYSTEM_FONTS_DIR)]) == os.path.normcase(SYSTEM_FONTS_DIR)
        if not is_system:
            # include as an "Unlisted Installed" font
            include_extra.append({"FontName": installed_name, "Category": "Unlisted Installed", "Found": True, "MatchedPath": paths[0], "MatchedName": installed_name, "Reason": "installed-unlisted"})

    print(f"Adding {len(include_extra)} installed-but-unlisted custom fonts (non-system).")
    for ex in include_extra:
        results.append(ex)

    # Build DataFrame and write CSV/XLSX
    df = pd.DataFrame(results)
    csv_out = f"{args.output_prefix}.csv"
    xlsx_out = f"{args.output_prefix}.xlsx"
    df.to_csv(csv_out, index=False, encoding="utf-8")
    df.to_excel(xlsx_out, index=False)
    print("Wrote:", csv_out, xlsx_out)

    # Build PDF
    pdf_out = f"{args.output_prefix}.pdf"
    page_w, page_h = letter
    c = canvas.Canvas(pdf_out, pagesize=letter)
    margin = 40
    y = page_h - margin
    line_height_base = 18

    # We will group by Category, printing each category header then font list.
    grouped = {}
    for r in results:
        grouped.setdefault(r["Category"], []).append(r)

    # Sort categories alphabetically, but keep 'Unlisted Installed' at the end
    cats = sorted(k for k in grouped.keys() if k != "Unlisted Installed")
    if "Unlisted Installed" in grouped:
        cats.append("Unlisted Installed")

    registered = {}  # map font registration name -> filepath

    for cat in cats:
        # write category heading (small)
        if y < margin + 100:
            c.showPage()
            y = page_h - margin
        c.setFont("Helvetica-Bold", 12)
        c.drawString(margin, y, cat)
        y -= line_height_base + 2

        # for each font in category, try to register and print using its font
        for entry in grouped[cat]:
            fname = entry["FontName"]
            path = entry["MatchedPath"]
            if entry["Found"] and path:
                # create a unique registration name (avoid duplicates)
                regname = (fname + "_" + os.path.basename(path)).replace(" ", "_")[:60]
                if regname not in registered:
                    try:
                        pdfmetrics.registerFont(RL_TTFont(regname, path))
                        registered[regname] = path
                    except Exception as e:
                        # registration failed; fallback
                        regname = None
                # print the font name with registered face if possible
                if regname and regname in registered:
                    try:
                        c.setFont(regname, 16)
                    except Exception:
                        c.setFont("Helvetica", 12)
                else:
                    c.setFont("Helvetica", 12)
                c.drawString(margin + 10, y, fname)
            else:
                # not found -> print name in Helvetica with an indicator
                c.setFont("Helvetica-Oblique", 12)
                c.drawString(margin + 10, y, fname + "  (not installed)")
            y -= line_height_base + 2
            if y < margin + 50:
                c.showPage()
                y = page_h - margin

    c.save()
    print("PDF written:", pdf_out)
    print("All done. Please open the CSV/XLSX in LibreOffice to review categories and any 'not installed' flags.")
    print("If you want, I can also produce a plain .docx where each font name is in its own run (but PDF is more reliable).")

if __name__ == "__main__":
    main()
