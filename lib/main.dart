//b e1
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:async';
//import 'dart:convert';
const api_key = "AIzaSyAQstU4fdpXbjrzNkgayr_seWo_cWR9fbg";
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _answerController = TextEditingController();
  String apiUrl = 'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key= $api_key';
  String responseText = '';
  String directSpeechSentence = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDirectSpeech();
  }

  Future<void> getDirectSpeech() async {
    setState(() {
      isLoading = true;
    });

String getPromt='Student is learning how to convert direct speech to indirect speech. For practice purposes please give only one sentence which is direct speech and which can be converted into indirect speech.';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': getPromt}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> candidates = data['candidates'];
      directSpeechSentence = candidates.isNotEmpty ? candidates[0]['output'] : '';
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        responseText = 'Error: ${response.statusCode}';
      });
    }
  }

  Future<void> checkAnswer() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': 'Student is learning how to convert direct speech to indirect speech. following is the original sentence in direct speech: $directSpeechSentence Is the following indirect speech correct? $_answerController.text'}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> candidates = data['candidates'];
      String generatedText = candidates.isNotEmpty ? candidates[0]['output'] : '';

      // Compare the generated text with the user's answer
      String userAnswer = _answerController.text;
      bool isCorrect = generatedText.contains(userAnswer);

      setState(() {
        isLoading = false;
        responseText = isCorrect ? 'Correct! $generatedText' : 'Incorrect. $generatedText';
      });
    } else {
      setState(() {
        isLoading = false;
        responseText = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Direct-Indirect Speech Practice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading) Text('Direct Speech: $directSpeechSentence'),
            SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Enter Indirect Speech'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Check Answer'),
            ),
            SizedBox(height: 20),
            Text(responseText),
          ],
        ),
      ),
    );
  }
}
