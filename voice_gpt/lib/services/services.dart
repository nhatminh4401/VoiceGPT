import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voice_gpt/widgets/drop_down.dart';

import '../constants/constants.dart';
import '../widgets/text_widget.dart';

class Services {
  static Future<void> showModalSheet({required BuildContext context}) async {
    await showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        backgroundColor: scaffoldBackgroundColor,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: TextWidget(
                  label: "Current model: gpt-3.5-turbo",
                  fontSize: 16,
                )),
                // Flexible(flex: 2, child: ModelsDrowDownWidget())
              ],
            ),
          );
        });
  }
}
