part of 'location_service_bloc.dart';

abstract class LocationServiceState extends Equatable {
  const LocationServiceState();

  @override
  List<Object> get props => [];
}

class LocationServiceInitial extends LocationServiceState {}

class ServiceThrottled extends LocationServiceState {}




class Awaiting extends LocationServiceState{}

// ignore: must_be_immutable
class ServiceOn extends LocationServiceState {
  DatabaseHelper databaseHelper = DatabaseHelper();

  dynamic getLocation() async {
    Location location = Location();
    GeoCode geoCode = GeoCode();
    try {
      List<Map<String, Object?>> list = await databaseHelper.queryLocation();
      if (list.isNotEmpty) {
        return list.last["city"];
      } else {
        location.changeSettings(accuracy: LocationAccuracy.high);
        LocationData locationData = await location.getLocation();
        Address address = await geoCode.reverseGeocoding(
            latitude: locationData.latitude as double,
            longitude: locationData.longitude as double);
        print(address);
        await databaseHelper.insert("Location", {"city": address.city,"latitude": locationData.latitude.toString(),"longitude": locationData.longitude.toString()});
        
        List<Map<String, Object?>> list = await databaseHelper.queryLocation();
        print(list);
        return list.last["city"];
      }
    } catch (e) {
      return "error";
    }
  }
}

class ServiceOffUser extends LocationServiceState {}

class ServiceOff extends LocationServiceState {}
