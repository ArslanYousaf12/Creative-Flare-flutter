// main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
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

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  // API key would be stored securely in a production app
  final String _apiKey = '';
  String? _imageUrl;
  bool _isLoading = false;
  String _errorMessage = '';
  String _modelVersion = 'dall-e-3'; // Default model

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
          'size': '1024x1024',
          'model': _modelVersion,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _imageUrl = data['data'][0]['url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${_parseErrorMessage(response.body)}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Exception: ${e.toString()}';
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
      appBar: AppBar(
        title: const Text('DALL-E Image Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Model selection
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Model',
                border: OutlineInputBorder(),
              ),
              value: _modelVersion,
              items: const [
                DropdownMenuItem(value: 'dall-e-3', child: Text('DALL-E 3')),
                DropdownMenuItem(value: 'dall-e-2', child: Text('DALL-E 2')),
              ],
              onChanged: (value) {
                setState(() {
                  _modelVersion = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Prompt input
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Enter your prompt',
                hintText: 'A futuristic city with flying cars',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Generate button
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Image'),
            ),

            // Error message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 20),

            // Image display
            Expanded(
              child: _imageUrl != null
                  ? Image.network(
                      _imageUrl!,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('Your generated image will appear here'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
