#!/usr/bin/env python
from PyPDF2 import PdfWriter, PdfReader, PageRange
from pathlib import Path
import sys

# check if we've already added the title page

dissertation_location = Path("_book", "posert-dissertation.pdf")
try:
    with open(dissertation_location, "rb") as f:
        dissertation = PdfReader(f)
        should_be_acknowledgements = dissertation.pages[2].extract_text()
        if "For Lindsey, who shows me" in should_be_acknowledgements:
            sys.exit()
except FileNotFoundError:
    sys.exit()

merger = PdfWriter()

with open("title-page.pdf", "rb") as f:
    merger.append(f)

try:
    with open(dissertation_location, "rb") as f:
        merger.append(f, pages=PageRange("1:"))
except FileNotFoundError:
    sys.exit()

merger.write(dissertation_location)
