class HelpController {
  void call() {
    final String helpMessage = """

Usage: arch <command> [arguments]
Available commands:
  --help        Print this help message
  --version     Print the current version
  --create      Create a new project or module
  --update      Update the project or module
  --delete      Delete the project or module
  --generate    Generate a new file

  project       Create a new project
  module        Create a new module
  file          Generate a new file
  
  """;
    print(helpMessage);
  }
}
