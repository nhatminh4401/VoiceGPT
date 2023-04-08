import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_model.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  Future<void> addUserMessage({required String msg}) async {
    chatList.add(ChatModel(msg: msg, chatIdx: 0));
    await saveMessageToLocal();
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required List<ChatModel> msg, required String chosenModelId}) async {
    chatList.addAll(await ApiService.sendMessage(
      message: msg,
      modelId: chosenModelId,
    ));
    await saveMessageToLocal();
    notifyListeners();
  }

  Future<void> saveMessageToLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('msg', chatList.map((e) => e.msg).toList());
    await prefs.setStringList(
        'chatIdx', chatList.map((e) => e.chatIdx.toString()).toList());
    print('save local $prefs');
  }

  Future<void> readMessageFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? msgList = prefs.getStringList('msg');
    final List<String>? chatIdxList = prefs.getStringList('chatIdx');
    print('local $msgList');
    print('local2 $chatIdxList');
    // chatList.asMap().entries.map((e) => e.value.msg = msgList![e.key]);
    // chatList
    //     .asMap()
    //     .entries
    //     .map((e) => e.value.chatIdx = chatIdxList![e.key] as int);
    // chatList.map((e) => e.msg = msgList)
    chatList.clear();
    int count = -1;
    // for (var e in msgList!) {
    //   print('map $e $_count.toString()');
    //   chatList.add(ChatModel(msg: e, chatIdx: 0));
    // }
    msgList?.forEach((e) => {
          // print('map $e $count.toString()'),
          if (count < chatIdxList!.length - 1) {count += 1},
          chatList.add(ChatModel(
              msg: e,
              chatIdx: int.tryParse(chatIdxList.elementAt(count)) as int)),
          print(chatIdxList.elementAt(count))
        });
    print('chat2 $chatList');
  }
}
