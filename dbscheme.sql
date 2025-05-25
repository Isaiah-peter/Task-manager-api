-- 1. Create the database
CREATE DATABASE todomanager;

-- 2. Connect to the database
\c todomanager;

-- 3. Create the tasks table
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    due DATE NOT NULL,
    priority TEXT NOT NULL CHECK (priority IN ('high', 'medium', 'low')),
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Done'))
);

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password TEXT NOT NULL  -- store hashed password ideally
);
