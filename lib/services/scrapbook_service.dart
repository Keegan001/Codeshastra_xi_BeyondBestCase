import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safar/core/constants.dart';
import 'package:safar/models/scrapbook_entry.dart';
import 'package:safar/models/itinerary.dart';
import 'package:safar/services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class ScrapbookService {
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  static const uuid = Uuid();
  
  // Get scrapbook entries for a specific itinerary
  Future<List<ScrapbookEntry>> getEntriesForItinerary(String itineraryId) async {
    try {
      // Get all entries from storage
      final allEntriesMap = await _getAllEntriesMap();
      
      // Filter by itinerary ID
      if (allEntriesMap.containsKey(itineraryId)) {
        final entriesList = List<Map<String, dynamic>>.from(allEntriesMap[itineraryId]);
        final entries = entriesList.map((json) => ScrapbookEntry.fromJson(json)).toList();
        
        // Sort by timestamp (newest first)
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return entries;
      }
      
      return [];
    } catch (e) {
      print('Error getting scrapbook entries: $e');
      return [];
    }
  }
  
  // Add a new scrapbook entry
  Future<ScrapbookEntry?> addEntry({
    required String itineraryId,
    required String title,
    required String content,
    required ScrapbookEntryType type,
    required DateTime timestamp,
    double? latitude,
    double? longitude,
    XFile? mediaFile,
  }) async {
    try {
      // Generate a unique ID for the entry
      final entryId = uuid.v4();
      
      // Save media file locally if provided
      String? mediaPath;
      if (mediaFile != null) {
        mediaPath = await _saveMediaFile(mediaFile, entryId);
      }
      
      // Create the scrapbook entry
      final entry = ScrapbookEntry(
        id: entryId,
        title: title,
        content: content,
        type: type,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        mediaUrl: mediaPath,
      );
      
      // Save to local storage
      await _saveEntryToStorage(itineraryId, entry);
      
      return entry;
    } catch (e) {
      print('Error adding scrapbook entry: $e');
      return null;
    }
  }
  
  // Update an existing scrapbook entry
  Future<bool> updateEntry({
    required String itineraryId,
    required ScrapbookEntry updatedEntry,
    XFile? newMediaFile,
  }) async {
    try {
      // Get all entries from storage
      final allEntriesMap = await _getAllEntriesMap();
      
      if (!allEntriesMap.containsKey(itineraryId)) {
        return false;
      }
      
      final entriesList = List<Map<String, dynamic>>.from(allEntriesMap[itineraryId]);
      final entryIndex = entriesList.indexWhere((json) => json['id'] == updatedEntry.id);
      
      if (entryIndex == -1) {
        return false;
      }
      
      // Handle media file update
      String? mediaPath = updatedEntry.mediaUrl;
      if (newMediaFile != null) {
        // Delete old media file if exists
        if (mediaPath != null && mediaPath.startsWith('file://')) {
          final oldFile = File(mediaPath.replaceFirst('file://', ''));
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        }
        
        // Save new media file
        mediaPath = await _saveMediaFile(newMediaFile, updatedEntry.id);
      }
      
      // Get existing entry to preserve properties that might not be set in updatedEntry
      final existingEntryJson = entriesList[entryIndex];
      final existingEntry = ScrapbookEntry.fromJson(existingEntryJson);
      
      // Create updated entry with new media path, preserving existing properties if not explicitly updated
      final finalUpdatedEntry = existingEntry.copyWith(
        id: updatedEntry.id,
        title: updatedEntry.title,
        content: updatedEntry.content,
        type: updatedEntry.type,
        timestamp: updatedEntry.timestamp,
        latitude: updatedEntry.latitude,
        longitude: updatedEntry.longitude,
        mediaUrl: mediaPath ?? updatedEntry.mediaUrl,
        backgroundStyle: updatedEntry.backgroundStyle,
        layoutStyle: updatedEntry.layoutStyle,
        zoomLevel: updatedEntry.zoomLevel,
        backgroundColor: updatedEntry.backgroundColor,
      );
      
      // Update the entry in the list
      entriesList[entryIndex] = finalUpdatedEntry.toJson();
      
      // Save back to storage
      allEntriesMap[itineraryId] = entriesList;
      await _storageService.setString(
        StorageKeys.scrapbookEntries, 
        jsonEncode(allEntriesMap)
      );
      
      return true;
    } catch (e) {
      print('Error updating scrapbook entry: $e');
      return false;
    }
  }
  
  // Delete a scrapbook entry
  Future<bool> deleteEntry(String itineraryId, String entryId) async {
    try {
      // Get all entries from storage
      final allEntriesMap = await _getAllEntriesMap();
      
      if (!allEntriesMap.containsKey(itineraryId)) {
        return false;
      }
      
      final entriesList = List<Map<String, dynamic>>.from(allEntriesMap[itineraryId]);
      final entryToDelete = entriesList.firstWhere((json) => json['id'] == entryId, orElse: () => {});
      
      if (entryToDelete.isEmpty) {
        return false;
      }
      
      // Delete media file if it exists
      if (entryToDelete['mediaUrl'] != null && entryToDelete['mediaUrl'].toString().startsWith('file://')) {
        final mediaFile = File(entryToDelete['mediaUrl'].toString().replaceFirst('file://', ''));
        if (await mediaFile.exists()) {
          await mediaFile.delete();
        }
      }
      
      // Delete multiple media files for collages
      if (entryToDelete['mediaUrls'] != null) {
        final mediaUrls = List<String>.from(entryToDelete['mediaUrls']);
        for (final url in mediaUrls) {
          if (url.startsWith('file://')) {
            final mediaFile = File(url.replaceFirst('file://', ''));
            if (await mediaFile.exists()) {
              await mediaFile.delete();
            }
          }
        }
      }
      
      // Remove entry from list
      entriesList.removeWhere((json) => json['id'] == entryId);
      
      // Save back to storage
      allEntriesMap[itineraryId] = entriesList;
      await _storageService.setString(
        StorageKeys.scrapbookEntries, 
        jsonEncode(allEntriesMap)
      );
      
      return true;
    } catch (e) {
      print('Error deleting scrapbook entry: $e');
      return false;
    }
  }
  
  // Pick an image from gallery
  Future<XFile?> pickImage() async {
    try {
      return await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
  
  // Pick a video from gallery
  Future<XFile?> pickVideo() async {
    try {
      return await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }
  
  // Record audio (this is a stub - in a real app, would use a proper audio recording package)
  Future<XFile?> recordAudio() async {
    // In a real app, this would use an audio recording package
    // For now, we'll return null
    return null;
  }
  
  // Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      return await _imagePicker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
  
  // Add a new collage entry
  Future<ScrapbookEntry?> addCollageEntry({
    required String itineraryId,
    required String title,
    required String content,
    required DateTime timestamp,
    required List<XFile> mediaFiles,
    required CollageLayout collageLayout,
    double? latitude,
    double? longitude,
    BackgroundStyle backgroundStyle = BackgroundStyle.none,
    Color? backgroundColor,
  }) async {
    try {
      // Generate a unique ID for the entry
      final entryId = uuid.v4();
      
      // Save all media files locally
      final List<String> mediaPaths = await _saveMultipleMediaFiles(mediaFiles, entryId);
      
      if (mediaPaths.isEmpty) {
        return null;
      }
      
      // Create the scrapbook entry
      final entry = ScrapbookEntry(
        id: entryId,
        title: title,
        content: content,
        type: ScrapbookEntryType.collage,
        timestamp: timestamp,
        latitude: latitude,
        longitude: longitude,
        mediaUrls: mediaPaths,
        backgroundStyle: backgroundStyle,
        layoutStyle: LayoutStyle.collage,
        backgroundColor: backgroundColor,
        collageLayout: collageLayout,
      );
      
      // Save to local storage
      await _saveEntryToStorage(itineraryId, entry);
      
      return entry;
    } catch (e) {
      print('Error adding collage entry: $e');
      return null;
    }
  }
  
  // Save multiple media files locally and return the paths
  Future<List<String>> _saveMultipleMediaFiles(List<XFile> files, String entryId) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      
      // Create a directory for scrapbook media if it doesn't exist
      final Directory scrapbookDir = Directory('$appDocPath/scrapbook');
      if (!await scrapbookDir.exists()) {
        await scrapbookDir.create(recursive: true);
      }
      
      final List<String> mediaPaths = [];
      
      // Save each file
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        
        // Generate a unique filename
        final extension = path.extension(file.path);
        final fileName = '${entryId}_${i+1}$extension';
        final localFilePath = '${scrapbookDir.path}/$fileName';
        
        // Copy the file to the local path
        final File newFile = File(localFilePath);
        await newFile.writeAsBytes(await file.readAsBytes());
        
        // Add the file URL to the list
        mediaPaths.add('file://$localFilePath');
      }
      
      return mediaPaths;
    } catch (e) {
      print('Error saving media files: $e');
      return [];
    }
  }
  
  // Private helper methods
  
  // Get all entries as a map of itineraryId -> List of entry JSONs
  Future<Map<String, dynamic>> _getAllEntriesMap() async {
    final entriesJson = await _storageService.getString(StorageKeys.scrapbookEntries);
    if (entriesJson == null || entriesJson.isEmpty) {
      return {};
    }
    
    try {
      return jsonDecode(entriesJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
  
  // Save entry to local storage
  Future<void> _saveEntryToStorage(String itineraryId, ScrapbookEntry entry) async {
    // Get all existing entries
    final allEntriesMap = await _getAllEntriesMap();
    
    // Add new entry to the list for this itinerary
    if (!allEntriesMap.containsKey(itineraryId)) {
      allEntriesMap[itineraryId] = [];
    }
    
    final entriesList = List<dynamic>.from(allEntriesMap[itineraryId]);
    entriesList.add(entry.toJson());
    allEntriesMap[itineraryId] = entriesList;
    
    // Save back to storage
    await _storageService.setString(
      StorageKeys.scrapbookEntries, 
      jsonEncode(allEntriesMap)
    );
  }
  
  // Save a media file locally and return the path
  Future<String> _saveMediaFile(XFile file, String entryId) async {
    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      
      // Create a directory for scrapbook media if it doesn't exist
      final Directory scrapbookDir = Directory('$appDocPath/scrapbook');
      if (!await scrapbookDir.exists()) {
        await scrapbookDir.create(recursive: true);
      }
      
      // Generate a unique filename
      final extension = path.extension(file.path);
      final fileName = '$entryId$extension';
      final localFilePath = '${scrapbookDir.path}/$fileName';
      
      // Copy the file to the local path
      final File newFile = File(localFilePath);
      await newFile.writeAsBytes(await file.readAsBytes());
      
      // Return the file URL with file:// scheme
      return 'file://$localFilePath';
    } catch (e) {
      print('Error saving media file: $e');
      rethrow;
    }
  }
  
  // Get all scrapbook entries (for all itineraries)
  Future<List<ScrapbookEntry>> getAllEntries() async {
    try {
      final allEntriesMap = await _getAllEntriesMap();
      final allEntries = <ScrapbookEntry>[];
      
      allEntriesMap.forEach((itineraryId, entriesList) {
        final entries = List<Map<String, dynamic>>.from(entriesList)
          .map((json) => ScrapbookEntry.fromJson(json))
          .toList();
        allEntries.addAll(entries);
      });
      
      // Sort by timestamp (newest first)
      allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allEntries;
    } catch (e) {
      print('Error getting all scrapbook entries: $e');
      return [];
    }
  }
} 