import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': '1',
      'name': 'Aminata Koné',
      'avatar': 'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg',
      'lastMessage': 'Merci pour la visite guidée ! C\'était parfait.',
      'timestamp': '14:30',
      'unreadCount': 0,
      'isOnline': true,
      'isTyping': false,
    },
    {
      'id': '2',
      'name': 'Fatoumata Traoré',
      'avatar': 'https://images.pexels.com/photos/1181519/pexels-photo-1181519.jpeg',
      'lastMessage': 'Bonjour ! Je peux vous aider pour l\'organisation de votre événement',
      'timestamp': '12:45',
      'unreadCount': 2,
      'isOnline': true,
      'isTyping': true,
    },
    {
      'id': '3',
      'name': 'Adjoa Assi',
      'avatar': 'https://images.pexels.com/photos/1547971/pexels-photo-1547971.jpeg',
      'lastMessage': 'Service VIP confirmé pour demain 18h',
      'timestamp': 'Hier',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': false,
    },
    {
      'id': '4',
      'name': 'Koffi Yao',
      'avatar': 'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg',
      'lastMessage': 'La consultation business s\'est bien passée',
      'timestamp': '2 jours',
      'unreadCount': 0,
      'isOnline': false,
      'isTyping': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search conversations
            },
          ),
        ],
      ),
      body: _conversations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                return _buildConversationTile(conversation);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.mediumGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune conversation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à discuter avec nos professionnels',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> conversation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.lightGray,
              backgroundImage: NetworkImage(conversation['avatar']),
            ),
            if (conversation['isOnline'])
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                conversation['name'],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              conversation['timestamp'],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (conversation['isTyping'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'En train d\'écrire...',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Text(
                      conversation['lastMessage'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: conversation['unreadCount'] > 0
                            ? AppColors.darkGray
                            : AppColors.mediumGray,
                        fontWeight: conversation['unreadCount'] > 0
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (conversation['unreadCount'] > 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      conversation['unreadCount'].toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          _openChatScreen(conversation);
        },
      ),
    );
  }

  void _openChatScreen(Map<String, dynamic> conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          companionName: conversation['name'],
          companionAvatar: conversation['avatar'],
          isOnline: conversation['isOnline'],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String companionName;
  final String companionAvatar;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.companionName,
    required this.companionAvatar,
    required this.isOnline,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'id': '1',
      'text': 'Bonjour ! Comment puis-je vous aider ?',
      'isSentByMe': false,
      'timestamp': '14:30',
    },
    {
      'id': '2',
      'text': 'Salut ! Je voudrais réserver une visite guidée pour demain.',
      'isSentByMe': true,
      'timestamp': '14:32',
    },
    {
      'id': '3',
      'text': 'Parfait ! À quelle heure souhaitez-vous commencer la visite ?',
      'isSentByMe': false,
      'timestamp': '14:33',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.companionAvatar),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.companionName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isOnline ? 'En ligne' : 'Hors ligne',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.isOnline ? AppColors.success : AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Call companion
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Video call
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSentByMe = message['isSentByMe'] as bool;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSentByMe 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isSentByMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.companionAvatar),
            ),
          if (!isSentByMe) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSentByMe 
                    ? AppColors.orange 
                    : AppColors.lightGray,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isSentByMe 
                      ? const Radius.circular(20) 
                      : const Radius.circular(4),
                  bottomRight: isSentByMe 
                      ? const Radius.circular(4) 
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['text'],
                    style: TextStyle(
                      color: isSentByMe ? AppColors.white : AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['timestamp'],
                    style: TextStyle(
                      color: isSentByMe 
                          ? AppColors.white.withOpacity(0.7)
                          : AppColors.mediumGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isSentByMe) const SizedBox(width: 8),
          if (isSentByMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.orange.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 16,
                color: AppColors.orange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: AppColors.mediumGray,
              ),
              onPressed: () {
                // Show emoji picker
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.attach_file,
                color: AppColors.mediumGray,
              ),
              onPressed: () {
                // Attach file
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: AppColors.orange,
              ),
              onPressed: () {
                _sendMessage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'text': _messageController.text.trim(),
          'isSentByMe': true,
          'timestamp': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
      });
      _messageController.clear();
    }
  }
}
