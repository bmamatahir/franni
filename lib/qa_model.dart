class QuestionAnswers {
  final int qId;
  List<int> answers;
  bool confirmed;
  bool dirty = false;

  addAnswer(int value) {
    if (!answers.contains(value)) answers.add(value);
    dirty = true;
  }

  removeAnswer(int value) {
    answers.remove(value);
  }

  answerChecked(int value) {
    return answers.contains(value);
  }

  toggleAnswer(int value) {
    if (answerChecked(value)) {
      removeAnswer(value);
    } else
      addAnswer(value);
  }

  bool isEmpty() {
    return answers.length == 0;
  }

  String printAnswers() {
    return this.answers.join(", ");
  }

  QuestionAnswers(this.qId)
      : answers = [],
        confirmed = false;
}
