/// A placeholder class that represents an entity or model.
class CategoryOption {
  const CategoryOption(
      this.id, this.title, this.description, this.categorieType);

  final int id;

  final String title;

  final String description;

  final CategoryOptionType categorieType;
}

enum CategoryOptionType {
  recipe,
  studyPlan,
}
