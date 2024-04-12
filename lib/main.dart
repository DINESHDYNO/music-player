import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_player/sample.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isMuted = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double playbackSpeed = 1.0;
  double volume = 1.0;
  List<String> musicUrls = [
    "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
    "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
    "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
  ];
  int currentMusicIndex = 0;

  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [
      if(duration.inHours > 0 ) hours,
      minutes, seconds
    ].join(':');
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    setAudio();
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        isLoading = false;
      });
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  Future<void> setAudio() async {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(UrlSource(musicUrls[currentMusicIndex]));
    audioPlayer.setPlaybackRate(playbackSpeed);
    await audioPlayer.setVolume(volume);
  }

  void setVolume(double value) {
    setState(() {
      volume = value;
    });
    audioPlayer.setVolume(volume);
  }
  Future<void> toggleMute() async {
    await audioPlayer.setVolume(isMuted ? 1.0 : 0.0);
    setState(() {
      isMuted = !isMuted;
    });
  }

  Future<void> playNext() async {
    if (currentMusicIndex < musicUrls.length - 1) {
      currentMusicIndex++;
    } else {
      currentMusicIndex = 0;
    }
    await setAudio();
  }

  Future<void> playPrevious() async {
    if (currentMusicIndex > 0) {
      currentMusicIndex--;
    } else {
      currentMusicIndex = musicUrls.length - 1;
    }
    await setAudio();
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Play Audio'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoApp()));
          }, icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: Image.network('https://media.istockphoto.com/id/1175435360/vector/music-note-icon-vector-illustration.jpg?s=612x612&w=0&k=20&c=R7s6RR849L57bv_c7jMIFRW4H87-FjLB8sqZ08mN0OU=')
            ),
            isLoading
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: CircularProgressIndicator(),
                )
                : Column(
           children: [
             Slider(
               min: 0,
               max: duration.inSeconds.toDouble(),
               value: position.inSeconds.toDouble(),
               onChanged: (value) async {
                 final position = Duration(seconds: value.toInt());
                 await audioPlayer.seek(position);
                 await audioPlayer.resume();
               },
             ),
             Padding(
                 padding: EdgeInsets.symmetric(horizontal: 20),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Text(formatTime(position)),
                     Text(formatTime(duration - position))
                   ],
                 )
             ),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 IconButton(
                   icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                   onPressed: toggleMute,
                 ),
                 CircleAvatar(
                   radius: 24,
                   child: IconButton(
                     onPressed: playPrevious,
                     icon: Icon(
                       Icons.skip_previous,
                     ),
                   ),
                 ),
                 CircleAvatar(
                   radius: 34,
                   child: IconButton(
                     onPressed: () async {
                       if(isPlaying){
                         await audioPlayer.pause();
                       } else {
                         await audioPlayer.resume();
                         setAudio();
                       }
                     },
                     icon: Icon(
                       isPlaying ? Icons.pause : Icons.play_arrow,size: 40,
                     ),
                   ),
                 ),
                 CircleAvatar(
                   radius: 24,
                   child: IconButton(
                     onPressed: playNext,
                     icon: Icon(
                         Icons.skip_next
                     ),
                   ),
                 ),
                 DropdownButton<String>(
                   value: playbackSpeed.toString(),
                   icon: const Icon(Icons.arrow_drop_down),
                   iconSize: 24,
                   elevation: 16,
                   style: const TextStyle(color: Colors.deepPurple),
                   underline: SizedBox(),
                   onChanged: (String? newValue) {
                     setState(() {
                       playbackSpeed = double.parse(newValue!);
                       audioPlayer.setPlaybackRate(playbackSpeed);
                     });
                   },
                   items: <String>['0.5', '1.0', '1.5', '2.0']
                       .map<DropdownMenuItem<String>>((String value) {
                     return DropdownMenuItem<String>(
                       value: value,
                       child: Text("${value}x"),
                     );
                   }).toList(),
                 ),
               ],
             ),
             SizedBox(height: 10,),
           ],
         )
       ]
      ),)
    );
  }
}
