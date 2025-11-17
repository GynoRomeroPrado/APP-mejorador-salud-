import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MedicationsModule } from './medications/medications.module';
import { ExercisesModule } from './exercises/exercises.module';
import { WorkoutsModule } from './workouts/workouts.module';
import { HealthArticlesModule } from './health-articles/health-articles.module';
import { GamificationModule } from './gamification/gamification.module';
import { SupabaseModule } from './common/supabase/supabase.module';

@Module({
  imports: [
    // Configuración
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        ttl: parseInt(process.env.THROTTLE_TTL || '60000'),
        limit: parseInt(process.env.THROTTLE_LIMIT || '100'),
      },
    ]),

    // Módulos de base de datos
    SupabaseModule,

    // Módulos de funcionalidad
    AuthModule,
    UsersModule,
    MedicationsModule,
    ExercisesModule,
    WorkoutsModule,
    HealthArticlesModule,
    GamificationModule,
  ],
})
export class AppModule {}
