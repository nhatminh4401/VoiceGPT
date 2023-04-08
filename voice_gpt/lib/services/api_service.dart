import "dart:convert";
import "dart:io";

import "package:dart_openai/openai.dart";
import "package:http/http.dart" as http;
import "package:voice_gpt/constants/api_constant.dart";
import 'dart:developer';

import "../models/chat_model.dart";
import "../models/models_model.dart";

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  // Send Message function
  static Future<List<ChatModel>> sendMessage(
      {required List<ChatModel> message, required String modelId}) async {
    try {
      OpenAI.apiKey = API_KEY;
      // var response = await http.post(
      //   Uri.parse("$BASE_URL/chat/completions"),
      //   headers: {
      //     'Authorization': 'Bearer $API_KEY',
      //     "Content-Type": "application/json"
      //   },
      //   body: jsonEncode(
      //     {
      //       "model": modelId,
      //       "messages": message
      //           .map((e) => [
      //                 {
      //                   "role": e.chatIdx == 0 ? "user" : "assistant",
      //                   "content": e.msg
      //                 }
      //               ])
      //           .toList(),
      //       "max_tokens": 4000,
      //       "temperature": 0,
      //       "top_p": 1,
      //       "frequency_penalty": 0.0,
      //       "presence_penalty": 0.0,
      //     },
      //   ),
      // );
      final res = await OpenAI.instance.chat.create(
          model: modelId,
          messages: message
              .map((e) => OpenAIChatCompletionChoiceMessageModel(
                  role: e.chatIdx == 0
                      ? OpenAIChatMessageRole.user
                      : OpenAIChatMessageRole.assistant,
                  content: e.msg))
              .toList());

      print('SENDED: $message, $modelId');
      // Map jsonResponse = jsonDecode(response.body);

      // print('response11 $jsonResponse');

      // if (jsonResponse['error'] != null) {
      //   print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
      //   throw HttpException(jsonResponse['error']["message"]);
      // }
      // List<ChatModel> chatList = [];
      // if (jsonResponse["choices"].length > 0) {
      //   log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
      //   chatList = List.generate(
      //     jsonResponse["choices"].length,
      //     (index) => ChatModel(
      //       msg: jsonResponse["choices"][index]["text"],
      //       chatIdx: 1,
      //     ),
      //   );
      // }
      List<ChatModel> chatList = [];
      if (res.choices.length > 0) {
        chatList = List.generate(
          res.choices.length,
          (index) => ChatModel(
            msg: res.choices.first.message.content,
            chatIdx: 1,
          ),
        );
      }
      // res.listen((chatStreamEvent) {
      //   print(chatStreamEvent.choices.first.delta.content); // ...
      //   if (chatStreamEvent.choices.length > 0) {
      //     chatList = List.generate(
      //       chatStreamEvent.choices.length,
      //       (index) => ChatModel(
      //         msg: chatStreamEvent.choices.first.delta.content.toString(),
      //         chatIdx: 1,
      //       ),
      //     );
      //   }
      // });
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
