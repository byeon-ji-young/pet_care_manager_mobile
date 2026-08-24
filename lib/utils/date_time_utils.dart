class DateTimeUtils {
  // 한국 표준시(KST, UTC+9)
  static DateTime nowKst() {
    return DateTime.now().toUtc().add(const Duration(hours: 9));
  }

  // 날짜만 비교하기 위한 KST 오늘 날짜
  static DateTime todayKst() {
    final now = nowKst();

    return DateTime(now.year, now.month, now.day);
  }
}
