#!/bin/bash
set -e

echo "Running custom PostgreSQL initialization script..."

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE lss_test;
    CREATE USER root WITH PASSWORD '$POSTGRES_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE lss_test TO root;
EOSQL

echo "Custom PostgreSQL initialization script completed."