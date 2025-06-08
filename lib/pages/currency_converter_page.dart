import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/services/currency_service.dart';
import 'package:intl/intl.dart';

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
  ];
  String _baseCurrency = 'IDR';

  Map<String, double> _convertedAmounts = {};
  bool _isLoading = false;
  String? _lastUpdated; // State untuk menyimpan waktu update

  // Controller dan animasi untuk list hasil
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  /// Memulai proses konversi mata uang
  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid untuk dikonversi.'),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
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
          newConvertedAmounts[currency] = amount * rate;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              _buildAppBar(),
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
                        _buildInputCard(),
                        const SizedBox(height: 24),
                        _buildConvertButton(),
                        const SizedBox(height: 30),
                        _buildResultsSection(),

                        if (_lastUpdated != null) _buildFooterInfo(),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Konverter Global',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _baseCurrency,
                items:
                    _currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(
                          currency,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _baseCurrency = val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _convert,
        icon:
            _isLoading
                ? Container()
                : const Icon(Icons.currency_exchange, size: 20),
        label:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                : const Text(
                  'Konversi Sekarang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_convertedAmounts.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.all_out_sharp, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Hasil konversi akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_convertedAmounts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Nilai dalam Mata Uang Lain',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _convertedAmounts.length,
          itemBuilder: (context, index) {
            final entry = _convertedAmounts.entries.elementAt(index);
            return FadeTransition(
              opacity: _animations[index],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(_animations[index]),
                child: _buildResultItem(
                  currency: entry.key,
                  amount: entry.value,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultItem({required String currency, required double amount}) {
    final numberFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 2,
    );
    final currencyFullName = {
      'IDR': 'Rupiah Indonesia',
      'SAR': 'Rial Arab Saudi',
      'USD': 'Dolar Amerika',
      'EUR': 'Euro',
      'JPY': 'Yen Jepang',
      'GBP': 'Pound Inggris',
      'AUD': 'Dolar Australia',
      'SGD': 'Dolar Singapura',
    };
    final currencyFlags = {
      'IDR': '🇮🇩',
      'SAR': '🇸🇦',
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'JPY': '🇯🇵',
      'GBP': '🇬🇧',
      'AUD': '🇦🇺',
      'SGD': '🇸🇬',
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              currencyFlags[currency] ?? '🏳️',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  currencyFullName[currency] ?? '',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            Text(
              numberFormat.format(amount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Data disediakan oleh ExchangeRate-API.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Terakhir diperbarui: $_lastUpdated WIB',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const Text(
              'MADE BY ADE7',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
