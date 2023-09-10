import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:exercise_log/provider/position_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import '../provider/calendar_provider.dart';
import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

class TakeoutScreen extends StatefulWidget {
  const TakeoutScreen({super.key});

  @override
  State<TakeoutScreen> createState() => _TakeoutScreenState();
}

class _TakeoutScreenState extends State<TakeoutScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  late PositionProvider _positionProvider;
  
  @override
  void initState() {
    super.initState();
    _positionProvider = Provider.of<PositionProvider>(context, listen: false);
  }  

  void test() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/123');
    ref.onChildAdded.listen((event) {
      var key = event.snapshot.key;
      var value = event.snapshot.value;
      log(key!);
      log(value.toString());
    });

    ref.onChildRemoved.listen((event) {
      
    });

    /* await ref.set({
      "name": "John",
      "age": 18,
      "address": {
        "line1": "100 Mountain View"
      }
    }); */
  }

  @override
  Widget build(BuildContext context) {
    var position = Provider.of<PositionProvider>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: SafeArea(
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: LatLng(37.5000326, 126.8680013), zoom: 16),
                myLocationEnabled: true,
                compassEnabled: true,
                markers: Set<Marker>.of(position.markers),
                polylines: Set<Polyline>.of(position.polylines.values),
                onMapCreated: (GoogleMapController controller) => _controller.complete(controller)
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if(!position.onWalking) {
                position.onWalking = true;
                position.positionInit(_controller);
                
              }
            },
            child: const Text("시작")
          ),
          ElevatedButton(
            onPressed: () async {
              var distance = position.totalDistance;
              if(distance == 0.0) {
                return ElegantNotification.error(
                  title: const Text("오류"),
                  description: const Text("운동 거리가 측정되지 않았습니다."))
                .show(context);
              }
              position.resetWalking(false);
              return showModal(
                context: context,
                configuration: const FadeScaleTransitionConfiguration(
                  transitionDuration: Duration(milliseconds: 300),
                  reverseTransitionDuration: Duration(milliseconds: 150)
                ),
                builder: ((context) {
                  return AlertDialog(
                    title: const Text("알림"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: const [
                         Text("오늘 운동 내용을 메모로 남기시겠습니까?"),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          var date = DateTime.utc(DateTime.now().year, DateTime.now().month, 
                          DateTime.now().day, 00, 00);
                          var value = "오늘 운동한 거리: $distance km";
                          context.read<CalendarProvider>().addMemo(date, value);
                          Navigator.pop(context);
                          ElegantNotification.success(
                              title: const Text("성공"),
                              description: const Text("캘린더에 운동 내역을 등록했습니다."))
                          .show(context);
                        }, 
                        child: const Text("확인")
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("취소")
                      )
                    ],
                  );
                }),
                
              );
            },
            child: const Text("종료")
          ),
          const SizedBox(height: 15),
          Text(position.textDistance),
          const SizedBox(height: 100),
          /* TextButton(
            onPressed: () {
              test();
            },
            child: const Text("forTest")
          ) */
        ],
      ), 
    );
  }

  @override
  void dispose() {
    _positionProvider.resetWalking(true);
    super.dispose();
  }
}




