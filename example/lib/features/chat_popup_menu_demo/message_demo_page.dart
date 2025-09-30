import 'package:flutter/material.dart';
import 'message_widget.dart';

/// 消息演示页面
class MessageDemoPage extends StatefulWidget {
  const MessageDemoPage({Key? key}) : super(key: key);

  @override
  State<MessageDemoPage> createState() => _MessageDemoPageState();
}

class _MessageDemoPageState extends State<MessageDemoPage> {
  final List<MessageData> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initMessages();
  }

  void _initMessages() {
    final now = DateTime.now();
    _messages.addAll([
      MessageData(
        id: '1',
        content: '你好！这是一条测试消息',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 5)),
        isFromMe: false,
      ),
      MessageData(
        id: '2',
        content: '收到，我来发个绝密表情包给你看看',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 4)),
        isFromMe: true,
      ),
      MessageData(
        id: '3',
        content: '😄',
        type: MessageType.emoji,
        timestamp: now.subtract(const Duration(minutes: 3)),
        isFromMe: true,
      ),
      MessageData(
        id: '4',
        content: '哈哈，很有趣的表情包！',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 2)),
        isFromMe: false,
      ),
      MessageData(
        id: '5',
        content: '长按消息可以看到弹出菜单哦',
        type: MessageType.text,
        timestamp: now.subtract(const Duration(minutes: 1)),
        isFromMe: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息演示'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: Container(
              // margin: const EdgeInsets.only(left: 60, right: 60),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                // padding: EdgeInsets.zero,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageWidget(
                    message: message,
                    onCopy: () => _showSnackBar('复制了消息: ${message.content}'),
                    onQuote: () => _showSnackBar('引用了消息: ${message.content}'),
                    onRecall: () => _showSnackBar('撤回了消息'),
                    onDelete: () => _showSnackBar('删除了消息'),
                  );
                },
              ),
            ),
          ),

          // 输入框区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () => _sendMessage('新消息'),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      _messages.add(
        MessageData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          type: MessageType.text,
          timestamp: DateTime.now(),
          isFromMe: true,
        ),
      );
    });

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
