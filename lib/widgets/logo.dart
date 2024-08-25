import 'package:flutter/material.dart';

class LoGo extends StatelessWidget {
  const LoGo({super.key});

  @override
  Widget build(BuildContext context) {
    var widthScreen = MediaQuery.of(context).size.width;
    const textLogo = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          "BEST",
          style: TextStyle(
              color: Colors.orange, fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text(
          "LOOK",
          style: TextStyle(
              color: Color.fromRGBO(34, 52, 98, 1),
              fontSize: 40,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 60.0)
      ],
    );
    return SizedBox(
      width: widthScreen,
      child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            textLogo,
          ]),
    );
  }
}
