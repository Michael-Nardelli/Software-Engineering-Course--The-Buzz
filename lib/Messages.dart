import 'dart:convert';

// list of all messages' data
class Messages {
  final String mStatus;
  final List<MessageData> mData;

  Messages({
    required this.mStatus,
    required this.mData,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    var list = json['mData'] as List;
    print(list.runtimeType);
    List<MessageData> messageList =
        list.map((i) => MessageData.fromJson(i)).toList();

    return Messages(
      mStatus: json['mStatus'],
      mData: messageList,
    );
  }
}

// contents & info for a single message
class MessageData {
  final int? mId;
  final String mTitle;
  final String? mContent;
  final int mLikes;
  final int mDislikes;
  final int mUserId;
  final String? filename;
  final String? filelink;

  MessageData(
      {required this.mId,
      required this.mUserId,
      required this.mTitle,
      required this.mContent,
      required this.mLikes,
      required this.mDislikes,
      required this.filename,
      required this.filelink});

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
        mId: json['mId'],
        mTitle: json['mTitle'],
        mContent: json['mContent'],
        mLikes: json['mLikeCount'],
        mDislikes: json['mDislikeCount'],
        mUserId: json['mUserId'],
        filelink: json['mFileLink'],
        filename: json['mFileName']);
  }
}
