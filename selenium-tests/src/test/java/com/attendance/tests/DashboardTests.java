package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Test class for Dashboard functionality
 * Tests dashboard validation and navigation
 */
public class DashboardTests extends BaseTest {

    @BeforeMethod
    public void login() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);
    }

    @Test(priority = 1, description = "Test dashboard page display")
    public void testDashboardDisplay() {
        LoggerUtils.info("Starting test: Dashboard Display");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing dashboard display");

        DashboardPage dashboardPage = new DashboardPage(driver);
        Assert.assertTrue(dashboardPage.isDashboardDisplayed(), "Dashboard should be displayed");
        Assert.assertTrue(dashboardPage.getDashboardTitle().contains("Dashboard"), "Dashboard title should be correct");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Dashboard displayed correctly");
        LoggerUtils.info("Dashboard display test passed");
    }

    @Test(priority = 2, description = "Test sidebar navigation")
    public void testSidebarNavigation() {
        LoggerUtils.info("Starting test: Sidebar Navigation");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing sidebar navigation");

        DashboardPage dashboardPage = new DashboardPage(driver);
        Assert.assertTrue(dashboardPage.isSidebarDisplayed(), "Sidebar should be displayed");

        // Test navigation to Workers page
        dashboardPage.clickWorkersLink();
        WaitUtils.waitForUrlContains(driver, "/workers");
        Assert.assertTrue(driver.getCurrentUrl().contains("/workers"), "Should navigate to workers page");
        
        // Navigate back to dashboard
        dashboardPage.clickDashboardLink();
        WaitUtils.waitForUrlContains(driver, "/dashboard");
        Assert.assertTrue(driver.getCurrentUrl().contains("/dashboard"), "Should navigate back to dashboard");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Sidebar navigation working");
        LoggerUtils.info("Sidebar navigation test passed");
    }

    @Test(priority = 3, description = "Test dashboard statistics cards")
    public void testDashboardStatistics() {
        LoggerUtils.info("Starting test: Dashboard Statistics");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing dashboard statistics");

        DashboardPage dashboardPage = new DashboardPage(driver);
        Assert.assertTrue(dashboardPage.isDashboardDisplayed(), "Dashboard should be displayed");

        // Verify statistics cards are displayed
        String workersCount = dashboardPage.getWorkersCount();
        Assert.assertNotNull(workersCount, "Workers count should be displayed");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Dashboard statistics displayed");
        LoggerUtils.info("Dashboard statistics test passed");
    }

    @Test(priority = 4, description = "Test logout functionality")
    public void testLogout() {
        LoggerUtils.info("Starting test: Logout");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing logout");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickLogout();
        WaitUtils.wait(2);

        // Verify redirect to login page
        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Should redirect to login page after logout");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Logout successful");
        LoggerUtils.info("Logout test passed");
    }
}

