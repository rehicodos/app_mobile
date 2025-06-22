import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: SearchScreenProjetBar(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class SearchScreenProjetBar extends StatefulWidget {
  const SearchScreenProjetBar({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreenProjetBar> {
  final TextEditingController _controller = TextEditingController();

  // Liste de données à rechercher
  List<String> allItems = [
    'Banane',
    'Mangue',
    'Orange',
    'Pomme',
    'Ananas',
    'Avocat',
    'Raisin',
    'Papaye',
    'Citron',
    'Melon',
  ];

  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems; // Afficher tout au début
  }

  void _performSearch(String query) {
    setState(() {
      filteredItems = allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Liste des projets",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // fontStyle: FontStyle.italic, // Texte en italique
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[600]),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      border: InputBorder.none,
                    ),
                    onChanged: _performSearch,
                    onSubmitted: _performSearch,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _performSearch(_controller.text);
                  },
                  child: Icon(Icons.arrow_forward, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: filteredItems.isEmpty
              ? Center(child: Text("Aucun résultat"))
              : ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(filteredItems[index]));
                  },
                ),
        ),
      ],
    );
  }
}
