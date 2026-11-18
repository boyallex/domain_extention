class CharacterStageProfile {
  const CharacterStageProfile({
    required this.id,
    required this.name,
    required this.enabled,
    this.figureAsset,
    this.backdropAsset,
  });

  final String id;
  final String name;
  final bool enabled;
  final String? figureAsset;
  final String? backdropAsset;

  bool get hasStageArt =>
      figureAsset != null &&
      figureAsset!.isNotEmpty &&
      backdropAsset != null &&
      backdropAsset!.isNotEmpty;
}
