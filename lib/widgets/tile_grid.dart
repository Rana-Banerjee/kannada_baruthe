import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/tile.dart';
import 'image_tile.dart';

class TileGrid extends StatelessWidget {
  final List<Tile> tiles;
  final int? selectedTileIndex;
  final int? correctTileIndex;
  final bool showFeedback;
  final Function(int) onTileTap;

  const TileGrid({
    super.key,
    required this.tiles,
    this.selectedTileIndex,
    this.correctTileIndex,
    required this.showFeedback,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    final crossAxisCount = config.tileColumns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        TileState state;
        
        if (!showFeedback) {
          state = TileState.neutral;
        } else {
          if (index == correctTileIndex) {
            state = TileState.revealedCorrect;
          } else if (index == selectedTileIndex) {
            state = tiles[index].isCorrect 
              ? TileState.correct 
              : TileState.wrong;
          } else {
            state = TileState.neutral;
          }
        }

        return ImageTile(
          tile: tile,
          state: state,
          onTap: () => onTileTap(index),
          index: index,
        );
      },
    );
  }
}
