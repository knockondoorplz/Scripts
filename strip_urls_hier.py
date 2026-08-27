#!/usr/bin/env python3
# Minimal bookmark skeleton extractor
# Outputs:
# Category
# url
# url
# Parent > Child
# url
# ...
#
# No external libs required.

import sys
from html.parser import HTMLParser

class BookmarkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.stack = []            # current folder stack
        self.last_h3 = None        # H3 text waiting for its DL
        self.capturing_h3 = False
        self.h3_buf = []
        self.capturing_a = False
        self.current_href = None
        self.a_buf = []
        self.printed_paths = set() # set of tuples of stack paths we've already printed

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'h3':
            self.capturing_h3 = True
            self.h3_buf = []
        elif tag == 'dl':
            # If an H3 immediately preceded this <DL>, push it as a folder level
            if self.last_h3:
                self.stack.append(self.last_h3)
                self.last_h3 = None
        elif tag == 'a':
            href = attrs.get('href') or attrs.get('HREF')
            if href:
                self.capturing_a = True
                self.current_href = href.strip()
                self.a_buf = []

    def handle_endtag(self, tag):
        if tag == 'h3':
            self.capturing_h3 = False
            text = ''.join(self.h3_buf).strip()
            # store for the next <dl> to pick up and push to stack
            self.last_h3 = text if text else None
            self.h3_buf = []
        elif tag == 'a':
            if self.capturing_a and self.current_href:
                # print header for current stack path if not yet printed
                path_tuple = tuple(self.stack)
                if path_tuple not in self.printed_paths:
                    if path_tuple:  # Only print a path line if there is at least one folder
                        print(' > '.join(path_tuple))
                    self.printed_paths.add(path_tuple)
                # Print the URL only (minimal)
                print(self.current_href)
            # reset link state
            self.capturing_a = False
            self.current_href = None
            self.a_buf = []
        elif tag == 'dl':
            # pop a folder level if present (closing the current DL)
            if self.stack:
                self.stack.pop()

    def handle_data(self, data):
        if self.capturing_h3:
            self.h3_buf.append(data)
        elif self.capturing_a:
            self.a_buf.append(data)

def main():
    if len(sys.argv) < 2:
        print("Usage: python strip_urls_hier.py omegabookmarks.html", file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            html = f.read()
    except Exception as e:
        print("Error reading file:", e, file=sys.stderr)
        sys.exit(1)

    parser = BookmarkParser()
    parser.feed(html)
    parser.close()

if __name__ == "__main__":
    main()
