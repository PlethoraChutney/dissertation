#!/usr/bin/env python
from PyPDF2 import PdfWriter, PageRange
from pathlib import Path
import sys

merger = PdfWriter()

with open("title-page.pdf", "rb") as f:
    merger.append(f)

dissertation_location = Path("_book", "posert-dissertation.pdf")
try:
    with open(dissertation_location, "rb") as f:
        merger.append(f, pages=PageRange("1:"))
except FileNotFoundError:
    sys.exit()

merger.write(dissertation_location)
