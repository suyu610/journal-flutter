class ItemLibrary {
  int? id;
  String? userId;
  String? name;
  String? icon; // 对应图标标识
  String? category;
  String? createTime;
  String? img;

  ItemLibrary({
    this.id,
    this.userId,
    this.name,
    this.icon,
    this.category,
    this.createTime,
    this.img,
  });

  ItemLibrary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    name = json['name'];
    icon = json['icon'];
    category = json['category'];
    createTime = json['createTime'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userId'] = userId;
    data['name'] = name;
    data['icon'] = icon;
    data['category'] = category;
    data['createTime'] = createTime;
    data['img'] = img;
    return data;
  }

  // toString
  @override
  String toString() {
    return 'ItemLibrary{id: $id, userId: $userId, name: $name, icon: $icon, category: $category, createTime: $createTime, img: $img}';
  }
}
