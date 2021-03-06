import 'package:flutter/material.dart';

class Question extends StatelessWidget {
  final String questionText;

  Question(this.questionText);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      /** 
       * margin: <require EdgeInsetsGeometry_Obj>
       * EdgeInsets extend EdgeInsetsGeometry (🗸)
       * Dart allows define multiple constructors with dot notation technique
       * <> In Java, using different signature to create constructor variants
       * */
      margin: EdgeInsets.all(10),
      child: Text(
        /**
         * main.dart: Stateful_MyApp(build(Quiz(Question(questionText))))
         */
        questionText, ///=> Stateless_Question re-render when it received external data here!
        style: TextStyle(fontSize: 28),
        textAlign: TextAlign.center,
      ),
    );
  }
}
