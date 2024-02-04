// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class CreateMemeBloc {
  final memeTextsSubject = BehaviorSubject<List<MemeText>>.seeded(<MemeText>[]);
  final selectedMemeTextsSubject = BehaviorSubject<MemeText?>.seeded(null);

  void addNewText() {
    final newMemeText = MemeText.create();
    memeTextsSubject.add([...memeTextsSubject.value, newMemeText]);
    selectedMemeTextsSubject.add(newMemeText);
    //memeTextsSubject.add(memeTextsSubject.value..add(MemeText.create()));
  }

  void changeMemeText(final String id, final String text) {
    final copyListMemeTexts = [...memeTextsSubject.value];
    final index = copyListMemeTexts.indexWhere((element) => element.id == id);
    if (index < 0) {
      return;
    }

    copyListMemeTexts.removeAt(index);
    copyListMemeTexts.insert(index, MemeText(id: id, text: text));
    memeTextsSubject.add(copyListMemeTexts);
  }

  void selectMemeText(final String id) {
    final foundMemeText =
        memeTextsSubject.value.firstWhereOrNull((element) => element.id == id);
    selectedMemeTextsSubject.add(foundMemeText);
  }

  void deselectMemeText() {
    selectedMemeTextsSubject.add(null);
  }

  Stream<List<MemeText>> observeMemeTexts() =>
      memeTextsSubject.distinct((previous, next) => listEquals(previous, next));

  Stream<MemeText?> observeSelectedMemeText() =>
      selectedMemeTextsSubject.distinct();

  Stream<List<MemeTextWithSelection>> observeMemeTextWithSelection() {
    return Rx.combineLatest2<List<MemeText>, MemeText?,
            List<MemeTextWithSelection>>(
        observeMemeTexts(), observeSelectedMemeText(),
        (memeTexts, selectedMemeText) {
      return memeTexts.map((memeText) {
        return MemeTextWithSelection(
            memeText: memeText, selected: memeText.id == selectedMemeText?.id);
      }).toList();
    });
  }

  void dispose() {
    memeTextsSubject.close();
    selectedMemeTextsSubject.close();
  }
}

class MemeTextWithSelection {
  final MemeText memeText;
  final bool selected;
  const MemeTextWithSelection({
    required this.memeText,
    required this.selected,
  });

  @override
  bool operator ==(covariant MemeTextWithSelection other) {
    if (identical(this, other)) return true;

    return other.memeText == memeText && other.selected == selected;
  }

  @override
  int get hashCode => memeText.hashCode ^ selected.hashCode;

  @override
  String toString() =>
      'MemeTextWithSelection(memeText: $memeText, selected: $selected)';
}

class MemeText {
  final String id;
  final String text;

  MemeText({required this.id, required this.text});

  factory MemeText.create() {
    return MemeText(id: const Uuid().v4(), text: '');
  }

  @override
  bool operator ==(covariant MemeText other) {
    if (identical(this, other)) return true;

    return other.id == id && other.text == text;
  }

  @override
  int get hashCode => id.hashCode ^ text.hashCode;

  @override
  String toString() => 'MemeText(id: $id, text: $text)';
}
