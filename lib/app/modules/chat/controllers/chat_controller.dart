import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/message.dart';

class ChatUiState {
  final List<Message> messages;
  final String messageText;
  final bool isUploading;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final String? currentUserPhotoUrl;

  ChatUiState({
    this.messages = const [],
    this.messageText = '',
    this.isUploading = false,
    this.otherUserName = 'Memuat...',
    this.otherUserPhotoUrl,
    this.currentUserPhotoUrl,
  });

  ChatUiState copyWith({
    List<Message>? messages,
    String? messageText,
    bool? isUploading,
    String? otherUserName,
    String? otherUserPhotoUrl,
    String? currentUserPhotoUrl,
  }) {
    return ChatUiState(
      messages: messages ?? this.messages,
      messageText: messageText ?? this.messageText,
      isUploading: isUploading ?? this.isUploading,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserPhotoUrl: otherUserPhotoUrl ?? this.otherUserPhotoUrl,
      currentUserPhotoUrl: currentUserPhotoUrl ?? this.currentUserPhotoUrl,
    );
  }
}

class ChatController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  // rideId akan di-set di onInit agar Get.arguments tersedia
  late final String rideId;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // UI State (Observable)
  final Rx<ChatUiState> uiState = ChatUiState().obs;

  StreamSubscription? _chatSubscription;

  @override
  void onInit() {
    super.onInit();
    // Set rideId dari arguments (jika tidak ada, lempar error agar mudah dideteksi)
    final arg = Get.arguments;
    if (arg is String && arg.isNotEmpty) {
      rideId = arg;
    } else {
      throw Exception(
        'ChatController: rideId tidak ditemukan di Get.arguments',
      );
    }

    _listenForMessages();
    _loadUsersInfo();
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _listenForMessages() {
    _chatSubscription?.cancel();
    _chatSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .listen(
          (List<Map<String, dynamic>> data) {
            try {
              // Salin data mentah dan pastikan tipe Map<String, dynamic>
              final rawList = data
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();

              DateTime toDate(dynamic v) {
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

              // Normalisasi setiap item agar cocok dengan Message.fromJson
              final messageList = rawList.map((json) {
                final m = Map<String, dynamic>.from(json);

                // normalisasi timestamp --> createdAt (DateTime)
                final createdRaw =
                    m['created_at'] ?? m['createdAt'] ?? m['ts'] ?? m['time'];
                m['createdAt'] = toDate(createdRaw);

                // normalisasi nama field lain yang sering berbeda
                if (m.containsKey('image_url')) m['imageUrl'] = m['image_url'];
                if (m.containsKey('sender_id')) m['senderId'] = m['sender_id'];
                if (m.containsKey('ride_id')) m['rideId'] = m['ride_id'];
                if (m.containsKey('photo_url')) m['photoUrl'] = m['photo_url'];

                return Message.fromJson(m);
              }).toList();

              // pastikan terurut berdasarkan createdAt (asumsikan Message.createdAt adalah DateTime)
              messageList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              uiState.value = uiState.value.copyWith(messages: messageList);

              // Auto-scroll ke bawah
              Future.delayed(const Duration(milliseconds: 100), () {
                if (scrollController.hasClients) {
                  scrollController.jumpTo(
                    scrollController.position.maxScrollExtent,
                  );
                }
              });
            } catch (e) {
              print('Error processing incoming messages: $e');
            }
          },
          onError: (err) {
            print('Chat stream error: $err');
          },
        );
  }

  Future<void> _loadUsersInfo() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Ambil data Ride untuk mengetahui siapa driver dan siapa passenger
      final rideData = await _supabase
          .from('ride_requests')
          .select('passenger_id, driver_id')
          .eq('id', rideId)
          .maybeSingle();

      final passengerId = rideData?['passenger_id'];
      final driverId = rideData?['driver_id'];

      // Tentukan ID lawan bicara
      final otherUserId = (currentUserId == passengerId)
          ? driverId
          : passengerId;

      // Ambil Foto Profil User Saat Ini
      final currentUserRes = await _supabase
          .from('users')
          .select('photo_url')
          .eq('id', currentUserId)
          .maybeSingle();

      final currentUserPhoto = currentUserRes?['photo_url'];

      if (otherUserId != null) {
        // Ambil Data Lawan Bicara
        final otherUserRes = await _supabase
            .from('users')
            .select('name, photo_url')
            .eq('id', otherUserId)
            .maybeSingle();

        uiState.value = uiState.value.copyWith(
          otherUserName: otherUserRes?['name'] ?? 'User',
          otherUserPhotoUrl: otherUserRes?['photo_url'],
          currentUserPhotoUrl: currentUserPhoto,
        );
      } else {
        uiState.value = uiState.value.copyWith(
          currentUserPhotoUrl: currentUserPhoto,
        );
      }
    } catch (e) {
      print('Error loading users info: $e');
      uiState.value = uiState.value.copyWith(
        otherUserName: 'Info tidak tersedia',
      );
    }
  }

  void onMessageChanged(String newText) {
    uiState.value = uiState.value.copyWith(messageText: newText);
  }

  Future<void> sendMessage() async {
    final textToSend = messageController.text.trim();
    if (textToSend.isEmpty) return;

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    // Bersihkan input segera agar UI responsif
    messageController.clear();
    uiState.value = uiState.value.copyWith(messageText: '');

    try {
      await _supabase.from('messages').insert({
        'ride_id': rideId,
        'sender_id': currentUserId,
        'content': textToSend,
        'type': 'text',
      });
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Gagal mengirim pesan');
    }
  }

  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Gagal memilih gambar');
    }
  }

  Future<void> _sendImage(File imageFile) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    uiState.value = uiState.value.copyWith(isUploading: true);

    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$rideId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload ke Supabase Storage (Bucket: 'chat-attachments')
      await _supabase.storage
          .from('chat-attachments')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Dapatkan URL Public
      final dynamic publicRes = _supabase.storage
          .from('chat-attachments')
          .getPublicUrl(fileName);

      String imageUrl = '';
      if (publicRes is String) {
        imageUrl = publicRes;
      } else if (publicRes is Map) {
        imageUrl =
            (publicRes['publicUrl'] ??
                    publicRes['public_url'] ??
                    publicRes['publicurl'] ??
                    '')
                .toString();
      } else {
        imageUrl = publicRes?.toString() ?? '';
      }

      if (imageUrl.isEmpty) {
        throw Exception('Gagal mendapatkan public URL gambar');
      }

      // Simpan Pesan Gambar ke Database
      await _supabase.from('messages').insert({
        'ride_id': rideId,
        'sender_id': currentUserId,
        'content': '',
        'image_url': imageUrl,
        'type': 'image',
      });
    } catch (e) {
      print('Error sending image: $e');
      Get.snackbar('Error', 'Gagal mengirim gambar: $e');
    } finally {
      uiState.value = uiState.value.copyWith(isUploading: false);
    }
  }
}
