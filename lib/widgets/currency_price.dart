import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';

/// Widget to display a price with currency conversion
class CurrencyPrice extends StatelessWidget {
  final int priceInCOP;
  final TextStyle? style;
  final bool showCode;
  final bool compact;

  const CurrencyPrice({
    super.key,
    required this.priceInCOP,
    this.style,
    this.showCode = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyService>(
      builder: (context, currencyService, child) {
        final formattedPrice = compact
            ? currencyService.formatPriceCompact(priceInCOP, showCode: showCode)
            : currencyService.formatPrice(priceInCOP, showCode: showCode);

        return Text(
          formattedPrice,
          style: style,
        );
      },
    );
  }
}

/// Extension method to easily format prices from any widget
extension PriceFormatting on BuildContext {
  String formatPrice(int priceInCOP, {bool showCode = false}) {
    final currencyService = Provider.of<CurrencyService>(this, listen: false);
    return currencyService.formatPrice(priceInCOP, showCode: showCode);
  }

  String formatPriceCompact(int priceInCOP, {bool showCode = false}) {
    final currencyService = Provider.of<CurrencyService>(this, listen: false);
    return currencyService.formatPriceCompact(priceInCOP, showCode: showCode);
  }
}
