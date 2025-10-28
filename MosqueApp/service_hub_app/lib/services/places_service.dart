import 'dart:convert';
import 'dart:io';

class PlaceResult {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class PlacesService {
  final String apiKey;
  PlacesService({required this.apiKey});

  Future<List<PlaceResult>> getNearbyMosques({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    if (apiKey.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radiusMeters&type=mosque&keyword=mosque|masjid&key=$apiKey');
    final client = HttpClient();
    String respBody = '';
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != 200) {
        final errBody = await response.transform(utf8.decoder).join();
        throw Exception('Places API error: ${response.statusCode} $errBody');
      }
      respBody = await response.transform(utf8.decoder).join();
    } finally {
      client.close(force: true);
    }

    final data = jsonDecode(respBody) as Map<String, dynamic>;
    final List results = (data['results'] ?? []) as List;

    return results.map<PlaceResult>((raw) {
      final geometry = raw['geometry'] ?? {};
      final loc = geometry['location'] ?? {};
      final name = (raw['name'] ?? '').toString();
      final address = (raw['vicinity'] ?? raw['formatted_address'] ?? '').toString();
      final id = (raw['place_id'] ?? '').toString();
      final lat = (loc['lat'] is num) ? (loc['lat'] as num).toDouble() : 0.0;
      final lng = (loc['lng'] is num) ? (loc['lng'] as num).toDouble() : 0.0;

      return PlaceResult(
        id: id,
        name: name,
        address: address,
        latitude: lat,
        longitude: lng,
      );
    }).toList();
  }
}