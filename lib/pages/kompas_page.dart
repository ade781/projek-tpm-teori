import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../widgets/kompas/compass_view.dart';
import '../widgets/kompas/heading_readout.dart';

class KompasPage extends StatefulWidget {
  const KompasPage({super.key});

  @override
  State<KompasPage> createState() => _KompasPageState();
}

class _KompasPageState extends State<KompasPage> {
  double? _heading;

  @override
  void initState() {
    super.initState();

    if (FlutterCompass.events != null) {
      FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            if (event.heading != null) {
          
              _heading = (event.heading! % 360 + 360) % 360;
            } else {
              _heading = null;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kompas Digital'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(200),
              Theme.of(context).colorScheme.secondary.withAlpha(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_heading == null)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Memuat data kompas... Pastikan perangkat Anda mendukung sensor kompas dan sensor tidak terganggu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                )
              else
                CompassView(heading: _heading!),
              const SizedBox(height: 30),
              HeadingReadout(heading: _heading),
              const SizedBox(height: 50),
              const Text(
                'MADE BY ADE7',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
