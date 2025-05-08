import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Info",style: GoogleFonts.kantumruyPro(),),
      ),
      body:  SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 25,),
              Text(
                'CamCyber POS V2',style: GoogleFonts.kantumruyPro(fontSize: 24,),
              ),
              SizedBox(height: 25,),
               Text(
                'Version',style: GoogleFonts.kantumruyPro(),
              ),
               Text(
                '2.0.2'
                ,style: GoogleFonts.kantumruyPro(),
              ),
              SizedBox(height: 15,),
               Text(
                'CamCyber POS V2 is build using open-source software licences.'
                ,style: GoogleFonts.kantumruyPro(),
                           ),
               
            ],
          ),
        ),
      ),
    );
  }
}