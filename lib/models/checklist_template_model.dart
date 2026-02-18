class ChecklistTemplate {
  int? id;
  String? userId;
  String? name;
  String? description;
  String? category;
  String? createTime;
  int? itemCount;
  List<TemplateItem>? itemList;

  ChecklistTemplate({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.category,
    this.createTime,
    this.itemCount,
    this.itemList,
  });

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplate(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      createTime: json['createTime'],
      itemCount: json['itemCount'] ?? 0,
      itemList: json['itemList'] != null
          ? (json['itemList'] as List)
              .map((i) => TemplateItem.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category,
      'createTime': createTime,
      'itemCount': itemCount,
      'itemList': itemList?.map((i) => i.toJson()).toList(),
    };
  }
}

class TemplateItem {
  int? id;
  int? templateId;
  int? itemId;
  int? quantity;
  String? category;
  String? itemName;
  String? userId;
  String? img;

  TemplateItem({
    this.id,
    this.templateId,
    this.itemId,
    this.quantity,
    this.category,
    this.itemName,
    this.userId,
    this.img,
  });

  factory TemplateItem.fromJson(Map<String, dynamic> json) {
    return TemplateItem(
      id: json['id'],
      templateId: json['templateId'],
      itemId: json['itemId'],
      quantity: json['quantity'],
      category: json['category'],
      itemName: json['itemName'],
      userId: json['userId'],
      img: json['img'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'itemId': itemId,
      'quantity': quantity,
      'category': category,
      'itemName': itemName,
      'userId': userId,
      'img': img,
    };
  }

  @override
  String toString() {
    return "TemplateItem(id: $id, templateId: $templateId, itemId: $itemId, quantity: $quantity, category: $category, itemName: $itemName, userId: $userId, img: $img)";
  }
}
