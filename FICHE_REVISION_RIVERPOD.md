# 📚 Fiche de Révision : Maîtriser Riverpod et le Débogage

Cette fiche résume les concepts clés abordés lors de la résolution du problème de synchronisation après login.

---

## 1. La Réactivité des Providers (`ref.watch`)

### Le Concept
Dans Riverpod, **l'injection de dépendance est réactive**. Si un Provider A a besoin des données actualisées d'un Provider B, il ne doit pas simplement les "lire" une fois, il doit les "surveiller".

### L'Erreur Classique
Lire une valeur au démarrage (`ref.read`) dans la méthode `build()`.
*   **Conséquence** : Le provider récupère la valeur initiale (ex: `null` si pas connecté) et ne se mettra **jamais** à jour, même si l'utilisateur se connecte 2 secondes plus tard.

### La Solution
Utiliser `ref.watch(provider)`.
*   **Effet** : Dès que le provider surveillé change (ex: `authProvider` passe de `null` à `token`), la méthode `build()` est **ré-exécutée** automatiquement.

```dart
// ❌ MAUVAIS : Ne se met pas à jour après le login
Future<User?> build() async {
  final token = ref.read(authProvider); // Lu une seule fois au lancement
  if (token == null) return null;
  return fetchUser();
}

// ✅ BON : Se recharge automatiquement quand l'auth change
Future<User?> build() async {
  final token = ref.watch(authProvider); // Réactive la méthode build si auth change
  if (token == null) return null;
  return fetchUser();
}
```

---

## 2. Le Piège du `late final` dans `build()`

### Le Concept
En Dart, `late final` signifie : "Je vais initialiser cette variable plus tard, mais **une seule fois**. Ensuite, elle est immuable."

### Le Conflit avec Riverpod
Comme vu plus haut, `ref.watch` force la méthode `build()` à se ré-exécuter plusieurs fois.
*   **Passage 1 (Démarrage)** : `build()` s'exécute -> `_dio` est initialisé.
*   **Passage 2 (Après login)** : `build()` s'exécute à nouveau -> Le code tente de ré-initialiser `_dio`.

### L'Erreur
Si `_dio` est déclaré `late final`, Dart lance une `LateInitializationError` car on essaie d'assigner une valeur à une constante déjà définie.

### La Solution
Retirer le mot-clé `final` si la variable est définie dans une méthode qui peut être rappelée (`build`, `update`, etc.).

```dart
class MonNotifier extends AsyncNotifier<Data> {
  // ❌ ERREUR : Crash au 2ème appel de build()
  late final Dio _dio; 
  
  // ✅ CORRECTION : Peut être réassigné sans erreur
  late Dio _dio;

  @override
  build() {
    _dio = ref.read(dioProvider); // Initialisation
  }
}
```

---

## 3. Méthodologie de Débogage

Quand on est bloqué, la déduction ne suffit pas. Il faut des preuves.

1.  **Tracer le flux (The Flow)** : Placer des `print` stratégiques pour voir l'ordre réel des événements.
    *   `[DEBUG] AuthChecker: Token reçu`
    *   `[DEBUG] EtudiantNotifier: build appelé`
2.  **Vérifier les hypothèses** :
    *   "Est-ce que le token est bien là ?" -> Loggez-le.
    *   "Est-ce que le provider se recharge ?" -> Loggez l'entrée dans `build`.
3.  **Isoler l'erreur** : Si le log s'arrête brutalement ou tourne en boucle, c'est là que se trouve le crash (comme notre boucle infinie sur `LateInitializationError`).

---

## 🎯 Quiz de Validation

Pour vérifier que tu as bien compris, essaie de répondre à ces questions (réponses en bas).

**Q1. Mon application nécessite un redémarrage pour afficher les données après le login. Quel est le problème probable ?**
A. La base de données est lente.
B. Les providers qui chargent les données n'écoutent pas (`watch`) l'état de l'authentification.
C. FlutterSecureStorage ne marche pas.

**Q2. Pourquoi `ref.read` est-il déconseillé dans la méthode `build` d'un provider ?**
A. Parce qu'il est plus lent.
B. Parce qu'il ne rend pas le provider réactif aux changements de ses dépendances.
C. Parce qu'il provoque des fuites de mémoire.

**Q3. J'ai une erreur `LateInitializationError: Field has already been initialized`. Quelle est la cause probable dans un Notifier Riverpod ?**
A. J'ai utilisé `late final` pour une variable qui est ré-assignée quand le provider se reconstruit.
B. Je n'ai pas initialisé la variable.
C. La variable est nulle.

---

### Réponses
*   **Q1** : **B**. C'est typique d'une dépendance manquante. Le provider de données est resté dans son état "Non connecté".
*   **Q2** : **B**. `ref.read` lit l'état à l'instant T. `ref.watch` s'abonne aux changements futurs.
*   **Q3** : **A**. La reconstruction du provider (suite à un `watch`) a relancé le code d'initialisation sur une variable qui refusait d'être modifiée (`final`).
