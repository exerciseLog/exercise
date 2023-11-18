import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_log/model/place_model.dart';
import 'package:exercise_log/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:url_launcher/url_launcher.dart';

class PositionProvider with ChangeNotifier {
  static String apiKey = "AIzaSyDmOFlGdyiX02ZHhgVgxkaARUJhoGDoSNs";
  final List<Marker> _markers = <Marker> [];
  List<LatLng> polylineList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<PolylineId, Polyline> _polylines = {};
  String _textDistance = "시작 버튼을 눌러 거리를 측정하세요!";
  double _totalDistance = 0;
  bool onWalking = false;
  late LatLng lastPosition;
  late LatLng currentPosition;
  
  String get textDistance => _textDistance;
  double get totalDistance => _totalDistance;
  List<Marker> get markers => _markers;
  Map<PolylineId, Polyline> get polylines => _polylines;

  showMarker(Completer<GoogleMapController> mapController, BuildContext context) async {
    final GoogleMapController controller = await mapController.future;
    double lat = 0.0;
    double lng = 0.0;
    _getUserLocation().then((value) async {
      lat = value.latitude;
      lng = value.longitude;
      currentPosition = LatLng(lat, lng);
      var cameraPosition = CameraPosition(
        target: LatLng(lat,lng), zoom: 15
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      
      var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=1000&type=restaurant&language=ko&key=$apiKey" ;
      var response = await get(Uri.parse(url));
      var body = jsonDecode(response.body);
      var results = body['results'];
           
      for(var i = 0; i < results.length; i++) {
        var geo = results[i]['geometry']['location'];
        var name = results[i]['name'];
        var placeId = results[i]['place_id'];
        var vic = results[i]['vicinity'];
        var latlng = LatLng(geo['lat'], geo['lng']);

        _markers.add(
          Marker(
            markerId: MarkerId("id $i"),
            position: latlng,
            infoWindow: InfoWindow(
              title: name,
              snippet: vic,
              onTap: () {
                _placeDetailDialog(placeId, context);
              } 
            ),
          )
        );
      }
      notifyListeners();
    });
  }

  blindMarker(bool isDispose) {
    _markers.clear(); 
    if(!isDispose) notifyListeners();
  }

  Future<void> _launchUrl(String number) async {
    var url = Uri.parse("tel:$number");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  _placeDetailDialog(String placeId, BuildContext context) async {
    var url = "https://maps.googleapis.com/maps/api/place/details/json?language=ko&place_id=$placeId&key=$apiKey";
    
    get(Uri.parse(url)).then((value) {
      var body = jsonDecode(value.body);
      var detail = PlaceModel.detailfromJson(body);
      var rating = detail.rating == 'null' ? '정보 없음' : detail.rating;
      
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("음식점 상세 정보"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Text(detail.name, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20) 
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(detail.openNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Visibility(
                        visible: detail.openDetail == "null" ? false : true,
                        child: Tooltip(
                          message: detail.openDetail,
                          child: const Icon(
                            Icons.info, size: 20,
                          ),
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text("전화번호: ${detail.number}"),
                  Text("구글 평점: $rating"),
                  Text("포장 가능 여부: ${detail.delivery}"),
                  
                ],
              )
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if(detail.number == '정보 없음') {
                    Fluttertoast.showToast(msg: '음식점에서 전화번호를 제공하지 않습니다.');
                  } else {
                    _launchUrl(detail.number);
                  }
                },
                child: const Text("전화 연결")
              ),
              /* TextButton(
                onPressed: () async {
                  var user = FirebaseAuth.instance.currentUser;
                  var uid = user!.uid;
                  var db = FirebaseFirestore.instance;
                  final userData = await db
                    .collection('user')
                    .doc(uid)
                    .get();
                  var userName = userData.data()!['userName'];
                  var userImage = userData['picked_image'];
                  var opName = detail.name;
                  db.collection('newchat').where("member", arrayContains: userName).get().then(
                    (values) {
                      if(values.size != 0) {
                        return showModal(
                          context: context,
                          configuration: const FadeScaleTransitionConfiguration(
                            transitionDuration: Duration(milliseconds: 300),
                            reverseTransitionDuration: Duration(milliseconds: 150)),
                          builder: (dlgContext) {
                            return AlertDialog(
                              title: const Text('안내'),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: const [
                                    Text('완료되지 않은 채팅 주문 내역이 있습니다. 새 주문 요청을 하시겠습니까?'),
                                  ]
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    for(var value in values.docs) {
                                      dev.log('${value.id} => ${value.data()}');
                                      db.collection('newchat').doc(value.id).delete();
                                    }
                                    var chatId = userName + ' : ' + DateTime.now().toString();
                                    _createChat(db, chatId, uid, userName, userImage, opName, context);
                                    _sendFCM(db, chatId, opName);
                                  },
                                  child: const Text('예')
                                ),
                                TextButton(
                                  onPressed: () {
                                    Fluttertoast.showToast(msg: '채팅 주문을 취소하였습니다.');
                                    Navigator.pop(dlgContext);
                                  },
                                  child: const Text('아니오')
                                )
                              ],
                            );
                          }
                        );
                      }
                      else {
                        var chatId = userName + ' : ' + DateTime.now().toString();
                        _createChat(db, chatId, uid, userName, userImage, opName, context);
                        _sendFCM(db, chatId, opName);
                      }
                    }
                  );

                  
                },
                child: const Text("채팅으로 연결")
              ), */
              TextButton(
                onPressed: () async {
                  var user = FirebaseAuth.instance.currentUser;
                  var uid = user!.uid;
                  var db = FirebaseFirestore.instance;
                  final userData = await db
                    .collection('user')
                    .doc(uid)
                    .get();
                  var userName = userData.data()!['userName'];
                  var userImage = userData['picked_image'];
                  var opName = detail.name;

                  if(userName == opName) {
                    Fluttertoast.showToast(msg: '잘못된 접근입니다.');
                    return;
                  }

                  db.collection('newchat').doc(opName).get()
                  .then((value) {
                    if(value.exists){
                      if(value['member'].toString().contains(userName)) {
                        Fluttertoast.showToast(msg: '이미 참여하고 있는 채팅방입니다.');
                      }
                      else {
                        db.collection('newchat').doc(opName).update({
                          'member': FieldValue.arrayUnion([userName])
                        }).then((value) => Navigator.push(
                          context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: opName))
                        ));

                      }
                    }
                    else {
                      _createChat(db, opName, uid, userName, userImage, opName, context);
                    }
                  });
                                                  
                },
                child: const Text('음식점 채팅방 입장')
              )
            ],
          );
        }
      );
    });
  }

  _createChat(FirebaseFirestore db, String chatId, String uid, dynamic userName, dynamic userImage,
   String opName, BuildContext context) {
    
      db.collection('newchat').doc(chatId).set({
        'member': [userName, opName]
      });    
      db.collection('newchat').doc(chatId)
      .collection('chat').doc().set({
        'text': "첫 채팅입니다!",
        'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'userID': uid,
        'userName': userName,
        'userImage': userImage
      }).then((value) => Navigator.push(context, 
        MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId))
      ));
  }

  void _sendFCM(FirebaseFirestore db, String chatId, String opName) {
    db.collection('user').where("userName", isEqualTo: opName).get()
    .then((values) {
      var fcmToken = 'none';
      for(var value in values.docs) {
        var data = value.data();
        fcmToken = data['token'];
        dev.log(fcmToken);
        _postMessage(db, fcmToken, chatId);
      }
      // if(fcmToken != 'none') _postMessage(fcmToken, chatId);
    });
  }

  Future<String?> _postMessage(FirebaseFirestore db, String fcmToken, String chatId) async {
    try {
      final ref = await db.collection('token').doc('oauth').get();
      String accessToken = ref.data()!['a'];
      final response = await post(
        Uri.parse("https://fcm.googleapis.com/v1/projects/exerlog-dy/messages:send"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          "message": {
            "token": fcmToken,
            "notification": {
              "title": "Exerciselog",
              "body" : "주문 요청이 왔습니다."
            },
            "data": {
              "id": chatId
            },
          },

        }),

      );
      if(response.statusCode == 200) {
        dev.log('res.code = 200');
        return null;
      } else {
        dev.log('res failed');
        dev.log(response.toString());
        return "Fail";
      }
    }
    on HttpException catch(error) {
      dev.log(error.message);
      return error.message;
    }
  }
  
  positionInit(Completer<GoogleMapController> mapController) {
    _getUserLocation().then((value) async {
      currentPosition = LatLng(value.latitude, value.longitude);
      polylineList.add(currentPosition);
      Future.delayed(const Duration(seconds: 1), () {
        checkWalking(mapController);
      });
    });
    notifyListeners();
  }

  checkWalking(Completer<GoogleMapController> mapController) async {
    if(!onWalking) return;
    
    final GoogleMapController controller = await mapController.future;
    _getUserLocation().then((value) async {
      _getDirection(value);
      
      var cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude), zoom: 18
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 5), () {
      checkWalking(mapController);
    });
  }
  
  resetWalking(bool isDispose) {
    onWalking = false;
    polylineList.clear();
    _textDistance = "시작 버튼을 눌러 거리를 측정하세요!";
    if(!isDispose) notifyListeners();
  }

  Future<Position> _getUserLocation() async {
    await Geolocator.requestPermission().then((value)
    {}).onError((error, stackTrace) async { 
      await Geolocator.requestPermission();
      dev.log(error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  _getDirection(Position position) async {
    lastPosition = currentPosition;
    currentPosition = LatLng(position.latitude, position.longitude);
    polylineList.add(currentPosition);
    
    _totalDistance = 0;
    for(var i = 0; i < polylineList.length-1; i++){
      _totalDistance += _calculateDistance(
        polylineList[i].latitude, 
        polylineList[i].longitude, 
        polylineList[i+1].latitude, 
        polylineList[i+1].longitude);
    }

    _totalDistance = double.parse(_totalDistance.toStringAsFixed(2));
    _textDistance = "거리: ${_totalDistance}km";
    //add to the list of poly line coordinates
    _addPolyLine(polylineList);
    notifyListeners();
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
  }

  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}