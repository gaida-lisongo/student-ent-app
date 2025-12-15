# Configuration CORS pour Next.js

## ⚠️ IMPORTANT: Les CORS n'existent que sur le Web!

Les CORS (Cross-Origin Resource Sharing) sont une restriction **du navigateur web**. Sur mobile (Android/iOS), il n'y a pas de CORS!

- **Flutter Mobile (Android/iOS)**: ✅ Pas de problème CORS
- **Flutter Web**: ❌ Peut avoir des problèmes CORS si la configuration serveur ne les autorise pas

## Configuration du serveur Next.js (api/etudiant/[id].ts)

### Option 1: Ajouter les headers CORS (Plus simple)

```typescript
// pages/api/etudiant/[id].ts
import { NextApiRequest, NextApiResponse } from "next";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  // Ajouter les headers CORS
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, OPTIONS"
  );
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  // Gérer les requêtes OPTIONS (preflight)
  if (req.method === "OPTIONS") {
    res.status(200).end();
    return;
  }

  // Votre logique métier ici
  const { id } = req.query;

  // ...votre code...

  res.status(200).json({
    success: true,
    data: {
      // ...vos données...
    },
  });
}
```

### Option 2: Utiliser next-cors (Plus robuste)

```bash
npm install next-cors
```

```typescript
// pages/api/etudiant/[id].ts
import { NextApiRequest, NextApiResponse } from "next";
import cors from "next-cors";

const handler = async (req: NextApiRequest, res: NextApiResponse) => {
  // Votre logique métier
  const { id } = req.query;

  res.status(200).json({
    success: true,
    data: {
      // ...vos données...
    },
  });
};

export default cors(handler, {
  allowedMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  origin: "*", // Ou spécifiez votre IP Flutter
});
```

### Option 3: Middleware global dans next.config.js

```javascript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: "/api/:path*",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
          {
            key: "Access-Control-Allow-Methods",
            value: "GET,POST,PUT,DELETE,OPTIONS",
          },
          {
            key: "Access-Control-Allow-Headers",
            value: "Content-Type,Authorization",
          },
        ],
      },
    ];
  },
};
```

## Configuration Flutter

L'URL de base est configurée dans [autth_provider.dart](lib/stores/autth_provider.dart):

```dart
static const String _baseURL = 'http://172.20.10.14:3000';
```

**⚠️ À adapter à votre adresse IP!**

### Vérifier l'URL de votre serveur:

```bash
# Sur votre machine hôte
ipconfig getifaddr en0  # macOS
ipconfig              # Windows
ip addr               # Linux
```

Remplacez `172.20.10.14` par votre adresse IP réelle.

## Tester la connexion

1. **Depuis Postman/Insomnia:**

```
GET http://votre-ip:3000/api/etudiant/6926d4e09c74cc9b8856a323
```

Doit retourner:

```json
{
  "success": true,
  "data": {
    "_id": "6926d4e09c74cc9b8856a323",
    "etudiantId": { ... },
    "promotionId": { ... },
    "anneeId": { ... },
    "statut": "En cours"
  }
}
```

2. **Depuis Flutter (appuyer sur le bouton SIMULATION AUTHENTIFICATION)**

Les logs vous montreront:

```
🚀 REQUEST: GET /api/etudiant/6926d4e09c74cc9b8856a323
✅ RESPONSE: 200 OK
✅ Authentification réussie: 6926d4e09c74cc9b8856a323
```

## Débogage

Si vous voyez des erreurs comme:

- `❌ ERROR: connectionError` → Vérifiez l'IP du serveur
- `❌ ERROR: receiveTimeout` → Le serveur est trop lent
- `❌ Erreur serveur 404` → L'endpoint n'existe pas

Vérifiez:

1. Le serveur Next.js tourne (`npm run dev`)
2. L'IP est correcte
3. Le port est correct (3000)
4. Les CORS sont configurés sur le serveur
