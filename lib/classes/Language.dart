class Language {
  final int id;
  final String name;
  final String languageCode;

  Language(this.id, this.name, this.languageCode);
  static List<Language> languageList() {
    return <Language>[
      Language(1, 'English', 'en'),
      Language(2, 'Hindi', 'hi'),
      Language(3, 'Marathi', 'mr'),
      Language(4, 'Kannada', 'kn'),
      Language(5, 'Tamil', 'ta'),
      Language(6, 'Telugu', 'te'),
      Language(7, 'Gujrati', 'gu'),
      Language(8, 'Punjabi', 'pa'),
      Language(9, 'Malayalam', 'ml'),
      Language(10, 'Nepali', 'ne'),
      Language(11, 'Oriya', 'or'),
      Language(12, 'Urdu', 'ur'),
    ];
  }
}
