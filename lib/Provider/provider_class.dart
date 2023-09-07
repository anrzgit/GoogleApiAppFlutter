import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final String? email;
  final String? username;
  final String? profilePic;
  final String? name;
  final String? phoneNumber;
  final String? createdAt;
  final bool? isAdmin;
  final bool? isSuperAdmin;

  const User({
    this.email,
    this.username,
    this.profilePic,
    this.name,
    this.phoneNumber,
    this.createdAt,
    this.isAdmin,
    this.isSuperAdmin,
  });
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier(super.state);
  void updateUser(
      {required String email,
      String? username,
      required String profilePic,
      required String name,
      String? phoneNumber,
      required String createdAt,
      required bool isAdmin,
      required bool isSuperAdmin}) {
    state = User(
      email: email,
      username: username,
      profilePic: profilePic,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: createdAt,
      isAdmin: isAdmin,
      isSuperAdmin: isSuperAdmin,
    );
  }
}
