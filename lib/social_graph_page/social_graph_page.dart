import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_graph/gen/assets.gen.dart';
import 'package:social_graph/knowledge_graph/knowledge_graph_view.dart';
import 'package:social_graph/knowledge_graph/models/node_content.dart';
import 'package:social_graph/social_graph_page/graph_user_popup.dart';
import 'package:social_graph/theme/app_color_palette.dart';
import 'package:social_graph/theme/app_text_theme.dart';
import 'package:social_graph/ui_util.dart';

import 'cubit/social_graph_page_cubit.dart';

final class SocialGraphPage extends StatelessWidget {
  const SocialGraphPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GraphAppColorPalette.black100,
      body: BlocBuilder<SocialGraphPageCubit, SocialGraphPageState>(
        builder: (context, state) {
          return Stack(
            children: [
              KnowledgeGraphView(
                dataset: state.dataset,
                edgeDirection: state.direction,
                onNodeTap:
                    ({required nodeContent, avatar}) =>
                        showModal(context, nodeContent, avatar),
              ),
              SafeArea(
                child: _AppBar(
                  onAddPressed:
                      () =>
                          context.read<SocialGraphPageCubit>().addRandomUser(),
                  onDirectionPressed:
                      () =>
                          context
                              .read<SocialGraphPageCubit>()
                              .toggleDirection(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showModal(
    BuildContext rootContext,
    NodeContent nodeContent,
    ui.Image? avatar,
  ) {
    showCupertinoModalPopup<void>(
      context: rootContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const ColoredBox(
                    color: Colors.transparent,
                    child: SizedBox.expand(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: IntrinsicHeight(
                      child: GraphUserPopup(
                        nodeContent: nodeContent,
                        avatar: avatar,
                        onDelete:
                            rootContext.read<SocialGraphPageCubit>().removeUser,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final class _AppBar extends StatelessWidget {
  const _AppBar({this.onAddPressed, this.onDirectionPressed});

  final void Function()? onAddPressed;
  final void Function()? onDirectionPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Assets.chevronLeftL.svg(
                height: 24,
                width: 24,
                colorFilter: Colors.black.filter,
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                onAddPressed?.call();
              },
              child: Assets.plusL.svg(
                height: 24,
                width: 24,
                colorFilter: Colors.black.filter,
              ),
            ),
            SizedBox(width: 8),
            BlocBuilder<SocialGraphPageCubit, SocialGraphPageState>(
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: () {
                    onDirectionPressed?.call();
                  },
                  child: Text(
                    state.direction.arrow,
                    style: AppTextTheme.current.titleSSemiBold.copyWith(
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 16),
          ],
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
