//b e v3
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String apiUrl = 'https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText?key=AIzaSyAQstU4fdpXbjrzNkgayr_seWo_cWR9fbg';
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

    String getPrompt =
        'Student is learning how to convert direct speech to indirect speech. For practice purposes, please give only one sentence which is direct speech and which can be converted into indirect speech. Please, only give back the sentence and no other text.';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': {'text': getPrompt}}),
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

    String prompt =
        'Student is learning how to convert direct speech to indirect speech. following is the original sentence in direct speech: $directSpeechSentence Is the following indirect speech correct? ${_answerController.text} Your response should be in JSON format. that JSON must contain a property named isCorrect. It should be true if the answer is true. else it should be false. If the answer is incorrect, please include explanation in text property of that JSON. Please do not respond in any other way then JSON.';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': {'text': prompt}}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      bool isCorrect = data['isCorrect'] == true;
      String generatedText = data['text'];

      setState(() {
        isLoading = false;
        responseText = isCorrect ? 'Correct! $generatedText' : 'Incorrect. $generatedText';
      });

      if (isCorrect) {
        // Show button only if the answer is incorrect
        // Fetch another sentence if the answer is correct
var future = new Future.delayed(const Duration(milliseconds: 1500),         getDirectSpeech);

//        getDirectSpeech();
      }
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
        title: liveText('Direct-Indirect Speech Practice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading) liveText('Direct Speech: $directSpeechSentence'),
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
            if (!isLoading && !isCorrect)
              ElevatedButton(
                onPressed: getDirectSpeech,
                child: Text('Get Next Sentence'),
              ),
            SizedBox(height: 20),
            liveText(responseText),
          ],
        ),
      ),
    );
  }
}
class LiveText extends StatelessWidget{
  final String text;
  LiveText(this.text);
  @override
  Widget build(BuildContext context) {
return Semantics(child:Text(text), liveRegion: true,);
  }
}