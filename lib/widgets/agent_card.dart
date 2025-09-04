import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/cultural_agent.dart';
import '../widgets/proxy_image.dart';

class AgentCard extends StatelessWidget {
  final CulturalAgent agent;
  final VoidCallback? onTap;

  const AgentCard({
    Key? key,
    required this.agent,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getTypeColor().withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto del agente (50% de la altura)
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: agent.imageUrl.isNotEmpty
                        ? ProxyImage(
                            imageUrl: agent.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: _getTypeColor().withOpacity(0.3),
                            child: Icon(
                              agent.type == AgentType.artisan
                                  ? Icons.palette
                                  : Icons.map,
                              size: 60,
                              color: _getTypeColor(),
                            ),
                          ),
                  ),
                ),
              ),

              // Información del agente (50% de la altura)
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        agent.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Tipo de agente
                      Row(
                        children: [
                          Text(
                            agent.typeIcon,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              agent.typeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTypeColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Contacto
                      if (agent.primaryContact.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                agent.primaryContact,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 6),

                      // Descripción/Especialidad
                      if (agent.expertise != null &&
                          agent.expertise!.isNotEmpty)
                        Text(
                          agent.expertise!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Ubicación
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              agent.fullLocation,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Acciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // WhatsApp
                          if (agent.whatsapp != null &&
                              agent.whatsapp!.isNotEmpty)
                            _buildActionButton(
                              icon: Icons.message,
                              color: Colors.green,
                              onTap: () => _openWhatsApp(agent.whatsapp!),
                            ),

                          // Ubicación
                          if (agent.latitude != null && agent.longitude != null)
                            _buildActionButton(
                              icon: Icons.map,
                              color: Colors.blue,
                              onTap: () =>
                                  _openMap(agent.latitude!, agent.longitude!),
                            ),

                          // Rating
                          if (agent.rating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    agent.rating!.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (agent.type) {
      case AgentType.artisan:
        return Colors.deepPurple;
      case AgentType.guide:
        return Colors.teal;
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse('https://wa.me/$cleanNumber');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        print('No se puede abrir WhatsApp');
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
    }
  }

  void _openMap(double latitude, double longitude) async {
    final Uri mapsUri =
        Uri.parse('https://maps.google.com/?q=$latitude,$longitude');

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      } else {
        print('No se puede abrir Maps');
      }
    } catch (e) {
      print('Error al abrir Maps: $e');
    }
  }
}
