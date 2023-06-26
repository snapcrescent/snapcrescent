package com.snapcrescent.config;

public class EnvironmentProperties {

    public static String SQL_URL = System.getenv("SQL_URL");
    public static String SQL_USER = System.getenv("SQL_USER");
    public static String SQL_PASSWORD = System.getenv("SQL_PASSWORD");
    
    
    public static String STORAGE_PATH = System.getenv("STORAGE_PATH") == null? "/media/" : System.getenv("STORAGE_PATH");
    
    public static String FFMPEG_PATH = System.getenv("FFMPEG_PATH") == null? "/usr/bin/" : System.getenv("FFMPEG_PATH");
    
    public static String ADMIN_PASSWORD = System.getenv("ADMIN_PASSWORD");
    

}