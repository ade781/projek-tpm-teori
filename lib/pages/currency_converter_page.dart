import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/services/currency_service.dart';
import 'package:intl/intl.dart';
import 'package:projek_akhir_teori/widgets/currency_converter/convert_button.dart';
import 'package:projek_akhir_teori/widgets/currency_converter/converter_app_bar.dart';
import 'package:projek_akhir_teori/widgets/currency_converter/converter_footer.dart';
import 'package:projek_akhir_teori/widgets/currency_converter/input_card.dart';
import 'package:projek_akhir_teori/widgets/currency_converter/results_section.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _currencyService = CurrencyService();

final List<String> _currencies = [
  'IDR',
  'SAR',
  'USD',
  'EUR',
  'JPY',
  'GBP',
  'AUD',
  'SGD',
  'MGA',
  'CAD',
  'CHF',
  'CNY',
  'NZD',
  'INR',
  'BRL',
  'RUB',
  'KRW',
  'TRY',
];

  String _baseCurrency = 'IDR';

  Map<String, double> _convertedAmounts = {};
  bool _isLoading = false;
  String? _lastUpdated;
  String? _validationError; // State untuk menyimpan pesan error

  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animations = [];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final String inputText = _amountController.text;

    final validCharacters = RegExp(r'^[0-9]*\.?[0-9]*$');
    if (inputText.isEmpty || !validCharacters.hasMatch(inputText)) {
      setState(() {
        _validationError = 'Input hanya boleh berisi angka.';
      });
      return;
    }

    if (inputText.length > 20) {
      setState(() {
        _validationError = 'Jangan ngawur, input terlalu panjang!';
      });
      return;
    }

    final amount = double.tryParse(inputText) ?? 0;
    if (amount <= 0) {
      setState(() {
        _validationError = 'Masukkan jumlah yang valid untuk dikonversi.';
      });
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _validationError = null; // Hapus error jika validasi berhasil
      _convertedAmounts = {};
      _lastUpdated = null;
    });

    try {
      final responseData = await _currencyService.getLatestRates(_baseCurrency);
      final rates = responseData['conversion_rates'] as Map<String, dynamic>;
      final lastUpdateUtc = responseData['time_last_update_utc'] as String;
      final parsedDate = DateFormat(
        "E, d MMM yyyy HH:mm:ss Z",
      ).parse(lastUpdateUtc, true);
      final formattedDate = DateFormat(
        'd MMM yyyy, HH:mm',
      ).format(parsedDate.toLocal());

      final newConvertedAmounts = <String, double>{};
      for (var currency in _currencies) {
        if (currency == _baseCurrency) continue;
        final rate = rates[currency];
        if (rate != null) {
          newConvertedAmounts[currency] = amount * (rate as num);
        }
      }

      setState(() {
        _convertedAmounts = newConvertedAmounts;
        _lastUpdated = formattedDate;
        _animations = List.generate(
          _convertedAmounts.length,
          (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (1 / _convertedAmounts.length) * index,
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
        );
      });
      _animationController.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _validationError = 'Gagal memuat data: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const ConverterAppBar(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InputCard(
                              amountController: _amountController,
                              baseCurrency: _baseCurrency,
                              currencies: _currencies,
                              onCurrencyChanged: (val) {
                                if (val != null) {
                                  setState(() => _baseCurrency = val);
                                }
                              },
                            ),
                            if (_validationError != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 16.0,
                                ),
                                child: Text(
                                  _validationError!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ConvertButton(
                          isLoading: _isLoading,
                          onPressed: _convert,
                        ),
                        const SizedBox(height: 30),
                        ResultsSection(
                          isLoading: _isLoading,
                          convertedAmounts: _convertedAmounts,
                          animations: _animations,
                        ),
                        if (_lastUpdated != null)
                          ConverterFooter(lastUpdated: _lastUpdated!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
