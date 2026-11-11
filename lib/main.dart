import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'services/local_storage_service.dart';
import 'services/thai_tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await ThaiTtsService.init();
  runApp(const ThaiStepByStepApp());
}

class ThaiStepByStepApp extends StatefulWidget {
  const ThaiStepByStepApp({super.key});

  @override
  State<ThaiStepByStepApp> createState() => _ThaiStepByStepAppState();
}

class _ThaiStepByStepAppState extends State<ThaiStepByStepApp> {
  final ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Step by Step International',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1B365D),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B365D)),
      ),
      home: const ThaiLearningHomeShell(),
    );
  }
}

class ThaiLearningHomeShell extends StatefulWidget {
  const ThaiLearningHomeShell({super.key});

  @override
  State<ThaiLearningHomeShell> createState() => _ThaiLearningHomeShellState();
}

class _ThaiLearningHomeShellState extends State<ThaiLearningHomeShell> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFAF8F5))
      ..addJavaScriptChannel(
        'FlutterTtsBridge',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final data = jsonDecode(message.message);
            if (data['action'] == 'speak') {
              final text = (data['text'] ?? '').toString();
              final rate = (data['rate'] as num?)?.toDouble() ?? 0.8;
              await ThaiTtsService.speak(text,
                  slow: rate < 0.65, baseRate: rate);
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoaded = true);
          },
        ),
      );
    _loadWebUi();
  }

  Future<void> _loadWebUi() async {
    try {
      final htmlString = await rootBundle
          .loadString('assets/web/thai_step_by_step_app.html');
      await _controller.loadHtmlString(
        htmlString,
        baseUrl: 'https://thaistepbystep.international/',
      );
    } catch (_) {
      await _controller
          .loadFlutterAsset('assets/web/thai_step_by_step_app.html');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          await _controller.runJavaScript("switchMainView('home');");
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1B365D),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (!_isLoaded)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFBBF24)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
