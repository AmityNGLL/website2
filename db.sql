-- Ensure the extension is created only if not exists
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Theatre table with trigram index
CREATE TABLE IF NOT EXISTS theatre (
    index SERIAL,
    id TEXT PRIMARY KEY NOT NULL UNIQUE,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    type TEXT NOT NULL,
    src TEXT NOT NULL,
    plays INTEGER NOT NULL,
    controls TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS trgm_idx ON theatre USING GIST (name gist_trgm_ops);

-- Compatibility table
CREATE TABLE IF NOT EXISTS compat (
    host TEXT PRIMARY KEY NOT NULL UNIQUE,
    proxy TEXT NOT NULL
);

-- TIERS
-- 0 - poor
-- 1 - $3/month official supporter
-- 2 - $10/month ultimate supporter

CREATE TABLE IF NOT EXISTS users (
	id SERIAL PRIMARY KEY,
	email TEXT NOT NULL UNIQUE,
	email_verified BOOLEAN DEFAULT false,
	email_verification_code TEXT,
	password_hash TEXT NOT NULL,
	admin BOOLEAN DEFAULT false,
	signup_timestamp TIMESTAMP DEFAULT NOW(),
	signup_ip TEXT NOT NULL,
    new_email TEXT, -- for changing ur email
    new_email_verification_secret TEXT,
    password_verification_secret TEXT, -- for changing ur password
    stripe_customer TEXT -- set when their email is verified
);

-- log of a user's emails
-- contains information about sender, destination
CREATE TABLE IF NOT EXISTS email (
	id SERIAL PRIMARY KEY,
    send_time TIMESTAMP DEFAULT NOW(),
    email TEXT NOT NULL,
    ip TEXT NOT NULL,
    user_id SERIAL NOT NULL, 
	FOREIGN KEY (user_id) REFERENCES users(id)
);

-- these are added to the table when stripe fires our webhook
-- and these are checked to make sure ur not p00r
CREATE TABLE IF NOT EXISTS payment (
    -- invoice id 
	id TEXT PRIMARY KEY,
    -- user_email TEXT NOT NULL,
    user_id SERIAL NOT NULL, -- user might change their email
    -- set based on the event product id
	tier INT NOT NULL,
    -- how long this is valid for
    period_start TIMESTAMP NOT NULL,
    period_end TIMESTAMP NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS session (
	secret TEXT PRIMARY KEY NOT NULL UNIQUE,
	created TIMESTAMP DEFAULT NOW(),
	ip TEXT NOT NULL,
	user_id INT NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

-- bans can be made by admins

CREATE TABLE IF NOT EXISTS ban (
    id SERIAL PRIMARY KEY,
    created TIMESTAMP DEFAULT NOW(),
    expires TIMESTAMP,
    reason TEXT,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS ipban (
    id SERIAL PRIMARY KEY,
    created TIMESTAMP DEFAULT NOW(), 
    expires TIMESTAMP,
    reason TEXT,
    ip TEXT NOT NULL UNIQUE,
    user_id INT, -- can optionally also ban a user
    FOREIGN KEY (user_id) REFERENCES users(id)
);