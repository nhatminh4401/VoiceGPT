class ChatModel {
  late final String msg;
  late final int chatIdx;

  ChatModel({required this.msg, required this.chatIdx});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json["msg"],
        chatIdx: json["chatIdx"],
      );
}
