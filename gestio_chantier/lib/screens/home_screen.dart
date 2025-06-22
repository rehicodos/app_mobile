import 'package:flutter/material.dart';
// import '../routes/app_routes.dart';
import '../screens/chantier_screen.dart';
import '../screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // List<String> filteredItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const Text(
          'Gestio chantier App',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // centerTitle: true,
        // elevation: 0,
      ),
      // drawer: const Drawer(),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(height: 50),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Accueil"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Quitter"),
              onTap: () {},
            ),
          ],
        ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      Text(
                        "Manuel",
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
                        Icons.playlist_add,
                        // Icons.now_widgets_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      // SizedBox(height: 0),
                      Text(
                        "+_projet",
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
                        Icons.admin_panel_settings_outlined,
                        size: 27,
                        color: Colors.blue,
                      ),
                      // SizedBox(height: 0),
                      Text(
                        "Admin",
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
                      Icon(Icons.help_outline, size: 27, color: Colors.blue),
                      // SizedBox(height: 0),
                      Text(
                        "Aide",
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
                      Icon(Icons.logout_outlined, size: 27, color: Colors.blue),
                      // Icon(Icons.login_sharp, size: 27, color: Colors.blue),
                      Text(
                        "Déconnexion",
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
                  "Liste des projets (4)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    // fontStyle: FontStyle.italic, // Texte en italique
                  ),
                ),
                SizedBox(height: 2),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    // height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      // color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            // controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Rechercher projet ici ...',
                              border: InputBorder.none,
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white70,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 3.0,
                                horizontal: 10.0,
                              ),
                            ),
                            // onChanged: _performSearch,
                            // onSubmitted: _performSearch,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // _performSearch(_controller.text);
                          },
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.blue,
                            // color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste scrollable
          Expanded(
            child: ListView(
              // padding: const EdgeInsets.all(),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 7),

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
                                    const Text(
                                      "CCP Dabou, ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        // letterSpacing: 1.2,
                                        // fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            String nomch = "CCP Dabou";
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChantierScreen(
                                                      nomChantier: nomch,
                                                    ),
                                              ),
                                            );
                                            // Navigator.pushNamed(
                                            //   context,
                                            //   AppRoutes.chantier,
                                            // );
                                          },
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.edit_square,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 25,
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
                                    const Text(
                                      "Chamako, ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        // letterSpacing: 1.2,
                                        // fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.edit_square,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 25,
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
                                    const Text(
                                      "CATE-ELEC VITIB, ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        // letterSpacing: 1.2,
                                        // fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.edit_square,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 25,
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
                                    const Text(
                                      "Abidjan ICA Treichville, ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        // letterSpacing: 1.2,
                                        // fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.edit_square,
                                            size: 25,
                                            color: Colors.green,
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          label: Icon(
                                            Icons.delete_forever,
                                            size: 25,
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
