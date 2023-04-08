import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:voice_gpt/services/asset_manager.dart';
import 'package:voice_gpt/widgets/text_widget.dart';

import '../constants/constants.dart';

class ChatWidget extends StatefulWidget {
  ChatWidget({super.key, required this.msg, required this.chatIdx});

  final String msg;
  final int chatIdx;

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool isPlayingListenBtn = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: widget.chatIdx == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      widget.chatIdx == 0
                          ? AssetsManager.userImage
                          : AssetsManager.openaiLogo,
                      height: 30,
                      width: 30,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: widget.chatIdx == 0
                          ? TextWidget(
                              label: widget.msg,
                            )
                          : DefaultTextStyle(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16),
                              child: Text(widget.msg),
                              // child: AnimatedTextKit(
                              //     pause: Duration(milliseconds: 0),
                              //     isRepeatingAnimation: false,
                              //     repeatForever: false,
                              //     displayFullTextOnTap: true,
                              //     totalRepeatCount: 1,
                              //     animatedTexts: [TyperAnimatedText(msg.trim())])
                            ),
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.chatIdx == 1,
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isPlayingListenBtn = !isPlayingListenBtn;
                        });
                      },
                      icon: Icon(
                        size: 40,
                        isPlayingListenBtn
                            ? Icons.play_circle
                            : Icons.stop_circle,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
