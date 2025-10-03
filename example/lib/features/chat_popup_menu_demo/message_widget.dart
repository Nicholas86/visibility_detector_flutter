import 'package:flutter/material.dart';
import 'chat_popup_menu_demo_page.dart';

/// 消息类型枚举
enum MessageType {
  text,
  image,
  emoji,
}

/// 消息数据模型
class MessageData {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isFromMe;
  final bool isFirstMessage; // 标识是否为第一条消息

  MessageData({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isFromMe,
    this.isFirstMessage = false, // 默认不是第一条消息
  });
}

/// 消息Widget - 包含消息气泡和弹出菜单
class MessageWidget extends StatefulWidget {
  final MessageData message;
  final VoidCallback? onCopy;
  final VoidCallback? onQuote;
  final VoidCallback? onRecall;
  final VoidCallback? onDelete;

  const MessageWidget({
    Key? key,
    required this.message,
    this.onCopy,
    this.onQuote,
    this.onRecall,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool _showPopupMenu = false;
  final GlobalKey _messageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: widget.message.isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧头像（对方消息时显示）
          if (!widget.message.isFromMe) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],

          // 消息内容区域
          Flexible(
            child: Column(
              crossAxisAlignment: widget.message.isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // 消息气泡和第一条消息标识
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 对方发送的第一条消息的图片标识（左边）
                    if (widget.message.isFirstMessage && !widget.message.isFromMe) ...[
                      Container(
                        width: 6,
                        height: 21,
                        child: Image.asset(
                          'assets/images/message_top_white.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    
                    // 消息气泡
                    GestureDetector(
                      key: _messageKey,
                      onLongPress: _showMenu,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 262,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: _buildMessageDecoration(),
                          child: _buildMessageContent(),
                        ),
                      ),
                    ),

                    // 我发送的第一条消息的图片标识（右边）
                    if (widget.message.isFirstMessage && widget.message.isFromMe) ...[
                      Container(
                        width: 6,
                        height: 21,
                        child: Image.asset(
                          'assets/images/message_top_red.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ],
                ),

                // 弹出菜单
                if (_showPopupMenu) _buildPopupMenu(),

                // 时间戳
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTime(widget.message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 右侧头像（自己消息时显示）
          if (widget.message.isFromMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  /// 构建消息装饰
  BoxDecoration _buildMessageDecoration() {
    BorderRadius borderRadius;
    
    if (widget.message.isFirstMessage) {
      // 第一条消息的圆角处理
      if (widget.message.isFromMe) {
        // 我发送的第一条消息：右上角不要圆角
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      } else {
        // 对方发送的第一条消息：左上角不要圆角
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        );
      }
    } else {
      // 其他情况：所有圆角都是8
      borderRadius = BorderRadius.circular(8);
    }
    
    return BoxDecoration(
      color: widget.message.isFromMe ? const Color(0xFFFFEDED) : const Color(0xFFFFFFFF),
      borderRadius: borderRadius,
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: widget.message.isFromMe ? Colors.blue : Colors.grey[400],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        widget.message.isFromMe ? Icons.person : Icons.person_outline,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  /// 构建消息内容
  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case MessageType.text:
        return Text(
          widget.message.content,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xff1D2024),
          ),
        );
      case MessageType.emoji:
        return Text(
          widget.message.content,
          style: const TextStyle(fontSize: 32),
        );
      case MessageType.image:
        return Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.image,
            size: 48,
            color: Colors.grey,
          ),
        );
    }
  }

  /// 构建弹出菜单
  Widget _buildPopupMenu() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: ChatPopupMenu(
        arrowWidth: 40,
        arrowHeight: 10,
        borderRadius: 12,
        backgroundColor: const Color(0xFF5E5F62),
        items: [
          MenuItem(
            icon: Icons.copy,
            label: "复制",
            onTap: () {
              _hideMenu();
              widget.onCopy?.call();
            },
          ),
          MenuItem(
            icon: Icons.format_quote,
            label: "引用",
            onTap: () {
              _hideMenu();
              widget.onQuote?.call();
            },
          ),
          if (widget.message.isFromMe)
            MenuItem(
              icon: Icons.undo,
              label: "撤回",
              onTap: () {
                _hideMenu();
                widget.onRecall?.call();
              },
            ),
          MenuItem(
            icon: Icons.delete,
            label: "删除",
            onTap: () {
              _hideMenu();
              widget.onDelete?.call();
            },
          ),
        ],
      ),
    );
  }

  /// 显示菜单
  void _showMenu() {
    setState(() {
      _showPopupMenu = true;
    });

    // 3秒后自动隐藏菜单
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _hideMenu();
      }
    });
  }

  /// 隐藏菜单
  void _hideMenu() {
    if (mounted) {
      setState(() {
        _showPopupMenu = false;
      });
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
