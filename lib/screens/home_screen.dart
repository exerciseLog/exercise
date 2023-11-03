import 'package:exercise_log/screens/map_screen.dart';
import 'package:exercise_log/screens/nutrition_screen.dart';
import 'package:exercise_log/screens/calendar_memo.dart';
import 'package:exercise_log/screens/walk_screen.dart';
import 'package:exercise_log/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

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
    const ChatScreen(chatId: 'fromHome'),
  ];

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
