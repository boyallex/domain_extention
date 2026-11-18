import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';

/// Набор спрайтов для одной эмоции: голова + рот + рука поверх тела.
class CharacterSpritePose {
  const CharacterSpritePose({
    required this.headAsset,
    required this.mouthAsset,
    required this.handAsset,
  });

  final String headAsset;
  final String mouthAsset;
  final String handAsset;
}

/// Атлас вырезанных частей из 2D animation sheet.
class CharacterSpriteAtlas {
  const CharacterSpriteAtlas({
    required this.bodyAsset,
    required this.poses,
  });

  final String bodyAsset;
  final Map<CharacterEmotion, CharacterSpritePose> poses;

  CharacterSpritePose poseFor(CharacterEmotion emotion) =>
      poses[emotion] ?? poses[CharacterEmotion.idle]!;
}

/// Sukuna: тело + 3 эмоции (лицо / губы / рука) из Meshy sheet.
const sukunaSpriteAtlas = CharacterSpriteAtlas(
  bodyAsset: 'assets/characters/sukuna/stage/atlas/body.png',
  poses: {
    CharacterEmotion.idle: CharacterSpritePose(
      headAsset: 'assets/characters/sukuna/stage/atlas/head_neutral.png',
      mouthAsset: 'assets/characters/sukuna/stage/atlas/mouth_m.png',
      handAsset: 'assets/characters/sukuna/stage/atlas/hand_relaxed.png',
    ),
    CharacterEmotion.amused: CharacterSpritePose(
      headAsset: 'assets/characters/sukuna/stage/atlas/head_smirk.png',
      mouthAsset: 'assets/characters/sukuna/stage/atlas/mouth_a.png',
      handAsset: 'assets/characters/sukuna/stage/atlas/hand_palm.png',
    ),
    CharacterEmotion.scornful: CharacterSpritePose(
      headAsset: 'assets/characters/sukuna/stage/atlas/head_angry.png',
      mouthAsset: 'assets/characters/sukuna/stage/atlas/mouth_s.png',
      handAsset: 'assets/characters/sukuna/stage/atlas/hand_fist.png',
    ),
  },
);
