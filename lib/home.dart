import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmail_clone/Provider/user_provider.dart';
import 'package:gmail_clone/screens/profile_screen.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis/youtube/v3.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  //To change the values stored in the provider, we need to use the notifier
  void submitDataToRiverPod(WidgetRef ref) {
    /////////////////////////////
    //1 way to update the value single values
    // ref.read(userProvider.notifier).update((state) => value);

    //2 way to update the complete calss values
    ref.read(userProvider.notifier).updateUser(
          email: user!['email'],
          username: user!['username'],
          profilePic: user!['profile_pic'],
          name: user!['name'],
          phoneNumber: user!['phoneNumber'],
          createdAt: user!['created_at'],
          isAdmin: user!['is_admin'],
          isSuperAdmin: user!['is_super_admin'],
        );
  }

  late Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    getDataFromFireStore();
  }

  getFutureDataFromFirestore() async {
    //to get the current user from firebase auth
    final userFromFireStore = FirebaseAuth.instance.currentUser;

    //to get the data stores in the firestore for this user
    return await FirebaseFirestore.instance
        .collection('google_users')
        .doc(userFromFireStore!.uid)
        .get();
  }

  getDataFromFireStore() async {
    final userData = await getFutureDataFromFirestore();

    user = userData.data();
    submitDataToRiverPod(ref);
    return userData;
  }

  //
  Future<void> fetchMail() async {
    print('gmail fetch Start');
    final httpClient = AuthService().getHttpClient();
    final accessToken = AuthService().getAccessToken();
    var gmailApi = GmailApi(httpClient);
    var messages = await gmailApi.users.messages.list('me');

    print(messages);
    var messageIds = messages.messages!.map((e) => e.id).toList();
    print('gmail fetch end');
    print(messageIds);
  }

  void fetchYoutube() async {
    print('mail fetch init');
    final httpClient = AuthService().getHttpClient();
    print("httpClient in fetch mail $httpClient");
    var youTubeApi = YouTubeApi(httpClient);
    var favorites = await youTubeApi.playlistItems.list(
      ['snippet'],
      playlistId: 'LL', // Liked List
    );
    var favoriteVideos = favorites.items!.map((e) => e.snippet!.title).toList();
    print('youtube fetch end');
    print(favoriteVideos);
  }
  //

  @override
  Widget build(BuildContext context) {
    //To read the values stored in the provider, we need to use the ref.watch
    //1 simple way to read the value single values
    // final name = ref.watch(userProvider) ?? 'username';

    final user = ref.watch(userProvider);

    return FutureBuilder(
      future: getDataFromFireStore(),
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Theme.of(context)
                .colorScheme
                .background, // navigation bar color
          ),
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.only(right: 7, bottom: 7),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black12, // Border color
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    user.profilePic ?? "waiting for data",
                    fit: BoxFit.cover,
                    height: 56.0, // Set the height of the AppBar
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SizedBox(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome ${user.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ),
                  child: const Text('Profile'),
                ),
                ElevatedButton(
                  onPressed: () => fetchMail(),
                  child: const Text('Fetch Mails'),
                ),
                ElevatedButton(
                  onPressed: () => fetchYoutube(),
                  child: const Text('Fetch youtube'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
