import 'package:flutter/material.dart';
import 'package:notesy_offline/models/note_model.dart';

import '../constants.dart';

/// A single item (preview of a Note) in the Notes list.
class NoteItem extends StatelessWidget {
  const NoteItem({Key? key, required this.note}) : super(key: key);

  final Note? note;
  // final tag;

  @override
  Widget build(BuildContext context) => Hero(
        tag: 'NoteItem${note?.id}',
        child: DefaultTextStyle(
          style: kNoteTextInnerDark,
          child: Container(
            decoration: BoxDecoration(
              color: (note?.color) == null || (note!.color) == null
                  ? kDefaultNoteColor
                  : HexColor(hexColor: note!.color!),
              borderRadius: BorderRadius.all(Radius.circular(16)),
              // border: note.color.value == 0xFFFFFFFF ? Border.all(color: kBorderColorLight) : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (note != null && note?.title?.isNotEmpty == true)
                  Text(
                    note!.title!,
                    style: kCardTitleLight,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (note != null && note?.title?.isNotEmpty == true) const SizedBox(height: 8),
                if (note?.content?.isNotEmpty == true)
                  Flexible(
                    flex: 1,
                    child: Text(
                      note?.content ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 8,
                      style: const TextStyle(fontSize: 15.0),
                    ), // wrapping using a Flexible to avoid overflow
                  ),
                SizedBox(height: 12.0),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...?note?.labelsToShow(showLabels: true),
                  ],
                ),
                SizedBox(height: 12.0),
                // if (note.reminderExists)
                //   Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Container(
                //         padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                //         decoration: BoxDecoration(
                //           color: Color(0xAAADADAD),
                //           borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //         ),
                //         child: Icon(
                //           Icons.alarm,
                //           size: 18.0,
                //         ),
                //       ),
                //     ],
                //   ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      note?.strCreatedAt ?? '',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    if (note?.reminderExists == true) Icon(Icons.alarm, size: 18.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
// class NoteCard extends StatelessWidget {
//   final Note? note;
//   final String? title, content;
//   final String? color;
//   final void Function(Note?) onTap;
//   const NoteCard(
//       {Key? key,
//       this.title,
//       this.content,
//       this.color = "NULL",
//       required this.onTap,
//       required this.note})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => onTap.call(note),
//       child: Card(
//         color: color == "NULL" ? null : HexColor(hexColor: color!),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (title != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   title!,
//                   style: const TextStyle(
//                     fontSize: 24.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             if (content != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   content!,
//                   style: const TextStyle(
//                     fontSize: 16.0,
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor) {
    if (hexColor == null) {
      return int.parse("444444", radix: 16);
    }
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor({final String hexColor = "F28C82"}) : super(_getColorFromHex(hexColor));
}
