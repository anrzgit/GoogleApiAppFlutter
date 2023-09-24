import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gmail_clone/Provider/user_provider.dart';
import 'package:gmail_clone/service/auth_service.dart';
import 'package:gmail_clone/widget/user_image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ///
  ///
  File? _pickedImage;
  bool _isUploading = false;

  ///
  void _signOut() async {
    await AuthService().signOut();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have been logged out'),
      ),
    );
  }

  pickImageFromGallery() async {
    final pickedImage = await PickImageWidget().pickImage();
    setState(() {
      _pickedImage = pickedImage;
    });
    print("222222222");
    print(_pickedImage);
  }

  uplodCoverImage() async {
    setState(() {
      _isUploading = true;
    });
    await PickImageWidget().uploadImageToFireSrore(_pickedImage!);
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image Uploaded'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 335,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    margin: const EdgeInsets.all(12),
                    height: 200,
                    width: double.infinity,
                    child: _pickedImage == null
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Image.network(
                              user.coverPic!,
                              alignment: Alignment.bottomLeft,
                              fit: BoxFit.fill,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                            child: Image.file(
                              _pickedImage!,
                              alignment: Alignment.bottomLeft,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: IconButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          onPressed: () => pickImageFromGallery(),
                          icon: const Icon(Icons.edit)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(user.profilePic!),
                          fit: BoxFit.fill,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              user.name!,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              user.email!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (user.isSuperAdmin!.toString() == 'false')
              const Text('you are not admin'),
            if (user.isSuperAdmin!.toString() == 'true')
              const Text('you are admin'),
            const Spacer(
              flex: 3,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.error,
                ),
              ),
              onPressed: () => _signOut(),
              child: Text(
                'Logout',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              onPressed: () => uplodCoverImage(),
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Upload Image',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    ),
            ),
            const Spacer(),
          ],
        ),
      ),
      // Consumer(builder: (context, watch, child) {
    );
  }
}
