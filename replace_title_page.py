#!/usr/bin/env python
from PyPDF2 import PdfWriter, PageRange
from pathlib import Path

merger = PdfWriter()

with open('title-page.pdf', 'rb') as f:
    merger.append(f)

dissertation_location = Path('_book', 'posert-dissertation.pdf')
with open(dissertation_location, 'rb') as f:
    merger.append(f, pages=PageRange('1:'))

merger.write(dissertation_location)