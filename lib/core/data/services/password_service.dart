import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

abstract class PasswordService {
  Future<String> hashPassword(String password);
  Future<bool> verifyPassword(String password, String hash);
}

class SecurePasswordService implements PasswordService {
  static const int _saltLength = 32;
  static const int _iterations = 10000;
  static const String _algorithm = 'sha256';

  @override
  Future<String> hashPassword(String password) async {
    final random = Random.secure();
    final saltBytes = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      saltBytes[i] = random.nextInt(256);
    }
    final salt = base64Encode(saltBytes);
    
    List<int> hash = utf8.encode(password + salt);
    
    for (int i = 0; i < _iterations; i++) {
      hash = sha256.convert(hash).bytes;
    }
    
    final finalHash = sha256.convert(hash).toString();
    
    return '$_algorithm:$_iterations:$salt:$finalHash';
  }

  @override
  Future<bool> verifyPassword(String password, String hash) async {
    try {
      final parts = hash.split(':');
      if (parts.length != 4) return false;
      
      final algorithm = parts[0];
      final iterations = int.tryParse(parts[1]);
      final salt = parts[2];
      final storedHash = parts[3];
      
      if (algorithm != _algorithm || iterations == null) return false;
      
      List<int> hashBytes = utf8.encode(password + salt);
      
      for (int i = 0; i < iterations; i++) {
        hashBytes = sha256.convert(hashBytes).bytes;
      }
      
      final computedHash = sha256.convert(hashBytes).toString();
      
      return computedHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> getSecurityInfo() {
    return {
      'algorithm': _algorithm,
      'iterations': _iterations,
      'saltLength': _saltLength,
      'description': 'Enhanced SHA-256 with PBKDF2-like key stretching',
      'securityLevel': 'High',
    };
  }
}
