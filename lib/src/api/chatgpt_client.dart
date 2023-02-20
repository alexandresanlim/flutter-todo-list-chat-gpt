import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String message;

  final List<String> steps;

  final List<String> firstSteps;

  final openAI = OpenAI.instance.build(
      token: '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',
      baseOption: HttpSetup(receiveTimeout: 6000),
      isLogger: true);

  ChatMessage(
      {required this.message, required this.firstSteps, required this.steps});
}

Future<ChatMessage> getChatResponse(String input) async {
  input = "Escreva uma receita para $input";

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/engines/text-davinci-003/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer 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',
    },
    body: jsonEncode({
      'prompt': input,
      'max_tokens': 300,
      'temperature': 0.3,
      'top_p': 1.0,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0
    }),
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final message = json['choices'][0]['text'] as String;

    List<String> lines = message.split('\n');

    List<String> firtSteps = [];

    RegExp firtStepsPattern = RegExp(r'^\s*-\s*(.*)$');

    for (String line in lines) {
      if (firtStepsPattern.hasMatch(line)) {
        firtSteps.add(line);
      }
    }

    List<String> steps = [];

    RegExp itemPattern = RegExp(r'^\d+\.?\s');

    for (String line in lines) {
      if (itemPattern.hasMatch(line)) {
        steps.add(line);
      }
    }

    return ChatMessage(message: message, firstSteps: firtSteps, steps: steps);
  } else {
    throw Exception('Failed to get chat response');
  }
}