import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PillImageFetcher extends StatefulWidget {
  const PillImageFetcher({Key? key}) : super(key: key);

  @override
  State<PillImageFetcher> createState() => _PillImageFetcherState();
}

class _PillImageFetcherState extends State<PillImageFetcher> {
  final TextEditingController _drugNameController = TextEditingController();
  String? _imageUrl;
  String? _errorMessage;
  bool _isLoading = false;

  // Replace with your actual backend URL
  static const String baseUrl = 'http://your-backend-url.com';
  
  // Replace with your actual JWT token or implement token management
  static const String authToken = 'your_jwt_token_here';

  Future<void> fetchPillImage(String drugName) async {
    if (drugName.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a drug name';
        _imageUrl = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _imageUrl = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/pill-image')
          .replace(queryParameters: {'drugName': drugName.trim()});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        String result = response.body;
        
        // Remove quotes if the response is a JSON string
        if (result.startsWith('"') && result.endsWith('"')) {
          result = result.substring(1, result.length - 1);
        }
        
        // Check if it's an error message or valid URL
        if (result.startsWith('Error') || result.startsWith('No Wikimedia image found')) {
          setState(() {
            _errorMessage = result;
            _imageUrl = null;
          });
        } else {
          setState(() {
            _imageUrl = result;
            _errorMessage = null;
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Authentication failed. Please check your credentials.';
          _imageUrl = null;
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _errorMessage = 'Access denied. Patient role required.';
          _imageUrl = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch image. Status: ${response.statusCode}';
          _imageUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _imageUrl = null;
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
      appBar: AppBar(
        title: const Text('Pill Image Finder'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drug name input
            TextField(
              controller: _drugNameController,
              decoration: const InputDecoration(
                labelText: 'Drug Name',
                hintText: 'Enter drug name (e.g., Aspirin, Ibuprofen)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              onSubmitted: (value) => fetchPillImage(value),
            ),
            
            const SizedBox(height: 16),
            
            // Search button
            ElevatedButton(
              onPressed: _isLoading 
                  ? null 
                  : () => fetchPillImage(_drugNameController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Searching...'),
                      ],
                    )
                  : const Text('Search Pill Image'),
            ),
            
            const SizedBox(height: 24),
            
            // Results area
            Expanded(
              child: _buildResultWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching pill image...'),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_imageUrl != null) {
      return Column(
        children: [
          Text(
            'Pill Image for "${_drugNameController.text}"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrl!,
                  fit: BoxFit.contain,
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
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text('Failed to load image'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Image URL: $_imageUrl',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    
    // Default state
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Enter a drug name to search for pill images',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _drugNameController.dispose();
    super.dispose();
  }
}

// Usage example - add this to your main.dart or wherever you want to use it
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pill Image Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PillImageFetcher(),
    );
  }
}

void main() {
  runApp(const MyApp());
}