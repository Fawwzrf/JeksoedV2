// filepath: lib/utils/currency_formatter.dart

/// Format integer amount to Indonesian Rupiah format with dot separators
/// Example: 1000000 -> "Rp1.000.000", 500000 -> "Rp500.000"
String formatCurrency(int amount) {
  if (amount == 0) return 'Rp0';
  
  // Convert to string and add dots every 3 digits from right
  final str = amount.toString();
  final buffer = StringBuffer('Rp');
  
  for (int i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  
  return buffer.toString();
}

/// Format double amount to Indonesian Rupiah format with dot separators
/// Example: 1000000.0 -> "Rp1.000.000"
String formatCurrencyDouble(double amount) {
  return formatCurrency(amount.toInt());
}
