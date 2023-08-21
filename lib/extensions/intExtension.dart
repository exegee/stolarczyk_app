extension PluralExtension on int {
  // 0 komentarzy
  // 1 komentarz
  // 2,3,4 komentarze
  // 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21 komentarzy
  // 22,23,24 komentarze
  // 25,26,27,28,29,30,31 komentarzy
  // 32,33,34 komentarze
  String commentPlural() {
    String word = 'Komentarzy';
    // If value is 0 then return default plural
    if (this == 0) {
      return word;
    }
    // If value equals 1 then return unique plural
    if (this == 1) {
      word = 'Komentarz';
      return word;
    }
    // If value is greater then 0 and different than 1 calculate remainder
    // and return matching plural word
    final valueReminder = remainder(10);

    if (valueReminder >= 2 && valueReminder <= 4) {
      word = 'Komentarze';
    } else {
      word = 'Komentarzy';
    }
    return word;
  }

  // 0 zadań
  // 1 zadanie
  // 2,3,4 zadania
  // 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21 zadań
  // 22,23,24 zadania
  // 25,26,27,28,29,30,31 zadań
  // 32,33,34 zadania
  String taskPlural() {
    String word = 'Zadań';
    // If value is 0 then return default plural
    if (this == 0) {
      return word;
    }
    // If value equals 1 then return unique plural
    if (this == 1) {
      word = 'Zadanie';
      return word;
    }
    // If value is greater then 0 and different than 1 calculate remainder
    // and return matching plural word
    final valueReminder = remainder(10);

    if (valueReminder >= 2 && valueReminder <= 4) {
      word = 'Zadania';
    } else {
      word = 'Zadań';
    }
    return word;
  }
}
