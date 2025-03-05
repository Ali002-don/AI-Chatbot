// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:developer';
import 'package:ai_chatbot/constant.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MyBotScreen extends StatefulWidget {
  const MyBotScreen({super.key});

  @override
  State<MyBotScreen> createState() => _MyBotScreenState();
}

class _MyBotScreenState extends State<MyBotScreen> {
  ChatUser myself = ChatUser(
    id: '1',
    firstName: 'Ali',
    profileImage: 'assets/person.png',
  );
  ChatUser bot = ChatUser(
    id: '2',
    firstName: 'AI',
    profileImage: 'assets/ai.png',
  );
  // Replace your APi key
  final ourUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyB3Suh4JpkE6pOKJ7CWvyC897uUDHDnQZE";
  final headers = {'Content-Type': 'application/json'};

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});
    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };
    await http
        .post(
      Uri.parse(ourUrl),
      headers: headers,
      body: jsonEncode(data),
    )
        .then(
      (value) {
        if (value.statusCode == 200) {
          var result = jsonDecode(value.body);
          log(result['candidates'][0]['content']['parts'][0]['text']);
          ChatMessage m1 = ChatMessage(
              text: result['candidates'][0]['content']['parts'][0]['text'],
              user: bot,
              createdAt: DateTime.now());
          allMessages.insert(0, m1);
        } else {
          log('Error Occurred');
        }
      },
    ).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        title: Row(
          children: [
            Image.asset(
              'assets/ai.png',
              height: 50,
            ),
            Text(
              'AI ChatBot',
              style: GoogleFonts.alikeAngular(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: DashChat(
        currentUser: myself,
        typingUsers: typing,
        onSend: (ChatMessage m) {
          getdata(m);
        },
        messages: allMessages,
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.grey[600],
          currentUserTextColor: Colors.white,
          currentUserTimeTextColor: Colors.white,
          messagePadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        inputOptions: InputOptions(
          cursorStyle: CursorStyle(color: Colors.white),
          inputDecoration: InputDecoration(
            filled: true,
            fillColor: cardColor,
            hintText: "Type your message...",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          inputTextStyle: TextStyle(color: Colors.white),
          sendButtonBuilder: (onSend) => IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: onSend,
          ),
        ),
      ),
    );
  }
}
