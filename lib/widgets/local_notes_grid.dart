import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:notesy_offline/models/note_model.dart';
import 'package:notesy_offline/services/note_service.dart';
import 'package:notesy_offline/widgets/note_card.dart';
import 'package:provider/provider.dart';

class LocalNotesStagGrid extends StatelessWidget {
  final Box<Note> boxContents;
  final void Function(Note?) onTap;
  final int length;
  final int fit;
  final double padding;
  LocalNotesStagGrid(
      {required this.boxContents,
      required this.onTap,
      required this.length,
      this.fit = 1,
      this.padding = 12});

  @override
  Widget build(BuildContext context) {
    final currentLabel = context.watch<NoteService>().labelInUse;
    final List<Note> boxList;
    if (currentLabel != null)
      boxList = boxContents.values
          .where((note) => note.labels?.contains(currentLabel) == true)
          .toList();
    else
      boxList = boxContents.values.toList();
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverStaggeredGrid.countBuilder(
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 15.0,
          crossAxisCount: 2,
          staggeredTileBuilder: (index) => StaggeredTile.fit(fit),
          itemBuilder: (context, index) {
            // final note = boxContents.getAt(index);
            final note = boxList[index];
            // final noteKey = boxContents.keyAt(index);
            note.id = note.key;
            if (currentLabel == null)
              return InkWell(
                onTap: () => onTap.call(note),
                child: NoteItem(note: note),
              );
            else {
              if (note.labels?.contains(currentLabel) == true)
                return InkWell(
                  onTap: () => onTap.call(note),
                  child: NoteItem(note: note),
                );
              else
                return InkWell();
            }
          },
          itemCount: boxList.length),
    );
  }
}
