-- ============================================================
-- BLUEFARM — SUPABASE DATABASE SCHEMA
-- Run this in your Supabase SQL Editor
-- ============================================================

-- ── Enable UUID extension ──────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── 1. PROFILES ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id               UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name        TEXT,
  farm_name        TEXT,
  farm_location    TEXT,
  pond_size        TEXT,
  water_body_type  TEXT,
  fish_species     TEXT,
  avatar_url       TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ── 2. SENSOR READINGS ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS sensor_readings (
  id               BIGSERIAL      PRIMARY KEY,
  created_at       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
  farm_id          UUID,                        -- v2: references farms(id)
  ph               FLOAT          NOT NULL DEFAULT 7.0,
  temperature      FLOAT          NOT NULL DEFAULT 28.0,
  turbidity        FLOAT          NOT NULL DEFAULT 2.5,
  dissolved_oxygen FLOAT                   DEFAULT 6.5,
  ammonia          FLOAT                   DEFAULT 0.15,
  water_level      FLOAT                   DEFAULT 90.0
);

-- Indexes for fast queries
CREATE INDEX IF NOT EXISTS idx_sr_created ON sensor_readings (created_at DESC);

-- Row Level Security
ALTER TABLE sensor_readings ENABLE ROW LEVEL SECURITY;

-- Public read (any authenticated user can read readings)
CREATE POLICY "Authenticated users can read sensor readings"
  ON sensor_readings FOR SELECT
  TO authenticated
  USING (true);

-- Anon key can INSERT (for Raspberry Pi / Arduino)
CREATE POLICY "Anon can insert sensor readings"
  ON sensor_readings FOR INSERT
  TO anon
  WITH CHECK (true);

-- Enable Realtime on sensor_readings
ALTER PUBLICATION supabase_realtime ADD TABLE sensor_readings;

-- ── 3. ALERTS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS alerts (
  id           BIGSERIAL      PRIMARY KEY,
  created_at   TIMESTAMPTZ    DEFAULT NOW(),
  user_id      UUID           REFERENCES auth.users(id),
  parameter    TEXT           NOT NULL,
  value        FLOAT          NOT NULL,
  status       TEXT           NOT NULL CHECK (status IN ('WARNING', 'DANGER')),
  acknowledged BOOLEAN        DEFAULT FALSE
);

ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own alerts"
  ON alerts FOR SELECT
  USING (auth.uid() = user_id);

-- ── 4. RELAY COMMANDS ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS relay_commands (
  id         BIGSERIAL    PRIMARY KEY,
  created_at TIMESTAMPTZ  DEFAULT NOW(),
  relay_id   TEXT         NOT NULL CHECK (relay_id IN ('pump', 'filter', 'aerator', 'extra')),
  state      BOOLEAN      NOT NULL,
  source     TEXT         DEFAULT 'manual' CHECK (source IN ('auto', 'manual')),
  executed   BOOLEAN      DEFAULT FALSE
);

ALTER TABLE relay_commands ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can insert relay commands (from app)
CREATE POLICY "Authenticated users can insert relay commands"
  ON relay_commands FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Any authenticated user can read relay commands (from app UI)
CREATE POLICY "Authenticated users can read relay commands"
  ON relay_commands FOR SELECT
  TO authenticated
  USING (true);

-- Anon key can SELECT relay commands (for hardware device polling)
CREATE POLICY "Anon can read relay commands"
  ON relay_commands FOR SELECT
  TO anon
  USING (true);

-- Anon can UPDATE relay commands (mark as executed)
CREATE POLICY "Anon can update relay commands"
  ON relay_commands FOR UPDATE
  TO anon
  USING (true)
  WITH CHECK (true);

-- ── 5. AUTO-CREATE PROFILE ON SIGNUP ──────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── 6. USEFUL VIEWS ────────────────────────────────────────
-- Latest reading view
CREATE OR REPLACE VIEW latest_sensor_reading AS
SELECT * FROM sensor_readings
ORDER BY created_at DESC
LIMIT 1;

-- Hourly averages for trend charts
CREATE OR REPLACE VIEW hourly_sensor_averages AS
SELECT
  DATE_TRUNC('hour', created_at) AS hour,
  ROUND(AVG(ph)::NUMERIC, 2)               AS avg_ph,
  ROUND(AVG(temperature)::NUMERIC, 2)      AS avg_temperature,
  ROUND(AVG(turbidity)::NUMERIC, 2)        AS avg_turbidity,
  ROUND(AVG(dissolved_oxygen)::NUMERIC, 2) AS avg_dissolved_oxygen,
  ROUND(AVG(ammonia)::NUMERIC, 3)          AS avg_ammonia,
  ROUND(AVG(water_level)::NUMERIC, 1)      AS avg_water_level,
  COUNT(*) AS reading_count
FROM sensor_readings
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY hour
ORDER BY hour DESC;

-- ── DONE ──────────────────────────────────────────────────
-- To verify setup, run:
-- SELECT COUNT(*) FROM sensor_readings;
-- INSERT INTO sensor_readings (ph, temperature, turbidity) VALUES (7.2, 28.5, 2.8);
