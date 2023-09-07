import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmail_clone/Provider/provider_class.dart';

//state provider is used to store the state of the user only for single widget

// final userProvider = StateProvider<String?>((ref) => null);

final userProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  return UserNotifier(
    //default value
    const User(
      email: '',
      username: '',
      profilePic:
          'https://t4.ftcdn.net/jpg/00/97/00/09/360_F_97000908_wwH2goIihwrMoeV9QF3BW6HtpsVFaNVM.jpg',
      name: '',
      phoneNumber: '',
      createdAt: '',
      isAdmin: false,
      isSuperAdmin: false,
    ),
  );
});
