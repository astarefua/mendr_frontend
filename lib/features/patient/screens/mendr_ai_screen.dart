import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MendrAIScreen extends StatefulWidget {
  const MendrAIScreen({super.key});

  @override
  State<MendrAIScreen> createState() => _MendrAIScreenState();
}

class _MendrAIScreenState extends State<MendrAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(role: 'user', text: text));
      _isLoading = true;
      _controller.clear();
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/chatbot/ask'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final reply = response.body.trim();
        setState(() {
          _messages.add(_Message(role: 'bot', text: reply));
        });
      } else {
        setState(() {
          _messages.add(_Message(role: 'bot', text: 'Something went wrong.')); 
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_Message(role: 'bot', text: 'Error: $e'));
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      //backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.blue,
          centerTitle: true, // 👈 This centers the title

        title: const Text('Mendr AI', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        //actions: const [Icon(Icons.search, color: Colors.white)],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildIntroView() : _buildChatView(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildIntroView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.android, size: 100, color: Colors.blue),
          SizedBox(height: 10),
          Text("Mendr AI", style: TextStyle(fontSize: 24, color: Colors.blue)),
          SizedBox(height: 8),
          Text("Hi ;)", style: TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.role == 'user';
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.android, color: Colors.white),
                ),
              ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue[100] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(message.text),
              ),
            ),
            if (isUser)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }


  Widget _buildInputBar() {
  return SafeArea(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color:  const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type message',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // 👈 This adds rounded edges
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    ),
  );
}


}

class _Message {
  final String role; // 'user' or 'bot'
  final String text;

  _Message({required this.role, required this.text});
}
