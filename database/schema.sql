-- ============================================
-- HEALTH & FITNESS APP - DATABASE SCHEMA
-- Version: 1.0.0-MVP
-- Database: PostgreSQL 16+
-- ============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";
CREATE EXTENSION IF NOT EXISTS "pgvector";

-- ============================================
-- MÓDULO USUARIOS Y AUTENTICACIÓN
-- ============================================

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    date_of_birth DATE,
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    gender VARCHAR(20), -- 'male', 'female', 'other', 'prefer_not_to_say'
    fitness_goal VARCHAR(50), -- 'strength', 'hypertrophy', 'endurance', 'weight_loss', 'maintenance'
    experience_level VARCHAR(20), -- 'beginner', 'intermediate', 'advanced'
    preferred_language VARCHAR(5) DEFAULT 'en',
    timezone VARCHAR(50),
    subscription_tier VARCHAR(20) DEFAULT 'free', -- 'free', 'premium'
    subscription_ends_at TIMESTAMP,
    avatar_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    last_active_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE user_settings (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    notifications_enabled BOOLEAN DEFAULT true,
    workout_reminder_enabled BOOLEAN DEFAULT true,
    workout_reminder_time TIME DEFAULT '09:00:00',
    medication_reminder_enabled BOOLEAN DEFAULT true,
    weekly_goal_workouts INT DEFAULT 3,
    units_system VARCHAR(10) DEFAULT 'metric', -- 'metric', 'imperial'
    theme VARCHAR(20) DEFAULT 'system', -- 'light', 'dark', 'system'
    privacy_share_workouts BOOLEAN DEFAULT false,
    privacy_share_progress BOOLEAN DEFAULT false,
    privacy_show_in_leaderboard BOOLEAN DEFAULT true,
    notification_sound VARCHAR(50) DEFAULT 'default',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_oauth_connections (
    connection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL, -- 'google', 'apple', 'facebook'
    provider_user_id VARCHAR(255) NOT NULL,
    access_token TEXT,
    refresh_token TEXT,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(provider, provider_user_id)
);

-- ============================================
-- MÓDULO EJERCICIOS Y ENTRENAMIENTO
-- ============================================

CREATE TABLE exercises (
    exercise_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id VARCHAR(100), -- ExerciseDB ID
    name VARCHAR(255) NOT NULL,
    description TEXT,
    instructions TEXT[],
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    gif_url VARCHAR(500),
    equipment TEXT[], -- ['barbell', 'bench', 'none']
    body_parts TEXT[], -- ['chest', 'shoulders', 'triceps']
    target_muscles TEXT[], -- ['pectoralis-major', 'anterior-deltoid']
    secondary_muscles TEXT[],
    difficulty VARCHAR(20), -- 'beginner', 'intermediate', 'advanced'
    category VARCHAR(50), -- 'strength', 'cardio', 'flexibility', 'mobility'
    is_compound BOOLEAN DEFAULT false,
    is_unilateral BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workouts (
    workout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    workout_date TIMESTAMP NOT NULL,
    workout_type VARCHAR(50), -- 'strength', 'cardio', 'mixed', 'flexibility'
    template_id UUID, -- Reference to workout_templates
    duration_minutes INT,
    total_volume DECIMAL(10,2), -- kg * reps summed
    calories_burned INT,
    avg_heart_rate INT,
    max_heart_rate INT,
    notes TEXT,
    mood VARCHAR(20), -- 'great', 'good', 'ok', 'poor', 'exhausted'
    difficulty_rating INT CHECK (difficulty_rating BETWEEN 1 AND 10),
    completed BOOLEAN DEFAULT true,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workout_exercises (
    workout_exercise_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID REFERENCES workouts(workout_id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES exercises(exercise_id),
    exercise_order INT NOT NULL,
    sets_completed INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workout_sets (
    set_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_exercise_id UUID REFERENCES workout_exercises(workout_exercise_id) ON DELETE CASCADE,
    set_number INT NOT NULL,
    weight_kg DECIMAL(6,2),
    reps INT,
    reps_in_reserve INT CHECK (reps_in_reserve BETWEEN 0 AND 10), -- RIR: 0-10
    duration_seconds INT, -- For cardio/planks
    distance_meters DECIMAL(8,2), -- For running/rowing
    rest_seconds INT,
    completed BOOLEAN DEFAULT true,
    form_rating INT CHECK (form_rating BETWEEN 1 AND 5),
    volume DECIMAL(10,2) GENERATED ALWAYS AS (COALESCE(weight_kg, 0) * COALESCE(reps, 0)) STORED,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workout_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    difficulty VARCHAR(20),
    estimated_duration_minutes INT,
    exercises JSONB, -- Array of {exercise_id, sets, reps, rest, notes}
    is_public BOOLEAN DEFAULT false,
    times_used INT DEFAULT 0,
    avg_rating DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE exercise_personal_records (
    pr_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES exercises(exercise_id),
    record_type VARCHAR(50), -- '1rm', '3rm', '5rm', 'max_volume', 'max_reps'
    value DECIMAL(10,2),
    reps INT,
    workout_id UUID REFERENCES workouts(workout_id),
    achieved_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, exercise_id, record_type)
);

-- ============================================
-- MÓDULO MEDICAMENTOS Y SUPLEMENTOS
-- ============================================

CREATE TABLE medications (
    med_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50), -- 'prescription', 'supplement', 'vitamin', 'protein', 'other'
    dosage VARCHAR(100), -- '500mg', '2 scoops', '1 tablet'
    instructions TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    refill_date DATE,
    refill_quantity INT,
    refill_reminder_days INT DEFAULT 7,
    color_hex VARCHAR(7) DEFAULT '#3B82F6', -- For UI
    icon VARCHAR(50) DEFAULT 'pill', -- 'pill', 'capsule', 'liquid', 'powder', 'injection'
    notes TEXT,
    photo_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE medication_schedules (
    schedule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    med_id UUID REFERENCES medications(med_id) ON DELETE CASCADE,
    time TIME NOT NULL,
    frequency VARCHAR(50) NOT NULL, -- 'daily', 'weekly', 'every_x_days', 'as_needed'
    interval_days INT, -- For 'every_x_days'
    days_of_week INT[], -- [1,2,3,4,5] = Mon-Fri, NULL = all days
    meal_timing VARCHAR(50), -- 'before_meal', 'with_meal', 'after_meal', 'empty_stomach', 'anytime'
    water_reminder BOOLEAN DEFAULT false,
    enabled BOOLEAN DEFAULT true,
    notification_sound VARCHAR(50) DEFAULT 'default',
    snooze_duration_minutes INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE medication_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    med_id UUID REFERENCES medications(med_id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES medication_schedules(schedule_id),
    scheduled_time TIMESTAMP NOT NULL,
    taken_time TIMESTAMP,
    status VARCHAR(20) NOT NULL, -- 'taken', 'missed', 'skipped', 'snoozed'
    snooze_count INT DEFAULT 0,
    notes TEXT,
    photo_url VARCHAR(500), -- Optional: photo of med taken
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE drug_interactions (
    interaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    drug_a VARCHAR(255) NOT NULL,
    drug_b VARCHAR(255) NOT NULL,
    severity VARCHAR(20) NOT NULL, -- 'major', 'moderate', 'minor'
    description TEXT,
    source VARCHAR(255), -- 'FDA', 'DrugBank', 'RxList'
    source_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(drug_a, drug_b)
);

-- ============================================
-- MÓDULO HEALTH CONTENT
-- ============================================

CREATE TABLE health_articles (
    article_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(500) NOT NULL,
    summary TEXT,
    content TEXT,
    source VARCHAR(255), -- 'PubMed', 'NewsAPI', 'Manual'
    source_url VARCHAR(1000),
    author VARCHAR(255),
    published_date DATE,
    credibility_score INT CHECK (credibility_score BETWEEN 0 AND 100),
    category VARCHAR(50), -- 'nutrition', 'exercise', 'mental_health', 'supplements', 'research'
    tags TEXT[],
    image_url VARCHAR(500),
    read_time_minutes INT,
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE article_bookmarks (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    article_id UUID REFERENCES health_articles(article_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, article_id)
);

CREATE TABLE article_likes (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    article_id UUID REFERENCES health_articles(article_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, article_id)
);

-- ============================================
-- MÓDULO GAMIFICACIÓN
-- ============================================

CREATE TABLE user_stats (
    user_id UUID PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    total_workouts INT DEFAULT 0,
    total_volume_kg DECIMAL(12,2) DEFAULT 0,
    total_minutes INT DEFAULT 0,
    total_exercises INT DEFAULT 0,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_workout_date DATE,
    total_xp INT DEFAULT 0,
    level INT DEFAULT 1,
    medications_taken_count INT DEFAULT 0,
    medications_total_count INT DEFAULT 0,
    medications_adherence_rate DECIMAL(5,2) DEFAULT 0, -- Percentage
    articles_read INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE achievements (
    achievement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50), -- 'milestone', 'performance', 'consistency', 'social', 'medication'
    tier VARCHAR(20), -- 'bronze', 'silver', 'gold', 'platinum'
    icon_url VARCHAR(500),
    xp_reward INT DEFAULT 0,
    condition JSONB, -- {type: 'workout_count', value: 100}
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_achievements (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(achievement_id),
    unlocked_at TIMESTAMP DEFAULT NOW(),
    progress INT DEFAULT 100, -- Percentage complete
    PRIMARY KEY (user_id, achievement_id)
);

CREATE TABLE leaderboard_entries (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    metric VARCHAR(50) NOT NULL, -- 'total_volume', 'streak', 'xp', 'workouts'
    value DECIMAL(12,2) NOT NULL,
    week_start DATE NOT NULL,
    rank INT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, metric, week_start)
);

CREATE TABLE daily_quotes (
    quote_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    author VARCHAR(255),
    category VARCHAR(50), -- 'fitness', 'health', 'motivation', 'discipline'
    source VARCHAR(100), -- 'ZenQuotes', 'Manual'
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- MÓDULO SOCIAL
-- ============================================

CREATE TABLE friendships (
    friendship_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    friend_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'blocked'
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, friend_id),
    CHECK (user_id != friend_id)
);

CREATE TABLE workout_comments (
    comment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID REFERENCES workouts(workout_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE workout_likes (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    workout_id UUID REFERENCES workouts(workout_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (user_id, workout_id)
);

-- ============================================
-- AUDITORÍA Y SEGURIDAD
-- ============================================

CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL, -- 'DATA_EXPORT', 'ACCOUNT_DELETED', 'LOGIN', etc.
    resource_type VARCHAR(50),
    resource_id UUID,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- ÍNDICES CRÍTICOS PARA PERFORMANCE
-- ============================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription ON users(subscription_tier, subscription_ends_at);

-- Workouts
CREATE INDEX idx_workouts_user_date ON workouts(user_id, workout_date DESC);
CREATE INDEX idx_workouts_date ON workouts(workout_date DESC);
CREATE INDEX idx_workouts_public ON workouts(is_public, workout_date DESC) WHERE is_public = true;

-- Workout Sets
CREATE INDEX idx_workout_sets_workout_ex ON workout_sets(workout_exercise_id);
CREATE INDEX idx_workout_exercises_workout ON workout_exercises(workout_id);
CREATE INDEX idx_workout_exercises_exercise ON workout_exercises(exercise_id);

-- Exercises
CREATE INDEX idx_exercises_body_parts ON exercises USING GIN(body_parts);
CREATE INDEX idx_exercises_equipment ON exercises USING GIN(equipment);
CREATE INDEX idx_exercises_category ON exercises(category, difficulty);
CREATE INDEX idx_exercises_name ON exercises(name);

-- Medications
CREATE INDEX idx_medications_user ON medications(user_id) WHERE end_date IS NULL OR end_date >= CURRENT_DATE;
CREATE INDEX idx_medications_refill ON medications(refill_date) WHERE refill_date IS NOT NULL;
CREATE INDEX idx_med_schedules_med ON medication_schedules(med_id) WHERE enabled = true;
CREATE INDEX idx_med_logs_scheduled ON medication_logs(scheduled_time DESC);
CREATE INDEX idx_med_logs_user_status ON medication_logs(med_id, status, scheduled_time DESC);

-- Health Articles
CREATE INDEX idx_articles_published ON health_articles(published_date DESC, credibility_score DESC);
CREATE INDEX idx_articles_category ON health_articles(category, published_date DESC);
CREATE INDEX idx_articles_tags ON health_articles USING GIN(tags);

-- Gamification
CREATE INDEX idx_leaderboard_metric_week ON leaderboard_entries(metric, week_start, rank);
CREATE INDEX idx_user_achievements_user ON user_achievements(user_id, unlocked_at DESC);

-- Social
CREATE INDEX idx_friendships_user ON friendships(user_id, status);
CREATE INDEX idx_friendships_friend ON friendships(friend_id, status);
CREATE INDEX idx_workout_comments_workout ON workout_comments(workout_id, created_at DESC);

-- Audit
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at DESC);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE medication_logs ENABLE ROW LEVEL SECURITY;

-- Users can only view/edit their own profile
CREATE POLICY "Users manage own profile" ON users
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users manage own settings" ON user_settings
    FOR ALL USING (auth.uid() = user_id);

-- Workouts: Users view own or public workouts
CREATE POLICY "Users view own or public workouts" ON workouts
    FOR SELECT USING (
        auth.uid() = user_id
        OR is_public = true
        OR EXISTS(
            SELECT 1 FROM friendships
            WHERE friend_id = auth.uid()
            AND user_id = workouts.user_id
            AND status = 'accepted'
        )
    );

CREATE POLICY "Users insert own workouts" ON workouts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own workouts" ON workouts
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users delete own workouts" ON workouts
    FOR DELETE USING (auth.uid() = user_id);

-- Medications: Strictly private
CREATE POLICY "Users manage own medications" ON medications
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users manage own med schedules" ON medication_schedules
    FOR ALL USING (EXISTS(
        SELECT 1 FROM medications WHERE med_id = medication_schedules.med_id AND user_id = auth.uid()
    ));

CREATE POLICY "Users manage own med logs" ON medication_logs
    FOR ALL USING (EXISTS(
        SELECT 1 FROM medications WHERE med_id = medication_logs.med_id AND user_id = auth.uid()
    ));

-- ============================================
-- TRIGGERS
-- ============================================

-- Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workouts_updated_at BEFORE UPDATE ON workouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medications_updated_at BEFORE UPDATE ON medications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update user stats on workout
CREATE OR REPLACE FUNCTION update_user_stats_on_workout()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE user_stats
    SET
        total_workouts = total_workouts + 1,
        total_volume_kg = total_volume_kg + COALESCE(NEW.total_volume, 0),
        total_minutes = total_minutes + COALESCE(NEW.duration_minutes, 0),
        last_workout_date = NEW.workout_date::date,
        current_streak = CASE
            WHEN last_workout_date = (NEW.workout_date::date - INTERVAL '1 day')::date THEN current_streak + 1
            WHEN last_workout_date < NEW.workout_date::date THEN 1
            ELSE current_streak
        END,
        longest_streak = GREATEST(
            longest_streak,
            CASE
                WHEN last_workout_date = (NEW.workout_date::date - INTERVAL '1 day')::date THEN current_streak + 1
                WHEN last_workout_date < NEW.workout_date::date THEN 1
                ELSE current_streak
            END
        ),
        updated_at = NOW()
    WHERE user_id = NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_stats_on_workout
    AFTER INSERT ON workouts
    FOR EACH ROW
    WHEN (NEW.completed = true)
    EXECUTE FUNCTION update_user_stats_on_workout();

-- ============================================
-- VISTAS MATERIALIZADAS
-- ============================================

CREATE MATERIALIZED VIEW weekly_exercise_progress AS
SELECT
    u.user_id,
    e.exercise_id,
    DATE_TRUNC('week', w.workout_date) as week_start,
    SUM(ws.volume) as total_volume,
    MAX(ws.weight_kg) as max_weight,
    AVG(ws.reps) as avg_reps,
    COUNT(DISTINCT w.workout_id) as workout_count,
    AVG(ws.form_rating) as avg_form_rating
FROM users u
JOIN workouts w ON u.user_id = w.user_id
JOIN workout_exercises we ON w.workout_id = we.workout_id
JOIN exercises e ON we.exercise_id = e.exercise_id
JOIN workout_sets ws ON we.workout_exercise_id = ws.workout_exercise_id
WHERE w.completed = true
GROUP BY u.user_id, e.exercise_id, week_start;

CREATE UNIQUE INDEX idx_weekly_progress_unique ON weekly_exercise_progress(user_id, exercise_id, week_start);
CREATE INDEX idx_weekly_progress_lookup ON weekly_exercise_progress(user_id, week_start DESC);

-- Refresh schedule (every day at 2 AM)
SELECT cron.schedule(
    'refresh-weekly-progress',
    '0 2 * * *',
    'REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_exercise_progress'
);

-- ============================================
-- SEED DATA: Initial Achievements
-- ============================================

INSERT INTO achievements (code, name, description, category, tier, xp_reward, condition) VALUES
    ('first_workout', 'First Workout', 'Complete your first workout', 'milestone', 'bronze', 100, '{"type": "workout_count", "value": 1}'),
    ('week_warrior', 'Week Warrior', 'Complete 7 workouts in a week', 'consistency', 'silver', 500, '{"type": "workouts_per_week", "value": 7}'),
    ('hundred_club', 'Hundred Club', 'Complete 100 workouts', 'milestone', 'gold', 2000, '{"type": "workout_count", "value": 100}'),
    ('streak_7', '7-Day Streak', 'Workout for 7 consecutive days', 'consistency', 'bronze', 300, '{"type": "streak", "value": 7}'),
    ('streak_30', '30-Day Streak', 'Workout for 30 consecutive days', 'consistency', 'gold', 1500, '{"type": "streak", "value": 30}'),
    ('volume_king', 'Volume King', 'Lift 10,000 kg total volume', 'performance', 'silver', 800, '{"type": "total_volume", "value": 10000}'),
    ('med_adherent', 'Med Master', '95% medication adherence for 30 days', 'medication', 'gold', 1000, '{"type": "adherence_rate", "value": 95, "days": 30}'),
    ('social_butterfly', 'Social Butterfly', 'Make 10 friends', 'social', 'bronze', 200, '{"type": "friend_count", "value": 10}'),
    ('knowledge_seeker', 'Knowledge Seeker', 'Read 50 health articles', 'milestone', 'silver', 500, '{"type": "articles_read", "value": 50}')
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- FUNCIONES ÚTILES
-- ============================================

-- Calculate user's current level based on XP
CREATE OR REPLACE FUNCTION calculate_level(xp INT)
RETURNS INT AS $$
BEGIN
    -- Level formula: sqrt(XP / 100)
    RETURN GREATEST(1, FLOOR(SQRT(xp / 100.0))::INT);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Get medication adherence rate for user
CREATE OR REPLACE FUNCTION get_medication_adherence(p_user_id UUID, days INT DEFAULT 30)
RETURNS DECIMAL AS $$
DECLARE
    total_count INT;
    taken_count INT;
BEGIN
    SELECT COUNT(*) INTO total_count
    FROM medication_logs ml
    JOIN medications m ON ml.med_id = m.med_id
    WHERE m.user_id = p_user_id
    AND ml.scheduled_time >= NOW() - (days || ' days')::INTERVAL;

    SELECT COUNT(*) INTO taken_count
    FROM medication_logs ml
    JOIN medications m ON ml.med_id = m.med_id
    WHERE m.user_id = p_user_id
    AND ml.status = 'taken'
    AND ml.scheduled_time >= NOW() - (days || ' days')::INTERVAL;

    IF total_count = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND((taken_count::DECIMAL / total_count * 100), 2);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- GRANTS (Adjust based on your setup)
-- ============================================

-- Grant to authenticated users (Supabase default role)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ============================================
-- SCHEMA VERSION
-- ============================================

CREATE TABLE schema_version (
    version VARCHAR(20) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO schema_version (version) VALUES ('1.0.0-MVP');
