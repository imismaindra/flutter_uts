import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatIDR(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }
}
