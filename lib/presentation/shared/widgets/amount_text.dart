import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Widget untuk menampilkan angka keuangan dengan format Rupiah
class AmountText extends StatelessWidget {
  final double amount;
  final String currency;
  final TextStyle? style;
  final bool compact;
  final bool showSign;
  final String? transactionType; // 'income' | 'expense' | 'transfer'

  const AmountText({
    super.key,
    required this.amount,
    this.currency = 'IDR',
    this.style,
    this.compact = false,
    this.showSign = false,
    this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ??
        AppTextStyles.amountMedium.copyWith(
          color: transactionType != null
              ? AppColors.byType(transactionType!)
              : AppColors.textPrimary,
        );

    return Text(
      _format(amount),
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _format(double value) {
    String prefix = '';
    if (value < 0) {
      prefix = '-';
    } else if (showSign && value > 0) {
      if (transactionType == 'expense') {
        prefix = '-';
      } else if (transactionType == 'income') {
        prefix = '+';
      } else if (transactionType == 'transfer') {
        prefix = '';
      } else {
        prefix = '+';
      }
    }

    if (compact && value.abs() >= 1000000000) {
      return '$prefix${currency == 'IDR' ? 'Rp' : currency} ${(value.abs() / 1000000000).toStringAsFixed(1)}M';
    }
    if (compact && value.abs() >= 1000000) {
      return '$prefix${currency == 'IDR' ? 'Rp' : currency} ${(value.abs() / 1000000).toStringAsFixed(1)}jt';
    }
    if (compact && value.abs() >= 1000) {
      return '$prefix${currency == 'IDR' ? 'Rp' : currency} ${(value.abs() / 1000).toStringAsFixed(0)}rb';
    }

    final formatted = NumberFormat.currency(
      locale: 'id_ID',
      symbol: currency == 'IDR' ? 'Rp' : '$currency ',
      decimalDigits: currency == 'IDR' ? 0 : 2,
    ).format(value.abs());

    return '$prefix$formatted';
  }
}
