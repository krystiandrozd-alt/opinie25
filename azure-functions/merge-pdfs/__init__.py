import logging
import json
import base64
import io
from typing import List
import azure.functions as func
from PyPDF2 import PdfMerger, PdfReader
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from datetime import datetime

def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Azure Function: Merge PDFs
    Merges multiple PDF documents into a single PDF for student opinion packages
    """
    logging.info('Merge PDFs function triggered')

    try:
        # Parse request body
        req_body = req.get_json()

        # Validate required fields
        if 'pdfs' not in req_body:
            return func.HttpResponse(
                json.dumps({
                    "error": "Missing 'pdfs' field in request body",
                    "usage": "Send array of base64-encoded PDF files"
                }),
                status_code=400,
                mimetype="application/json"
            )

        pdfs_data = req_body.get('pdfs', [])
        options = req_body.get('options', {})

        # Options
        add_cover_page = options.get('addCoverPage', False)
        cover_page_info = options.get('coverPageInfo', {})
        add_page_numbers = options.get('addPageNumbers', True)

        if not isinstance(pdfs_data, list) or len(pdfs_data) == 0:
            return func.HttpResponse(
                json.dumps({"error": "pdfs must be a non-empty array"}),
                status_code=400,
                mimetype="application/json"
            )

        # Create PDF merger
        merger = PdfMerger()

        # Add cover page if requested
        if add_cover_page:
            cover_pdf = create_cover_page(cover_page_info)
            merger.append(cover_pdf)

        # Decode and merge PDFs
        for idx, pdf_base64 in enumerate(pdfs_data):
            try:
                # Decode base64
                pdf_bytes = base64.b64decode(pdf_base64)
                pdf_file = io.BytesIO(pdf_bytes)

                # Append to merger
                merger.append(pdf_file)
                logging.info(f'Added PDF {idx + 1}/{len(pdfs_data)}')

            except Exception as e:
                logging.error(f'Error processing PDF {idx + 1}: {str(e)}')
                return func.HttpResponse(
                    json.dumps({
                        "error": f"Failed to process PDF {idx + 1}",
                        "message": str(e)
                    }),
                    status_code=400,
                    mimetype="application/json"
                )

        # Write merged PDF to bytes
        output = io.BytesIO()
        merger.write(output)
        merger.close()

        # Get the merged PDF bytes
        output.seek(0)
        merged_pdf_bytes = output.read()

        # Encode to base64
        merged_pdf_base64 = base64.b64encode(merged_pdf_bytes).decode('utf-8')

        # Calculate statistics
        output.seek(0)
        reader = PdfReader(output)
        page_count = len(reader.pages)

        # Return success response
        return func.HttpResponse(
            json.dumps({
                "success": True,
                "pdfBase64": merged_pdf_base64,
                "stats": {
                    "totalPages": page_count,
                    "sourceDocuments": len(pdfs_data),
                    "fileSizeBytes": len(merged_pdf_bytes)
                },
                "timestamp": datetime.utcnow().isoformat()
            }),
            status_code=200,
            mimetype="application/json"
        )

    except ValueError as e:
        logging.error(f'Invalid JSON in request: {str(e)}')
        return func.HttpResponse(
            json.dumps({"error": "Invalid JSON in request body"}),
            status_code=400,
            mimetype="application/json"
        )

    except Exception as e:
        logging.error(f'Error merging PDFs: {str(e)}')
        return func.HttpResponse(
            json.dumps({
                "error": "Failed to merge PDFs",
                "message": str(e)
            }),
            status_code=500,
            mimetype="application/json"
        )


def create_cover_page(info: dict) -> io.BytesIO:
    """
    Creates a cover page for the opinion package
    """
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4

    # Title
    c.setFont("Helvetica-Bold", 24)
    c.drawCentredString(width / 2, height - 4*cm, "Opinia Ucznia")

    # Student info
    c.setFont("Helvetica", 14)
    y = height - 7*cm

    if 'studentName' in info:
        c.drawString(4*cm, y, f"Uczeń: {info['studentName']}")
        y -= 1*cm

    if 'sectionName' in info:
        c.drawString(4*cm, y, f"Klasa: {info['sectionName']}")
        y -= 1*cm

    if 'schoolYear' in info:
        c.drawString(4*cm, y, f"Rok szkolny: {info['schoolYear']}")
        y -= 1*cm

    if 'semester' in info:
        c.drawString(4*cm, y, f"Semestr: {info['semester']}")
        y -= 1*cm

    if 'schoolName' in info:
        c.drawString(4*cm, y, f"Szkoła: {info['schoolName']}")
        y -= 1*cm

    # Date
    c.setFont("Helvetica", 10)
    c.drawString(4*cm, 3*cm, f"Wygenerowano: {datetime.now().strftime('%Y-%m-%d %H:%M')}")

    c.showPage()
    c.save()

    buffer.seek(0)
    return buffer
