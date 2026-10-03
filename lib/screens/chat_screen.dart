import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message.dart';
import '../models/student.dart';
import '../models/study_group.dart';
import '../services/group_service.dart';

class ChatScreen extends StatefulWidget {
  final StudyGroup group;

  const ChatScreen({
    super.key,
    required this.group,
  });

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color maroon = Color(0xFF800000);
  static const Color backgroundColor = Color(0xFFF9F9F9);

  final GroupService groupService = GroupService();

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final FocusNode inputFocus = FocusNode();

  List<Message> messages = [];

  Map<String, Student> senderProfiles = {};

  RealtimeChannel? channel;

  bool isInitialLoading = true;
  bool isSending = false;

  @override
  void initState() {
    super.initState();

    loadMessages();
    setupRealtime();
  }

  Future<void> loadMessages() async {
    try {
      final List<Message> loadedMessages =
          await groupService.getMessages(
        widget.group.id,
      );

      final List<String> senderIds = loadedMessages
          .map(
            (message) => message.senderId,
          )
          .toSet()
          .toList();

      final Map<String, Student> loadedSenders =
          await groupService.getMessageSenders(
        senderIds,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        messages = loadedMessages;
        senderProfiles = loadedSenders;
        isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isInitialLoading = false;
      });

      showMessage(
        'Could not load messages.',
      );
    }
  }

  void setupRealtime() {
    final SupabaseClient supabase =
        Supabase.instance.client;

    channel = supabase
        .channel(
          'group-${widget.group.id}',
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: widget.group.id,
          ),
          callback: (payload) {
            refreshMessages();
          },
        )
        .subscribe();
  }

  Future<void> refreshMessages() async {
    try {
      final List<Message> updatedMessages =
          await groupService.getMessages(
        widget.group.id,
      );

      final List<String> senderIds = updatedMessages
          .map(
            (message) => message.senderId,
          )
          .toSet()
          .toList();

      final Map<String, Student> updatedSenders =
          await groupService.getMessageSenders(
        senderIds,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        messages = updatedMessages;
        senderProfiles = updatedSenders;
      });
    } catch (error) {
      // Keep the current chat visible.
    }
  }

  Future<void> sendMessage() async {
    final String message =
        messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    if (isSending) {
      return;
    }

    messageController.clear();

    setState(() {
      isSending = true;
    });

    try {
      await groupService.sendMessage(
        groupId: widget.group.id,
        message: message,
      );

      await refreshMessages();

      if (mounted) {
        inputFocus.requestFocus();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      messageController.text = message;

      messageController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: messageController.text.length,
        ),
      );

      showMessage(
        'Could not send message.',
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isSending = false;
      });
    }
  }

  String formatTime(DateTime dateTime) {
    final DateTime localTime = dateTime.toLocal();

    int hour = localTime.hour;

    final String period =
        hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final String minute =
        localTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  String getSenderName(String senderId) {
    final Student? student =
        senderProfiles[senderId];

    if (student == null) {
      return 'StudyCircle Student';
    }

    if (student.displayName.trim().isNotEmpty) {
      return student.displayName.trim();
    }

    if (student.fullName.trim().isNotEmpty) {
      return student.fullName.trim();
    }

    return 'StudyCircle Student';
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    inputFocus.dispose();

    if (channel != null) {
      Supabase.instance.client.removeChannel(
        channel!,
      );
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.group.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageArea(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageArea() {
    if (isInitialLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: maroon,
        ),
      );
    }

    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 58,
                color: maroon,
              ),
              SizedBox(height: 14),
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Start the conversation!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentUser =
        Supabase.instance.client.auth.currentUser;

    return ListView.builder(
      controller: scrollController,
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        14,
        16,
        14,
        16,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final Message message = messages[index];

        final bool isMine =
            message.senderId == currentUser?.id;

        return _buildMessageBubble(
          message,
          isMine,
        );
      },
    );
  }

  Widget _buildMessageBubble(
    Message message,
    bool isMine,
  ) {
    final String senderName =
        getSenderName(message.senderId);

    final String time =
        formatTime(message.createdAt);

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.76,
        ),
        child: IntrinsicWidth(
          child: Container(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            padding: const EdgeInsets.fromLTRB(
              14,
              10,
              14,
              8,
            ),
            decoration: BoxDecoration(
              color: isMine
                  ? maroon
                  : Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: isMine
                  ? null
                  : Border.all(
                      color:
                          Colors.grey.shade200,
                    ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  senderName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isMine
                        ? Colors.white
                        : maroon,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message.message,
                  softWrap: true,
                  style: TextStyle(
                    color: isMine
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 3),

                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isMine
                          ? Colors.white70
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: messageController,
                focusNode: inputFocus,
                minLines: 1,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
                textInputAction:
                    TextInputAction.send,
                onSubmitted: (_) {
                  sendMessage();
                },
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                    borderSide:
                        const BorderSide(
                      color: maroon,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: maroon,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed:
                    isSending ? null : sendMessage,
                icon: Icon(
                  Icons.send,
                  color: isSending
                      ? Colors.white54
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}