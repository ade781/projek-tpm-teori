import 'dart:math';
import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/models/aqi_model.dart';
import 'package:projek_akhir_teori/models/quote_model.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';
import 'package:projek_akhir_teori/services/aqi_service.dart';
import 'package:projek_akhir_teori/services/quote_service.dart';
import 'package:projek_akhir_teori/widgets/home/aqi_card.dart';
import 'package:projek_akhir_teori/widgets/home/feature_list.dart';
import 'package:projek_akhir_teori/widgets/home/home_footer.dart';
import 'package:projek_akhir_teori/widgets/home/home_header.dart';
import 'package:projek_akhir_teori/widgets/home/quote_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final AqiService _aqiService = AqiService();
  final QuoteService _quoteService = QuoteService();

  String? _username;
  late Future<AqiData?> _aqiFuture;
  late Future<QuoteModel> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadUserData();
    _aqiFuture = _aqiService.getAqiForCurrentLocation();
    _quoteFuture = _loadRandomQuote();
  }

  Future<QuoteModel> _loadRandomQuote() async {
    final quotes = await _quoteService.fetchQuotes();
    if (quotes.isEmpty) {
      return QuoteModel(
        id: '0',
        isi:
            'Selamat datang di Lurufa. Tarik ke bawah untuk memuat hikmah baru.',
      );
    }
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  Future<void> _refreshData() async {
    setState(() {
      _aqiFuture = _aqiService.getAqiForCurrentLocation();
      _quoteFuture = _loadRandomQuote();
    });
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getLoggedInUserObject();
    if (mounted && user != null) {
      setState(() {
        _username = user.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/Background_home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              HomeHeader(username: _username),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              QuoteCard(quoteFuture: _quoteFuture),
              AqiCard(aqiFuture: _aqiFuture),
           
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Jelajahi Fitur Lainnya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
              const FeatureList(),
              const HomeFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
