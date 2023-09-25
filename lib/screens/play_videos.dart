import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gmail_clone/screens/play_video_widget.dart';
import 'package:video_player/video_player.dart';

class PlayVideos extends StatefulWidget {
  const PlayVideos({super.key});

  @override
  State<PlayVideos> createState() => _PlayVideosState();
}

Future<List<String>> getVideos() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('Error: User not signed in');
    return [];
  }

  final userRef =
      FirebaseFirestore.instance.collection('google_users').doc(user.uid);
  final doc = await userRef.get();

  if (doc.exists) {
    List<String> videos = List<String>.from(doc.data()?['videos'] ?? []);
    print(videos);
    return videos;
  } else {
    print('Error: User document does not exist');
    return [];
  }
}

class _PlayVideosState extends State<PlayVideos> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Videos'),
      ),
      body: FutureBuilder<List<String>>(
        future: getVideos(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(18)),
                  margin: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: PlayVideoWidget(videoUrl: snapshot.data![index]),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
