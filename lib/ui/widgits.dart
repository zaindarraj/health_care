
import 'package:flutter/material.dart';

BoxDecoration boxDecoration(Color color) {
  return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: 50,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(20));
}