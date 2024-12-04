import 'dart:developer';

import 'package:agromitra/utils/data/fetchInternetData.dart';
import 'package:agromitra/utils/data/urls.dart';
import 'package:agromitra/utils/ui/custom-button.dart';
import 'package:agromitra/utils/ui/custom-input-field.dart';
import 'package:agromitra/utils/ui/custom-text.dart';
import 'package:flutter/material.dart';
import 'package:agromitra/constant/color.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add({'text': message, 'isUser': true}); 
    });

    _scrollToBottom();

    var reply = await askingAi(message);

    setState(() {
      _messages.add({
        'text': '$reply',
        'isUser': false
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomTextWidget(
          text: 'Krishak Ai',
          textColor: AppColors.white,
          fontSize: 20,
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'] as bool;

                return Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isUser ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: Radius.circular(isUser ? 12 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 12),
                        ),
                      ),
                      child: CustomTextWidget(
                          text: message['text'],
                          overflow: TextOverflow.visible,
                          textColor:
                              isUser ? Colors.white : AppColors.textPrimary)),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          width: double.infinity,
          // height: 70,
          color: AppColors.background,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 1),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: CustomTextField(
                    hintText: 'Ask any thing related to agriculture...',
                    controller: _messageController,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: CustomButton(
                  backgroundColor: AppColors.primary,
                  textColor: Colors.white,
                  text: '',
                  postfixIcon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final message = _messageController.text;
                    _messageController.clear();
                    _sendMessage(message);
                  },
                ),
              ),
            ],
          )),
    );
  }
}

dynamic askingAi(question) async {
  var response = FetchData(
    url: UrlProvider.chatbotUrl,
    headers: {'Content-Type': 'application/json'},
    body: {"question": question.toString()},
  );
  var reply = await response.post();
  log(reply.toString());
  if(reply['success'] == true){
    return formatText(reply['answer']);
  }else{
    return "Sorry, unable to reach server at the moment. Please try again after some time.";
  }
}


String formatText(String input) {
  final regex = RegExp(r'\*{1,2}(.*?)\*{1,2}|\*');
  return input.replaceAllMapped(regex, (match) {
    return match.group(1) ?? '';
  });
}
