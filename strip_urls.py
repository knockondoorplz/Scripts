import re, sys

data = open(sys.argv[1], 'r', encoding='utf-8', errors='ignore').read()
urls = re.findall(r'https?://[^"\s<>]+', data)

seen = set()
for u in urls:
    if u not in seen:
        seen.add(u)
        print(u)
