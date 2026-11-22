import 'package:dio/dio.dart';

const _base = 'https://api.audius.co/v1';
const _appName = 'sc_client';

class Track {
  final String id;
  final String title;
  final String artist;
  final String? artwork;
  final int durationMs;
  Track(this.id, this.title, this.artist, this.artwork, this.durationMs);

  factory Track.fromJson(Map<String, dynamic> j) {
    final art = j['artwork'] as Map<String, dynamic>?;
    return Track(
      j['id'] as String,
      (j['title'] ?? '') as String,
      ((j['user'] ?? {})['name'] ?? '') as String,
      (art?['480x480'] ?? art?['150x150']) as String?,
      ((j['duration'] ?? 0) as num).toInt() * 1000,
    );
  }
}

/// Публичный API Audius (чтение без ключа).
class ScApi {
  final _dio = Dio();

  Future<List<Track>> search(String q) async {
    final r = await _dio.get(
      '$_base/tracks/search',
      queryParameters: {'query': q, 'app_name': _appName, 'limit': 30},
    );
    final list = (r.data['data'] as List?) ?? [];
    return list.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Track>> trending() async {
    final r = await _dio.get(
      '$_base/tracks/trending',
      queryParameters: {'app_name': _appName, 'limit': 30},
    );
    final list = (r.data['data'] as List?) ?? [];
    return list.map((e) => Track.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String?> streamUrl(String trackId) async {
    final url = '$_base/tracks/$trackId/stream';
    try {
      final r = await _dio.get(
        url,
        queryParameters: {'app_name': _appName, 'no_redirect': 'true'},
      );
      final d = r.data;
      if (d is Map && d['data'] is String) return d['data'] as String;
    } catch (_) {}
    // запасной вариант: сам эндпоинт отдаёт редирект на файл
    return '$url?app_name=$_appName';
  }
}
