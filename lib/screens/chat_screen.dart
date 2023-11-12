import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercise_log/chatting/chat/message.dart';
import 'package:exercise_log/chatting/chat/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _authentication = FirebaseAuth.instance;
  String chatId = 'chatId';
  User? loggedUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getChatId();
    });
    getCurrentUser();
  }


  Future<void> getChatId() async {
    if(widget.chatId == 'fromHome') {
      var db = FirebaseFirestore.instance;
      var uid = FirebaseAuth.instance.currentUser!.uid;
      var userData = await db.collection('user').doc(uid).get();
      var userName = userData.data()!['userName'];
      db.collection('newchat').where("member", arrayContains: userName)
      .get().then((values) {
        if(values.size == 0) {
          Fluttertoast.showToast(msg: '현재 활성화된 채팅이 없습니다.');
        }
        else {
          for(var value in values.docs) {
            setState(() {
              chatId = value.id;
            });
          }
        }
      });
    }
    else {
      setState(() {
        chatId = widget.chatId;
      });
    }
  }

  void getCurrentUser() {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat screen'),
        backgroundColor: const Color(0xFF9bbbd4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.black54),
          onPressed: () {
            /* Navigator.push(
                context, MaterialPageRoute(builder: (context) => const HomeScreen())); */
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app_sharp,
              color: Colors.blue,
            ),
            onPressed: () {
              _authentication.signOut();
              //Navigator.pop(context);
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFF9bbbd4),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages(chatId: chatId),
            ),
            NewMessage(chatId: chatId),
          ],
        ),
      ),
    );
  }
}
