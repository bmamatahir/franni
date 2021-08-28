import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:franni/qa_model.dart';

import 'enums.dart';

class AnswerViewModel extends ChangeNotifier {
  int currentQuestionId;
  List<QuestionAnswers> answersList = List<QuestionAnswers>();
  Function endCallback;
  DrivingLicenceType drivingLicenceType;
  int autoNextSec;

  StreamController<int> _countDown = StreamController.broadcast();

  Stream<int> get countDown => _countDown.stream;

  Timer timer;

  AnswerViewModel({this.drivingLicenceType, this.autoNextSec = 15});

  _startTimer() {
    _countDown.sink.add(autoNextSec);
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      int currentSec = autoNextSec - t.tick;
      _countDown.sink.add(currentSec);
      if (currentSec == -1) {
        _endTimer();
        next();
      }
    });
  }

  _endTimer() {
    _countDown.sink.add(null);
    timer?.cancel();
    timer = null;
  }

  start() {
    currentQuestionId = 1;
    answersList.add(QuestionAnswers(currentQuestionId));
  }

  next() {
    if (currentQuestionId == drivingLicenceType.questionNumbers) {
      if (endCallback != null) endCallback();
      return;
    }

    currentQuestionId++;
    answersList.add(QuestionAnswers(currentQuestionId));
    _endTimer();

    notifyListeners();
  }

  previous() {
    if (currentQuestionId == 1) {
      return;
    }
    currentQuestionId--;
    notifyListeners();
  }

  reset() {
    currentQuestionId = 1;
    answersList = List<QuestionAnswers>();
    notifyListeners();
  }

  bool selected(answerId) {
    QuestionAnswers qa = getCurrentQA();
    if (qa == null) return false;
    return qa.answerChecked(answerId);
  }

  setAnswer(answerId) {
    QuestionAnswers qa = getCurrentQA();
    if (!qa.dirty) {
      _startTimer();
    }
    qa.toggleAnswer(answerId);
    notifyListeners();
  }

  QuestionAnswers getCurrentQA() {
    return getQA(this.currentQuestionId);
  }

  QuestionAnswers getQA(qId) {
    List<QuestionAnswers> p = answersList.where((e) => e.qId == qId).toList();
    return p.length > 0 ? p.first : null;
  }

  bool confirmedAnswersForCurrentQA() {
    return getCurrentQA().confirmed;
  }

  bool confirmedAnswer(qId) {
    QuestionAnswers qa = getQA(qId);
    if (qa == null || qa.isEmpty()) return false;
    return qa.confirmed;
  }

  void toggleAnswerConfirmation() {
    getQA(currentQuestionId).confirmed = !getQA(currentQuestionId).confirmed;
    notifyListeners();
  }
}
