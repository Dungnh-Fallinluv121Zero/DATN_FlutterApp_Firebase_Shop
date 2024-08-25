import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationCustom extends StatelessWidget {
  final bool showBottomAppBar;

  final Function()? onHomePressed;
  final Function()? onProfilePressed;

  const BottomNavigationCustom({
    Key? key,
    required this.showBottomAppBar,
    this.onHomePressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutSine,
      height: showBottomAppBar ? 55 : 0,
      child: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: onHomePressed,
              icon: const Icon(
                Icons.home_outlined,
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            IconButton(
              onPressed: onProfilePressed,
              icon: const Icon(
                CupertinoIcons.person,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
