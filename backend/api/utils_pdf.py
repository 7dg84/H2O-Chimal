from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors

def generate_payment_pdf(tramite, amount):
    buffer = BytesIO()
    
    # Page setup - letter size: 612 x 792 points
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=45,
        leftMargin=45,
        topMargin=45,
        bottomMargin=45
    )
    
    story = []
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#1A365D'),  # Sleek dark blue
        alignment=1,  # Center
        spaceAfter=15
    )
    
    header_style = ParagraphStyle(
        'DocHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=colors.HexColor('#2B6CB0'),  # Medium blue
        spaceAfter=5
    )
    
    label_style = ParagraphStyle(
        'Label',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#2D3748')
    )
    
    value_style = ParagraphStyle(
        'Value',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=colors.HexColor('#4A5568')
    )
    
    amount_label_style = ParagraphStyle(
        'AmountLabel',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=17,
        textColor=colors.HexColor('#2D3748')
    )
    
    amount_value_style = ParagraphStyle(
        'AmountValue',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=colors.HexColor('#C53030')  # Crimson red for amount
    )

    footer_style = ParagraphStyle(
        'Footer',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor('#718096'),
        alignment=1,
        spaceBefore=15
    )
    
    # 1. Header/Logo
    story.append(Paragraph("H2O CHIMAL", ParagraphStyle('LogoText', fontName='Helvetica-Bold', fontSize=22, leading=26, textColor=colors.HexColor('#1A365D'), alignment=1)))
    story.append(Paragraph("Sistema de Gestión de Trámites de Agua", ParagraphStyle('SubLogoText', fontName='Helvetica', fontSize=9, leading=11, textColor=colors.HexColor('#718096'), alignment=1)))
    story.append(Spacer(1, 15))
    
    # 2. Main Title
    story.append(Paragraph("COMPROBANTE DE REQUERIMIENTO DE PAGO", title_style))
    story.append(Spacer(1, 8))
    
    # 3. Info Table
    user_name = tramite.user.name if tramite.user else "N/A"
    user_curp = tramite.user.curp if tramite.user else "N/A"
    user_email = tramite.user.email if tramite.user else "N/A"
    created_str = tramite.created_at.strftime("%d/%m/%Y %H:%M") if tramite.created_at else "Fecha actual"
    
    data = [
        [Paragraph("Detalles del Trámite", header_style), ""],
        [Paragraph("Folio del Trámite:", label_style), Paragraph(str(tramite.folio), value_style)],
        [Paragraph("Servicio:", label_style), Paragraph(tramite.service.name, value_style)],
        [Paragraph("Fecha de Solicitud:", label_style), Paragraph(created_str, value_style)],
        [Paragraph("Estado Actual:", label_style), Paragraph(tramite.status, value_style)],
        ["", ""],
        [Paragraph("Información del Solicitante", header_style), ""],
        [Paragraph("Nombre:", label_style), Paragraph(user_name, value_style)],
        [Paragraph("CURP:", label_style), Paragraph(user_curp, value_style)],
        [Paragraph("Correo Electrónico:", label_style), Paragraph(user_email, value_style)],
        ["", ""],
        [Paragraph("Detalles del Pago Requerido", header_style), ""],
        [Paragraph("Monto a Pagar:", amount_label_style), Paragraph(f"${amount:,.2f} MXN", amount_value_style)],
    ]
    
    table = Table(data, colWidths=[140, 360])
    table.setStyle(TableStyle([
        ('SPAN', (0, 0), (1, 0)),
        ('SPAN', (0, 6), (1, 6)),
        ('SPAN', (0, 11), (1, 11)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
        ('TOPPADDING', (0, 0), (-1, -1), 3),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('LINEBELOW', (0, 0), (1, 0), 1, colors.HexColor('#E2E8F0')),
        ('LINEBELOW', (0, 6), (1, 6), 1, colors.HexColor('#E2E8F0')),
        ('LINEBELOW', (0, 11), (1, 11), 1, colors.HexColor('#E2E8F0')),
        ('BACKGROUND', (0, 12), (1, 12), colors.HexColor('#FFF5F5')),
        ('BOX', (0, 12), (1, 12), 1, colors.HexColor('#FEB2B2')),
        ('TOPPADDING', (0, 12), (1, 12), 8),
        ('BOTTOMPADDING', (0, 12), (1, 12), 8),
    ]))
    
    story.append(table)
    story.append(Spacer(1, 30))
    
    # 4. Footer
    story.append(Paragraph("Este documento es una orden de pago automática generada por el sistema.", footer_style))
    story.append(Paragraph("Por favor, realice su pago en las ventanillas autorizadas o a través de los medios electrónicos oficiales.", footer_style))
    story.append(Paragraph(f"ID del Trámite: {tramite.id}", ParagraphStyle('SecCode', fontName='Courier', fontSize=7, leading=9, textColor=colors.HexColor('#A0AEC0'), alignment=1)))
    
    doc.build(story)
    
    pdf_bytes = buffer.getvalue()
    buffer.close()
    return pdf_bytes


def generate_oficio_pdf(tramite):
    from io import BytesIO
    from reportlab.lib.pagesizes import letter
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib import colors
    from reportlab.graphics.shapes import Drawing
    from reportlab.graphics.barcode.qr import QrCodeWidget
    from django.utils import timezone

    buffer = BytesIO()
    
    # Page setup - letter size: 612 x 792 points
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=45,
        leftMargin=45,
        topMargin=45,
        bottomMargin=45
    )
    
    story = []
    styles = getSampleStyleSheet()
    
    # Custom styles
    title_style = ParagraphStyle(
        'OficioTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#1A365D'),  # Sleek dark blue
        alignment=1,  # Center
        spaceAfter=10
    )
    
    left_header_style = ParagraphStyle(
        'LeftHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13,
        textColor=colors.HexColor('#1A365D'),
        alignment=0  # Left
    )

    right_header_style = ParagraphStyle(
        'RightHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13,
        textColor=colors.HexColor('#1A365D'),
        alignment=2  # Right
    )
    
    folio_label_style = ParagraphStyle(
        'FolioLabel',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=8,
        leading=10,
        textColor=colors.HexColor('#718096'),
        alignment=2
    )
    
    folio_value_style = ParagraphStyle(
        'FolioValue',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=colors.HexColor('#2D3748'),
        alignment=2
    )
    
    folio_text_style = ParagraphStyle(
        'FolioText',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=12,
        textColor=colors.HexColor('#718096'),
        alignment=2
    )
    
    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=13,
        textColor=colors.HexColor('#2C5282'),  # Faint blue
        spaceAfter=8
    )
    
    details_style = ParagraphStyle(
        'DetailsStyle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=14
    )
    
    cert_style = ParagraphStyle(
        'CertStyle',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=8.5,
        leading=12,
        textColor=colors.HexColor('#718096')
    )
    
    seal_icon_style = ParagraphStyle(
        'SealIcon',
        parent=styles['Normal'],
        alignment=1
    )
    
    seal_text_style = ParagraphStyle(
        'SealText',
        parent=styles['Normal'],
        leading=11
    )

    # 1. Header Table
    left_text = (
        "ODAPAS<br/>"
        "<font size='6' color='#718096'>ORGANISMO DESCENTRALIZADO DE AGUA POTABLE,<br/>"
        "ALCANTARILLADO Y SANEAMIENTO DE CHIMALHUACÁN</font>"
    )

    right_text = (
        "GOBIERNO DE<br/>"
        "CHIMALHUACÁN<br/>"
        "<font size='6' color='#718096'>H. AYUNTAMIENTO CONSTITUCIONAL</font>"
    )

    header_table = Table(
        [[Paragraph(left_text, left_header_style), Paragraph(right_text, right_header_style)]],
        colWidths=[261, 261]
    )
    header_table.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('TOPPADDING', (0, 0), (-1, -1), 0),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 0),
    ]))
    story.append(header_table)
    story.append(Spacer(1, 15))

    # 2. Folio and Date Block
    created_val = tramite.created_at or timezone.now()
    year = created_val.year
    months_es = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    month_str = months_es[created_val.month - 1]
    day = created_val.day
    date_str = f"{day} de {month_str}, {year}"
    
    folio_val = tramite.folio or 0
    folio_str = f"H2O-{year}-{folio_val:04d}"
    
    story.append(Paragraph("FOLIO DE CONTROL", folio_label_style))
    story.append(Paragraph(folio_str, folio_value_style))
    story.append(Paragraph("Chimalhuacán, Estado de México", folio_text_style))
    story.append(Paragraph(date_str, folio_text_style))
    story.append(Spacer(1, 20))

    # 3. Main Title
    story.append(Paragraph("OFICIO DE TRÁMITE", title_style))
    story.append(Spacer(1, 5))
    
    # Horizontal line below title
    line_table = Table([[""]], colWidths=[522], rowHeights=[2])
    line_table.setStyle(TableStyle([
        ('LINEBELOW', (0, 0), (-1, -1), 1.5, colors.HexColor('#1A365D')),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 0),
        ('TOPPADDING', (0, 0), (-1, -1), 0),
    ]))
    story.append(line_table)
    story.append(Spacer(1, 15))

    # 4. Datos del Trámite
    story.append(Paragraph("📋 DATOS DEL TRÁMITE", section_header_style))
    
    user = tramite.user
    if user:
        address_parts = []
        if user.street:
            address_parts.append(f"Calle {user.street}")
        if user.exterior_number:
            address_parts.append(f"No. {user.exterior_number}")
        if user.colonia:
            address_parts.append(f"Col. {user.colonia}")
        if user.postal_code:
            address_parts.append(f"C.P. {user.postal_code}")
        address_parts.append("Chimalhuacán, Estado de México")
        address_str = ", ".join(address_parts) + "."
    else:
        address_str = "Chimalhuacán, Estado de México."
        
    details_html = (
        f"<font size='7.5' color='#A0AEC0'><b>TIPO DE TRÁMITE</b></font><br/>"
        f"<font size='9.5' color='#2D3748'><b>{tramite.service.name}</b></font><br/><br/>"
        f"<font size='7.5' color='#A0AEC0'><b>UBICACIÓN</b></font><br/>"
        f"<font size='9.5' color='#2D3748'><b>{address_str}</b></font>"
    )
    
    details_table = Table([[Paragraph(details_html, details_style)]], colWidths=[510])
    details_table.setStyle(TableStyle([
        ('LINELEFT', (0, 0), (0, -1), 2.5, colors.HexColor('#3182CE')),  # Accent blue line on the left
        ('LEFTPADDING', (0, 0), (-1, -1), 12),
        ('RIGHTPADDING', (0, 0), (-1, -1), 0),
        ('TOPPADDING', (0, 0), (-1, -1), 2),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2),
    ]))
    story.append(details_table)
    story.append(Spacer(1, 20))

    # 5. Certificación Digital
    story.append(Paragraph("🛡️ CERTIFICACIÓN DIGITAL", section_header_style))
    
    cert_text = (
        "Este documento cuenta con validez jurídica institucional y ha sido timbrado electrónicamente "
        "mediante protocolos de encriptación seguros. La autenticidad puede ser verificada escaneando "
        "el código QR adjunto."
    )
    story.append(Paragraph(cert_text, cert_style))
    story.append(Spacer(1, 12))

    # 6. Sello de Validación
    seal_data = [
        [Paragraph("<font size='14' color='#4A5568'>🛡️</font>", seal_icon_style), 
         Paragraph("<font size='7' color='#A0AEC0'><b>SELLO DE VALIDACIÓN</b></font><br/>"
                   f"<font size='9' color='#2D3748'><b>AUTORIDAD H2O-G{year}</b></font>", seal_text_style)]
    ]
    seal_table = Table(seal_data, colWidths=[35, 487])
    seal_table.setStyle(TableStyle([
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ALIGN', (0, 0), (0, 0), 'CENTER'),
        ('TOPPADDING', (0, 0), (-1, -1), 0),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 0),
    ]))
    story.append(seal_table)
    story.append(Spacer(1, 20))

    # 7. QR Code inside a styled box
    verify_url = f"https://h2o.chimalhuacan.gob.mx/verify/oficio/{tramite.id}"
    qr = QrCodeWidget(verify_url)
    qr.barWidth = 90
    qr.barHeight = 90
    qr.x = 0
    qr.y = 0

    qr_drawing = Drawing(90, 90)
    qr_drawing.add(qr)

    qr_table = Table([[qr_drawing]], colWidths=[100])
    qr_table.setStyle(TableStyle([
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#E2E8F0')),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 4),
        ('RIGHTPADDING', (0, 0), (-1, -1), 4),
    ]))
    qr_table.hAlign = 'CENTER'
    story.append(qr_table)

    def draw_footer_and_background(canvas, doc):
        canvas.saveState()
        canvas.setFont('Helvetica', 7)
        canvas.setFillColor(colors.HexColor('#A0AEC0'))
        canvas.drawCentredString(306, 25, "H. AYUNTAMIENTO DE CHIMALHUACÁN | ODAPAS | DIRECCIÓN TÉCNICA")
        canvas.restoreState()

    doc.build(story, onFirstPage=draw_footer_and_background)
    
    pdf_bytes = buffer.getvalue()
    buffer.close()
    return pdf_bytes

