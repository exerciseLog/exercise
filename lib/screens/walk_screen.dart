import 'dart:async';
import 'package:exercise_log/provider/bmi_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


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
    _resetStepsAtMidnight();
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
    double y = _lastEvent?.y ?? 0.0;
    if ((_previousY < 0 && y > 0) || (_previousY > 0 && y < 0)) {
      setState(() {
        _steps++;
      });
    }
    _previousY = y;
  }

  void _resetStepsAtMidnight() {
    Timer.periodic(const Duration(days: 1), (timer) {
      DateTime now = DateTime.now();
      if (now.hour == 0 && now.minute == 0 && now.second == 0) {
        setState(() {
          _steps = 0;
        });
      }
    });
  }

  void _loadSteps() async {
    final List<Map<String, dynamic>> data = await _database.query(
      'steps',
      orderBy: 'id DESC',
      limit: 1,
    );
    if (data.isNotEmpty) {
      final int steps = data[0]['steps'];
      setState(() {
        _steps = steps;
      });
    }
  }

  void _saveSteps() async {
    await _database.transaction((txn) async {
      await txn.insert(
        'steps',
        {'steps': _steps, 'timestamp': DateTime.now().toIso8601String()},
      );
    });
  }

  double _calculateBMI() {
    // BMI 지수 계산
    if (_height > 0.0) {
      double heightInMeters = _height / 100;
      return _weight / (heightInMeters * heightInMeters);
    } else {
      return 0.0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription?.cancel();
    // _saveSteps();
    _database.close();
  }

  @override
  Widget build(BuildContext context) {
    var bmiProvider = Provider.of<BmiProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title), // 상단 앱바에 제목 표시
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
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
                      bmiProvider.setHeight(value);
                      setState(() {
                        _height = double.tryParse(value) ?? 0.0;
                      });
                    },
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    '걸음 수:', // 걸음 수 텍스트
                  ),
                  Text(
                    '$_steps', // 현재 걸음 수
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'BMI 지수:', // BMI 지수 텍스트
                  ),
                  Text(
                    _calculateBMI()
                        .toStringAsFixed(2), // BMI 지수 계산 결과 표시 (소수점 둘째 자리까지)
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
