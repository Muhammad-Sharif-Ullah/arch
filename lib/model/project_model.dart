// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProjectModel {
  final String projectName;
  final String projectDescription;
  final String authorName;
  final String selectionOfFlavor;
  final List<String> customFlavor;
  final String designPattern;
  final String androidPackageName;
  final String iosPackageName;
  final List<String> platforms;
  final String license;
  final String apiClient;

  ProjectModel({
    required this.projectName,
    required this.projectDescription,
    required this.authorName,
    required this.selectionOfFlavor,
    required this.customFlavor,
    required this.designPattern,
    required this.androidPackageName,
    required this.iosPackageName,
    required this.platforms,
    required this.license,
    required this.apiClient,
  });

  @override
  String toString() {
    return 'ProjectModel{projectName: $projectName, projectDescription: $projectDescription, authorName: $authorName, selectionOfFlavor: $selectionOfFlavor, customFlavor: $customFlavor, designPattern: $designPattern, androidPackageName: $androidPackageName, iosPackageName: $iosPackageName, platforms: $platforms, license: $license, apiClient: $apiClient}';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'projectName': projectName,
      'projectDescription': projectDescription,
      'authorName': authorName,
      'selectionOfFlavor': selectionOfFlavor,
      'customFlavor': customFlavor,
      'designPattern': designPattern,
      'androidPackageName': androidPackageName,
      'iosPackageName': iosPackageName,
      'platforms': platforms,
      'license': license,
      'apiClient': apiClient,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      projectName: map['projectName'] as String,
      projectDescription: map['projectDescription'] as String,
      authorName: map['authorName'] as String,
      selectionOfFlavor: map['selectionOfFlavor'] as String,
      customFlavor: List<String>.from((map['customFlavor'] as List<String>)),
      designPattern: map['designPattern'] as String,
      androidPackageName: map['androidPackageName'] as String,
      iosPackageName: map['iosPackageName'] as String,
      platforms: List<String>.from((map['platforms'] as List<String>)),
      license: map['license'] as String,
      apiClient: map['apiClient'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectModel.fromJson(String source) =>
      ProjectModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
