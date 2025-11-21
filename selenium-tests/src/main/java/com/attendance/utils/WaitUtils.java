package com.attendance.utils;

import com.attendance.config.ConfigReader;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

/**
 * Utility class for explicit waits
 * Provides reusable wait methods for common scenarios
 */
public class WaitUtils {
    private static WebDriverWait getWait(WebDriver driver) {
        return new WebDriverWait(driver, Duration.ofSeconds(ConfigReader.getExplicitWait()));
    }

    /**
     * Wait for element to be visible
     * @param driver WebDriver instance
     * @param locator Element locator
     * @return WebElement
     */
    public static WebElement waitForElementVisible(WebDriver driver, By locator) {
        return getWait(driver).until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    /**
     * Wait for element to be clickable
     * @param driver WebDriver instance
     * @param locator Element locator
     * @return WebElement
     */
    public static WebElement waitForElementClickable(WebDriver driver, By locator) {
        return getWait(driver).until(ExpectedConditions.elementToBeClickable(locator));
    }

    /**
     * Wait for element to be present in DOM
     * @param driver WebDriver instance
     * @param locator Element locator
     * @return WebElement
     */
    public static WebElement waitForElementPresent(WebDriver driver, By locator) {
        return getWait(driver).until(ExpectedConditions.presenceOfElementLocated(locator));
    }

    /**
     * Wait for element to be invisible
     * @param driver WebDriver instance
     * @param locator Element locator
     * @return boolean
     */
    public static boolean waitForElementInvisible(WebDriver driver, By locator) {
        return getWait(driver).until(ExpectedConditions.invisibilityOfElementLocated(locator));
    }

    /**
     * Wait for all elements to be visible
     * @param driver WebDriver instance
     * @param locator Element locator
     * @return List of WebElements
     */
    public static List<WebElement> waitForAllElementsVisible(WebDriver driver, By locator) {
        return getWait(driver).until(ExpectedConditions.visibilityOfAllElementsLocatedBy(locator));
    }

    /**
     * Wait for text to be present in element
     * @param driver WebDriver instance
     * @param locator Element locator
     * @param text Text to wait for
     * @return boolean
     */
    public static boolean waitForTextToBePresent(WebDriver driver, By locator, String text) {
        return getWait(driver).until(ExpectedConditions.textToBePresentInElementLocated(locator, text));
    }

    /**
     * Wait for URL to contain text
     * @param driver WebDriver instance
     * @param urlText URL text to wait for
     * @return boolean
     */
    public static boolean waitForUrlContains(WebDriver driver, String urlText) {
        return getWait(driver).until(ExpectedConditions.urlContains(urlText));
    }

    /**
     * Wait for page title to contain text
     * @param driver WebDriver instance
     * @param titleText Title text to wait for
     * @return boolean
     */
    public static boolean waitForTitleContains(WebDriver driver, String titleText) {
        return getWait(driver).until(ExpectedConditions.titleContains(titleText));
    }

    /**
     * Wait for alert to be present
     * @param driver WebDriver instance
     * @return Alert
     */
    public static org.openqa.selenium.Alert waitForAlert(WebDriver driver) {
        return getWait(driver).until(ExpectedConditions.alertIsPresent());
    }

    /**
     * Wait for element to be stale (useful for dynamic content)
     * @param driver WebDriver instance
     * @param element Element to check
     * @return boolean
     */
    public static boolean waitForElementStale(WebDriver driver, WebElement element) {
        return getWait(driver).until(ExpectedConditions.stalenessOf(element));
    }

    /**
     * Wait for specific duration (use sparingly)
     * @param seconds Seconds to wait
     */
    public static void wait(int seconds) {
        try {
            Thread.sleep(seconds * 1000L);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}

