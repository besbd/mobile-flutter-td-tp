import 'dart:convert';
import 'package:http/http.dart' as http;

class Produit {
  final int id;
  final String nom;
  final double prix;
  final int stock;
  final String categorie;

  Produit({
    required this.id,
    required this.nom,
    required this.prix,
    required this.stock,
    required this.categorie,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      nom: json['nom'],
      prix: json['prix'].toDouble(),
      stock: json['stock'],
      categorie: json['categorie'],
    );
  }
}

class Commande {
  final int id;
  final List<ProduitCommande> produits;
  final double total;
  final String date;

  Commande({
    required this.id,
    required this.produits,
    required this.total,
    required this.date,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      produits: List<ProduitCommande>.from(
          json['produits'].map((x) => ProduitCommande.fromJson(x))),
      total: json['total'].toDouble(),
      date: json['date'],
    );
  }
}

class ProduitCommande {
  final int id;
  final int quantite;

  ProduitCommande({
    required this.id,
    required this.quantite,
  });

  factory ProduitCommande.fromJson(Map<String, dynamic> json) {
    return ProduitCommande(
      id: json['id'],
      quantite: json['quantite'],
    );
  }
}

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<Produit>> getProduits() async {
    final response = await http.get(Uri.parse('$baseUrl/produits'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Produit.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load produits');
    }
  }

  static Future<Commande> createCommande(List<ProduitCommande> produits) async {
    final response = await http.post(
      Uri.parse('$baseUrl/commandes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'produits': produits}),
    );
    if (response.statusCode == 201) {
      return Commande.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create commande');
    }
  }
}

void main() async {
  try {
    // 1. Récupérer les produits
    final produits = await ApiClient.getProduits();
    print('Produits disponibles:');
    produits.forEach((p) => print('${p.id}. ${p.nom} - ${p.prix}DH'));

    // 2. Créer une commande
    final nouvelleCommande = await ApiClient.createCommande([
      ProduitCommande(id: 1, quantite: 2),
      ProduitCommande(id: 2, quantite: 1),
    ]);
    print('\nCommande créée: #${nouvelleCommande.id}');
    print('Total: ${nouvelleCommande.total}DH');
    print('Date: ${nouvelleCommande.date}');
  } catch (e) {
    print('Erreur: $e');
  }
}