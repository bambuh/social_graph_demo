extension IntDuration on int {
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
  Duration get weeks => Duration(days: this * 7);
  Duration get months => Duration(days: this * 30);
  Duration get years => Duration(days: this * 365);
}

extension DoubleDuration on double {
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get seconds => Duration(milliseconds: (this * 1000).toInt());
  Duration get minutes => Duration(milliseconds: (this * 1000 * 60).toInt());
  Duration get hours => Duration(milliseconds: (this * 1000 * 60 * 60).toInt());
  Duration get days =>
      Duration(milliseconds: (this * 1000 * 60 * 60 * 24).toInt());
  Duration get weeks =>
      Duration(milliseconds: (this * 1000 * 60 * 60 * 24 * 7).toInt());
  Duration get months =>
      Duration(milliseconds: (this * 1000 * 60 * 60 * 24 * 30).toInt());
  Duration get years =>
      Duration(milliseconds: (this * 1000 * 60 * 60 * 24 * 365).toInt());
}
