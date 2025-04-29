import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_model.dart';
import 'storage_service.dart';

class ChatServices extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;

  final _storageService = StorageService();

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String currentUserName = _firebaseAuth.currentUser!.displayName ?? '';
    final userDoc =
        await _fireStore.collection("users").doc(currentUserId).get();
    if (userDoc.exists && userDoc.data()!.containsKey('nom')) {
      currentUserName =
          "${userDoc.data()!['nom']} ${userDoc.data()!['prenom']}";
    }

    final DateTime dateTime = DateTime.now();

    MessagesModel newMessage = MessagesModel(
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      messageText: message,
      createdAt: dateTime,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    final chatRoomDoc =
        await _fireStore.collection("chat_rooms").doc(chatRoomId).get();

    if (!chatRoomDoc.exists) {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).set({
        'participants': ids,
        'createdAt': Timestamp.fromDate(dateTime),
        'lastActivity': Timestamp.fromDate(dateTime),
        'participantRoles': {
          currentUserId: await _getUserRole(currentUserId),
          receiverId: await _getUserRole(receiverId),
        },
      });
    } else {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
        'lastActivity': Timestamp.fromDate(dateTime),
      });
    }

    final messageRef = await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add({
          ...newMessage.toMap(),
          'readBy': [currentUserId],
        });

    await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
      'lastMessage': {
        'text': message,
        'senderId': currentUserId,
        'timestamp': Timestamp.fromDate(dateTime),
      },
    });
  }

  Future<void> sendImageMessage(String receiverId, File imageFile) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String currentUserName = _firebaseAuth.currentUser!.displayName ?? '';
    final userDoc =
        await _fireStore.collection("users").doc(currentUserId).get();
    if (userDoc.exists && userDoc.data()!.containsKey('nom')) {
      currentUserName =
          "${userDoc.data()!['nom']} ${userDoc.data()!['prenom']}";
    }
    final DateTime dateTime = DateTime.now();

    final String fileName = const Uuid().v4();

    final String? imageUrl = await _storageService.uploadFile(
      imageFile,
      'chat_images',
    );

    if (imageUrl == null) {
      debugPrint('Échec du téléchargement de l\'image sur Cloudinary');
      return;
    }

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    final chatRoomDoc =
        await _fireStore.collection("chat_rooms").doc(chatRoomId).get();

    if (!chatRoomDoc.exists) {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).set({
        'participants': ids,
        'createdAt': Timestamp.fromDate(dateTime),
        'lastActivity': Timestamp.fromDate(dateTime),
        'participantRoles': {
          currentUserId: await _getUserRole(currentUserId),
          receiverId: await _getUserRole(receiverId),
        },
      });
    } else {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
        'lastActivity': Timestamp.fromDate(dateTime),
      });
    }

    await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add({
          'senderId': currentUserId,
          'senderName': currentUserName,
          'receiverId': receiverId,
          'messageText': '📷 Image',
          'imageUrl': imageUrl,
          'messageType': 'image',
          'createdAt': Timestamp.fromDate(dateTime),
          'readBy': [currentUserId],
        });

    await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
      'lastMessage': {
        'text': '📷 Image',
        'senderId': currentUserId,
        'timestamp': Timestamp.fromDate(dateTime),
      },
    });
  }

  Future<void> sendOptimizedImageMessage(
    String receiverId,
    File imageFile, {
    int width = 800,
    int height = 600,
  }) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String currentUserName = _firebaseAuth.currentUser!.displayName ?? '';
    final userDoc =
        await _fireStore.collection("users").doc(currentUserId).get();
    if (userDoc.exists && userDoc.data()!.containsKey('nom')) {
      currentUserName =
          "${userDoc.data()!['nom']} ${userDoc.data()!['prenom']}";
    }
    final DateTime dateTime = DateTime.now();

    final String? originalImageUrl = await _storageService.uploadFile(
      imageFile,
      'chat_images',
    );

    if (originalImageUrl == null) {
      debugPrint('Échec du téléchargement de l\'image sur Cloudinary');
      return;
    }

    final String optimizedImageUrl = _storageService.getOptimizedImageUrl(
      originalImageUrl,
      width: width,
      height: height,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    final chatRoomDoc =
        await _fireStore.collection("chat_rooms").doc(chatRoomId).get();

    if (!chatRoomDoc.exists) {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).set({
        'participants': ids,
        'createdAt': Timestamp.fromDate(dateTime),
        'lastActivity': Timestamp.fromDate(dateTime),
        'participantRoles': {
          currentUserId: await _getUserRole(currentUserId),
          receiverId: await _getUserRole(receiverId),
        },
      });
    } else {
      await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
        'lastActivity': Timestamp.fromDate(dateTime),
      });
    }

    await _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add({
          'senderId': currentUserId,
          'senderName': currentUserName,
          'receiverId': receiverId,
          'messageText': '📷 Image',
          'imageUrl': optimizedImageUrl,
          'originalImageUrl': originalImageUrl,
          'messageType': 'image',
          'createdAt': Timestamp.fromDate(dateTime),
          'readBy': [currentUserId],
        });

    await _fireStore.collection("chat_rooms").doc(chatRoomId).update({
      'lastMessage': {
        'text': '📷 Image',
        'senderId': currentUserId,
        'timestamp': Timestamp.fromDate(dateTime),
      },
    });
  }

  Stream<QuerySnapshot> getMessage(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> markMessageAsRead(String messageId, String chatRoomId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    final messageRef = _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (messageDoc.exists) {
      final messageData = messageDoc.data()!;
      List<String> readBy = List<String>.from(messageData['readBy'] ?? []);

      if (!readBy.contains(currentUserId)) {
        readBy.add(currentUserId);
        await messageRef.update({'readBy': readBy});
      }
    }
  }

  Future<void> addReaction(
    String messageId,
    String receiverId,
    String emoji,
  ) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    final messageRef = _fireStore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .doc(messageId);

    final messageDoc = await messageRef.get();
    if (messageDoc.exists) {
      final messageData = messageDoc.data()!;
      List<dynamic> reactions = List<dynamic>.from(
        messageData['reactions'] ?? [],
      );

      final existingReactionIndex = reactions.indexWhere(
        (reaction) =>
            reaction['userId'] == currentUserId && reaction['emoji'] == emoji,
      );

      if (existingReactionIndex != -1) {
        reactions.removeAt(existingReactionIndex);
      } else {
        reactions.add({
          'userId': currentUserId,
          'emoji': emoji,
          'timestamp': Timestamp.fromDate(DateTime.now()),
        });
      }

      await messageRef.update({'reactions': reactions});
    }
  }

  Future<void> setTypingStatus(String receiverId, bool isTyping) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    await _fireStore.collection("users_status").doc(currentUserId).set({
      'isTyping': isTyping,
      'typingTo': isTyping ? receiverId : null,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getUserTypingStatus(String userId) {
    return _fireStore.collection("users_status").doc(userId).snapshots();
  }

  Stream<DocumentSnapshot> getUserOnlineStatus(String userId) {
    return _fireStore.collection("users_status").doc(userId).snapshots();
  }

  Future<void> setUserOnlineStatus(bool isOnline) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    await _fireStore.collection("users_status").doc(currentUserId).set({
      'isOnline': isOnline,
      'lastSeen': isOnline ? null : Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  Future<String> _getUserRole(String userId) async {
    final userDoc = await _fireStore.collection("users").doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null && userData['role'] != null) {
        return userData['role'];
      }
    }

    return 'locataire';
  }

  Future<File?> pickImage(ImageSource source) async {
    return await _storageService.pickImage(source);
  }
}
