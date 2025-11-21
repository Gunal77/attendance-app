package com.attendance.pages;

import com.attendance.utils.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

/**
 * Page Object Model for Login Page
 * Contains all locators and methods for login page interactions
 */
public class LoginPage {
    private WebDriver driver;

    // Locators
    private By emailInput = By.id("email");
    private By passwordInput = By.id("password");
    private By signInButton = By.xpath("//button[contains(text(), 'Sign in')]");
    private By errorMessage = By.xpath("//div[contains(@class, 'bg-red-50')]");
    private By showPasswordButton = By.xpath("//button[contains(@class, 'text-gray-500')]");
    private By loginPageTitle = By.xpath("//h2[contains(text(), 'Sign in to your account')]");

    public LoginPage(WebDriver driver) {
        this.driver = driver;
    }

    /**
     * Enter email address
     * @param email Email address
     */
    public void enterEmail(String email) {
        WebElement emailField = WaitUtils.waitForElementVisible(driver, emailInput);
        emailField.clear();
        emailField.sendKeys(email);
    }

    /**
     * Enter password
     * @param password Password
     */
    public void enterPassword(String password) {
        WebElement passwordField = WaitUtils.waitForElementVisible(driver, passwordInput);
        passwordField.clear();
        passwordField.sendKeys(password);
    }

    /**
     * Click sign in button
     */
    public void clickSignIn() {
        WebElement signInBtn = WaitUtils.waitForElementClickable(driver, signInButton);
        signInBtn.click();
    }

    /**
     * Perform login with credentials
     * @param email Email address
     * @param password Password
     */
    public void login(String email, String password) {
        enterEmail(email);
        enterPassword(password);
        clickSignIn();
    }

    /**
     * Get error message text
     * @return Error message
     */
    public String getErrorMessage() {
        try {
            WebElement errorElement = WaitUtils.waitForElementVisible(driver, errorMessage);
            return errorElement.getText();
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * Check if error message is displayed
     * @return true if error message is displayed
     */
    public boolean isErrorMessageDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, errorMessage).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Toggle password visibility
     */
    public void togglePasswordVisibility() {
        WebElement toggleBtn = WaitUtils.waitForElementClickable(driver, showPasswordButton);
        toggleBtn.click();
    }

    /**
     * Check if login page is displayed
     * @return true if login page is displayed
     */
    public boolean isLoginPageDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, loginPageTitle).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get current URL
     * @return Current URL
     */
    public String getCurrentUrl() {
        return driver.getCurrentUrl();
    }
}

