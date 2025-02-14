class CategoryModel {
  final String image;
  final String name;
  final int id;

  CategoryModel({required this.image, required this.name, required this.id});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      image: json['icon'],
      name: json['service_name'],
      id: json['id'],
    );
  }
}

List<CategoryModel> myCategories = [
  CategoryModel(
    image: 'assets/cases/تنظيف.png',
    name: 'تنظيف', id: 1,
  ),
  CategoryModel(
    image: 'assets/cases/حشو.png',
    name: 'حشو', id: 2,
  ),
  CategoryModel(
    image: 'assets/cases/سحب عصب.png',
    name: 'سحب عصب', id: 3,
  ),
  CategoryModel(
    image: 'assets/cases/تراكيب.png',
    name: 'تراكيب', id: 4,
  ),
  CategoryModel(
    image: 'assets/cases/طقم اسنان.png',
    name: 'طقم اسنان', id: 5,
  ),
  CategoryModel(
    image: 'assets/cases/تلميع.png',
    name: 'تلميع', id: 6,
  ),
  CategoryModel(
    image: 'assets/cases/تبييض.png',
    name: 'تبييض', id: 7,
  ),
  CategoryModel(
    image: 'assets/cases/خلع.png',
    name: 'خلع', id: 8,
  ),
  CategoryModel(
    image: 'assets/cases/زراعة.png',
    name: 'زراعة', id: 9,
  ),
  CategoryModel(
    image: 'assets/cases/جسور.png',
    name: 'جسور', id: 10,
  ),
  CategoryModel(
    image: 'assets/cases/فيشرسيلنت.png',
    name: 'فيشرسيلنت', id: 11,
  ),
  CategoryModel(
    image: 'assets/cases/طقم اسنان.png',
    name: 'تقويم أسنان', id: 12,
  ),
  CategoryModel(
    image: 'assets/cases/طقم اسنان.png',
    name: 'فلوريد', id: 13,
  ),
  CategoryModel(
    image: 'assets/cases/معاينة.png',
    name: 'معاينة', id: 14,
  ),
];

