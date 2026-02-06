extension StringExtension on String {
  // 定义一个 capitalize 方法
  String toTitleCase() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
