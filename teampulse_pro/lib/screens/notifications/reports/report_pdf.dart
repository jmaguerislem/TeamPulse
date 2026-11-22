import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Génère le rapport en PDF et ouvre le partage Android
/// (enregistrer dans Drive / Fichiers, envoyer par mail…).
Future<void> exportReportPdf({
  required String title,
  required String subtitle,
  required List<(String, String)> rows,
}) async {
  // Police avec accents et apostrophes typographiques (téléchargée une fois).
  final regular = await PdfGoogleFonts.dMSansRegular();
  final bold = await PdfGoogleFonts.dMSansBold();
  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TeamPulse Pro',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.indigo),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 28),
          ...rows.map(
            (r) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(r.$1),
                  pw.Text(
                    r.$2,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: 'rapport-teampulse.pdf',
  );
}
