import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
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
  bool showSendBtn = false;
  late TextEditingController textEditingController;
  late ScrollController scrollController;
  late FocusNode focusNode;
  SpeechToText speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  bool isPlayingListenBtn = false;
  @override
  void initState() {
    scrollController = ScrollController();
    textEditingController = TextEditingController();
    super.initState();
    focusNode = FocusNode();
    initSpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.readMessageFromLocal();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    _speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      textEditingController.text = _lastWords;
      print('listen res: $_lastWords');
    });
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    print('chatList: $chatProvider.chatList');
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.openaiLogo)),
        title: Center(child: Text("Chat")),
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
                        chatIdx: chatProvider.chatList[index].chatIdx);
                  })),
          if (_isTyping) ...[
            const SpinKitThreeBounce(
              color: Colors.white,
              size: 18,
            ),
          ],
          SizedBox(height: 15),
          Column(
            children: [
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
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              showSendBtn = true;
                            });
                          } else {
                            setState(() {
                              showSendBtn = false;
                            });
                          }
                        },
                        onSubmitted: (value) async {
                          await sendMessage(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "Start typing or talking...",
                            hintStyle: TextStyle(color: Colors.grey)),
                      )),
                      Visibility(
                        visible: showSendBtn,
                        child: IconButton(
                            onPressed: () async {
                              await sendMessage(
                                  modelsProvider: modelsProvider,
                                  chatProvider: chatProvider);
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Visibility(
                        visible: showSendBtn,
                        child: IconButton(
                            onPressed: () {
                              textEditingController.clear();
                              setState(() {
                                showSendBtn = false;
                              });
                            },
                            icon: Icon(
                              size: 30,
                              Icons.delete,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        child: FittedBox(
                          child: FloatingActionButton(
                            onPressed:
                                // If not yet listening for speech start, otherwise stop
                                speechToText.isNotListening
                                    ? _startListening
                                    : _stopListening,
                            tooltip: 'Listen',
                            child: Icon(speechToText.isNotListening
                                ? Icons.mic_off
                                : Icons.mic),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              )
            ],
          ),
          SizedBox(height: 10),
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
