import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/character_model.dart';
import '../models/episode_model.dart';
import '../models/location_model.dart';

enum ContentType { characters, episodes, locations }

class AppProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  ContentType currentType = ContentType.characters;
  bool isLoading = false;
  String? errorMessage;
  List<Character> characters = [];
  List<Episode> episodes = [];
  List<LocationModel> locations = [];
  int currentPage = 1;
  bool hasNextPage = true;
  Map<int, Character> cachedCharacters = {};
  Map<int, Episode> cachedEpisodes = {};
  Map<int, LocationModel> cachedLocations = {};
  String _searchQuery = '';
  String? _statusFilter;
  String? _speciesFilter;
  String? _genderFilter;
  String? _locationTypeFilter;
  String? _locationDimensionFilter;
  String? _episodeCodeFilter;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get speciesFilter => _speciesFilter;
  String? get genderFilter => _genderFilter;
  String? get locationTypeFilter => _locationTypeFilter;
  String? get locationDimensionFilter => _locationDimensionFilter;
  String? get episodeCodeFilter => _episodeCodeFilter;

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _resetAndReload();
  }

  void setStatusFilter(String? status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    _resetAndReload();
  }

  void setSpeciesFilter(String? species) {
    if (_speciesFilter == species) return;
    _speciesFilter = species;
    _resetAndReload();
  }

  void setGenderFilter(String? gender) {
    if (_genderFilter == gender) return;
    _genderFilter = gender;
    _resetAndReload();
  }

  void setLocationTypeFilter(String? type) {
    if (_locationTypeFilter == type) return;
    _locationTypeFilter = type;
    _resetAndReload();
  }

  void setLocationDimensionFilter(String? dimension) {
    if (_locationDimensionFilter == dimension) return;
    _locationDimensionFilter = dimension;
    _resetAndReload();
  }

  void setEpisodeCodeFilter(String? code) {
    if (_episodeCodeFilter == code) return;
    _episodeCodeFilter = code;
    _resetAndReload();
  }

  void _resetAndReload() {
    currentPage = 1;
    hasNextPage = true;
    characters.clear();
    episodes.clear();
    locations.clear();
    errorMessage = null;
    notifyListeners();
    loadContent();
  }

  void switchContentType(ContentType type) {
    if (currentType != type) {
      currentType = type;
      _searchQuery = '';

      _statusFilter = null;
      _speciesFilter = null;
      _genderFilter = null;
      _locationTypeFilter = null;
      _locationDimensionFilter = null;
      _episodeCodeFilter = null;

      _resetAndReload();
    }
  }

  Future<void> loadContent() async {
    if (isLoading || !hasNextPage) {
      return;
    }

    isLoading = true;

    if (currentPage > 1) {
      errorMessage = null;
      notifyListeners();
    }

    try {
      Map<String, dynamic> result;

      if (currentType == ContentType.characters) {
        result = await apiService.fetchCharacters(
          currentPage,
          query: _searchQuery,
          status: _statusFilter,
          species: _speciesFilter,
          gender: _genderFilter,
        );
        final List<Character> newCharacters = result['items'];
        characters.addAll(newCharacters);

        for (var character in newCharacters) {
          cachedCharacters[character.id] = character;
        }
      } else if (currentType == ContentType.episodes) {
        result = await apiService.fetchEpisodes(
          currentPage,
          query: _searchQuery,
          episode: _episodeCodeFilter,
        );
        final List<Episode> newEpisodes = result['items'];
        episodes.addAll(newEpisodes);

        for (var episode in newEpisodes) {
          cachedEpisodes[episode.id] = episode;
        }
      } else {
        result = await apiService.fetchLocations(
          currentPage,
          query: _searchQuery,
          type: _locationTypeFilter,
          dimension: _locationDimensionFilter,
        );
        final List<LocationModel> newLocations = result['items'];
        locations.addAll(newLocations);

        for (var location in newLocations) {
          cachedLocations[location.id] = location;
        }
      }

      hasNextPage = result['hasNextPage'];
      currentPage++;
    } catch (e) {
      errorMessage = 'Erro ao carregar dados: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Character> getCharacterById(int id) async {
    if (cachedCharacters.containsKey(id)) {
      return cachedCharacters[id]!;
    }

    final character = await apiService.fetchCharacterById(id);
    cachedCharacters[id] = character;
    return character;
  }

  Future<Episode> getEpisodeById(int id) async {
    if (cachedEpisodes.containsKey(id)) {
      return cachedEpisodes[id]!;
    }

    final episode = await apiService.fetchEpisodeById(id);
    cachedEpisodes[id] = episode;
    return episode;
  }

  Future<LocationModel> getLocationById(int id) async {
    if (cachedLocations.containsKey(id)) {
      return cachedLocations[id]!;
    }

    final location = await apiService.fetchLocationById(id);
    cachedLocations[id] = location;
    return location;
  }
}
