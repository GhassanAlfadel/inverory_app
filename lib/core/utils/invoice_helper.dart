import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart' show rootBundle;

class InvoiceHelper {
  static Future<void> printInvoice({
    required int invoiceId,
    required DateTime date,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double discount,
  }) async {
    final pdf = pw.Document();

    // Load fonts from local assets for offline supportt
    // Note: We are using a highly compatible Arabic font to avoid parsing errors
    final regularFontData = await rootBundle.load(
      'assets/fonts/Arimo-Regular.ttf',
    );
    final boldFontData = await rootBundle.load('assets/fonts/Arimo-Bold.ttf');

    final arabicFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: boldFont),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Stack(
                    alignment: pw.Alignment.center,
                    children: [
                      // Store Name and Info
                      pw.Column(
                        children: [
                          pw.Text(
                            'جولدن استور',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 24,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.Text(
                            'بيع - شراء - استبدال',
                            style: pw.TextStyle(font: arabicFont, fontSize: 12),
                          ),
                          pw.Text(
                            'جميع ملحقات الهواتف المحمولة واللابتوبات',
                            style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          ),
                          pw.Text(
                            '٠٩١٣٩٥١٥٨٠ - ٠٩١٧١٧٧٠٠٧ : ت',
                            style: pw.TextStyle(font: arabicFont, fontSize: 10),
                          ),
                        ],
                      ),
                      // Logos (Placeholders)
                      pw.Positioned(
                        left: 0,
                        top: 0,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'LAPTOP',
                              style: pw.TextStyle(fontSize: 8, font: boldFont),
                            ),
                            pw.Text(
                              'SAMSUNG',
                              style: pw.TextStyle(fontSize: 8, font: boldFont),
                            ),
                          ],
                        ),
                      ),
                      pw.Positioned(
                        right: 0,
                        top: 0,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'HONOR',
                              style: pw.TextStyle(fontSize: 8, font: boldFont),
                            ),
                            pw.Text(
                              'HUAWEI / APPLE',
                              style: pw.TextStyle(fontSize: 8, font: boldFont),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // Invoice Type Box
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(5),
                      ),
                    ),
                    child: pw.Text(
                      'فاتورة مبدئية',
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                  ),
                ),

                pw.SizedBox(height: 15),

                // Date and Customer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'التاريخ: ${intl.DateFormat('yyyy/MM/dd').format(date)} م',
                      style: pw.TextStyle(font: arabicFont, fontSize: 12),
                    ),
                    pw.Text(
                      'الرقم: #$invoiceId',
                      style: pw.TextStyle(font: arabicFont, fontSize: 12),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'المطلوب من السيد: $customerName',
                  style: pw.TextStyle(font: arabicFont, fontSize: 12),
                ),

                pw.SizedBox(height: 15),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2), // Total
                    1: const pw.FlexColumnWidth(1), // Qty
                    2: const pw.FlexColumnWidth(4), // Item
                    3: const pw.FlexColumnWidth(2), // Price
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Text(
                              'الجملة',
                              style: pw.TextStyle(font: boldFont),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Text(
                              'العدد',
                              style: pw.TextStyle(font: boldFont),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Text(
                              'البيان',
                              style: pw.TextStyle(font: boldFont),
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Text(
                              'السعر',
                              style: pw.TextStyle(font: boldFont),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Item Rows
                    ...items.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Center(
                              child: pw.Text(
                                intl.NumberFormat(
                                  '#,##0',
                                ).format(item['subtotal']),
                                style: pw.TextStyle(font: arabicFont),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Center(
                              child: pw.Text(
                                '${item['quantity']}',
                                style: pw.TextStyle(font: arabicFont),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              item['product_name'],
                              style: pw.TextStyle(font: arabicFont),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Center(
                              child: pw.Text(
                                intl.NumberFormat(
                                  '#,##0',
                                ).format(item['price']),
                                style: pw.TextStyle(font: arabicFont),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Fill remaining space with empty rows
                    if (items.length < 8)
                      ...List.generate(8 - items.length, (index) {
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12),
                              child: pw.Text(''),
                            ),
                          ],
                        );
                      }),
                  ],
                ),

                pw.SizedBox(height: 15),

                // Footer
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'الجملة كتابة: ....................................',
                        style: pw.TextStyle(font: arabicFont, fontSize: 10),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                      ),
                      child: pw.Text(
                        'المجموع الكلي: ${intl.NumberFormat('#,##0.00').format(totalAmount)} SDG',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 30),

                pw.Align(
                  alignment: pw.Alignment.bottomLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'التوقيع',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '................................',
                        style: pw.TextStyle(font: arabicFont, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'فاتورة_$invoiceId',
    );
  }
}
