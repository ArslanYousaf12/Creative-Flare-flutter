// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DALL-E Image Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF00F5FF),
          surface: const Color(0xFF252A34),
          background: const Color(0xFF1A1A2E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: const Color(0xFF6C63FF).withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252A34),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
      home: const ImageGeneratorScreen(),
    );
  }
}

class ImageGeneratorScreen extends StatefulWidget {
  const ImageGeneratorScreen({Key? key}) : super(key: key);

  @override
  _ImageGeneratorScreenState createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  // API key is hardcoded and hidden from users
  final String _apiKey =
      'YOUR_OPENAI_API_KEY_HERE'; // Replace with your actual API key
  String? _imageUrl;
  bool _isLoading = false;
  String _errorMessage = '';
  String _modelVersion = 'dall-e-3'; // Default to DALL-E 3
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  Future<void> _generateImage() async {
    if (_promptController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a prompt';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _imageUrl = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'prompt': _promptController.text,
          'n': 1,
          'size': '1024x1024', // Standard size for DALL-E 3
          'model': _modelVersion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _imageUrl = data['data'][0]['url'];
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = 'Error: ${_parseErrorMessage(response.body)}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Exception: ${e.toString().split('\n')[0]}';
        _isLoading = false;
      });
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final parsed = json.decode(responseBody);
      return parsed['error']['message'] ?? 'Unknown error';
    } catch (_) {
      return 'Failed to parse error message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6C63FF),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'DALL-E',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Image Generator',
                        style: TextStyle(
                          color: const Color(0xFF00F5FF).withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Inspiration text
                      Center(
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Transform ideas into art',
                              textStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          totalRepeatCount: 1,
                          displayFullTextOnTap: true,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Model Selection Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: const Color(0xFF252A34),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Model',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A2E),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                ),
                                dropdownColor: const Color(0xFF252A34),
                                value: _modelVersion,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'dall-e-3',
                                      child: Text('DALL-E 3 (Best Quality)')),
                                  DropdownMenuItem(
                                      value: 'dall-e-2',
                                      child: Text('DALL-E 2 (Faster)')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _modelVersion = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Prompt Input Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: const Color(0xFF252A34),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What would you like to create?',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _promptController,
                                decoration: InputDecoration(
                                  hintText:
                                      'A futuristic city with flying cars and neon lights',
                                  hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3)),
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A2E),
                                  prefixIcon: const Icon(Icons.brush,
                                      color: Color(0xFF6C63FF)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Generate Button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _generateImage,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isLoading ? 'Creating Magic...' : 'Generate Image',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error Message
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Image Display
                      if (_imageUrl != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: const Color(0xFF252A34),
                            elevation: 16,
                            shadowColor:
                                const Color(0xFF6C63FF).withOpacity(0.5),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Image.network(
                                    _imageUrl!,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 300,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            color: const Color(0xFF6C63FF),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 300,
                                        color: Colors.black.withOpacity(0.1),
                                        child: const Center(
                                          child: Text('Error loading image'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade400,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Image Created Successfully",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
