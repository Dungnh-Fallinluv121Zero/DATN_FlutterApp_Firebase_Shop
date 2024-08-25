class AddressModel {
  String? id;
  final String name;
  final String phone;
  final String address;

  AddressModel({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return AddressModel(
      id: id ?? map['id'],
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
