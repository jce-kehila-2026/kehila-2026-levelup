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

  final docsToFix = snap.docs
      .where((doc) => !doc.data().containsKey('isArchived'))
      .toList();

  if (docsToFix.isEmpty) {
    debugPrint('Migration: all ${snap.docs.length} documents already have isArchived. Nothing to do.');
    return;
  }

  // Firestore batches are limited to 500 ops each.
  const batchSize = 500;
  int updated = 0;

  for (int i = 0; i < docsToFix.length; i += batchSize) {
    final chunk = docsToFix.skip(i).take(batchSize).toList();
    final batch = db.batch();
    for (final doc in chunk) {
      batch.update(doc.reference, {'isArchived': false});
    }
    await batch.commit();
    updated += chunk.length;
    debugPrint('Migration: committed batch — $updated / ${docsToFix.length} updated so far.');
  }

  debugPrint('Migration complete: $updated document(s) updated out of ${snap.docs.length} total.');
}
