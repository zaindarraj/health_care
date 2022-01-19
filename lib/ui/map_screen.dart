import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:health_care_app/logic/notification%20/cubit/notification_cubit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    Key? key,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
  
  }
  @override
  Widget build(BuildContext context) {
      if (defaultTargetPlatform == TargetPlatform.android) {
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
}
    return Scaffold(body: BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationClicked) {
          return Center(
            child: GoogleMap(
              
              markers: {Marker( infoWindow: InfoWindow(
          title: state.mapData["FirstName"],
        ),markerId: MarkerId(state.mapData["ID"]),position: LatLng(double.parse(state.mapData["latitude"] as String),
                        double.parse(state.mapData["longitude"] as String)), icon: BitmapDescriptor.defaultMarker)},
              mapType: MapType.satellite,
                initialCameraPosition: CameraPosition(
                  zoom: 18,
                    target: LatLng(double.parse(state.mapData["latitude"] as String),
                        double.parse(state.mapData["longitude"] as String)))),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    ));
  }
}
