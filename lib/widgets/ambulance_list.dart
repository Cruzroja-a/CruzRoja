import 'package:flutter/material.dart';
import 'package:cruzroja/models/ambulance_model.dart';

import '../screens/ambulance_detail_screen.dart';


typedef AmbulanceTapCallback = void Function(Ambulance ambulance);

class AmbulanceList extends StatelessWidget {
  final List<Ambulance> ambulances;
  final VoidCallback? onAddAmbulance;
  final AmbulanceTapCallback? onTapAmbulance;
  final bool modoSeleccion;
  final Set<int>? seleccionados;
  final void Function(int)? onToggleSeleccion;

  const AmbulanceList({
    super.key,
    required this.ambulances,
    this.onAddAmbulance,
    this.modoSeleccion = false,
    this.seleccionados,
    this.onToggleSeleccion,
    this.onTapAmbulance,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: ambulances.length,
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemBuilder: (context, index) {
          final ambulance = ambulances[index];
          final seleccionado = modoSeleccion && (seleccionados?.contains(index) ?? false);
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: modoSeleccion
                  ? Checkbox(
                      value: seleccionado,
                      onChanged: (_) {
                        if (onToggleSeleccion != null) onToggleSeleccion!(index);
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.local_hospital, color: Colors.red, size: 20),
                    ),
              title: Text(
                '${ambulance.model} - ${ambulance.plate}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                ambulance.plate,
                style: const TextStyle(color: Colors.black54, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: modoSeleccion
                  ? null
                  : const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tileColor: Colors.white,
              onTap: modoSeleccion
                  ? () {
                      if (onToggleSeleccion != null) onToggleSeleccion!(index);
                    }
                  : () {
                      if (onTapAmbulance != null) {
                        onTapAmbulance!(ambulance);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AmbulanceDetailScreen(ambulance: ambulance),
                          ),
                        );
                      }
                    },
            ),
          );
        },
      );
  }
}