import 'package:flutter/material.dart';

// Fixed HEX color codes to standard 8-digit alpha-hex formats (0xFF + 6 hex chars)
Color orage2 = const Color(0xFFDD9E60);
Color orange = const Color(0xFFCF5E49);
Color yellow = const Color(0xFFE3C783);
Color black = const Color(0xFF321C28);
Color white = const Color(0xFFF5F5F5);

// Supported file formats for GAX IDE File System
List<String> supportedDocumentExtensions = [
  ".pdf",
  ".doc",
  ".txt",
  ".ppt",
  ".docx",
  ".pptx",
  ".xlsx",
  ".xls",
];

List<String> supportedVideoExtensions = [
  ".mp4",
  ".mkv",
  ".avi",
  ".flv",
  ".wmv",
  ".mov",
  ".3gp",
  ".webm",
];

List<String> supportedImageExtensions = [
  ".jpg",
  ".jpeg",
  ".png",
  ".gif",
  ".bmp",
  ".webp",
];

List<String> supportedSoundExtensions = [
  ".mp3",
  ".wav",
  ".aac",
  ".ogg",
  ".wma",
  ".flac",
  ".m4a",
];
