import 'dart:developer';
import 'package:exercise_log/screens/map_screen.dart';
import 'package:exercise_log/screens/nutrition_screen.dart';
import 'package:exercise_log/screens/calendar_memo.dart';
import 'package:exercise_log/screens/walk_screen.dart';
import 'package:exercise_log/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'google_login_screen.dart';
import 'chatlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    const CalendarMemo(),
    const NutApiPage(),
    const BmiScreen(
      title: 'BMI',
    ),
    const TakeoutScreen(),
    const ChatListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    _setToken();
  }

  Future<void> _setToken() async {
    var db = FirebaseFirestore.instance;
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var userRef = db.collection('user').doc(uid);
    userRef.get().then((value) async {
      if(!value.exists) {
        Fluttertoast.showToast(msg: '구글 로그인 완료를 위해 추가 정보 입력이 필요합니다.');
        if(context.mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const GoogleSignupScreen();
            },
          ));
        }
      }
      else {
        var fcmToken = await FirebaseMessaging.instance.getToken();
    
        FirebaseMessaging.instance.requestPermission(
          badge: true,
          alert: true,
          sound: true
        );
        db.collection('user').doc(uid).update({
          'token': fcmToken
        });
      }
    });
  }

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onMessage.listen((event) {
      log(event.data.toString());
      _messageDialog(event.data['id']);
    });

    var initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null) {
      _goChat(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_goChat);

  }

  void _goChat(RemoteMessage message) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ChatScreen(chatId: message.data['id'])
    ));
  }

  Future<dynamic> _messageDialog(String chatId) {
    return showDialog(context: context, 
    builder: (context) {
      return AlertDialog(
        title: const Text('알림'),
        content: 
            const Text('채팅 주문 요청이 왔습니다.'),
        actions: [
          TextButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: chatId)
            ));
          }, 
            child: const Text('주문 받기')
          ),
          TextButton(onPressed: () {
            Navigator.pop(context);
          },
            child: const Text('닫기')
          )
          
        ],
      );
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 1000),
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: '달력',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: '칼로리',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run),
              label: '만보기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: '포장주문',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.login),
              label: '채팅',
            ),
          ],
          currentIndex: _selectedIndex,
          showUnselectedLabels: true,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.greenAccent,
          onTap: _onItemTapped),
    );
  }
}
