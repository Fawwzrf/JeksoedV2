import 'dart:io';
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

  // Ambil rideId dari arguments saat navigasi
  final String rideId = Get.arguments as String;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // UI State (Observable)
  final Rx<ChatUiState> uiState = ChatUiState().obs;

  StreamSubscription? _chatSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToMessages();
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _listenForMessages() {
    _chatSubscription = _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId) // Filter pesan berdasarkan ID perjalanan
        .order('created_at', ascending: true)
        .listen((List<Map<String, dynamic>> data) {
          // Konversi data JSON dari Supabase ke Model Message
          final messageList = data.map((json) {
            // Pastikan model Message Anda memiliki factory fromJson/fromMap
            // yang bisa menangani format waktu ISO8601 string
            return Message.fromJson(json);
          }).toList();

          uiState.value = uiState.value.copyWith(messages: messageList);

          // Auto-scroll ke bawah
          Future.delayed(const Duration(milliseconds: 100), () {
            if (scrollController.hasClients) {
              scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              );
            }
          });
        });
  }

  Future<void> _loadUsersInfo() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      // Ambil data Ride untuk mengetahui siapa driver dan siapa passenger
      final rideData = await _supabase
          .from('rides')
          .select('passenger_id, driver_id')
          .eq('id', rideId)
          .single();

      final passengerId = rideData['passenger_id'];
      final driverId = rideData['driver_id'];

      // Tentukan ID lawan bicara
      final otherUserId = (currentUserId == passengerId)
          ? driverId
          : passengerId;

      // Ambil Foto Profil User Saat Ini
      final currentUserRes = await _supabase
          .from('users')
          .select(
            'photo_url',
          ) // Pastikan nama kolom di DB sesuai (misal: photo_url atau profile_image)
          .eq('id', currentUserId)
          .maybeSingle();

      final currentUserPhoto = currentUserRes?['photo_url'];

      if (otherUserId != null) {
        // Ambil Data Lawan Bicara
        final otherUserRes = await _supabase
            .from('users')
            .select('name, photo_url')
            .eq('id', otherUserId)
            .single();

        uiState.value = uiState.value.copyWith(
          otherUserName: otherUserRes['name'] ?? 'User',
          otherUserPhotoUrl: otherUserRes['photo_url'],
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
        // 'created_at': akan diisi otomatis oleh default value DB
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
        imageQuality: 70, // Kompres sedikit agar upload lebih cepat
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
      // Buat nama file unik
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$rideId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 1. Upload ke Supabase Storage (Bucket: 'chat-attachments')
      // Pastikan Anda sudah membuat bucket ini di dashboard Supabase dan set ke Public
      await _supabase.storage
          .from('chat-attachments')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Dapatkan URL Public
      final imageUrl = _supabase.storage
          .from('chat-attachments')
          .getPublicUrl(fileName);

      // 3. Simpan Pesan Gambar ke Database
      await _supabase.from('messages').insert({
        'ride_id': rideId,
        'sender_id': currentUserId,
        'content': '', // Kosong untuk gambar, atau bisa isi deskripsi
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
