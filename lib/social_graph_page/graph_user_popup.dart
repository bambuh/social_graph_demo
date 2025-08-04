import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/theme/app_color_palette.dart';
import 'package:social_graph/theme/app_text_theme.dart';

final class GraphUserPopup extends StatelessWidget {
  const GraphUserPopup({
    required this.nodeContent,
    this.avatar,
    this.onDelete,
    super.key,
  });

  final NodeContent nodeContent;
  final ui.Image? avatar;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
        child: Container(
          color: GraphAppColorPalette.grey800_88,
          width: 360,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (avatar != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(64),
                        child: FutureBuilder(
                          future: avatar!.toByteData(
                            format: ui.ImageByteFormat.png,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(width: 64, height: 64);
                            }
                            return Image(
                              image: MemoryImage(
                                snapshot.data!.buffer.asUint8List(),
                              ),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      nodeContent.name,
                      style: AppTextTheme.current.titleXSMedium.copyWith(
                        color: GraphAppColorPalette.white100,
                      ),
                    ),
                    Text(
                      nodeContent.contentType.name,
                      style: AppTextTheme.current.bodyMRegular.copyWith(
                        color: GraphAppColorPalette.white64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('More'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete?.call(nodeContent.id);
                            },
                            child: Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
