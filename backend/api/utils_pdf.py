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
