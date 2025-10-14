import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  Position? _currentPosition;
  String? _currentLocationName;
  bool _isLocationEnabled = false;

  Position? get currentPosition => _currentPosition;
  String? get currentLocationName => _currentLocationName;
  bool get isLocationEnabled => _isLocationEnabled;

  /// Initialize location service and check permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationEnabled = false;
        return false;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocationEnabled = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocationEnabled = false;
        return false;
      }

      _isLocationEnabled = true;
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      _isLocationEnabled = false;
      return false;
    }
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Always check service and permission status
      bool initialized = await initialize();
      if (!initialized) {
        print('Location initialization failed: services disabled or permission denied');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      await _updateLocationName(position);
      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Update location name based on coordinates using reverse geocoding
  Future<void> _updateLocationName(Position position) async {
    try {
      print('Starting geocoding for coordinates: ${position.latitude}, ${position.longitude}');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      print('Geocoding returned ${placemarks.length} placemarks');
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        print('Placemark data:');
        print('  locality: ${place.locality}');
        print('  subAdministrativeArea: ${place.subAdministrativeArea}');
        print('  administrativeArea: ${place.administrativeArea}');
        print('  country: ${place.country}');
        print('  name: ${place.name}');
        print('  thoroughfare: ${place.thoroughfare}');
        print('  subThoroughfare: ${place.subThoroughfare}');
        
        // Build location name from subAdministrativeArea only
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          _currentLocationName = place.subAdministrativeArea!;
          print('Final location name: $_currentLocationName');
        } else {
          _currentLocationName = 'Current Location';
          print('No subAdministrativeArea found, using default');
        }
      } else {
        _currentLocationName = 'Current Location';
        print('No placemarks found, using default');
      }
    } catch (e) {
      print('Error updating location name: $e');
      _currentLocationName = 'Current Location';
    }
  }

  /// Get formatted current location string
  String getCurrentLocationString() {
    if (_currentLocationName != null) {
      return _currentLocationName!;
    }
    return 'Current Location';
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Open app settings for location permission
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      print('Error opening location settings: $e');
      return false;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert to kilometers
  }
}