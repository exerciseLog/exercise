import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math';
import 'dart:developer' as dev;


class PositionProvider with ChangeNotifier {
  final List<Marker> _markers = <Marker> [];
  List<LatLng> polylineList = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final Map<PolylineId, Polyline> _polylines = {};
  String _textDistance = "시작 버튼을 눌러 거리를 측정하세요!";
  bool onWalking = false;
  late LatLng lastPosition;
  late LatLng currentPosition;

  String get textDistance => _textDistance;
  List<Marker> get markers => _markers;
  Map<PolylineId, Polyline> get polylines => _polylines;
  
  positionInit() {
    _getUserLocation().then((value) async {
      currentPosition = LatLng(value.latitude, value.longitude);
      polylineList.add(currentPosition);
    });
    notifyListeners();
  }

  checkWalking(Completer<GoogleMapController> mapcontroller) async {
    if(!onWalking) return;

    final GoogleMapController controller = await mapcontroller.future;
    _getUserLocation().then((value) async {
      _getDirection(value);
      _markers.add(
        Marker(
          markerId: const MarkerId("value"),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(title: '현재 위치')
        )
      );
      var cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude), zoom: 18
      );
      
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 5), () {
      checkWalking(mapcontroller);
    });
  }
  
  resetWalking() {
    onWalking = false;
    polylineList.clear();
     _textDistance = "시작 버튼을 눌러 거리를 측정하세요!";
    notifyListeners();
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
    
    double totalDistance = 0;
    for(var i = 0; i < polylineList.length-1; i++){
      totalDistance += _calculateDistance(
        polylineList[i].latitude, 
        polylineList[i].longitude, 
        polylineList[i+1].latitude, 
        polylineList[i+1].longitude);
    }

    totalDistance = double.parse(totalDistance.toStringAsFixed(2));
    _textDistance = "거리: ${totalDistance}km";
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