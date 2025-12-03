// filepath: lib/app/modules/chat/views/chat_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/chat_controller.dart';
import '../../../../data/models/message.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uiState = controller.uiState.value;

      return Scaffold(
        appBar: ChatAppBar(
          name: uiState.otherUserName,
          photoUrl: uiState.otherUserPhotoUrl,
          onBackPressed: () => Get.back(),
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatMessagesList(
                messages: uiState.messages,
                currentUserId: controller.currentUserId ?? '',
                currentUserPhotoUrl: uiState.currentUserPhotoUrl,
                otherUserPhotoUrl: uiState.otherUserPhotoUrl,
              ),
            ),
            ChatMessageInput(
              messageText: uiState.messageText,
              isUploading: uiState.isUploading,
              onMessageChanged: controller.onMessageChanged,
              onSendMessage: controller.sendMessage,
              onPickImage: controller.pickAndSendImage,
            ),
          ],
        ),
      );
    });
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? photoUrl;
  final VoidCallback onBackPressed;

  const ChatAppBar({
    super.key,
    required this.name,
    this.photoUrl,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            backgroundImage: photoUrl != null
                ? CachedNetworkImageProvider(photoUrl!)
                : null,
            child: photoUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ChatMessagesList extends StatelessWidget {
  final List<Message> messages;
  final String currentUserId;
  final String? currentUserPhotoUrl;
  final String? otherUserPhotoUrl;

  const ChatMessagesList({
    super.key,
    required this.messages,
    required this.currentUserId,
    this.currentUserPhotoUrl,
    this.otherUserPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pesan\nMulai percakapan sekarang!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMyMessage = message.senderId == currentUserId;

        return MessageBubble(
          message: message,
          isMyMessage: isMyMessage,
          myPhotoUrl: currentUserPhotoUrl,
          otherUserPhotoUrl: otherUserPhotoUrl,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMyMessage;
  final String? myPhotoUrl;
  final String? otherUserPhotoUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.myPhotoUrl,
    this.otherUserPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMyMessage
        ? const Color(0xFF272343) // Dark color untuk pesan sendiri
        : const Color(0xFFFFD803); // Yellow untuk pesan lawan

    final textColor = isMyMessage ? Colors.white : Colors.black;

    final bubbleShape = isMyMessage
        ? const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          )
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(16),
            ),
          );

    return Row(
      mainAxisAlignment: isMyMessage
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMyMessage) ...[
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            backgroundImage: otherUserPhotoUrl != null
                ? CachedNetworkImageProvider(otherUserPhotoUrl!)
                : null,
            child: otherUserPhotoUrl == null
                ? const Icon(Icons.person, size: 16, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              shape: bubbleShape,
              color: bubbleColor,
              child: _buildMessageContent(textColor),
            ),
          ),
        ),
        if (isMyMessage) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[300],
            backgroundImage: myPhotoUrl != null
                ? CachedNetworkImageProvider(myPhotoUrl!)
                : null,
            child: myPhotoUrl == null
                ? const Icon(Icons.person, size: 16, color: Colors.grey)
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildMessageContent(Color textColor) {
    if (message.type == 'image' && message.imageUrl != null) {
      return Container(
        padding: const EdgeInsets.all(4),
        child: ClipRoundedRectangle(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: message.imageUrl!,
            width: 200,
            height: 250,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 250,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 250,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 14),
        ),
      );
    }
  }
}

class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const ClipRoundedRectangle({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: borderRadius, child: child);
  }
}

class ChatMessageInput extends StatelessWidget {
  final String messageText;
  final bool isUploading;
  final Function(String) onMessageChanged;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;

  const ChatMessageInput({
    super.key,
    required this.messageText,
    required this.isUploading,
    required this.onMessageChanged,
    required this.onSendMessage,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: onMessageChanged,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan kamu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: messageText.trim().isEmpty
                      ? IconButton(
                          icon: isUploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.photo_camera_outlined),
                          onPressed: isUploading ? null : onPickImage,
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: onSendMessage,
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                controller: TextEditingController(text: messageText)
                  ..selection = TextSelection.collapsed(
                    offset: messageText.length,
                  ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) =>
                    messageText.trim().isNotEmpty ? onSendMessage() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
