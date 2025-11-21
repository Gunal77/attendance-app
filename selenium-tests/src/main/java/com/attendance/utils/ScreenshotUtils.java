package com.attendance.utils;

import com.attendance.config.ConfigReader;
import org.apache.commons.io.FileUtils;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebDriver;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Utility class for taking screenshots
 * Automatically saves screenshots on test failures
 */
public class ScreenshotUtils {
    private static final String SCREENSHOT_DIR = ConfigReader.getScreenshotPath();

    /**
     * Take screenshot and save with timestamp
     * @param driver WebDriver instance
     * @param screenshotName Name of the screenshot
     * @return File path of saved screenshot
     */
    public static String takeScreenshot(WebDriver driver, String screenshotName) {
        try {
            // Create screenshot directory if it doesn't exist
            File screenshotDir = new File(SCREENSHOT_DIR);
            if (!screenshotDir.exists()) {
                screenshotDir.mkdirs();
            }

            // Generate timestamp
            String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
            String fileName = screenshotName + "_" + timestamp + ".png";
            String filePath = SCREENSHOT_DIR + File.separator + fileName;

            // Take screenshot
            TakesScreenshot takesScreenshot = (TakesScreenshot) driver;
            File sourceFile = takesScreenshot.getScreenshotAs(OutputType.FILE);
            File destinationFile = new File(filePath);
            FileUtils.copyFile(sourceFile, destinationFile);

            LoggerUtils.info("Screenshot saved: " + filePath);
            return filePath;
        } catch (IOException e) {
            LoggerUtils.error("Failed to take screenshot: " + e.getMessage());
            return null;
        }
    }

    /**
     * Take screenshot with default name
     * @param driver WebDriver instance
     * @return File path of saved screenshot
     */
    public static String takeScreenshot(WebDriver driver) {
        return takeScreenshot(driver, "screenshot");
    }

    /**
     * Take screenshot on test failure
     * @param driver WebDriver instance
     * @param testName Test method name
     * @return File path of saved screenshot
     */
    public static String takeScreenshotOnFailure(WebDriver driver, String testName) {
        return takeScreenshot(driver, "FAILED_" + testName);
    }
}

