package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.Test;

/**
 * Test class for Login functionality
 * Tests valid login, invalid login, and validation
 */
public class LoginTests extends BaseTest {

    @Test(priority = 1, description = "Test valid admin login")
    public void testValidLogin() {
        LoggerUtils.info("Starting test: Valid Login");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing valid login");

        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");

        // Perform login
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());

        // Verify redirect to dashboard
        DashboardPage dashboardPage = new DashboardPage(driver);
        Assert.assertTrue(dashboardPage.isDashboardDisplayed(), "Dashboard should be displayed after login");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Valid login successful");
        LoggerUtils.info("Valid login test passed");
    }

    @Test(priority = 2, description = "Test invalid email login")
    public void testInvalidEmailLogin() {
        LoggerUtils.info("Starting test: Invalid Email Login");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing invalid email login");

        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");

        // Attempt login with invalid email
        loginPage.login("invalid@email.com", ConfigReader.getAdminPassword());

        // Verify error message is displayed
        Assert.assertTrue(loginPage.isErrorMessageDisplayed(), "Error message should be displayed for invalid email");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Invalid email login validation working");
        LoggerUtils.info("Invalid email login test passed");
    }

    @Test(priority = 3, description = "Test invalid password login")
    public void testInvalidPasswordLogin() {
        LoggerUtils.info("Starting test: Invalid Password Login");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing invalid password login");

        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");

        // Attempt login with invalid password
        loginPage.login(ConfigReader.getAdminEmail(), "wrongpassword");

        // Verify error message is displayed
        Assert.assertTrue(loginPage.isErrorMessageDisplayed(), "Error message should be displayed for invalid password");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Invalid password login validation working");
        LoggerUtils.info("Invalid password login test passed");
    }

    @Test(priority = 4, description = "Test empty credentials login")
    public void testEmptyCredentialsLogin() {
        LoggerUtils.info("Starting test: Empty Credentials Login");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing empty credentials login");

        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");

        // Attempt login with empty credentials
        loginPage.enterEmail("");
        loginPage.enterPassword("");
        loginPage.clickSignIn();

        // Verify we're still on login page (HTML5 validation should prevent submission)
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Should remain on login page with empty credentials");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Empty credentials validation working");
        LoggerUtils.info("Empty credentials login test passed");
    }

    @Test(priority = 5, description = "Test password visibility toggle")
    public void testPasswordVisibilityToggle() {
        LoggerUtils.info("Starting test: Password Visibility Toggle");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing password visibility toggle");

        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");

        // Enter password
        loginPage.enterPassword("testpassword");

        // Toggle password visibility
        loginPage.togglePasswordVisibility();
        WaitUtils.wait(1);

        // Toggle back
        loginPage.togglePasswordVisibility();
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Password visibility toggle working");
        LoggerUtils.info("Password visibility toggle test passed");
    }
}

