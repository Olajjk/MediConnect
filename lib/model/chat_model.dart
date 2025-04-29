import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MessagesModel extends Equatable {
  final String senderId;
  final String senderName;
  final String receiverId;
  final String messageText;
  final DateTime createdAt;

  const MessagesModel({
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.messageText,
    required this.createdAt,
  });

  MessagesModel copyWith({
    String? senderId,
    String? senderName,
    String? receiverId,
    String? messageText,
    DateTime? createdAt,
  }) {
    return MessagesModel(
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'messageText': messageText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MessagesModel.fromMap(Map<String, dynamic> map) {
    return MessagesModel(
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      receiverId: map['receiverId'] as String,
      messageText: map['messageText'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessagesModel.fromJson(String source) =>
      MessagesModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [senderId, senderName, receiverId, messageText, createdAt];
  }
}
