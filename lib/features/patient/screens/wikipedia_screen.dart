import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../utils/constants.dart'; // ✅ or the correct relative path


void main() {
  runApp(DrugInfoApp());
}

class DrugInfoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drug Information',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DrugSearchScreen(),
    );
  }
}

class DrugSearchScreen extends StatefulWidget {
  @override
  _DrugSearchScreenState createState() => _DrugSearchScreenState();
}

class _DrugSearchScreenState extends State<DrugSearchScreen> {
  final TextEditingController _drugNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Replace with your actual backend URL - use the same baseUrl from your constants
  
  
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _searchDrugInfo() async {
    final drugName = _drugNameController.text.trim();
    
    if (drugName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a drug name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get token from SharedPreferences
      final token = await _getAuthToken();
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication required. Please login again.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/medication/pill-image?drugName=${Uri.encodeComponent(drugName)}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final wikipediaUrl = response.body;
        
        // Check if it's a valid URL or an error message
        if (wikipediaUrl.startsWith('http')) {
          // Navigate to Wikipedia screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WikipediaScreen(
                url: wikipediaUrl,
                drugName: drugName,
              ),
            ),
          );
        } else {
          setState(() {
            _errorMessage = wikipediaUrl; // Display the error message from backend
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Authentication failed. Please login again.';
        });
        // Optionally, you can clear the token and redirect to login
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
      } else if (response.statusCode == 403) {
        setState(() {
          _errorMessage = 'Access denied. Patient role required.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Network error. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Drug Information Search'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Drug Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _drugNameController,
                      decoration: InputDecoration(
                        labelText: 'Enter Drug Name',
                        hintText: 'e.g., Aspirin, Ibuprofen',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      onSubmitted: (_) => _searchDrugInfo(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchDrugInfo,
                      child: _isLoading
                          ? Row(
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
                                SizedBox(width: 10),
                                Text('Searching...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search),
                                SizedBox(width: 8),
                                Text('Search Wikipedia'),
                              ],
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 20),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 30),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter a drug name to get detailed information from Wikipedia. The app will display the complete Wikipedia page with comprehensive drug information.',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _drugNameController.dispose();
    super.dispose();
  }
}

class WikipediaScreen extends StatefulWidget {
  final String url;
  final String drugName;

  const WikipediaScreen({
    Key? key,
    required this.url,
    required this.drugName,
  }) : super(key: key);

  @override
  _WikipediaScreenState createState() => _WikipediaScreenState();
}

class _WikipediaScreenState extends State<WikipediaScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Failed to load page: ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _refreshPage() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.drugName} - Wikipedia'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPage,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              // You can implement opening in external browser if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('URL: ${widget.url}'),
                  action: SnackBarAction(
                    label: 'Copy',
                    onPressed: () {
                      // Implement copy to clipboard functionality
                    },
                  ),
                ),
              );
            },
            tooltip: 'Open in Browser',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshPage,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading Wikipedia page...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}