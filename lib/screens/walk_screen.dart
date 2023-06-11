import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _BmiScreenState createState() =>
      _BmiScreenState(); // MyHomePage 상태를 관리하는 _MyHomePageState 클래스 생성
}

class _BmiScreenState extends State<BmiScreen> {
  AccelerometerEvent? _lastEvent;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  int _steps = 0;
  double _previousY = 0.0;
  double _weight = 0.0; // 체중 변수 추가
  double _height = 0.0; // 신장 변수 추가
  late Database _database;

  @override
  void initState() {
    super.initState();
    _openDatabase().then((database) {
      _database = database;
      _loadSteps();
    });
    _listenToSensor();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSteps();
    }
  }

  Future<Database> _openDatabase() async {
    final String path = await getDatabasesPath();
    final String databasePath = join(path, 'step_data.db');

    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS steps(id INTEGER PRIMARY KEY AUTOINCREMENT, steps INTEGER, timestamp TEXT)',
        );
      },
    );
  }

  void _listenToSensor() {
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
          setState(() {
            _lastEvent = event;
            _calculateSteps();
          });
        });
  }

  void _calculateSteps() {
    //걸음수 계산
    double y = _lastEvent?.y ?? 0.0;
    if ((_previousY < 0 && y > 0) || (_previousY > 0 && y < 0)) {
      if (y.abs() > 1.0) {
        setState(() {
          _steps++;
        });
      }
    }
    _previousY = y;
  }


  void _loadSteps() async {
    final List<Map<String, dynamic>> data = await _database.query(
      'steps',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (data.isNotEmpty) {
      final int steps = data[0]['steps'];
      final String timestamp = data[0]['timestamp'];
      final DateTime dbDate = DateTime.parse(timestamp).toLocal();
      final DateTime currentDate = DateTime.now();

      if (dbDate.year != currentDate.year ||
          dbDate.month != currentDate.month ||
          dbDate.day != currentDate.day) {
        await _database.delete('steps');
        setState(() {
          _steps = 0;
        });
        return;
      }

      setState(() {
        _steps = steps;
      });
    }
  }

  void _saveSteps() async {
    //걸음수 와 현재 시각 저장
    await _database.transaction((txn) async {
      await txn.insert(
        'steps',
        {'steps': _steps, 'timestamp': DateTime.now().toIso8601String()},
      );
    });
  }

  String _calculateBMI() {
    // BMI 지수 계산  18.5~23사이는 정상 23~25과체중 25이상 비만 18.5 저체중
    if (_height > 0.0) {
      double heightInMeters = _height / 100;
      double bmi = _weight / (heightInMeters * heightInMeters);

      if (bmi < 18.5) {
        return '저체중';
      } else if (bmi >= 18.5 && bmi < 23.0) {
        return '정상';
      } else if (bmi >= 23.0 && bmi < 25.0) {
        return '과체중';
      } else {
        return '비만';
      }
    } else {
      return '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
    _saveSteps();
    _database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // 상단 앱바에 제목 표시
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '체중 (kg):', // 체중 입력 텍스트
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _weight = double.tryParse(value) ?? 0.0;
                      });
                    },
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    '신장 (cm):', // 신장 입력 텍스트
                  ),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _height = double.tryParse(value) ?? 0.0;
                      });
                    },
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '걸음 수:', // 걸음 수 저장 버튼
                  ),
                  Text(
                    '$_steps', // 현재 걸음 수
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveSteps();
                    },
                    child: Text('걸음 수 저장'), // 걸음 수 저장 버튼
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'BMI 지수:', // BMI 지수 텍스트
                  ),
                  Text(
                    _calculateBMI(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
