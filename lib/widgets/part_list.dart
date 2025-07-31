import 'package:flutter/material.dart';
import 'package:cruzroja/models/part_model.dart';
import 'package:intl/intl.dart';
import '../screens/part_detail_screen.dart';


class PartList extends StatefulWidget {
  final List<Part> parts;
  final VoidCallback? onAddPart;
  final bool modoSeleccion;
  final Set<int> seleccionados;
  final void Function(int)? onToggleSeleccion;
  final void Function(Part)? onTapPart;

  const PartList({
    super.key,
    required this.parts,
    this.onAddPart,
    this.modoSeleccion = false,
    this.seleccionados = const {},
    this.onToggleSeleccion,
    this.onTapPart,
  });

  @override
  State<PartList> createState() => _PartListState();
}

class _PartListState extends State<PartList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: widget.parts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          final part = widget.parts[index];
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Stack(
              children: [
                ListTile(
                  leading: widget.modoSeleccion
                      ? Checkbox(
                          value: widget.seleccionados.contains(index),
                          onChanged: (checked) {
                            if (widget.onToggleSeleccion != null) widget.onToggleSeleccion!(index);
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.build, color: Colors.red, size: 20),
                        ),
                  title: Text(
                    part.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    part.maintenanceId,
                    style: const TextStyle(color: Colors.black54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: widget.modoSeleccion
                      ? null
                      : const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tileColor: Colors.white,
                  onTap: widget.modoSeleccion
                      ? () {
                          if (widget.onToggleSeleccion != null) widget.onToggleSeleccion!(index);
                        }
                      : () {
                          if (widget.onTapPart != null) {
                            widget.onTapPart!(part);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PartDetailScreen(part: part),
                              ),
                            );
                          }
                        },
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(part.date),
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      );
  }
}
// ...