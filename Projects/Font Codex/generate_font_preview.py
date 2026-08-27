#!/usr/bin/env python3
r"""
generate_font_preview_final.py

Robust generator that:
 - reads a FontCodex CSV (your sheet)
 - finds actual font files (by internal name, filename stem, fuzzy matches)
 - extracts internal font display name (nameID 4 or nameID 1)
 - registers fonts and generates:
    - FontCodex_Preview.pdf
    - FontCodex_Preview.xlsx  (column B visually previews each font)
    - FontCodex_Preview_Cleaned.csv
Usage:
    python generate_font_preview_final.py --input "FontCodex.csv" --fonts-dir "C:\Users\brigi\AppData\Local\Microsoft\Windows\Fonts" "C:\Windows\Fonts"
"""

import os
import re
import argparse
from pathlib import Path
from collections import OrderedDict

# fuzzy matching - prefer python-Levenshtein if available
try:
    import Levenshtein as _lev
    def fuzzy_ratio(a,b):
        return _lev.ratio(a,b)
except Exception:
    from difflib import SequenceMatcher
    def fuzzy_ratio(a,b):
        return SequenceMatcher(None, a, b).ratio()

import pandas as pd
from fontTools.ttLib import TTFont
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont as RL_TTFont
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from openpyxl import Workbook
from openpyxl.styles import Font as XLFont

# ---------- Config ----------
FONT_EXTS = {".ttf", ".otf", ".ttc", ".woff", ".woff2"}
ILLEGAL_EXCEL_RE = re.compile(r"[\x00-\x08\x0B\x0C\x0E-\x1F]")

def sanitize_excel(s):
    if pd.isna(s):
        return ""
    return ILLEGAL_EXCEL_RE.sub("", str(s))

def safe_str(s):
    return "" if s is None else str(s)

# ---- font name extraction ----
def read_internal_names(font_path: Path):
    """
    Return a tuple (fullname, familyname, postscriptname) from the font file.
    If unavailable, returns (stem, stem, stem).
    """
    try:
        tt = TTFont(str(font_path), ignoreDecompileErrors=True)
        fullname = None
        family = None
        post = None
        for rec in tt["name"].names:
            try:
                txt = rec.toStr()
            except Exception:
                continue
            if rec.nameID == 4 and not fullname:
                fullname = txt
            if rec.nameID == 1 and not family:
                family = txt
            if rec.nameID == 6 and not post:
                post = txt
        chosen_full = fullname or family or post or font_path.stem
        return (safe_str(fullname or ""), safe_str(family or ""), safe_str(post or ""), chosen_full)
    except Exception as e:
        return ("", "", "", font_path.stem)

def index_font_folders(font_dirs):
    """
    Walk the provided font directories, gather font files and internal names.
    Returns:
      - file_list: list of font file full paths
      - by_internal: dict mapping lower(internal name) -> [paths]
      - by_stem: dict mapping lower(filename stem) -> [paths]
      - meta: dict path -> dict(fullname, family, post)
    """
    by_internal = {}
    by_stem = {}
    meta = {}
    file_list = []
    for fd in font_dirs:
        fd = Path(fd)
        if not fd.exists():
            continue
        for p in fd.rglob("*"):
            if p.suffix.lower() not in FONT_EXTS:
                continue
            try:
                fullname, family, post, chosen = read_internal_names(p)
            except Exception:
                fullname, family, post, chosen = ("", "", "", p.stem)
            file_list.append(str(p.resolve()))
            # index by several internal labels and by filename stem
            for key in filter(None, [fullname, family, post, chosen]):
                by_internal.setdefault(key.strip().lower(), []).append(str(p.resolve()))
            by_stem.setdefault(p.stem.lower(), []).append(str(p.resolve()))
            meta[str(p.resolve())] = {"fullname":fullname, "family":family, "post":post, "chosen":chosen}
    return file_list, by_internal, by_stem, meta

def find_font_file_for_label(label, by_internal, by_stem, meta):
    """
    Try to locate the best font file path for the given label.
    Steps:
      1) exact internal name match
      2) exact stem match
      3) fuzzy internal name match (threshold)
      4) fuzzy stem match
      5) fallback None
    Returns (path, reason, matched_internal_name)
    """
    if not label:
        return None, "empty", ""
    L = label.strip().lower()
    # 1 exact internal
    if L in by_internal:
        return by_internal[L][0], "exact-internal", L
    # 2 exact stem
    if L in by_stem:
        return by_stem[L][0], "exact-stem", L
    # 3 fuzzy internal
    best = None
    best_score = 0.0
    for key in by_internal.keys():
        score = fuzzy_ratio(L, key)
        if score > best_score:
            best_score = score
            best = key
    if best and best_score >= 0.75:
        return by_internal[best][0], f"fuzzy-internal:{best_score:.2f}", best
    # 4 fuzzy stem
    best = None
    best_score = 0.0
    for key in by_stem.keys():
        score = fuzzy_ratio(L, key)
        if score > best_score:
            best_score = score
            best = key
    if best and best_score >= 0.75:
        return by_stem[best][0], f"fuzzy-stem:{best_score:.2f}", best
    return None, "not-found", ""

# ---- PDF building ----
def register_font_for_pdf(path, pdf_reg_map):
    """
    Register font file for ReportLab if not already registered.
    Return registration name (string) or None if failed.
    We use a stable alias per path.
    """
    path = str(path)
    if path in pdf_reg_map:
        return pdf_reg_map[path]
    try:
        # create safe alias
        alias = "FNT_" + re.sub(r"\W+", "_", os.path.basename(path))
        pdfmetrics.registerFont(RL_TTFont(alias, path))
        pdf_reg_map[path] = alias
        return alias
    except Exception:
        pdf_reg_map[path] = None
        return None

def generate_pdf_from_rows(rows, out_pdf_path):
    page_w, page_h = letter
    c = canvas.Canvas(out_pdf_path, pagesize=letter)
    margin = 50
    y = page_h - margin
    line_h = 30
    pdf_reg_map = {}

    # rows already in desired print sequence
    for r in rows:
        label = r.get("LabelToShow", r.get("CleanName"))
        font_path = r.get("MatchedPath")
        regname = None
        if font_path:
            regname = register_font_for_pdf(font_path, pdf_reg_map)
        if regname:
            try:
                c.setFont(regname, 20)
            except Exception:
                c.setFont("Helvetica", 14)
                label = f"{label}  (render-fallback)"
        else:
            c.setFont("Helvetica", 14)
            label = f"{label}  (missing)"
        c.drawString(margin, y, safe_str(label))
        y -= line_h
        if y < margin:
            c.showPage()
            y = page_h - margin
    c.save()

# ---- XLSX building ----
def generate_xlsx_from_rows(rows, out_xlsx_path):
    wb = Workbook()
    ws = wb.active
    ws.title = "Font Codex Preview"

    headers = ["Label", "Preview (font)", "Category", "Found", "MatchedPath", "MatchReason", "InternalName"]
    ws.append(headers)

    for r in rows:
        label = r.get("LabelToShow", r.get("CleanName"))
        matched = r.get("MatchedPath", "")
        found = r.get("Found", False)
        reason = r.get("MatchReason", "")
        internal = r.get("InternalName", "")

        ws.append([sanitize_excel(label), sanitize_excel(label), sanitize_excel(r.get("Category", "")),
                   "Yes" if found else "No", sanitize_excel(matched), sanitize_excel(reason), sanitize_excel(internal)])
        # apply font to column B if font found
        if found and matched:
            try:
                # prefer internal name for cell font; fallback to family/full chosen
                fontname = internal or r.get("XLFontFamily") or r.get("XLFontFull") or r.get("CleanName")
                ws_cell = ws.cell(row=ws.max_row, column=2)
                ws_cell.font = XLFont(name=safe_str(fontname), size=14)
            except Exception:
                # if applying style fails, ignore but keep row
                pass

    # save xlsx
    wb.save(out_xlsx_path)

# ---- main flow ----
def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input", "-i", required=True, help="Path to FontCodex CSV (local)")
    p.add_argument("--fonts-dir", "-f", required=False, nargs="+", help="One or more font directories to scan (order matters).")
    p.add_argument("--out-prefix", default="FontCodex_Preview", help="Output file prefix")
    args = p.parse_args()

    input_csv = Path(args.input)
    if not input_csv.exists():
        print("ERROR: input CSV not found:", input_csv)
        return

    # read CSV — attempt to detect font-name column but allow any
    df = pd.read_csv(input_csv, dtype=str, keep_default_na=False)
    # pick column likely holding font names
    name_cols = [c for c in df.columns if c.lower() in ("font", "fontname", "font name", "name")]
    if name_cols:
        name_col = name_cols[0]
    else:
        # fallback to first column
        name_col = df.columns[0]

    # prepare rows: label is whatever you want printed, CleanName will be used for matching attempts
    rows = []
    for _, row in df.iterrows():
        raw = safe_str(row.get(name_col, "")).strip()
        if not raw:
            continue
        # store label (keep parentheses/notes for human), but CleanName strips trailing annotations like "(not installed)"
        label = raw
        clean = re.sub(r"\s*\(.*?\)\s*$", "", raw).strip()
        # additional cleanup: remove stray markers at end like " y", " t" etc.
        clean = re.sub(r"\b(?:y|t|z|w|installed|all accents|no accents|\*|\+|•)\b\s*$", "", clean, flags=re.IGNORECASE).strip()
        rows.append({"Raw": raw, "LabelToShow": label, "CleanName": clean, "Category": safe_str(row.get("Category",""))})

    # build font indexes
    font_dirs = args.fonts_dir or []
    # if user didn't pass dirs, default to standard Windows folders
    if not font_dirs:
        font_dirs = [r"C:\Users\brigi\AppData\Local\Microsoft\Windows\Fonts", r"C:\Windows\Fonts"]
    print("Scanning font directories:", font_dirs)
    file_list, by_internal, by_stem, meta = index_font_folders(font_dirs)
    print(f"Found {len(file_list)} font files across scanned dirs.")

    # match each row robustly
    results = []
    for r in rows:
        label = r["LabelToShow"]
        clean = r["CleanName"]
        # 1) try match using clean name
        path, reason, matched_key = find_font_file_for_label(clean, by_internal, by_stem, meta)
        # 2) If not found, try using raw label (sometimes the label included more accurate token)
        if not path:
            path, reason2, matched_key2 = find_font_file_for_label(label, by_internal, by_stem, meta)
            if path:
                reason = reason2
                matched_key = matched_key2
        # 3) If still not found, try fuzzy lower thresholds (relaxed)
        if not path:
            # try fuzzy against internal names with lower cutoff
            bestscore = 0.0
            bestkey = None
            for k in by_internal.keys():
                score = fuzzy_ratio(clean.lower(), k)
                if score > bestscore:
                    bestscore = score
                    bestkey = k
            if bestkey and bestscore >= 0.6:
                path = by_internal[bestkey][0]
                reason = f"relaxed-fuzzy-internal:{bestscore:.2f}"
                matched_key = bestkey

        found = bool(path)
        internal_display = ""
        internal_family = ""
        internal_full = ""
        if path:
            internal_full, internal_family, internal_post, chosen = read_internal_names(Path(path))
            internal_display = chosen
            internal_family = internal_family or internal_full or chosen
            internal_full = internal_full or chosen

        results.append({
            "Raw": r["Raw"],
            "LabelToShow": label,
            "CleanName": clean,
            "Category": r.get("Category",""),
            "MatchedPath": path or "",
            "Found": found,
            "MatchReason": reason or "not-found",
            "InternalName": internal_display,
            "XLFontFamily": internal_family,
            "XLFontFull": internal_full
        })

    # Sorting: you said you want them to flow in perfect sequence, alphabetically by type.
    # We'll sort by Category then CleanName (both case-insensitive). If no Category, sort globally.
    results_sorted = sorted(results, key=lambda x: (x.get("Category","").lower(), x.get("CleanName","").lower()))

    # write cleaned CSV
    cleaned_csv = args.out_prefix + "_Cleaned.csv"
    pd.DataFrame(results_sorted).to_csv(cleaned_csv, index=False, encoding="utf-8")
    print("Wrote cleaned CSV:", cleaned_csv)

    # generate PDF
    pdf_out = args.out_prefix + ".pdf"
    print("Generating PDF:", pdf_out)
    generate_pdf_from_rows(results_sorted, pdf_out)
    print("PDF generated:", pdf_out)

    # generate XLSX
    xlsx_out = args.out_prefix + ".xlsx"
    print("Generating XLSX:", xlsx_out)
    generate_xlsx_from_rows(results_sorted, xlsx_out)
    print("XLSX generated:", xlsx_out)

    # final diagnostics
    total = len(results_sorted)
    found_count = sum(1 for r in results_sorted if r["Found"])
    print(f"Matched {found_count}/{total} fonts ({found_count/total:.0%}) across scanned font directories.")
    print("If some high-priority fonts didn't match, open the *_Cleaned.csv and adjust the CleanName to match internal name or filename stem, then rerun.")

if __name__ == "__main__":
    main()