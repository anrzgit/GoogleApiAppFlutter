import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmail_clone/home.dart';
import 'package:gmail_clone/screens/mails_screen.dart';
import 'package:gmail_clone/screens/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<NavigationScreen> {
  List<Widget> homeScreenItems = [
    const Home(),
    const MailScreen(),
    const ProfileScreen()
  ];

  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        border: Border.all(
            color: Colors.transparent, style: BorderStyle.solid, width: 0),
        currentIndex: _page,
        activeColor: Theme.of(context).colorScheme.primary,
        inactiveColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.background,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.mail_outline,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
