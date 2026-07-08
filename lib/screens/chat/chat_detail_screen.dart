import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapak_tani/providers/auth_provider.dart';
import 'package:lapak_tani/services/chat_service.dart';
import 'package:lapak_tani/models/chat_room_model.dart';
import 'package:lapak_tani/models/chat_message_model.dart';
import 'package:lapak_tani/screens/buyer/product_detail_screen.dart';
import 'package:lapak_tani/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoomModel? room;
  // Jika room null, kita butuh ini untuk membuat room baru (diinisiasi dari produk)
  final String? targetUserId;
  final String? targetUserName;
  
  // Data produk yang di-tag
  final String? taggedProductId;
  final String? taggedProductName;
  final String? taggedProductImageUrl;

  const ChatDetailScreen({
    super.key,
    this.room,
    this.targetUserId,
    this.targetUserName,
    this.taggedProductId,
    this.taggedProductName,
    this.taggedProductImageUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _chatService = ChatService();
  final _messageController = TextEditingController();
  
  String? _roomId;
  bool _isLoadingRoom = false;

  // Local state for the tagged product so the user can clear it
  String? _currentTagId;
  String? _currentTagName;
  String? _currentTagImage;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _roomId = widget.room!.id;
      _markAsRead();
    } else {
      _initRoom();
    }
    
    // Set initial tag
    _currentTagId = widget.taggedProductId;
    _currentTagName = widget.taggedProductName;
    _currentTagImage = widget.taggedProductImageUrl;
  }

  Future<void> _markAsRead() async {
    if (_roomId == null) return;
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await _chatService.resetUnreadCount(_roomId!, user.role);
    }
  }

  Future<void> _initRoom() async {
    setState(() => _isLoadingRoom = true);
    final user = context.read<AuthProvider>().user!;
    
    final buyerId = user.role == 'pembeli' ? user.uid : widget.targetUserId!;
    final sellerId = user.role == 'petani' ? user.uid : widget.targetUserId!;
    final buyerName = user.role == 'pembeli' ? user.name : widget.targetUserName!;
    final sellerName = user.role == 'petani' ? user.name : widget.targetUserName!;

    final roomId = await _chatService.getOrCreateRoom(buyerId, sellerId, buyerName, sellerName);
    
    if (mounted) {
      setState(() {
        _roomId = roomId;
        _isLoadingRoom = false;
      });
      _markAsRead();
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _currentTagId == null) return;
    
    if (_roomId == null) return; // Wait until room is created
    
    final user = context.read<AuthProvider>().user!;

    final message = ChatMessageModel(
      id: '', // Service generates
      roomId: _roomId!,
      senderId: user.uid,
      text: text,
      productId: _currentTagId,
      productName: _currentTagName,
      productImageUrl: _currentTagImage,
      createdAt: DateTime.now(),
    );

    _messageController.clear();
    setState(() {
      _currentTagId = null;
      _currentTagName = null;
      _currentTagImage = null;
    });

    await _chatService.sendMessage(message, user.role);
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe) {
    final timeStr = DateFormat('HH:mm').format(msg.createdAt);
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.productId != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: msg.productId!),
                  ));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (msg.productImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            msg.productImageUrl!,
                            width: 40, height: 40, fit: BoxFit.cover,
                            errorBuilder: (_,__,___) => const Icon(Icons.image, size: 40),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          msg.productName ?? 'Produk', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (msg.text.isNotEmpty)
              Text(
                msg.text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black),
              ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeStr,
                style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user!;
    final isBuyer = user.role == 'pembeli';
    
    // Determine target name for appbar
    String appBarTitle = 'Chat';
    if (widget.room != null) {
      appBarTitle = isBuyer ? widget.room!.sellerName : widget.room!.buyerName;
    } else if (widget.targetUserName != null) {
      appBarTitle = widget.targetUserName!;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: _isLoadingRoom
          ? const LoadingWidget()
          : Column(
              children: [
                Expanded(
                  child: _roomId == null
                      ? const Center(child: Text('Gagal memuat ruang obrolan'))
                      : StreamBuilder<List<ChatMessageModel>>(
                          stream: _chatService.getChatMessages(_roomId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const LoadingWidget();
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            final msgs = snapshot.data ?? [];
                            if (msgs.isEmpty) {
                              return const Center(child: Text('Kirim pesan pertama Anda.'));
                            }

                            return ListView.builder(
                              reverse: true, // Newest at bottom
                              itemCount: msgs.length,
                              itemBuilder: (context, index) {
                                final msg = msgs[index];
                                final isMe = msg.senderId == user.uid;
                                return _buildMessageBubble(msg, isMe);
                              },
                            );
                          },
                        ),
                ),
                
                // Tagged Product Preview Area (before sending)
                if (_currentTagId != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    child: Row(
                      children: [
                        if (_currentTagImage != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              _currentTagImage!,
                              width: 40, height: 40, fit: BoxFit.cover,
                              errorBuilder: (_,__,___) => const Icon(Icons.image, size: 40),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Menautkan Produk:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                _currentTagName ?? 'Produk',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _currentTagId = null;
                              _currentTagName = null;
                              _currentTagImage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Input Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
                    ]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
