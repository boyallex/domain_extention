import 'package:domain_extention/features/character_stage/domain/entity/character_emotion.dart';
import 'package:domain_extention/features/character_stage/domain/entity/character_sprite_pose.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

/// Flame-обёртка над атласом: грузит спрайты и отдаёт анимации смены эмоций.
class CharacterSpriteAnimator {
  CharacterSpriteAnimator({
    this.atlas = sukunaSpriteAtlas,
    Images? images,
  }) : _images = images ?? Images(prefix: '');

  final CharacterSpriteAtlas atlas;
  final Images _images;

  bool _loaded = false;
  Sprite? body;
  final Map<CharacterEmotion, CharacterLoadedPose> _poses = {};

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    final paths = <String>{
      atlas.bodyAsset,
      for (final pose in atlas.poses.values) ...[
        pose.headAsset,
        pose.mouthAsset,
        pose.handAsset,
      ],
    };
    await _images.loadAll(paths.toList(growable: false));
    body = Sprite(_images.fromCache(atlas.bodyAsset));
    for (final entry in atlas.poses.entries) {
      final pose = entry.value;
      _poses[entry.key] = CharacterLoadedPose(
        head: Sprite(_images.fromCache(pose.headAsset)),
        mouth: Sprite(_images.fromCache(pose.mouthAsset)),
        hand: Sprite(_images.fromCache(pose.handAsset)),
      );
    }
    _loaded = true;
  }

  CharacterLoadedPose pose(CharacterEmotion emotion) {
    final loaded = _poses[emotion] ?? _poses[CharacterEmotion.idle];
    if (loaded == null) {
      throw StateError('Sprite atlas is empty');
    }
    return loaded;
  }

  /// Короткая анимация губ для эмоции: closed → open → closed.
  SpriteAnimation mouthPulse(CharacterEmotion emotion) {
    final current = pose(emotion);
    final idle = pose(CharacterEmotion.idle);
    return SpriteAnimation.spriteList(
      [idle.mouth, current.mouth, idle.mouth],
      stepTime: 0.18,
      loop: false,
    );
  }

  void dispose() {
    _images.clearCache();
    _loaded = false;
    body = null;
    _poses.clear();
  }
}

class CharacterLoadedPose {
  const CharacterLoadedPose({
    required this.head,
    required this.mouth,
    required this.hand,
  });

  final Sprite head;
  final Sprite mouth;
  final Sprite hand;
}
