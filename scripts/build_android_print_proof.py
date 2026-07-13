#!/usr/bin/env python3

"""Build a print-size proof PDF from the unedited Android source screenshots."""

from pathlib import Path
import sys

from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.utils import ImageReader


ROOT = Path(__file__).resolve().parent.parent
SCREENSHOT_ROOT = ROOT / "docs" / "book-screenshots"
DEFAULT_OUTPUT = ROOT / "tmp" / "pdfs" / "android-print-proof.pdf"


def draw_image_page(pdf: Canvas, image_path: Path, width_mm: int, label: str) -> None:
    page_width, page_height = A4
    image = ImageReader(str(image_path))
    pixel_width, pixel_height = image.getSize()
    draw_width = width_mm * mm
    draw_height = draw_width * pixel_height / pixel_width
    x = (page_width - draw_width) / 2
    y = (page_height - draw_height) / 2

    pdf.setFont("Helvetica-Bold", 11)
    pdf.drawString(18 * mm, page_height - 18 * mm, label)
    pdf.setFont("Helvetica", 9)
    pdf.drawString(
        18 * mm,
        page_height - 24 * mm,
        f"Unedited source - placed width {width_mm} mm - {pixel_width} x {pixel_height} px",
    )
    pdf.drawImage(image, x, y, width=draw_width, height=draw_height, preserveAspectRatio=True)
    pdf.setLineWidth(0.5)
    pdf.rect(x, y, draw_width, draw_height)
    pdf.showPage()


def main() -> None:
    output = Path(sys.argv[1]).expanduser().resolve() if len(sys.argv) > 1 else DEFAULT_OUTPUT
    output.parent.mkdir(parents=True, exist_ok=True)

    app_images = sorted((SCREENSHOT_ROOT / "android-app").glob("a-*.png"))
    console_images = sorted((SCREENSHOT_ROOT / "google-play").glob("g-*.jpg"))
    if len(app_images) != 6 or len(console_images) != 20:
        raise SystemExit(
            f"Expected 6 app images and 20 console images, found {len(app_images)} and {len(console_images)}"
        )

    pdf = Canvas(str(output), pagesize=A4, pageCompression=1)
    pdf.setTitle("Android appendix print-size proof")
    for image_path in app_images:
        draw_image_page(pdf, image_path, 75, f"App screen - {image_path.name}")
    for image_path in console_images:
        draw_image_page(pdf, image_path, 130, f"Play Console - {image_path.name}")
    pdf.save()
    print(output)


if __name__ == "__main__":
    main()
