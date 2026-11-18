-- ==============================================================================
-- Module 01: Database Creation and Initialization
-- Project 38: E-Commerce Recommendation Engine Dataset Pipeline
-- Author: Senior Backend Developer & Database Architect
-- ==============================================================================

-- Create the database if it doesn't already exist with appropriate character set and collation
CREATE DATABASE IF NOT EXISTS recommendation_engine
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE recommendation_engine;

-- Verify database context
SELECT 
    DATABASE() AS current_database,
    @@character_set_database AS charset,
    @@collation_database AS collation;
