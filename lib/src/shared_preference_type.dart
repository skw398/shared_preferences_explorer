enum SharedPreferencesType {
  legacy,
  asyncOrWithCache,
  ;

  String get label => switch (this) {
        SharedPreferencesType.legacy => 'Legacy',
        SharedPreferencesType.asyncOrWithCache => 'Async/WithCache',
      };
}
