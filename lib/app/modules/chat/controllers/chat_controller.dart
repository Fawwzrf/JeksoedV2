// filepath: lib/app/modules/chat/controllers/chat_controller.dart

import 'dart:io';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final String rideRequestId;
  String? get currentUserId => _auth.currentUser?.uid;

  var uiState = ChatUiState().obs;

  ChatController({required this.rideRequestId});

  @override
  void onInit() {
    super.onInit();
    if (currentUserId != null) {
      _listenForMessages();
      _loadUsersInfo();
    }
  }

  void _listenForMessages() {
    _db
        .collection('chats')
        .doc(rideRequestId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          final messageList = snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id))
              .toList();
          uiState.value = uiState.value.copyWith(messages: messageList);
        });
  }

  Future<void> _loadUsersInfo() async {
    try {
      // 1. Ambil data ride request untuk menemukan ID passenger dan driver
      final rideRequestDoc = await _db
          .collection('ride_requests')
          .doc(rideRequestId)
          .get();

      if (!rideRequestDoc.exists) return;

      final passengerId = rideRequestDoc.data()?['passengerId'];
      final driverId = rideRequestDoc.data()?['driverId'];

      final otherUserId = (currentUserId == passengerId)
          ? driverId
          : passengerId;

      // Ambil foto profil user saat ini
      final currentUserDoc = await _db
          .collection('users')
          .doc(currentUserId!)
          .get();
      final currentUserPhoto = currentUserDoc.data()?['photoUrl'];

      if (otherUserId != null) {
        // 2. Ambil data user lawan bicara dari koleksi 'users'
        final otherUserDoc = await _db
            .collection('users')
            .doc(otherUserId)
            .get();

        final otherUserData = otherUserDoc.data();
        final otherUserName = otherUserData?['nama'] ?? 'User';
        final otherUserPhoto = otherUserData?['photoUrl'];

        uiState.value = uiState.value.copyWith(
          otherUserName: otherUserName,
          otherUserPhotoUrl: otherUserPhoto,
          currentUserPhotoUrl: currentUserPhoto,
        );
      }
    } catch (e) {
      print('Error loading users info: $e');
      uiState.value = uiState.value.copyWith(otherUserName: 'Error');
    }
  }

  void onMessageChanged(String newText) {
    uiState.value = uiState.value.copyWith(messageText: newText);
  }

  Future<void> sendMessage() async {
    final textToSend = uiState.value.messageText.trim();
    if (textToSend.isEmpty || currentUserId == null) return;

    try {
      final message = {
        'text': textToSend,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      };

      await _db
          .collection('chats')
          .doc(rideRequestId)
          .collection('messages')
          .add(message);

      uiState.value = uiState.value.copyWith(messageText: '');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> pickAndSendImage() async {
    if (currentUserId == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _sendImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _sendImage(File imageFile) async {
    if (currentUserId == null) return;

    uiState.value = uiState.value.copyWith(isUploading: true);

    try {
      // 1. Buat path unik untuk file di Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(
        'chats/$rideRequestId/$currentUserId/$fileName',
      );

      // 2. Upload file
      await storageRef.putFile(imageFile);

      // 3. Dapatkan URL download
      final downloadUrl = await storageRef.getDownloadURL();

      // 4. Simpan pesan tipe gambar ke Firestore
      final message = {
        'type': 'image',
        'imageUrl': downloadUrl,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'text': '', // Empty text for image messages
      };

      await _db
          .collection('chats')
          .doc(rideRequestId)
          .collection('messages')
          .add(message);
    } catch (e) {
      print('Error sending image: $e');
      Get.snackbar('Error', 'Gagal mengirim gambar');
    } finally {
      uiState.value = uiState.value.copyWith(isUploading: false);
    }
  }
}
