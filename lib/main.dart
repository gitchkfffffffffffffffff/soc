import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  JustAudioMediaKit.ensureInitialized(); // нужен для Windows
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Music Client',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepOrange,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ScApi();
  final player = AudioPlayer();
  final ctrl = TextEditingController();
  List<Track> tracks = [];
  Track? current;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    api.trending().then((r) {
      if (mounted) setState(() => tracks = r);
    }).catchError((_) {});
  }

  Future<void> search() async {
    if (ctrl.text.trim().isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      final r = await api.search(ctrl.text.trim());
      setState(() => tracks = r);
    } catch (e) {
      setState(() => error = 'Ошибка поиска: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> play(Track t) async {
    setState(() { current = t; error = null; });
    try {
      final url = await api.streamUrl(t.id);
      if (url == null) throw 'нет потока для этого трека';
      await player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      player.play();
    } catch (e) {
      setState(() => error = 'Ошибка воспроизведения: $e');
    }
  }

  @override
  void dispose() {
    player.dispose();
    ctrl.dispose();
    super.dispose();
  }

  String fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: ctrl,
          onSubmitted: (_) => search(),
          decoration: const InputDecoration(
            hintText: 'Поиск треков (Audius)',
            border: InputBorder.none,
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: search)],
      ),
      body: Column(children: [
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          Padding(padding: const EdgeInsets.all(8), child: Text(error!)),
        Expanded(
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (_, i) {
              final t = tracks[i];
              return ListTile(
                leading: t.artwork != null
                    ? Image.network(t.artwork!, width: 48, height: 48, fit: BoxFit.cover)
                    : const Icon(Icons.music_note),
                title: Text(t.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(t.artist, maxLines: 1),
                selected: current?.id == t.id,
                onTap: () => play(t),
              );
            },
          ),
        ),
        if (current != null) _miniPlayer(),
      ]),
    );
  }

  Widget _miniPlayer() => Material(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (_, snap) {
                final pos = snap.data ?? Duration.zero;
                final dur = player.duration ?? Duration(milliseconds: current!.durationMs);
                final max = dur.inMilliseconds.toDouble().clamp(1, double.infinity);
                return Row(children: [
                  Text(fmt(pos)),
                  Expanded(
                    child: Slider(
                      value: pos.inMilliseconds.toDouble().clamp(0, max),
                      max: max,
                      onChanged: (v) => player.seek(Duration(milliseconds: v.toInt())),
                    ),
                  ),
                  Text(fmt(dur)),
                ]);
              },
            ),
            Row(children: [
              Expanded(
                child: Text(current!.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (_, snap) {
                  final playing = snap.data?.playing ?? false;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                    onPressed: () => playing ? player.pause() : player.play(),
                  );
                },
              ),
            ]),
          ]),
        ),
      );
}
