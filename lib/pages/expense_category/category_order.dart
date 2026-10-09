List<Map<String, dynamic>> orderCategoryItems(
  List<Map<String, dynamic>> defaults,
  List<Map<String, dynamic>> customs,
  List<String>? savedOrder,
) {
  final newestFirst = List<Map<String, dynamic>>.from(customs)
    ..sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
  final items = <Map<String, dynamic>>[...newestFirst, ...defaults];
  if (savedOrder == null || savedOrder.isEmpty) return items;

  final originalPositions = {
    for (var index = 0; index < items.length; index++) items[index]: index,
  };
  items.sort((a, b) {
    final indexA = savedOrder.indexOf(a['labelName'].toString());
    final indexB = savedOrder.indexOf(b['labelName'].toString());
    if (indexA == -1 && indexB != -1) return -1;
    if (indexB == -1 && indexA != -1) return 1;
    if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
    return originalPositions[a]!.compareTo(originalPositions[b]!);
  });
  return items;
}
