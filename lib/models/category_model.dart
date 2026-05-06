import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconCode;
  final int colorValue;
  final String userId;
  final int position;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.userId,
    this.position = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      iconCode: map['iconCode'] ?? '58713',
      colorValue: map['colorValue'] ?? 0xFFFFC107,
      userId: map['userId'] ?? '',
      position: map['position'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'userId': userId,
      'position': position,
    };
  }

  IconData get icon => IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}
