package com.attendance.utils;

import com.attendance.config.ConfigReader;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Utility class for logging
 * Provides both console and file logging capabilities
 */
public class LoggerUtils {
    private static final Logger logger = LogManager.getLogger(LoggerUtils.class);
    private static final String LOG_DIR = ConfigReader.getLogPath();
    private static FileWriter fileWriter;

    static {
        initializeFileLogger();
    }

    /**
     * Initialize file logger
     */
    private static void initializeFileLogger() {
        try {
            File logDir = new File(LOG_DIR);
            if (!logDir.exists()) {
                logDir.mkdirs();
            }

            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String logFile = LOG_DIR + File.separator + "test_execution_" + timestamp + ".log";
            fileWriter = new FileWriter(logFile, true);
        } catch (IOException e) {
            System.err.println("Failed to initialize file logger: " + e.getMessage());
        }
    }

    /**
     * Log info message
     * @param message Message to log
     */
    public static void info(String message) {
        logger.info(message);
        writeToFile("INFO", message);
    }

    /**
     * Log error message
     * @param message Message to log
     */
    public static void error(String message) {
        logger.error(message);
        writeToFile("ERROR", message);
    }

    /**
     * Log warning message
     * @param message Message to log
     */
    public static void warn(String message) {
        logger.warn(message);
        writeToFile("WARN", message);
    }

    /**
     * Log debug message
     * @param message Message to log
     */
    public static void debug(String message) {
        logger.debug(message);
        writeToFile("DEBUG", message);
    }

    /**
     * Write log to file
     * @param level Log level
     * @param message Message to log
     */
    private static void writeToFile(String level, String message) {
        if (fileWriter != null) {
            try {
                String timestamp = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
                fileWriter.write(String.format("[%s] [%s] %s%n", timestamp, level, message));
                fileWriter.flush();
            } catch (IOException e) {
                System.err.println("Failed to write to log file: " + e.getMessage());
            }
        }
    }

    /**
     * Close file logger
     */
    public static void closeLogger() {
        if (fileWriter != null) {
            try {
                fileWriter.close();
            } catch (IOException e) {
                System.err.println("Failed to close file logger: " + e.getMessage());
            }
        }
    }
}

