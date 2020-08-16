import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

const String hquestionsBoxName = "questions";
const String hpreferencesBoxName = "preferences";

const String hdrivingLicenceType = "driving_licence_type";
const String hquestionAutoNextDuration = "question_auto_next_duration";

class HiveDB  {
  Future<void> connect() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    await Future.wait([
      Hive.openBox(hpreferencesBoxName),
    ]);
  }

  Box getPreferencesBox() {
    return Hive.box(hpreferencesBoxName);
  }

  Future close() {
    return Hive.close();
  }
}
