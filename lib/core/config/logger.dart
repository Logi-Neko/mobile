// lib/core/logger.dart
import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.all, // Show all log levels: trace, debug, info, warning, error, fatal
  printer: PrettyPrinter(
    methodCount: 2, // Show stack trace (2 methods)
    errorMethodCount: 8, // Show more lines for errors
    lineLength: 120, // Wider lines
    colors: true,   // Enable colors
    printEmojis: true, // Enable emojis
    printTime: true, // Show timestamps
  ),
);
