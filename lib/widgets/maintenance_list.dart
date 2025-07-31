import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cruzroja/models/maintenance_model.dart';
import '../screens/maintenance_detail_screen.dart';


typedef MaintenanceTapCallback = void Function(Maintenance maintenance);

class MaintenanceList extends StatefulWidget {
  final List<Maintenance> maintenances;
  final VoidCallback? onAddMaintenance;
  final bool modoSeleccion;
  final Set<int> seleccionados;
  final void Function(int)? onToggleSeleccion;
  final MaintenanceTapCallback? onTapMaintenance;

  const MaintenanceList({
    super.key,
    required this.maintenances,
    this.onAddMaintenance,
    this.modoSeleccion = false,
    this.seleccionados = const {},
    this.onToggleSeleccion,
    this.onTapMaintenance,
  });
  @override
  State<MaintenanceList> createState() => _MaintenanceListState();
}

class _MaintenanceListState extends State<MaintenanceList> {
  // Ya no se usa lista interna ni carga desde Firestore, todo viene del padre

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: widget.maintenances.length,
        itemBuilder: (context, index) {
          final maintenance = widget.maintenances[index];
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
                          child: const Icon(Icons.settings, color: Colors.red, size: 20),
                        ),
                  title: Text(
                    maintenance.maintenanceType,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    maintenance.maintenanceId,
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
                          if (widget.onTapMaintenance != null) {
                            widget.onTapMaintenance!(maintenance);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MaintenanceDetailScreen(
                                  maintenance: maintenance,
                                  ambulanceModel: maintenance.maintenanceId,
                                ),
                              ),
                            );
                          }
                        },
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(maintenance.date),
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