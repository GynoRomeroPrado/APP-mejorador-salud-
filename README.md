# Health & Fitness App with Medication Reminders

A comprehensive mobile health application combining workout tracking, medication reminders, health news, and AI-powered recommendations.

## Project Overview

**Market Size**: $16.6B (2024) → $88B (2032), CAGR 15.4%
**Target Users**: Fitness enthusiasts, chronic patients, adults 25-55 years
**Platform**: Cross-platform (iOS, Android, Web via Flutter)

## Features

### Phase 1: MVP (Months 1-3)
- ✅ User authentication (Email/Password + OAuth Google/Apple)
- ✅ Exercise library (1,000+ exercises with GIFs from ExerciseDB)
- ✅ Workout tracking (sets, reps, weight, timer)
- ✅ Medication reminders (smart alarms, calendar, adherence tracking)
- ✅ Gamification (streaks, badges, achievements)
- ✅ Daily motivational quotes
- ✅ GDPR compliance (Privacy Policy, ToS)

### Phase 2: Growth (Months 4-6)
- MediaPipe pose detection (auto rep counting)
- ML workout recommendations (XGBoost)
- Health news feed (NewsAPI + PubMed)
- Drug interaction checker
- Social features (friends, challenges, leaderboards)
- Freemium model ($9.99/month)

### Phase 3: Scale (Months 7-12)
- AR workout guidance
- Wearable integrations (Apple Watch, Fitbit)
- Advanced ML (injury prediction, auto-periodization)
- Nutrition tracking + meal planning
- Live video classes
- Marketplace (coaches, premium plans)

## Tech Stack

### Frontend
- **Framework**: Flutter 3.19+
- **State Management**: Riverpod 2.4+
- **Local Database**: Hive/Isar (offline-first)
- **Notifications**: flutter_local_notifications
- **ML**: TensorFlow Lite, MediaPipe

### Backend
- **API**: Node.js 20+ with NestJS 10+
- **Real-time**: Socket.IO
- **ML Service**: Python 3.11+ with FastAPI 0.109+
- **ML Libraries**: scikit-learn, XGBoost, MediaPipe 0.10+

### Database & Cloud
- **Primary DB**: PostgreSQL 16+ via Supabase
- **Cache**: Upstash Redis (serverless)
- **Storage**: CloudFlare R2 / Supabase Storage
- **Hosting MVP**: Railway ($5/mo) + Supabase ($25/mo)
- **CDN**: CloudFlare (free tier)

### DevOps
- **CI/CD**: GitHub Actions
- **Monitoring**: Sentry (errors), Mixpanel (analytics)
- **Version Control**: Git + GitHub

## Project Structure

```
health-app/
├── mobile/                    # Flutter mobile app
│   ├── lib/
│   │   ├── core/             # Core utilities, constants
│   │   ├── features/         # Feature modules
│   │   │   ├── auth/
│   │   │   ├── workouts/
│   │   │   ├── medications/
│   │   │   ├── gamification/
│   │   │   └── profile/
│   │   ├── shared/           # Shared widgets, services
│   │   └── main.dart
│   ├── test/
│   └── pubspec.yaml
│
├── backend/                   # NestJS API server
│   ├── src/
│   │   ├── auth/
│   │   ├── users/
│   │   ├── workouts/
│   │   ├── medications/
│   │   ├── exercises/
│   │   ├── gamification/
│   │   └── main.ts
│   ├── test/
│   └── package.json
│
├── ml-service/               # Python FastAPI ML service
│   ├── app/
│   │   ├── models/           # ML models
│   │   ├── routers/          # API routes
│   │   ├── services/         # Business logic
│   │   └── main.py
│   ├── tests/
│   └── requirements.txt
│
├── database/                 # Database schemas & migrations
│   ├── migrations/
│   ├── seeds/
│   └── schema.sql
│
├── docs/                     # Documentation
│   ├── api/                  # API documentation
│   ├── architecture/         # Architecture diagrams
│   └── compliance/           # Privacy policy, ToS
│
└── infrastructure/           # Deployment configs
    ├── docker/
    ├── kubernetes/
    └── terraform/
```

## Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Node.js 20+
- Python 3.11+
- PostgreSQL 16+
- Redis
- Supabase account
- RapidAPI account (for ExerciseDB)

### Installation

#### 1. Clone Repository
```bash
git clone https://github.com/GynoRomeroPrado/APP-mejorador-salud-.git
cd APP-mejorador-salud-
```

#### 2. Setup Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

#### 3. Setup Backend
```bash
cd backend
npm install
npm run start:dev
```

#### 4. Setup ML Service
```bash
cd ml-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

#### 5. Setup Database
```bash
# Run in Supabase SQL editor or locally
psql -U postgres -d health_app -f database/schema.sql
```

### Environment Variables

Create `.env` files in each service directory:

**Backend (.env)**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/health_app
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
RAPIDAPI_KEY=your-rapidapi-key
NEWSAPI_KEY=your-newsapi-key
PUBMED_API_KEY=your-pubmed-key
```

**Mobile (.env)**
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:3000
ML_SERVICE_URL=http://localhost:8000
```

**ML Service (.env)**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/health_app
MODEL_PATH=./models
```

## API Documentation

API documentation is available at:
- Backend: http://localhost:3000/api/docs (Swagger)
- ML Service: http://localhost:8000/docs (FastAPI auto-docs)

## Testing

```bash
# Mobile
cd mobile && flutter test

# Backend
cd backend && npm test

# ML Service
cd ml-service && pytest
```

## Deployment

### MVP Deployment (Railway + Supabase)

1. **Database**: Deploy PostgreSQL on Supabase
2. **Backend**: Deploy NestJS on Railway
3. **ML Service**: Deploy FastAPI on Railway
4. **Mobile**: Build and deploy to TestFlight/Play Console

See [deployment guide](docs/deployment.md) for details.

## Security & Compliance

- **Encryption**: AES-256-GCM for sensitive data at rest
- **Transport**: TLS 1.3 for all API communication
- **GDPR**: Full compliance with data export, deletion, portability
- **HIPAA**: Medication data encryption and audit logs
- **Authentication**: OAuth 2.0, JWT tokens with refresh

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## Support

- Email: support@healthapp.com
- Documentation: https://docs.healthapp.com
- Issues: https://github.com/GynoRomeroPrado/APP-mejorador-salud-/issues

## Roadmap

See [ROADMAP.md](ROADMAP.md) for detailed development timeline.

## Acknowledgments

- ExerciseDB for exercise data
- PubMed for medical research
- NewsAPI for health news
- ZenQuotes for motivational content
- Supabase for backend infrastructure

---

**Version**: 1.0.0-MVP
**Last Updated**: November 2024
**Status**: Active Development
