package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.AttendancePage;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.pages.ProjectPage;
import com.attendance.pages.WorkerPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.Test;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * End-to-end test scenarios
 * Tests complete user workflows
 */
public class EndToEndTests extends BaseTest {
    private static final String E2E_WORKER_NAME = "E2E Worker " + System.currentTimeMillis();
    private static final String E2E_WORKER_EMAIL = "e2eworker" + System.currentTimeMillis() + "@test.com";
    private static final String E2E_PROJECT_NAME = "E2E Project " + System.currentTimeMillis();

    @Test(priority = 1, description = "Complete workflow: Login -> Add Worker -> Add Project -> View Attendance")
    public void testCompleteWorkflow() {
        LoggerUtils.info("Starting E2E test: Complete Workflow");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing complete workflow");

        // Step 1: Login
        LoginPage loginPage = new LoginPage(driver);
        Assert.assertTrue(loginPage.isLoginPageDisplayed(), "Login page should be displayed");
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);

        // Step 2: Verify Dashboard
        DashboardPage dashboardPage = new DashboardPage(driver);
        Assert.assertTrue(dashboardPage.isDashboardDisplayed(), "Dashboard should be displayed");

        // Step 3: Add Worker
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);
        WorkerPage workerPage = new WorkerPage(driver);
        Assert.assertTrue(workerPage.isWorkerPageDisplayed(), "Worker page should be displayed");
        workerPage.addWorker(E2E_WORKER_NAME, E2E_WORKER_EMAIL, "9876543210", "Construction");
        WaitUtils.wait(2);

        // Step 4: Add Project
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);
        ProjectPage projectPage = new ProjectPage(driver);
        Assert.assertTrue(projectPage.isProjectPageDisplayed(), "Project page should be displayed");
        
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = startDate.plusMonths(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        
        projectPage.addProject(
            E2E_PROJECT_NAME,
            "E2E Test Project Description",
            "Singapore",
            startDate.format(formatter),
            endDate.format(formatter),
            "50000.00"
        );
        WaitUtils.wait(2);

        // Step 5: View Attendance
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);
        AttendancePage attendancePage = new AttendancePage(driver);
        Assert.assertTrue(attendancePage.isAttendancePageDisplayed(), "Attendance page should be displayed");
        Assert.assertTrue(attendancePage.isAttendanceTableDisplayed(), "Attendance table should be displayed");

        extentTest.log(com.aventstack.extentreports.Status.PASS, "Complete workflow executed successfully");
        LoggerUtils.info("Complete workflow test passed");
    }

    @Test(priority = 2, description = "Navigation flow: Test all sidebar links")
    public void testNavigationFlow() {
        LoggerUtils.info("Starting E2E test: Navigation Flow");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing navigation flow");

        // Login
        LoginPage loginPage = new LoginPage(driver);
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);

        DashboardPage dashboardPage = new DashboardPage(driver);
        
        // Navigate through all pages
        dashboardPage.clickWorkersLink();
        WaitUtils.waitForUrlContains(driver, "/workers");
        Assert.assertTrue(driver.getCurrentUrl().contains("/workers"), "Should be on workers page");

        dashboardPage.clickProjectsLink();
        WaitUtils.waitForUrlContains(driver, "/projects");
        Assert.assertTrue(driver.getCurrentUrl().contains("/projects"), "Should be on projects page");

        dashboardPage.clickAttendanceLink();
        WaitUtils.waitForUrlContains(driver, "/attendance");
        Assert.assertTrue(driver.getCurrentUrl().contains("/attendance"), "Should be on attendance page");

        dashboardPage.clickDashboardLink();
        WaitUtils.waitForUrlContains(driver, "/dashboard");
        Assert.assertTrue(driver.getCurrentUrl().contains("/dashboard"), "Should be on dashboard page");

        extentTest.log(com.aventstack.extentreports.Status.PASS, "Navigation flow working correctly");
        LoggerUtils.info("Navigation flow test passed");
    }
}

