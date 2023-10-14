enum MemoType {
  all("전부"),
  ateFood("음식"),
  walk("걷기"),
  exercise("운동");

  const MemoType(this.buttonValue);
  final String buttonValue;
}

MemoType memoTypeMapper(String value) {
  for (var i in MemoType.values) {
    if (i.name == value) {
      return i;
    }
  }
  return MemoType.exercise;
}
