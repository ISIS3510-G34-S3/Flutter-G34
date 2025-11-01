import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lru_cache/lru_cache.dart';

/// Cached exchange rate entry with timestamp
class ExchangeRateEntry {
  final Map<String, double> rates;
  final DateTime timestamp;

  ExchangeRateEntry({required this.rates, required this.timestamp});

  bool get isStale => DateTime.now().difference(timestamp).inHours >= 24;
}

/// Supported currencies with their symbols and names
enum Currency {
  cop('COP', '\$', 'Colombian Peso'),
  usd('USD', '\$', 'US Dollar'),
  eur('EUR', '€', 'Euro'),
  gbp('GBP', '£', 'British Pound'),
  jpy('JPY', '¥', 'Japanese Yen'),
  cad('CAD', 'C\$', 'Canadian Dollar'),
  aud('AUD', 'A\$', 'Australian Dollar'),
  mxn('MXN', 'Mex\$', 'Mexican Peso'),
  brl('BRL', 'R\$', 'Brazilian Real'),
  chf('CHF', 'CHF', 'Swiss Franc');

  const Currency(this.code, this.symbol, this.name);
  final String code;
  final String symbol;
  final String name;

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency.cop,
    );
  }
}

/// Service for managing currency preferences and exchange rates
class CurrencyService extends ChangeNotifier {
  static const String _prefsCurrencyKey = 'preferred_currency';

  // LRU Cache for exchange rates (capacity: 10 different rate sets)
  final LruCache<String, ExchangeRateEntry> _ratesCache = LruCache(10);
  static const String _cacheKey = 'COP'; // Base currency for our rates

  // Using exchangerate-api.com free tier (1500 requests/month)
  static const String _apiUrl =
      'https://api.exchangerate-api.com/v4/latest/COP';

  Currency _preferredCurrency = Currency.cop;
  Map<String, double> _exchangeRates = {};
  DateTime? _lastUpdate;
  bool _isLoading = false;

  Currency get preferredCurrency => _preferredCurrency;
  Map<String, double> get exchangeRates => _exchangeRates;
  DateTime? get lastUpdate => _lastUpdate;
  bool get isLoading => _isLoading;

  /// Initialize the service and load saved preferences
  Future<void> initialize() async {
    await _loadPreferences();

    // Check if we need to update rates (daily update)
    final shouldUpdate = _lastUpdate == null ||
        DateTime.now().difference(_lastUpdate!).inHours >= 24;

    if (shouldUpdate) {
      await fetchExchangeRates();
    }
  }

  /// Load saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load preferred currency from SharedPreferences
      final currencyCode = prefs.getString(_prefsCurrencyKey);
      if (currencyCode != null) {
        _preferredCurrency = Currency.fromCode(currencyCode);
      }

      // Try to get exchange rates from LRU cache
      final cachedEntry = await _ratesCache.get(_cacheKey);
      if (cachedEntry != null) {
        _exchangeRates = cachedEntry.rates;
        _lastUpdate = cachedEntry.timestamp;
        debugPrint('📦 Loaded exchange rates from LRU cache');
      } else {
        debugPrint('❌ No exchange rates in LRU cache');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading currency preferences: $e');
    }
  }

  /// Set the preferred currency
  Future<void> setPreferredCurrency(Currency currency) async {
    try {
      _preferredCurrency = currency;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsCurrencyKey, currency.code);

      notifyListeners();

      // Fetch rates if we don't have them yet
      if (_exchangeRates.isEmpty) {
        await fetchExchangeRates();
      }
    } catch (e) {
      debugPrint('Error setting preferred currency: $e');
    }
  }

  /// Fetch exchange rates from API
  Future<bool> fetchExchangeRates() async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> rates = data['rates'];

        // Store rates in memory
        _exchangeRates =
            rates.map((key, value) => MapEntry(key, value.toDouble()));
        _lastUpdate = DateTime.now();

        // Save to LRU cache
        final cacheEntry = ExchangeRateEntry(
          rates: _exchangeRates,
          timestamp: _lastUpdate!,
        );
        _ratesCache.put(_cacheKey, cacheEntry);
        debugPrint('💾 Saved exchange rates to LRU cache');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to fetch exchange rates: ${response.statusCode}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Convert COP amount to preferred currency
  double convertFromCOP(int amountCOP) {
    if (_preferredCurrency == Currency.cop) {
      return amountCOP.toDouble();
    }

    final rate = _exchangeRates[_preferredCurrency.code];
    if (rate == null || rate == 0) {
      return amountCOP.toDouble();
    }

    return amountCOP * rate;
  }

  /// Format price with currency symbol and proper formatting
  String formatPrice(int amountCOP, {bool showCode = false}) {
    final convertedAmount = convertFromCOP(amountCOP);
    final symbol = _preferredCurrency.symbol;
    final code = _preferredCurrency.code;

    // Format based on currency
    String formattedAmount;

    if (_preferredCurrency == Currency.jpy) {
      // Japanese Yen has no decimal places
      formattedAmount = convertedAmount.toStringAsFixed(0);
    } else if (_preferredCurrency == Currency.cop) {
      // Colombian Peso - no decimals for whole amounts
      formattedAmount = _formatWithCommas(convertedAmount.toInt());
    } else {
      // Most currencies use 2 decimal places
      formattedAmount = convertedAmount.toStringAsFixed(2);
    }

    if (showCode) {
      return '$symbol$formattedAmount $code';
    } else {
      return '$symbol$formattedAmount';
    }
  }

  /// Format price in compact form (e.g., 150K, 1.5M)
  String formatPriceCompact(int amountCOP, {bool showCode = false}) {
    final convertedAmount = convertFromCOP(amountCOP);
    final symbol = _preferredCurrency.symbol;
    final code = _preferredCurrency.code;

    String formattedAmount;

    if (convertedAmount >= 1000000) {
      formattedAmount = '${(convertedAmount / 1000000).toStringAsFixed(1)}M';
    } else if (convertedAmount >= 1000) {
      formattedAmount = '${(convertedAmount / 1000).toStringAsFixed(0)}K';
    } else {
      formattedAmount = convertedAmount.toStringAsFixed(0);
    }

    if (showCode) {
      return '$symbol$formattedAmount $code';
    } else {
      return '$symbol$formattedAmount';
    }
  }

  /// Helper to format numbers with commas
  String _formatWithCommas(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Get exchange rate info text
  String getExchangeRateInfo() {
    if (_preferredCurrency == Currency.cop) {
      return 'Prices shown in Colombian Pesos';
    }

    final rate = _exchangeRates[_preferredCurrency.code];
    if (rate == null) {
      return 'Exchange rates unavailable';
    }

    final copAmount = (1 / rate).toStringAsFixed(2);
    return '1 ${_preferredCurrency.code} = $copAmount COP';
  }

  /// Check if rates are stale (older than 24 hours)
  bool areRatesStale() {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!).inHours >= 24;
  }
}
