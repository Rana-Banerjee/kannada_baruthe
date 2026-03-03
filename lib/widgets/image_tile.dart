import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/tile.dart';

enum TileState {
  neutral,
  correct,
  wrong,
  revealedCorrect,
}

class ImageTile extends StatelessWidget {
  final Tile tile;
  final TileState state;
  final VoidCallback onTap;
  final int index;

  const ImageTile({
    super.key,
    required this.tile,
    required this.state,
    required this.onTap,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final config = AppConfig.instance;
    
    Color borderColor;
    Color backgroundColor;
    double elevation;
    
    switch (state) {
      case TileState.neutral:
        borderColor = Colors.grey.shade300;
        backgroundColor = Colors.white;
        elevation = 2;
        break;
      case TileState.correct:
        borderColor = _parseColor(config.correctColor);
        backgroundColor = _parseColor(config.correctColor).withOpacity(0.1);
        elevation = 4;
        break;
      case TileState.wrong:
        borderColor = _parseColor(config.wrongColor);
        backgroundColor = _parseColor(config.wrongColor).withOpacity(0.1);
        elevation = 4;
        break;
      case TileState.revealedCorrect:
        borderColor = _parseColor(config.correctColor);
        backgroundColor = _parseColor(config.correctColor).withOpacity(0.1);
        elevation = 2;
        break;
    }

    return GestureDetector(
      onTap: state == TileState.neutral ? onTap : null,
      child: Container(
        key: Key('kl_tile_t${index + 1}'),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: state == TileState.neutral ? 2 : 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  tile.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Label
            Container(
              key: Key('kl_tile_label_t${index + 1}'),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: state == TileState.neutral 
                  ? Colors.grey.shade50 
                  : backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Text(
                tile.englishLabel,
                style: TextStyle(
                  fontSize: config.sizeTileLabel,
                  fontWeight: FontWeight.w600,
                  color: _parseColor(config.textColorPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  }
}
