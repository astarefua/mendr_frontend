import 'package:flutter/material.dart';

class WikipediaScreen extends StatelessWidget {
  const WikipediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wikipedia')),
      body: const Center(
        child: Text(
          'Wikipedia Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
