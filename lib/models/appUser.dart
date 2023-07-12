import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppUser {
  final String? uid;
  final String email;
  final String username;
  final String imagerUrl;

  AppUser(
      {this.uid,
      required this.email,
      required this.username,
      required this.imagerUrl});

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      imagerUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'username': username,
        'imageUrl': imagerUrl,
      };

  factory AppUser.init() {
    return AppUser(email: '', username: '', imagerUrl: '');
  }
}

// The StateNotifier class that will be passed to our StateNotifierProvider.
// This class should not expose state outside of its "state" property, which means
// no public getters/properties!
// The public methods on this class will be what allow the UI to modify the state.
class AppUserNotifier extends StateNotifier<AppUser> {
  // We initialize the list of todos to an empty list
  AppUserNotifier() : super(AppUser.init());

  // Let's allow the UI to add todos.
  void modify(AppUser user) {
    // Since our state is immutable, we are not allowed to do `state.add(todo)`.
    // Instead, we should create a new list of todos which contains the previous
    // items and the new one.
    // Using Dart's spread operator here is helpful!
    state = user;
    // No need to call "notifyListeners" or anything similar. Calling "state ="
    // will automatically rebuild the UI when necessary.
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our TodosNotifier class.
final appUserProvider = StateNotifierProvider<AppUserNotifier, AppUser>((ref) {
  return AppUserNotifier();
});
