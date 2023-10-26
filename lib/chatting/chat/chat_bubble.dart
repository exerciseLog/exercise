import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:intl/intl.dart';

class ChatBubbles extends StatelessWidget {
  ChatBubbles(this.message, this.isMe, this.userName, this.userImage, this.time,
      {Key? key})
      : super(key: key);

  final String message;
  final String userName;
  final bool isMe;
  final String userImage;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 45, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.sendBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 20),
                backGroundColor: Color(0xFFfef01b),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        dataTimeFormat(time),
                        style: TextStyle(
                            letterSpacing: 0.04,
                            fontSize: 14,
                            color: Color.fromRGBO(82, 82, 82, 0.644)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!isMe)
            Padding(
              padding: const EdgeInsets.fromLTRB(45, 10, 0, 0),
              child: ChatBubble(
                clipper: ChatBubbleClipper8(type: BubbleType.receiverBubble),
                backGroundColor: Color(0xFFffffff),
                margin: EdgeInsets.only(top: 20),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        dataTimeFormat(time),
                        style: TextStyle(
                            letterSpacing: 0.04,
                            fontSize: 14,
                            color: Color.fromRGBO(82, 82, 82, 0.644)),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
      Positioned(
        top: 0,
        right: isMe ? 5 : null,
        left: isMe ? null : 5,
        child: CircleAvatar(
          backgroundImage: NetworkImage(userImage),
        ),
      ),
    ]);
  }

  String dataTimeFormat(String time) {
    DateTime timeFormat = DateFormat('yyyy-MM-dd hh:mm:ss').parse(time);

    String result = '';
    DateTime now = DateTime.now();
    Duration diff = now.difference(timeFormat);
    if (diff.inDays > 0) {
      result = '${diff.inDays}일 전';
    } else if (diff.inHours > 0 && diff.inDays == 0) {
      result = '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      result = '${diff.inMinutes}분 전';
    } else {
      result = '방금 전';
    }
    return result;
  }
}
