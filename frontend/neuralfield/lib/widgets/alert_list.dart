// import 'package:flutter/material.dart';
//
// class AlertList extends StatelessWidget {
//   const AlertList({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final List<AlertItem> alerts = const [
//       AlertItem(title: 'Aphids', severity: 'High', severityColor: Color(0xFFF44336)),
//       AlertItem(title: 'Blight', severity: 'Medium', severityColor: Color(0xFFFF9800)),
//       AlertItem(title: 'Mildew', severity: 'Low', severityColor: Color(0xFF4CAF50)),
//     ];
//
//     return Column(
//       children: alerts.map((alert) => AlertCard(alert: alert)).toList(),
//     );
//   }
// }
//
// class AlertItem {
//   final String title;
//   final String severity;
//   final Color severityColor;
//
//   const AlertItem({
//     required this.title,
//     required this.severity,
//     required this.severityColor,
//   });
// }
//
// class AlertCard extends StatelessWidget {
//   final AlertItem alert;
//
//   const AlertCard({super.key, required this.alert});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: alert.severityColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Icons.warning_amber_rounded,
//               color: alert.severityColor,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   alert.title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2C3E2B),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Risk level: ${alert.severity}',
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: alert.severityColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: alert.severityColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               alert.severity,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//                 color: alert.severityColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }