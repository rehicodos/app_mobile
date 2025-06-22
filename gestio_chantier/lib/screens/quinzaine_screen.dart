import 'package:flutter/material.dart';
import '../screens/appel_list_ov_screen.dart';
import '../screens/add_ouvrier_screen.dart';
// import '../reach/reach_projet.dart';

void main() {
  runApp(
    const MaterialApp(
      home: QuinzaineScreen(sessionQ: 'q'),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class QuinzaineScreen extends StatelessWidget {
  final String sessionQ;
  const QuinzaineScreen({super.key, required this.sessionQ});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Session/Période',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),

      body: Column(
        children: [
          // Row fixé en haut
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    // Action quand on clique sur le tout
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_outlined, size: 27, color: Colors.blue),
                      Text(
                        "Accueil",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action quand on clique sur le tout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkerRegistrationCameraPage(),
                      ),
                    );
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.engineering, size: 27, color: Colors.blue),
                      Text(
                        "+_Ouvrier",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action quand on clique sur le tout
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PageOuvrier()),
                    );
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        // Icons.now_widgets_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      // SizedBox(height: 0),
                      Text(
                        "Pointage",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Action quand on clique sur le tout
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.send_to_mobile_outlined,
                        // Icons.now_widgets_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      // SizedBox(height: 0),
                      Text(
                        "Paiement",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            width: MediaQuery.of(context).size.width * 0.97,
            alignment: Alignment.center, // centre le contenu
            decoration: BoxDecoration(
              // color: Colors.amber,
              color: Colors.white38,
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              children: [
                Text(
                  sessionQ,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    // fontStyle: FontStyle.italic, // Texte en italique
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "08/07/25 - 22/07/25",
                  style: TextStyle(
                    fontSize: 10,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontStyle: FontStyle.italic, // Texte en italique
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Dépense total MO: 66 000 f",
                  style: TextStyle(
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontStyle: FontStyle.italic, // Texte en italique
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            alignment: Alignment.center,
            // color: Colors.white,
            child: Text(
              "Liste des ouvriers (3)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),
          // Liste scrollable
          Expanded(
            child: ListView(
              // padding: const EdgeInsets.all(),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),

              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          // height: 48,
                          // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          // alignment: Alignment.sp,
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          width: MediaQuery.of(context).size.width * 0.97,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 0.8,
                              ),
                            ),
                            color: Colors.white60,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // 👈 ici le spacing !
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                  ),
                                  color: Colors.white60,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/logoAelite.jpg',
                                          ), // 📸 ton image
                                          fit: BoxFit
                                              .cover, // ou `contain`, `fill`, etc.
                                        ),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ), // ✅ coins arrondis
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Yao Alain",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Maçon",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Prix_jrlier: 8 000 f",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Tel: 07 87 38 32 40",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Ajouté le, 16/06/25",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Pointage: 11 jr(s)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},

                                    label: Icon(
                                      Icons.edit_square,
                                      size: 27,
                                      color: Colors.green,
                                    ),
                                  ),

                                  TextButton.icon(
                                    onPressed: () {},
                                    label: Icon(
                                      Icons.delete_forever,
                                      size: 27,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          // height: 48,
                          // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          // alignment: Alignment.sp,
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          width: MediaQuery.of(context).size.width * 0.97,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 0.8,
                              ),
                            ),
                            color: Colors.white60,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // 👈 ici le spacing !
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                  ),
                                  color: Colors.white60,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/logoAelite.jpg',
                                          ), // 📸 ton image
                                          fit: BoxFit
                                              .cover, // ou `contain`, `fill`, etc.
                                        ),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ), // ✅ coins arrondis
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Bambou Sié",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Ferrailleur",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Prix_jrlier: 7 000 f",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Tel: 01 22 38 32 40",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Ajouté le, 16/06/25",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Pointage: 10 jr(s)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},

                                    label: Icon(
                                      Icons.edit_square,
                                      size: 27,
                                      color: Colors.green,
                                    ),
                                  ),

                                  TextButton.icon(
                                    onPressed: () {},
                                    label: Icon(
                                      Icons.delete_forever,
                                      size: 27,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          // height: 48,
                          // margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                          // alignment: Alignment.sp,
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 5,
                          ),
                          width: MediaQuery.of(context).size.width * 0.97,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 0.8,
                              ),
                            ),
                            color: Colors.white60,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // 👈 ici le spacing !
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(
                                      color: Colors.black,
                                      width: 0.8,
                                    ),
                                  ),
                                  color: Colors.white60,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      margin: EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            'assets/images/logoAelite.jpg',
                                          ), // 📸 ton image
                                          fit: BoxFit
                                              .cover, // ou `contain`, `fill`, etc.
                                        ),
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ), // ✅ coins arrondis
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Kouamé Yves",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Aide",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Prix_jrlier: 4 000 f",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Tel: 05 45 38 32 40",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Ajouté le, 16/06/25",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Text(
                                          "Pointage: 2 jr(s)",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {},

                                    label: Icon(
                                      Icons.edit_square,
                                      size: 27,
                                      color: Colors.green,
                                    ),
                                  ),

                                  TextButton.icon(
                                    onPressed: () {},
                                    label: Icon(
                                      Icons.delete_forever,
                                      size: 27,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
