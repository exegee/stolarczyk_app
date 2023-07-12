class Client {
  String? id;
  String code;
  String street;
  String city;
  String postal;
  String country;
  String? description;

  Client({
    required this.code,
    required this.street,
    required this.city,
    required this.postal,
    required this.country,
  });
}
