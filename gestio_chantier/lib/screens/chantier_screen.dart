import 'package:flutter/material.dart';
import '../screens/quinzaine_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ChantierScreen(nomChantier: 'nch'),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ChantierScreen extends StatelessWidget {
  final String nomChantier;
  const ChantierScreen({super.key, required this.nomChantier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Projet',
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
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.post_add_rounded,
                        size: 27,
                        color: Colors.blue,
                      ),
                      Text(
                        "+_Session",
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
                        Icons.library_add_outlined,
                        // Icons.now_widgets_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      // SizedBox(height: 0),
                      Text(
                        "Rapport-jrlier",
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //     // Action quand on clique sur le tout
                //   },
                //   child: const Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Icon(
                //         Icons.swap_vert_circle_outlined,
                //         // Icons.now_widgets_outlined,
                //         size: 27,
                //         color: Colors.blue,
                //       ),
                //       // SizedBox(height: 0),
                //       Text(
                //         "Suivi-Mat",
                //         style: TextStyle(fontSize: 10, color: Colors.black),
                //       ),
                //     ],
                //   ),
                // ),
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
                  "Projet: $nomChantier",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    // fontStyle: FontStyle.italic, // Texte en italique
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  "Dépense total MO éffectuée: 141 000 f",
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
              "Liste des Sessions (3)",
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
                    Container(
                      height: 48,
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.8),
                        ),
                        color: Colors.white60,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Quinzaine 3, (40 000 f)",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              // letterSpacing: 1.2,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const Text(
                                            "Période: 08/07/25 - 22/07/25",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            String nomch = "Quinzaine 3";
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QuinzaineScreen(
                                                      sessionQ: nomch,
                                                    ),
                                              ),
                                            );
                                          },
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},

                                          label: Icon(
                                            Icons.edit,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "En cours",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 22,
                                            color: Colors.red,
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
                    ),
                    Container(
                      height: 48,
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.8),
                        ),
                        color: Colors.white60,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Semaine 2, (66 000 f)",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              // letterSpacing: 1.2,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const Text(
                                            "Période: 07/06/25 - 14/06/25",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},

                                          label: Icon(
                                            Icons.edit,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Terminé",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 22,
                                            color: Colors.red,
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
                    ),
                    Container(
                      height: 48,
                      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 0.8),
                        ),
                        color: Colors.white60,
                      ),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 5),
                                      child: Column(
                                        children: [
                                          const Text(
                                            "Quinzaine 1, (35 000 f)",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                              // letterSpacing: 1.2,
                                              // fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          const Text(
                                            "Période: 21/05/25 - 04/06/25",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},

                                          label: Icon(
                                            Icons.edit,
                                            size: 22,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          "Terminé",
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 22,
                                            color: Colors.red,
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
