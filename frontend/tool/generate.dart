import 'dart:io';

Future<void> runCommand(String executable, List<String> arguments) async {
  final label = '$executable ${arguments.join(' ')}';
  print('▶  $label\n');

  final result = await Process.run(
    executable,
    arguments,
    runInShell: true,
  );

  if (result.stdout.toString().isNotEmpty) {
    print(result.stdout);
  }

  if (result.stderr.toString().isNotEmpty) {
    stderr.writeln(result.stderr);
  }

  print('exit code: ${result.exitCode}\n');

  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
}

void main() async {
  await runCommand('dart', ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  await runCommand('dart', ['run', 'flutter_launcher_icons']);
}
