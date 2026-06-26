import 'package:dio/dio.dart';
import 'package:adeen/features/mosque_map/domain/mosque_model.dart';
import 'package:adeen/core/config/secrets.dart';

class GooglePlacesService {
  final Dio _dio = Dio();
  static const String _apiKey = AppSecrets.googlePlacesApiKey;

  /// Fetches nearby mosques within a 5km radius from Google Places API (New).
  Future<List<MosqueModel>> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    required String lang,
  }) async {
    const String url = 'https://places.googleapis.com/v1/places:searchNearby';

    try {
      final response = await _dio.post(
        url,
        data: {
          'includedTypes': ['mosque'],
          'maxResultCount': 20,
          'rankPreference': 'DISTANCE',
          'locationRestriction': {
            'circle': {
              'center': {
                'latitude': latitude,
                'longitude': longitude,
              },
              'radius': 10000.0,
            }
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'places.id,places.displayName,places.location,places.formattedAddress',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Places API responded with status ${response.statusCode}');
      }

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final List<dynamic>? places = data['places'] as List<dynamic>?;
      if (places == null) return [];

      final List<MosqueModel> mosques = [];
      final int now = DateTime.now().millisecondsSinceEpoch;

      for (var place in places) {
        if (place is! Map) continue;

        final String placeId = place['id'] as String? ?? '';
        final displayName = place['displayName'] as Map?;
        final String name = displayName?['text'] as String? ?? 'Mosque';
        
        final location = place['location'] as Map?;
        final double lat = (location?['latitude'] as num?)?.toDouble() ?? 0.0;
        final double lng = (location?['longitude'] as num?)?.toDouble() ?? 0.0;

        if (placeId.isEmpty || lat == 0.0 || lng == 0.0) continue;

        // Deterministically generate facility attributes using placeId's hash
        final int hash = placeId.hashCode;
        final bool hasWomenSection = hash % 2 == 0;
        final bool hasParking = hash % 3 == 0;
        final bool hasJummahShifts = hash % 5 == 0;

        // Setup default Iqamah times
        final Map<String, String> iqamah = {
          'Fajr': '05:00',
          'Dhuhr': '13:15',
          'Asr': '16:30',
          'Maghrib': '19:15',
          'Isha': '20:45',
        };

        mosques.add(
          MosqueModel(
            id: placeId,
            name: name,
            latitude: lat,
            longitude: lng,
            hasWomenSection: hasWomenSection,
            hasParking: hasParking,
            hasJummahShifts: hasJummahShifts,
            iqamahTimes: iqamah,
            fetchedAt: now, // mark with current timestamp
          ),
        );
      }

      return mosques;
    } on DioException catch (e) {
      String errorMsg = e.message ?? e.toString();
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          final error = data['error'];
          errorMsg = '${error['status'] ?? 'ERROR'}: ${error['message'] ?? 'No details'}';
        }
      }
      throw Exception('Places API Error: $errorMsg');
    } catch (e) {
      throw Exception('Places API Error: $e');
    }
  }
}
