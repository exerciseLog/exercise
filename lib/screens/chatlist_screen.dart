import 'dart:developer';

import 'package:exercise_log/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  var user = FirebaseAuth.instance.currentUser;
  var db = FirebaseFirestore.instance;
  var userName = '';

  @override
  void initState() {
    super.initState();
     
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var name = await _getName();
      log(name);
      setState(() {
        userName = name;
      });
    });
  }

  dynamic _getName() async {
    var uid = user!.uid;
    var userData = await db.collection('user').doc(uid).get();
    return userData.data()!['userName'];
  }
  
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          const Text("참가 중인 채팅", 
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'NaverNanum',
              fontWeight: FontWeight.w600)
          ),
          Expanded(
            child: Column(
              children: [
                ChatList(userName: userName),
              ],
            )
          ),
        ],
      ),
      
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({
    super.key,
    required this.userName
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
      .collection("newchat").where("member", arrayContains: userName)
      .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final docs = snapshot.data!.docs;
        log(docs.length.toString());
        return ListView.separated(
          shrinkWrap: true,
          itemCount: docs.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(docs[index].id),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ChatScreen(chatId: docs[index].id)
                ));              
              },
            );
            
          }
        );
      }
    );
  }
}