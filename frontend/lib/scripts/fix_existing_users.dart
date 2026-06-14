// One-time migration: backfill isArchived=false on any user doc that lacks it.
// Run with: flutter run -t lib/scripts/fix_existing_users.dart
// Safe to run multiple times — only docs missing the field are touched.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _runMigration();
}

Future<void> _runMigration() async {
  final db = FirebaseFirestore.instance;
  final snap = await db.collection('users').get();

  // 1. Backfill isArchived=false if missing
  final docsToFix = snap.docs
      .where((doc) => !doc.data().containsKey('isArchived'))
      .toList();

  if (docsToFix.isNotEmpty) {
    final batch = db.batch();
    for (final doc in docsToFix) {
      batch.update(doc.reference, {'isArchived': false});
    }
    await batch.commit();
    debugPrint('Migration: backfilled isArchived on ${docsToFix.length} docs.');
  }

  // 2. Security migration: move sensitive fields to users_private
  int migratedUsers = 0;
  final batch = db.batch();
  for (final doc in snap.docs) {
    final data = doc.data();
    final privateData = <String, dynamic>{};
    final publicUpdates = <String, dynamic>{};

    if (data.containsKey('pinCode')) {
      privateData['pinCode'] = data['pinCode'];
      publicUpdates['pinCode'] = FieldValue.delete();
    }
    if (data.containsKey('email')) {
      privateData['email'] = data['email'];
      publicUpdates['email'] = FieldValue.delete();
    }
    if (data.containsKey('phoneNumber')) {
      privateData['phoneNumber'] = data['phoneNumber'];
      publicUpdates['phoneNumber'] = FieldValue.delete();
    }
    if (data.containsKey('address')) {
      privateData['address'] = data['address'];
      publicUpdates['address'] = FieldValue.delete();
    }

    if (privateData.isNotEmpty) {
      final privateDocRef = db.collection('users_private').doc(doc.id);
      batch.set(privateDocRef, privateData, SetOptions(merge: true));
      batch.update(doc.reference, publicUpdates);
      migratedUsers++;
    }
  }

  if (migratedUsers > 0) {
    await batch.commit();
    debugPrint('Migration: successfully migrated $migratedUsers users to users_private.');
  } else {
    debugPrint('Migration: no users needed private data migration.');
  }
}
