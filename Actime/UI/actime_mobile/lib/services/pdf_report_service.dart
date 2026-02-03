import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

/// PDF Report generation service for organization reports
/// Handles generating and sharing PDF reports for participations and enrollments
class PdfReportService {
  // Singleton pattern
  static final PdfReportService _instance = PdfReportService._internal();
  factory PdfReportService() => _instance;
  PdfReportService._internal();

  // PDF color scheme
  static final PdfColor _primaryColor = PdfColor.fromHex('#0D7C8C');
  static const PdfColor _textColor = PdfColors.black;
  static final PdfColor _borderColor = PdfColor.fromHex('#E0E0E0');
  static final PdfColor _alternateRowColor = PdfColor.fromHex('#F5F5F5');

  /// Generate and share participations report
  Future<ApiResponse<void>> generateParticipationsReport({
    required String organizationId,
    required String organizationName,
    String? organizationLogoUrl,
    required List<EventParticipation> participations,
    required int totalParticipations,
  }) async {
    try {
      final pdf = await _buildParticipationsDocument(
        organizationName: organizationName,
        organizationLogoUrl: organizationLogoUrl,
        participations: participations,
        totalParticipations: totalParticipations,
      );

      final dateStr = DateFormat('dd_MM_yyyy').format(DateTime.now());
      await _shareOrSavePdf(pdf, 'Actime_Participations_Report_$dateStr.pdf');

      return ApiResponse.success(
        null,
        message: 'Izvještaj uspješno generisan',
      );
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// Generate and share enrollments/memberships report
  Future<ApiResponse<void>> generateEnrollmentsReport({
    required String organizationId,
    required String organizationName,
    String? organizationLogoUrl,
    required List<Membership> enrollments,
  }) async {
    try {
      final pdf = await _buildEnrollmentsDocument(
        organizationName: organizationName,
        organizationLogoUrl: organizationLogoUrl,
        enrollments: enrollments,
      );

      final dateStr = DateFormat('dd_MM_yyyy').format(DateTime.now());
      await _shareOrSavePdf(pdf, 'Actime_Enrollments_Report_$dateStr.pdf');

      return ApiResponse.success(
        null,
        message: 'Izvještaj uspješno generisan',
      );
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// Build participations PDF document
  Future<pw.Document> _buildParticipationsDocument({
    required String organizationName,
    String? organizationLogoUrl,
    required List<EventParticipation> participations,
    required int totalParticipations,
  }) async {
    final pdf = pw.Document();

    // Load logo if available
    pw.ImageProvider? logoImage;
    if (organizationLogoUrl != null && organizationLogoUrl.isNotEmpty) {
      try {
        logoImage = await networkImage(organizationLogoUrl);
      } catch (e) {
        // Logo failed to load, continue without it
        logoImage = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildReportHeader(
                organizationName: organizationName,
                logoImage: logoImage,
              ),
              pw.SizedBox(height: 30),

              // Report title
              pw.Text(
                'Participations Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 10),

              // Generated date
              pw.Text(
                'Generated: ${DateFormat('dd.MM.yyyy. HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary statistics
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: _alternateRowColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Total Participations: ',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '$totalParticipations',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Participations table
              if (participations.isEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Text(
                      'No participations to display',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                )
              else
                _buildParticipationsTable(participations),

              // Footer (pushed to bottom)
              pw.Spacer(),
              _buildReportFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Build enrollments PDF document
  Future<pw.Document> _buildEnrollmentsDocument({
    required String organizationName,
    String? organizationLogoUrl,
    required List<Membership> enrollments,
  }) async {
    final pdf = pw.Document();

    // Load logo if available
    pw.ImageProvider? logoImage;
    if (organizationLogoUrl != null && organizationLogoUrl.isNotEmpty) {
      try {
        logoImage = await networkImage(organizationLogoUrl);
      } catch (e) {
        // Logo failed to load, continue without it
        logoImage = null;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildReportHeader(
                organizationName: organizationName,
                logoImage: logoImage,
              ),
              pw.SizedBox(height: 30),

              // Report title
              pw.Text(
                'Enrollments Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 10),

              // Generated date
              pw.Text(
                'Generated: ${DateFormat('dd.MM.yyyy. HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary statistics
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: _alternateRowColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Total Enrolled Members: ',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${enrollments.length}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Enrollments table
              if (enrollments.isEmpty)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(40),
                    child: pw.Text(
                      'No enrolled members to display',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ),
                )
              else
                _buildEnrollmentsTable(enrollments),

              // Footer (pushed to bottom)
              pw.Spacer(),
              _buildReportFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Build report header with organization name and logo
  pw.Widget _buildReportHeader({
    required String organizationName,
    pw.ImageProvider? logoImage,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Organization info
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              organizationName,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: _primaryColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Actime',
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        // Logo
        if (logoImage != null)
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
          ),
      ],
    );
  }

  /// Build participations table
  pw.Widget _buildParticipationsTable(List<EventParticipation> participations) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _primaryColor),
          children: [
            _buildTableCell(
              'Event Name',
              isHeader: true,
              textColor: PdfColors.white,
            ),
            _buildTableCell(
              'Participants',
              isHeader: true,
              textColor: PdfColors.white,
            ),
          ],
        ),
        // Data rows
        ...participations.asMap().entries.map((entry) {
          final index = entry.key;
          final participation = entry.value;
          final isAlternate = index % 2 == 1;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isAlternate ? _alternateRowColor : PdfColors.white,
            ),
            children: [
              _buildTableCell(participation.eventName),
              _buildTableCell(
                '${participation.participantsCount}',
                alignment: pw.Alignment.center,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build enrollments table
  pw.Widget _buildEnrollmentsTable(List<Membership> enrollments) {
    final dateFormat = DateFormat('dd.MM.yyyy.');

    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _primaryColor),
          children: [
            _buildTableCell(
              'Member Name',
              isHeader: true,
              textColor: PdfColors.white,
            ),
            _buildTableCell(
              'Email',
              isHeader: true,
              textColor: PdfColors.white,
            ),
            _buildTableCell(
              'Enrollment Date',
              isHeader: true,
              textColor: PdfColors.white,
            ),
            _buildTableCell(
              'Months',
              isHeader: true,
              textColor: PdfColors.white,
            ),
          ],
        ),
        // Data rows
        ...enrollments.asMap().entries.map((entry) {
          final index = entry.key;
          final membership = entry.value;
          final isAlternate = index % 2 == 1;

          // Calculate months since enrollment
          final enrolledDate = membership.startDate ?? membership.createdAt;
          final monthsSinceEnrollment = DateTime.now().difference(enrolledDate).inDays ~/ 30;

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isAlternate ? _alternateRowColor : PdfColors.white,
            ),
            children: [
              _buildTableCell(membership.user?.name ?? 'Unknown'),
              _buildTableCell(membership.user?.email ?? 'N/A'),
              _buildTableCell(
                dateFormat.format(enrolledDate),
                alignment: pw.Alignment.center,
              ),
              _buildTableCell(
                '$monthsSinceEnrollment',
                alignment: pw.Alignment.center,
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Build table cell with consistent styling
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor textColor = _textColor,
    pw.Alignment alignment = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor,
        ),
      ),
    );
  }

  /// Build report footer
  pw.Widget _buildReportFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by Actime',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            DateFormat('dd.MM.yyyy. HH:mm:ss').format(DateTime.now()),
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Share or save PDF using native share sheet
  Future<void> _shareOrSavePdf(pw.Document pdf, String filename) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('SocketException')) {
      return 'Nema internet veze';
    }
    if (errorStr.contains('TimeoutException')) {
      return 'Generisanje izvještaja je isteklo. Pokušajte ponovo.';
    }
    if (errorStr.contains('FormatException')) {
      return 'Greška u formatiranju podataka';
    }
    if (errorStr.contains('NetworkImageLoadException')) {
      return 'Greška pri učitavanju loga organizacije';
    }

    return 'Došlo je do greške. Pokušajte ponovo.';
  }
}
