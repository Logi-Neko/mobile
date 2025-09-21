// lib/core/logger.dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // hiện số dòng log
    errorMethodCount: 5,
    colors: true,   // màu sắc
    printEmojis: true,
  ),
);
