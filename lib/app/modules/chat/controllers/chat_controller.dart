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

  late final String rideId;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final Rx<ChatUiState> uiState = ChatUiState().obs;
  StreamSubscription? _chatSubscription;

  @override
  void onInit() {
    super.onInit();

    // Logika pengambilan ID yang sudah diperbaiki sebelumnya
    String? idFromParam = Get.parameters['rideRequestId'];
    final arg = Get.arguments;

    if (idFromParam != null && idFromParam.isNotEmpty) {
      rideId = idFromParam;
    } else if (arg is String && arg.isNotEmpty) {
      rideId = arg;
    } else {
      throw Exception('ChatController: rideId tidak ditemukan.');
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

  // --- FUNGSI SCROLL OTOMATIS KE BAWAH ---
  void _scrollToBottom() {
    if (scrollController.hasClients) {
      // Beri sedikit delay agar UI sempat merender item baru
      Future.delayed(const Duration(milliseconds: 300), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _listenForMessages() {
    _chatSubscription?.cancel();
    _chatSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .listen((List<Map<String, dynamic>> data) {
          try {
            final rawList = data
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

            // Helper parsing tanggal yang kuat
            DateTime toDate(dynamic v) {
              if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
              if (v is DateTime) return v;
              if (v is String) {
                return DateTime.tryParse(v) ??
                    DateTime.fromMillisecondsSinceEpoch(0);
              }
              return DateTime.fromMillisecondsSinceEpoch(0);
            }

            final messageList = rawList.map((json) {
              final m = Map<String, dynamic>.from(json);

              final createdRaw = m['created_at'] ?? m['createdAt'] ?? m['ts'];
              m['createdAt'] = toDate(createdRaw);

              if (m.containsKey('image_url')) m['imageUrl'] = m['image_url'];
              if (m.containsKey('sender_id')) m['senderId'] = m['sender_id'];
              if (m.containsKey('ride_id')) m['rideId'] = m['ride_id'];

              return Message.fromJson(m);
            }).toList();

            // PERBAIKAN SORTING: Pastikan yang lama di atas (Indeks 0), baru di bawah
            messageList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            uiState.value = uiState.value.copyWith(messages: messageList);

            // Auto Scroll setiap kali data berubah (termasuk saat gambar masuk)
            _scrollToBottom();
          } catch (e) {
            print('Error processing messages: $e');
          }
        }, onError: (err) => print('Chat stream error: $err'));
  }

  Future<void> _loadUsersInfo() async {
    // ... (kode ini tetap sama, tidak perlu diubah) ...
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final rideData = await _supabase
          .from('ride_requests')
          .select('passenger_id, driver_id')
          .eq('id', rideId)
          .maybeSingle();

      if (rideData == null) return;
      final passengerId = rideData['passenger_id'];
      final driverId = rideData['driver_id'];
      final otherUserId = (currentUserId == passengerId)
          ? driverId
          : passengerId;

      final currentUserRes = await _supabase
          .from('users')
          .select('photo_url')
          .eq('id', currentUserId)
          .maybeSingle();

      String otherName = 'User';
      String? otherPhoto;

      if (otherUserId != null) {
        final otherUserRes = await _supabase
            .from('users')
            .select('name, photo_url')
            .eq('id', otherUserId)
            .maybeSingle();
        if (otherUserRes != null) {
          otherName = otherUserRes['name'] ?? 'User';
          otherPhoto = otherUserRes['photo_url'];
        }
      }

      uiState.value = uiState.value.copyWith(
        otherUserName: otherName,
        otherUserPhotoUrl: otherPhoto,
        currentUserPhotoUrl: currentUserRes?['photo_url'],
      );
    } catch (e) {
      print('Error loading users info: $e');
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

    messageController.clear();
    uiState.value = uiState.value.copyWith(messageText: '');

    try {
      await _supabase.from('messages').insert({
        'ride_id': rideId,
        'sender_id': currentUserId,
        'content': textToSend,
        'type': 'text',
        // PERBAIKAN: Kirim waktu dari HP agar tidak null/delay
        'created_at': DateTime.now().toIso8601String(),
      });
      _scrollToBottom(); // Scroll manual saat kirim
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Gagal', 'Pesan tidak terkirim');
    }
  }

  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Kompres biar cepat upload
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
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

      // Upload ke bucket chat-attachments
      // Pastikan bucket 'chat-attachments' sudah dibuat di Supabase Storage & Public
      await _supabase.storage
          .from('chat-attachments')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _supabase.storage
          .from('chat-attachments')
          .getPublicUrl(fileName);

      // Insert ke database
      await _supabase.from('messages').insert({
        'ride_id': rideId,
        'sender_id': currentUserId,
        'content': '', // Kosongkan content kalau gambar
        'image_url': publicUrl,
        'type': 'image',
        'created_at': DateTime.now().toIso8601String(),
      });

      _scrollToBottom(); // Scroll setelah upload sukses
    } catch (e) {
      print('Error sending image: $e');
      Get.snackbar('Error', 'Gagal kirim gambar: $e');
    } finally {
      uiState.value = uiState.value.copyWith(isUploading: false);
    }
  }
}
