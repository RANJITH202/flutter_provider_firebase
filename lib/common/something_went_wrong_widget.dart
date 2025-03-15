// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class SomethingWentWrongPage extends StatefulWidget {
//   SomethingWentWrongPage({Key? key, this.errorDetails}) : super(key: key);

//   final FlutterErrorDetails? errorDetails;
//   @override
//   State<SomethingWentWrongPage> createState() => _SomethingWentWrongPageState();
// }

// class _SomethingWentWrongPageState extends State<SomethingWentWrongPage> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Scaffold(
//           key: scaffoldKey,
//           backgroundColor: context.appColorTheme.primaryBackground,
//           body: SafeArea(
//             top: true,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Spacer(),
//                 Align(
//                   alignment: AlignmentDirectional(0.0, 0.0),
//                   child: Padding(
//                     padding:
//                         EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
//                     child: Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: context.appColorTheme.secondaryBackground,
//                         boxShadow: [
//                           BoxShadow(
//                             blurRadius: 16.0,
//                             color: Color(0x0E000000),
//                             offset: Offset(0.0, 8.0),
//                           )
//                         ],
//                         borderRadius: BorderRadius.circular(16.0),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsetsDirectional.fromSTEB(
//                             16.0, 32.0, 16.0, 32.0),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: Image.network(
//                                 'https://storage.googleapis.com/flutterflow-enterprise-india.appspot.com/teams/sdQsX1OG3JuvLFCsHa8b/assets/8ooti5utqtme/empty-document.png',
//                                 width: 196.0,
//                                 height: 196.0,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             Text(
//                               "Something went wrong!",
//                               textStyleColor: Colors.black,
//                               style: AppTextStyles.f18pxSemiBold,
//                             ),
//                             Padding(
//                               padding: EdgeInsetsDirectional.fromSTEB(
//                                   48.0, 8.0, 48.0, 0.0),
//                               child: AppText(
//                                 kDebugMode
//                                     ? "Error : ${widget.errorDetails?.summary ?? ""}"
//                                     : "An error has occurred. We are working to fix this issue. Please check back soon.",
//                                 textAlign: TextAlign.center,
//                                 textStyleColor:
//                                     context.appColorTheme.coolGrey120,
//                                 style: AppTextStyles.f12pxSemiBold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 Padding(
//                   padding:
//                       EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 100.0),
//                   child: AppButtonWidget(
//                     onPressed: () async {
//                       context.safePop();
//                     },
//                     text: FFLocalizations.of(context).getText(
//                       'xpjwl3cz' /* Got it */,
//                     ),
//                     options: AppButtonOptions(
//                       width: double.infinity,
//                       height: 48.0,
//                       padding:
//                           EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
//                       iconPadding:
//                           EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
//                       color: context.appColorTheme.primary,
//                       textStyle: AppTextStyles.f18pxSemiBold,
//                       textStyleColor: context.appColorTheme.secondaryBackground,
//                       elevation: 3.0,
//                       borderSide: BorderSide(
//                         color: context.appColorTheme.transparent,
//                         width: 1.0,
//                       ),
//                       borderRadius: BorderRadius.circular(60.0),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
