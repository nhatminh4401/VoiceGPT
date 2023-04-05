import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:voice_gpt/models/chat_model.dart';
import 'package:voice_gpt/providers/chat_provider.dart';
import 'package:voice_gpt/services/api_service.dart';
import 'package:voice_gpt/services/asset_manager.dart';
import 'package:voice_gpt/services/services.dart';
import 'package:voice_gpt/widgets/chat_widget.dart';
import 'package:voice_gpt/widgets/text_widget.dart';

import '../constants/constants.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/model_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController scrollController;
  late FocusNode focusNode;
  @override
  void initState() {
    scrollController = ScrollController();
    textEditingController = TextEditingController();
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.openaiLogo)),
        title: Text("ChatGPT"),
        actions: [
          IconButton(
              onPressed: () async {
                await Services.showModalSheet(context: context);
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
          child: Column(
        children: [
          Flexible(
              child: ListView.builder(
                  controller: scrollController,
                  itemCount: chatProvider.chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider.chatList[index].msg,
                      chatIdx: chatProvider.chatList[index].chatIdx,
                    );
                  })),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          SizedBox(height: 15),
          Material(
            color: cardColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    controller: textEditingController,
                    onSubmitted: (value) async {
                      await sendMessage(
                          modelsProvider: modelsProvider,
                          chatProvider: chatProvider);
                    },
                    decoration: const InputDecoration.collapsed(
                        hintText: "How can I help you?",
                        hintStyle: TextStyle(color: Colors.grey)),
                  )),
                  IconButton(
                      onPressed: () async {
                        await sendMessage(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider);
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  void scrollListToEnd() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 2), curve: Curves.easeOut);
  }

  Future<void> sendMessage(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            TextWidget(label: "You can't send multiple messages at a time"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(label: "Please type a message"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      print('Sending...');
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIdx: 0));
        chatProvider.addUserMessage(msg: textEditingController.text);
        textEditingController.clear();
        focusNode.unfocus();
      });
      await chatProvider.sendMessageAndGetAnswers(
          msg: chatProvider.chatList,
          chosenModelId: modelsProvider.getCurrentModel);
      // chatList.addAll(await ApiService.sendMessage(
      //     message: textEditingController.text,
      //     modelId: modelsProvider.getCurrentModel));
      setState(() {});
    } catch (error) {
      print("error: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(label: error.toString()),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }
}
