// filepath: lib/data/models/message.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String? rideId;
  final String? senderId;
  final String content;
  final String? imageUrl;
  final String type;
  final DateTime createdAt;

  Message({
    required this.id,
    this.rideId,
    this.senderId,
    required this.content,
    this.imageUrl,
    this.type = 'text',
    required this.createdAt,
  });

  // Factory yang aman untuk berbagai format payload dari Supabase
  factory Message.fromJson(Map<String, dynamic> json) {
    dynamic createdRaw =
        json['createdAt'] ??
        json['created_at'] ??
        json['ts'] ??
        json['time'] ??
        json['timestamp'];

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
        try {
          return DateTime.parse(s);
        } catch (_) {}
        try {
          return DateTime.fromMillisecondsSinceEpoch(int.parse(s));
        } catch (_) {}
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Message(
      id: (json['id'] ?? json['message_id'] ?? '').toString(),
      rideId: (json['rideId'] ?? json['ride_id'])?.toString(),
      senderId: (json['senderId'] ?? json['sender_id'])?.toString(),
      content: (json['content'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      type: (json['type'] ?? 'text').toString(),
      createdAt: parseDate(createdRaw),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ride_id': rideId,
      'sender_id': senderId,
      'content': content,
      'image_url': imageUrl,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
