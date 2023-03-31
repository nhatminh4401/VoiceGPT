import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:voice_gpt/services/asset_manager.dart';
import 'package:voice_gpt/widgets/text_widget.dart';

import '../constants/constants.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.msg, required this.chatIdx});

  final String msg;
  final int chatIdx;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: chatIdx == 0 ? scaffoldBackgroundColor : cardColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  chatIdx == 0
                      ? AssetsManager.userImage
                      : AssetsManager.openaiLogo,
                  height: 30,
                  width: 30,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextWidget(
                    label: msg,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
