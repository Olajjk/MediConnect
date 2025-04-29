import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal() {
    _initCloudinary();
  }

  late CloudinaryPublic _cloudinary;

  // Initialisation de Cloudinary
  void _initCloudinary() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || uploadPreset == null) {
      throw Exception(
        'Les variables CLOUDINARY_CLOUD_NAME et CLOUDINARY_UPLOAD_PRESET doivent être définies dans le fichier .env',
      );
    }

    _cloudinary = CloudinaryPublic(cloudName, uploadPreset);
    debugPrint('Cloudinary initialisé avec succès: $cloudName');
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Erreur lors de la sélection de l\'image: $e');
      return null;
    }
  }

  Future<String?> uploadFile(File file, String folder) async {
    try {
      final String fileExtension = path.extension(file.path).toLowerCase();

      if (![
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.pdf',
      ].contains(fileExtension)) {
        throw Exception(
          'Format de fichier non supporté. Utilisez JPG, PNG ou GIF ou PDF',
        );
      }

      final CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: folder,
          //resourceType: fileExtension == ".pdf" ? CloudinaryResourceType.Raw : CloudinaryResourceType.Image,
          resourceType: CloudinaryResourceType.Auto,
        ),
      );
      print("response code : ${response.toString()}");
      debugPrint('Image ou Pdf téléchargée avec succès: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Erreur lors du téléchargement de l\'image ou du pdf: $e');
      return null;
    }
  }

  String getOptimizedImageUrl(
    String originalUrl, {
    int width = 400,
    int height = 400,
  }) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;

    // Si c'est un PDF, ne pas transformer
    if (originalUrl.endsWith('.pdf')) return originalUrl;

    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/c_fill,g_face,h_${height},w_${width},q_auto,f_auto/',
    );
  }

  String getProfileImageUrl(String originalUrl, {int size = 200}) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl;
    }

    return originalUrl.replaceFirst(
      '/upload/',
      '/upload/c_fill,g_face,h_${size},w_${size},r_max,q_auto,f_auto/',
    );
  }

  Future<void> downloadFile(String url, String savePath) async {
    try {
      final http.Response response = await http.get(Uri.parse(url));
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }
}
