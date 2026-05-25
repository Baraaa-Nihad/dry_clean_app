// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:saleem_dry_clean/components/Modals/BlankCategoryModal.dart';
// import 'package:saleem_dry_clean/style/AppTextStyles.dart';
// import 'package:saleem_dry_clean/theme/AppColors.dart';

// class PreviouslyAddedCard extends StatelessWidget {
//   final String title;
//   final List<Map<String, dynamic>> items;
//   final double fem;

//   const PreviouslyAddedCard({
//     Key? key,
//     required this.title,
//     required this.items,
//     required this.fem,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // Define the services for the modal
//         Map<String, Map<String, dynamic>> services = {
//           'Washing & ironing': {'price': 18.0, 'unit': 'item'},
//           'Washing': {'price': 10.0, 'unit': 'item'},
//           'Ironing': {'price': 8.0, 'unit': 'item'},
//         };
//         // Trigger the modal when the card is pressed
//         showItemDetailsModal(context, fem, title, services);
//       },
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 16 * fem),
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment(-1.00, -0.00),
//                   end: Alignment(4, 0),
//                   colors: [
//                     AppColors.blue,
//                     AppColors.green,
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(16 * fem),
//               ),
//               padding: EdgeInsets.all(1), // The width of the gradient border
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.white,
//                   borderRadius: BorderRadius.circular(16 * fem),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SvgPicture.asset(
//                             'assets/vectors/starVector.svg',
//                             width: 16 * fem,
//                             height: 18 * fem,
//                           ),
//                           SizedBox(width: 20), // Gap between icon and title
//                           Container(
//                             height: 48,
//                             child: Align(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 "Previously Added carpets",
//                                 style: AppTextStyles.getFontFamily(
//                                   context,
//                                   AppTextStyles.bold16Gradient(context)
//                                       .copyWith(
//                                           fontSize: 16.0 * fem,
//                                           fontWeight: FontWeight.w600,
//                                           color: AppColors.white),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 20), // Gap between title and icon
//                           SvgPicture.asset(
//                             'assets/vectors/starVector.svg',
//                             width: 16 * fem,
//                             height: 18 * fem,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Divider(
//                       color: AppColors.gray20,
//                       thickness: 0.5,
//                       height: 0.5,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(16 * fem),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ...items.asMap().entries.map((entry) {
//                             int index = entry.key;
//                             Map<String, dynamic> item = entry.value;

//                             return Column(
//                               children: [
//                                 Padding(
//                                   padding:
//                                       EdgeInsets.symmetric(vertical: 8 * fem),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         width: 48,
//                                         height: 48,
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(12 * fem),
//                                           border: Border.all(
//                                             color: AppColors.stroke,
//                                             width:
//                                                 1.0, // Set the border width to 1
//                                           ),
//                                           image: DecorationImage(
//                                             image:
//                                                 AssetImage(item['imagePath']!),
//                                             fit: BoxFit.cover,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(width: 16 * fem),
//                                       Expanded(
//                                         child: Text(
//                                           item['label']!,
//                                           style: AppTextStyles.getFontFamily(
//                                             context,
//                                             AppTextStyles.regular16Gray70(
//                                                     context)
//                                                 .copyWith(
//                                               fontSize: 16.0 * fem,
//                                               fontWeight: FontWeight.w500

//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SvgPicture.asset(
//                                         'assets/vectors/plus_icon.svg', // Ensure the path is correct
//                                         width: 48 * fem,
//                                         height: 48 * fem,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 if (index != items.length - 1)
//                                   Container(
//                                     margin: EdgeInsets.only(
//                                         left: 64 *
//                                             fem), // Adjust the margin to match the image border
//                                     child: Divider(
//                                       color: AppColors.gray20,
//                                       thickness: 0.5,
//                                     ),
//                                   ),
//                               ],
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void showItemDetailsModal(BuildContext context, double fem, String title,
//     Map<String, Map<String, dynamic>> services) {
//   BlankCategoryModal.show(
//     context,
//     mainTitle: title,
//     subTitle: 'Pants',
//     prefixIconPath: 'assets/vectors/close_icon.svg',
//     onPrefixIconTap: () {
//       Navigator.pop(context);
//     },
//     fem: fem,
//     isDisabledButton: true,
//     services: services, // Pass the services to the modal
//   );
// }
