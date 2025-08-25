import 'package:flutter/material.dart';
import '../models/cultural_agent.dart';
 
class CulturalAgentListTile extends StatelessWidget {
  final CulturalAgent agent;

  const CulturalAgentListTile({Key? key, required this.agent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(agent.imageUrl ?? ''),
        radius: 25.0,
      ),
      title: Text(
        agent.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(agent.region),
      // You can add an onTap here if you want to make the list tile interactive
      // onTap: () {
      //   // TODO: Handle tap on cultural agent
      // },
    );
  }
}