#!/usr/bin/env python
from pathlib import Path

glossary_path = Path("parts", "glossary.qmd")

with open(glossary_path, "r") as f:
    glossary_lines = [x.rstrip() for x in f]

glossary_lines = glossary_lines[2:]
glossary = {}

for i in range(len(glossary_lines)):
    line = glossary_lines[i]
    if ": " in line:
        title = glossary_lines[i - 1]
        if title[0].lower() == title[0]:
            title = "".join(title[0].upper() + title[1:])
        glossary[title] = line

sorted_keys = list(glossary.keys())
sorted_keys.sort()

with open(glossary_path, "w") as f:
    f.write("# Glossary {.unnumbered}\n")
    f.write("\n")
    for key in sorted_keys:
        f.write(key + "\n")
        f.write(glossary[key] + "\n")
        f.write("\n")
