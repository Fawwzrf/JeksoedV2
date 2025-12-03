// filepath: lib/data/models/message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String? imageUrl;
  final String type; // "text" or "image"
  final String senderId;
  final Timestamp? timestamp;

  Message({
    this.id = '',
    this.text = '',
    this.imageUrl,
    this.type = 'text',
    required this.senderId,
    this.timestamp,
  });

  factory Message.fromMap(Map<String, dynamic> data, String id) {
    return Message(
      id: id,
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      type: data['type'] ?? 'text',
      senderId: data['senderId'] ?? '',
      timestamp: data['timestamp'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'imageUrl': imageUrl,
      'type': type,
      'senderId': senderId,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
    };
  }

  Message copyWith({
    String? id,
    String? text,
    String? imageUrl,
    String? type,
    String? senderId,
    Timestamp? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, text: $text, type: $type, senderId: $senderId)';
  }
}
