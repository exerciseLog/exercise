import 'dart:async';
import 'package:exercise_log/provider/position_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class TakeoutScreen extends StatefulWidget {
  const TakeoutScreen({super.key});

  @override
  State<TakeoutScreen> createState() => _TakeoutScreenState();
}

class _TakeoutScreenState extends State<TakeoutScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<PositionProvider>(context, listen: false).positionInit();
    });
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
                initialCameraPosition: const CameraPosition(target: LatLng(37.5000326, 126.8680013), zoom: 14),
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
                position.checkWalking(_controller);
                
              }
            },
            child: const Text("시작")
          ),
          ElevatedButton(
            onPressed: () {
              position.resetWalking();
            },
            child: const Text("종료")
          ),
          Text(position.textDistance)
        ],
      ), 
    );
  }
}




