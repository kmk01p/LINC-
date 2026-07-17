-- Creates the app_user_profiles table used for extended signup metadata.
CREATE TABLE IF NOT EXISTS app_user_profiles (
    user_id UUID PRIMARY KEY REFERENCES app_users (id) ON DELETE CASCADE,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL,
    phone_number VARCHAR(40) NOT NULL,
    birth_date DATE NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_app_user_profiles_email ON app_user_profiles (LOWER(email));
CREATE UNIQUE INDEX IF NOT EXISTS uq_app_user_profiles_phone ON app_user_profiles (phone_number);
