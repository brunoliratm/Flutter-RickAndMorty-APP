import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../models/location_model.dart';

class ApiService {
  static const String _authority = 'rickandmortyapi.com';
  static const String _apiPath = '/api';

  Future<Map<String, dynamic>> fetchCharacters(
    int page, {
    String query = '',
    String? status,
    String? species,
    String? gender,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (query.isNotEmpty) {
      queryParams['name'] = query;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (species != null && species.isNotEmpty) queryParams['species'] = species;
    if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;

    final uri = Uri.https(_authority, '$_apiPath/character', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Character> characters = [];

      for (var item in data['results']) {
        characters.add(Character.fromJson(item));
      }

      return {'items': characters, 'hasNextPage': data['info']['next'] != null};
    } else if (response.statusCode == 404) {
      return {'items': <Character>[], 'hasNextPage': false};
    } else {
      throw Exception(
        'Falha ao carregar personagens (Status: ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> fetchEpisodes(
    int page, {
    String query = '',
    String? episode,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (query.isNotEmpty) {
      queryParams['name'] = query;
    }
    if (episode != null && episode.isNotEmpty) queryParams['episode'] = episode;

    final uri = Uri.https(_authority, '$_apiPath/episode', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Episode> episodes = [];

      for (var item in data['results']) {
        episodes.add(Episode.fromJson(item));
      }

      return {'items': episodes, 'hasNextPage': data['info']['next'] != null};
    } else if (response.statusCode == 404) {
      return {'items': <Episode>[], 'hasNextPage': false};
    } else {
      throw Exception(
        'Falha ao carregar episódios (Status: ${response.statusCode})',
      );
    }
  }

  Future<Map<String, dynamic>> fetchLocations(
    int page, {
    String query = '',
    String? type,
    String? dimension,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (query.isNotEmpty) {
      queryParams['name'] = query;
    }
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (dimension != null && dimension.isNotEmpty) {
      queryParams['dimension'] = dimension;
  }
    final uri = Uri.https(_authority, '$_apiPath/location', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<LocationModel> locations = [];

      for (var item in data['results']) {
        locations.add(LocationModel.fromJson(item));
      }

      return {'items': locations, 'hasNextPage': data['info']['next'] != null};
    } else if (response.statusCode == 404) {
      return {'items': <LocationModel>[], 'hasNextPage': false};
    } else {
      throw Exception(
        'Falha ao carregar locais (Status: ${response.statusCode})',
      );
    }
  }

  Future<Character> fetchCharacterById(int id) async {
    final uri = Uri.https(_authority, '$_apiPath/character/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Character.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Falha ao carregar personagem (Status: ${response.statusCode})',
      );
    }
  }

  Future<Episode> fetchEpisodeById(int id) async {
    final uri = Uri.https(_authority, '$_apiPath/episode/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Episode.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Falha ao carregar episódio (Status: ${response.statusCode})',
      );
    }
  }

  Future<LocationModel> fetchLocationById(int id) async {
    final uri = Uri.https(_authority, '$_apiPath/location/$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return LocationModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Falha ao carregar local (Status: ${response.statusCode})',
      );
    }
  }

  int extractIdFromUrl(String url) {
    final parts = url.split('/');
    return int.parse(parts.last);
  }
}
