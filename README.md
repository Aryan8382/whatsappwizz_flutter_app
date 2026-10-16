# WhatsApp Wiz — Flutter App

Full-stack WhatsApp Business Platform built with Flutter (frontend) + NestJS (backend) + MySQL (database via Prisma ORM).

---

## 🚀 Quick Start Commands

### 1. Start Backend
```powershell
cd "D:\WABA ANDROID APP\working-project2\waba-work-updated googledrive\waba-work-updated\backend"
npm run start:dev
```
Backend runs at: **http://localhost:4000**
Swagger docs at: **http://localhost:4000/api/docs**

### 2. Start Flutter App (Chrome)
```powershell
cd "d:\WABA ANDROID APP\whatsapp_wiz"
flutter run -d chrome --web-port 8080
```
App opens at: **http://localhost:8080**

### 3. Build Android APK
```powershell
cd "d:\WABA ANDROID APP\whatsapp_wiz"
flutter build apk --release --flavor prod -t lib/main.dart
```
APK output: `build/app/outputs/flutter-apk/app-prod-release.apk`

### 4. Fresh Start (clean + run)
```powershell
cd "d:\WABA ANDROID APP\whatsapp_wiz"
flutter clean
flutter pub get
flutter run -d chrome --web-port 8080
```

---

## 🏗️ Project Architecture

```
WABA ANDROID APP/
├── whatsapp_wiz/                  ← Flutter App
│   └── lib/
│       ├── core/
│       │   ├── constants/
│       │   │   └── app_constants.dart     ← API URL config
│       │   ├── services/
│       │   │   ├── api_service.dart        ← Central HTTP client (Dio)
│       │   │   ├── api_repositories.dart   ← Barrel exports
│       │   │   └── repositories/          ← One repo per backend module
│       │   └── theme/                     ← Colors, typography, icons
│       ├── features/
│       │   ├── auth/                      ← Login, JWT token storage
│       │   ├── dashboard/                 ← Stats overview
│       │   ├── contacts/                  ← Contacts, segments, tags
│       │   ├── campaigns/                 ← Broadcast campaigns
│       │   ├── templates/                 ← WhatsApp message templates
│       │   ├── chatbot/                   ← Bot flow builder
│       │   ├── automation/                ← Event-driven workflows
│       │   ├── inbox/                     ← Live conversation inbox
│       │   ├── flows/                     ← WhatsApp native flows
│       │   ├── custom_fields/             ← Contact custom attributes
│       │   ├── dnd/                       ← Do Not Disturb list
│       │   ├── media/                     ← Media asset library
│       │   ├── wallet/                    ← Billing & transactions
│       │   ├── settings/                  ← Org, WABA, API keys, webhooks
│       │   ├── users/                     ← Team management
│       │   └── navigation/                ← Router, scaffold, bottom nav
│       └── shared/
│           └── widgets/                   ← Reusable UI components
│
└── working-project2/
    └── waba-work-updated/
        ├── backend/                       ← NestJS API Server
        │   ├── src/
        │   │   ├── auth/                  ← JWT authentication
        │   │   ├── contacts/              ← Contacts CRUD
        │   │   ├── campaigns/             ← Campaigns management
        │   │   ├── templates/             ← WhatsApp templates
        │   │   ├── chatbots/              ← Bot flows
        │   │   ├── automation/            ← Automation workflows
        │   │   ├── conversations/         ← Inbox conversations
        │   │   ├── messages/              ← Message sending
        │   │   ├── flows/                 ← WhatsApp flows
        │   │   ├── wallet/                ← Wallet & billing
        │   │   ├── users/                 ← User management
        │   │   ├── segments/              ← Audience segments
        │   │   ├── reports/               ← Analytics reports
        │   │   ├── webhooks/              ← Webhook management
        │   │   ├── waba/                  ← WABA account setup
        │   │   ├── upload/                ← File uploads
        │   │   └── media/                 ← Media library
        │   ├── prisma/
        │   │   └── schema.prisma          ← Database schema
        │   └── .env                       ← Environment variables
        └── frontend/                      ← Original Next.js web app (reference)
```

---

## 🔌 API Connection

### URL Configuration
File: `lib/core/constants/app_constants.dart`

The app uses the **live ngrok URL** from the website backend `.env`:
```
BACKEND_URL = https://penalize-opt-reflex.ngrok-free.app
```

| Platform | URL Used |
|----------|----------|
| Flutter Web (Chrome) | `https://penalize-opt-reflex.ngrok-free.app/api/v1` |
| Android Emulator | `https://penalize-opt-reflex.ngrok-free.app/api/v1` |
| Physical Android Device | Same ngrok URL (works over internet) |

> If ngrok URL changes, update `productionBackendUrl` in `app_constants.dart`

### How API Calls Work

```
Flutter Screen
     ↓
Riverpod Provider  (e.g. contactsRepositoryProvider)
     ↓
API Repository     (e.g. ContactsApiRepository)
     ↓
ApiService (Dio)   → adds Bearer token automatically
     ↓
NestJS Backend     → http://localhost:4000/api/v1
     ↓
Prisma ORM
     ↓
MySQL Database     → u709643491_whatsapp_wiz
```

### Auth Flow
1. User enters email + password on login screen
2. `POST /api/v1/auth/login` → returns `{ accessToken, refreshToken, user }`
3. Tokens saved in `flutter_secure_storage` (encrypted)
4. Every request → Dio interceptor attaches `Authorization: Bearer <token>`
5. On 401 → session cleared → redirected to login

---

## 📡 Complete API Reference

All endpoints match the original website (`working-project2`) exactly. No backend changes were made.

### Auth — `/api/v1/auth`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/login` | Login with email + password |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Logout + invalidate token |
| GET | `/auth/me` | Get current user profile |
| POST | `/auth/change-password` | Change password |

### Contacts — `/api/v1/contacts`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/contacts` | List all contacts (search, tag filter) |
| POST | `/contacts` | Create contact |
| PUT | `/contacts/:id` | Update contact |
| DELETE | `/contacts/:id` | Delete contact |
| POST | `/contacts/import` | Import CSV file |
| GET | `/contacts/export` | Export contacts as CSV |
| GET | `/contacts/tags` | List all tags |
| POST | `/contacts/tags` | Create tag |
| DELETE | `/contacts/tags/:id` | Delete tag |

### Segments — `/api/v1/segments`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/segments` | List all segments |
| POST | `/segments/preview` | Preview segment contact count |
| POST | `/segments` | Create segment |
| PUT | `/segments/:id` | Update segment |
| DELETE | `/segments/:id` | Delete segment |

### Templates — `/api/v1/templates`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/templates` | List all templates |
| POST | `/templates` | Create template |
| PUT | `/templates/:id` | Update template |
| POST | `/templates/:id/submit` | Submit to Meta for approval |
| POST | `/templates/sync` | Sync from Meta |
| DELETE | `/templates/:id` | Delete template |

### Campaigns — `/api/v1/campaigns`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/campaigns` | List all campaigns |
| POST | `/campaigns` | Create campaign |
| POST | `/campaigns/:id/start` | Start campaign |
| POST | `/campaigns/:id/pause` | Pause campaign |
| POST | `/campaigns/:id/resume` | Resume campaign |
| GET | `/campaigns/:id/analytics` | Campaign analytics |
| DELETE | `/campaigns/:id` | Delete campaign |

### Chatbot — `/api/v1/bots`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/bots` | List all bot flows |
| POST | `/bots` | Create bot flow |
| PUT | `/bots/:id` | Update bot flow |
| POST | `/bots/:id/nodes` | Add node |
| POST | `/bots/:id/publish` | Publish bot |
| POST | `/bots/:id/unpublish` | Unpublish bot |
| DELETE | `/bots/:id` | Delete bot |

### Automation — `/api/v1/automation`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/automation` | List workflows |
| POST | `/automation` | Create workflow |
| PUT | `/automation/:id` | Update workflow |
| POST | `/automation/:id/activate` | Activate workflow |
| POST | `/automation/:id/pause` | Pause workflow |
| DELETE | `/automation/:id` | Delete workflow |

### Conversations / Inbox — `/api/v1/conversations`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/conversations` | List conversations |
| GET | `/conversations/:id` | Get single conversation |
| POST | `/conversations/:id/assign` | Assign to agent |
| POST | `/conversations/:id/status` | Update status (open/resolved/closed) |
| POST | `/conversations/:id/notes` | Add internal note |
| POST | `/conversations/:id/labels` | Add label |

### Messages — `/api/v1/messages`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/messages/send` | Send text message |
| POST | `/messages/template` | Send template message |
| POST | `/messages/media` | Send media message |
| GET | `/messages/conversation/:id` | Get conversation messages |
| POST | `/messages/:id/retry` | Retry failed message |

### Wallet — `/api/v1/wallet`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/wallet` | Get wallet balance |
| POST | `/wallet/recharge` | Add credits |
| GET | `/wallet/transactions` | Transaction history |
| GET | `/wallet/invoices` | Invoice list |

### Users — `/api/v1/users`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users` | List team members |
| POST | `/users` | Create user |
| PUT | `/users/:id` | Update user |
| DELETE | `/users/:id` | Delete user |

### Settings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST/PUT | `/organizations` | Org settings |
| GET/POST | `/apikeys` | API key management |
| GET/POST/PUT | `/webhooks` | Webhook management |
| GET | `/waba/status` | WABA account status |
| GET | `/waba/numbers` | WhatsApp numbers |

### Reports — `/api/v1/reports`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/reports/dashboard` | Dashboard stats |
| GET | `/reports/messages` | Message analytics |
| GET | `/reports/campaigns` | Campaign analytics |
| GET | `/reports/agents` | Agent performance |

---

## 🗄️ Database

**Engine:** MySQL (hosted on Hostinger)
**ORM:** Prisma v6
**Connection:** Set in backend `.env`

```env
DATABASE_URL="mysql://user:pass@host:3306/whatsapp_wiz"
```

### Key Tables
| Table | Purpose |
|-------|---------|
| `users` | Team members & auth |
| `organizations` | Multi-tenant orgs |
| `contacts` | WhatsApp subscribers |
| `tags` | Contact labels |
| `segments` | Audience groups |
| `templates` | Message templates |
| `campaigns` | Broadcast campaigns |
| `conversations` | Inbox chats |
| `messages` | Individual messages |
| `bot_flows` | Chatbot definitions |
| `automation_workflows` | Event rules |
| `wallets` | Credit balance |
| `wallet_transactions` | Payment records |
| `whatsapp_flows` | Native WA flows |
| `waba_accounts` | WABA connections |
| `whatsapp_numbers` | Phone numbers |
| `api_keys` | Developer keys |
| `webhooks` | Webhook configs |
| `custom_fields` | Contact attributes |
| `dnd_entries` | Blocked numbers |
| `media` | Uploaded files |

---

## 🔑 Demo Login Credentials

| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@whatsappwiz.io | Admin@123 |
| Org Admin | admin@demo.com | Admin@123 |
| Supervisor | supervisor@demo.com | Supervisor@123 |
| Agent | agent@demo.com | Agent@123 |
| Reseller | reseller@demo.com | Reseller@123 |

---

## 📦 Flutter Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation/routing |
| `dio` | HTTP client (API calls) |
| `flutter_secure_storage` | Encrypted token storage |
| `socket_io_client` | Real-time WebSocket |
| `fl_chart` | Charts & analytics graphs |
| `file_picker` | CSV import file picker |
| `cached_network_image` | Image caching |
| `intl` | Date/number formatting |

---

## ⚙️ Backend Environment Variables

File: `backend/.env`

```env
PORT=4000
DATABASE_URL="mysql://..."
JWT_ACCESS_SECRET="..."
JWT_REFRESH_SECRET="..."
JWT_EXPIRES_IN="8h"
FRONTEND_URL="http://localhost:3001"
BACKEND_URL="https://your-ngrok-or-domain.app"
MESSENGER_API_BASE_URL="https://graph.facebook.com/v25.0"
MESSENGER_API_KEY="EAABsb..."
MESSENGER_WABA_ID="..."
MESSENGER_PHONE_NUMBER_ID="..."
META_WEBHOOK_VERIFY_TOKEN="..."
META_APP_SECRET="..."
```

---

## 🛠️ Troubleshooting

### Backend won't start — "prisma generate" error
```powershell
cd backend
npx prisma generate
npm run start:dev
```

### Flutter web CORS error
- Make sure backend is running on port 4000
- Backend CORS is configured to allow `http://localhost:8080`
- Flutter web automatically uses `http://localhost:4000`

### Android emulator can't connect
- Use `http://10.0.2.2:4000` (already configured)
- Make sure backend is running on your host machine

### Physical Android device can't connect
Change in `lib/core/constants/app_constants.dart`:
```dart
static String get apiHost {
  if (kIsWeb) return 'http://localhost:4000';
  return 'http://192.168.1.YOUR_IP:4000'; // ← your LAN IP
}
```

### Port already in use
```powershell
# Kill port 4000
$p = Get-NetTCPConnection -LocalPort 4000 -ErrorAction SilentlyContinue | Select -ExpandProperty OwningProcess
if ($p) { Stop-Process -Id $p -Force }

# Kill port 8080
$p = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select -ExpandProperty OwningProcess
if ($p) { Stop-Process -Id $p -Force }
```
