import 'dart:io';
void main() {
  var lines = File('lib/data/levels.dart').readAsLinesSync();
  var start = lines.indexWhere((l) => l.contains('id: 15,'));
  if (start != -1) {
    var blockStart = start - 2;
    var end = lines.indexWhere((l) => l.contains('),'), start);
    print(lines.sublist(blockStart, end + 2).join('\n'));
  }
}
