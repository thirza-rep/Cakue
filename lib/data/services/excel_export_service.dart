import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/transaction_entity.dart';

/// Service untuk export data transaksi ke format Excel (.xlsx)
class ExcelExportService {
  /// Export semua transaksi user dalam rentang bulan tertentu
  static Future<void> exportTransactions({
    required List<TransactionEntity> transactions,
    required String userName,
    required String yearMonth, // '2025-08'
  }) async {
    final excel = Excel.createExcel();

    // ─── Sheet 1: Ringkasan ─────────────────────────────────────
    final summarySheet = excel['Ringkasan'];
    excel.setDefaultSheet('Ringkasan');

    _writeSummary(summarySheet, transactions, userName, yearMonth);

    // ─── Sheet 2: Detail Transaksi ──────────────────────────────
    final detailSheet = excel['Detail Transaksi'];
    _writeDetail(detailSheet, transactions);

    // ─── Sheet 3: Per Kategori ──────────────────────────────────
    final categorySheet = excel['Per Kategori'];
    _writeCategorySummary(categorySheet, transactions);

    // ─── Simpan & Share ─────────────────────────────────────────
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Gagal encode Excel');

    final dir = await getTemporaryDirectory();
    final fileName = 'Cakue_${userName}_$yearMonth.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
      subject: 'Laporan Keuangan Cakue - $yearMonth',
      text: 'Laporan keuangan $userName untuk $yearMonth',
    );
  }

  static void _writeSummary(
    Sheet sheet,
    List<TransactionEntity> transactions,
    String userName,
    String yearMonth,
  ) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final income = transactions
        .where((t) => t.type == TransactionType.income && t.deletedAt == null)
        .fold<double>(0, (sum, t) => sum + t.baseAmount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense && t.deletedAt == null)
        .fold<double>(0, (sum, t) => sum + t.baseAmount);

    final headers = [
      ['Laporan Keuangan Cakue', ''],
      ['Nama', userName],
      ['Periode', yearMonth],
      ['Dibuat', DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())],
      ['', ''],
      ['Total Pemasukan', currency.format(income)],
      ['Total Pengeluaran', currency.format(expense)],
      ['Selisih', currency.format(income - expense)],
      ['Total Transaksi', '${transactions.length} transaksi'],
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i)).value = TextCellValue(headers[i][0]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i)).value = TextCellValue(headers[i][1]);
    }
  }

  static void _writeDetail(Sheet sheet, List<TransactionEntity> transactions) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');

    // Header row
    final headers = ['No', 'Tanggal', 'Tipe', 'Kategori', 'Rekening', 'Nominal', 'Catatan'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
    }

    // Data rows
    final sorted = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var i = 0; i < sorted.length; i++) {
      final t = sorted[i];
      final r = i + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r)).value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r)).value = TextCellValue(dateFormat.format(t.date));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: r)).value = TextCellValue(t.type.label);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: r)).value = TextCellValue(t.categoryUuid ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: r)).value = TextCellValue(t.accountUuid);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: r)).value = TextCellValue(currency.format(t.baseAmount));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: r)).value = TextCellValue(t.note ?? '');
    }
  }

  static void _writeCategorySummary(Sheet sheet, List<TransactionEntity> transactions) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      if (t.deletedAt != null) continue;
      final key = '${t.type.name}__${t.categoryUuid ?? 'Tanpa Kategori'}';
      categoryTotals[key] = (categoryTotals[key] ?? 0) + t.baseAmount;
    }

    final headers = ['Tipe', 'Kategori', 'Total'];
    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
    }

    var rowIdx = 1;
    categoryTotals.forEach((key, total) {
      final parts = key.split('__');
      final tipe = parts[0] == 'income' ? 'Pemasukan' : 'Pengeluaran';
      final kategori = parts.length > 1 ? parts[1] : 'Tanpa Kategori';
      
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx)).value = TextCellValue(tipe);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx)).value = TextCellValue(kategori);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx)).value = TextCellValue(currency.format(total));
      rowIdx++;
    });
  }
}
