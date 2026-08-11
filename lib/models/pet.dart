class Pet {
  final int? id; // ?는 값이 없을 수도 있다는 뜻. (새로 등록하는 순간에는 아직 DB가 번호를 만들어주지 않았으니까 ? 작성함)
  final String name;
  final DateTime? birthDate;
  final String? gender;
  final String? breed;
  final double? weight; // 몸무게는 소수점이 필요하니까 double

  Pet({
    this.id,
    required this.name,
    this.birthDate,
    this.gender,
    this.breed,
    this.weight,
  });
}