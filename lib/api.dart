import 'dart:convert';
import 'package:dio/dio.dart';

const clientId = String.fromEnvironment('SC_CLIENT_ID');
const clientSecret = String.fromEnvironment('SC_CLIENT_SECRET');

class Track {
  final int id;
  final String title;
  final String artist;
  final String? artwork;
  final int durationMs;
  Track(this.id, this.title, this.artist, this.artwork, this.durationMs);

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        j['id'] as int,
        (j['title'] ?? '') as String,
        ((j['user'] ?? {})['username'] ?? '') as String,
        j['artwork_url'] as String?,
        (j['duration'] ?? 0) as int,
      );
}

/// Официальный SoundCloud API (client_credentials).
/// Ключи берутся на https://soundcloud.com/you/apps
class ScApi {
  final _dio = Dio();
  String? token;
  DateTime _exp = DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, String> get authHeaders => {'Authorization': 'OAuth $token'};

  Future<void> _auth() async {
    if (token != null && DateTime.now().isBefore(_exp)) return;
    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final r = await _dio.post(
      'https://secure.soundcloud.com/oauth/token',
      data: {'grant_type': 'client_credentials'},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Basic $basic',
          'accept': 'application/json; charset=utf-8',
        },
      ),
    );
    token = r.data['access_token'] as String;
    final sec = (r.data['expires_in'] ?? 3600) as int;
    _exp = DateTime.now().add(Duration(seconds: sec - 60));
  }

  Future<List<Track>> search(String q) async {
    await _auth();
    final r = await _dio.get(
      'https://api.soundcloud.com/tracks',
      queryParameters: {'q': q, 'limit': 30, 'access': 'playable'},
      options: Options(headers: authHeaders),
    );
    return (r.data as List)
        .map((e) => Track.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String?> streamUrl(int trackId) async {
    await _auth();
    final r = await _dio.get(
      'https://api.soundcloud.com/tracks/$trackId/streams',
      options: Options(headers: authHeaders),
    );
    final d = r.data as Map<String, dynamic>;
    return (d['http_mp3_128_url'] ?? d['hls_mp3_128_url']) as String?;
  }
}
