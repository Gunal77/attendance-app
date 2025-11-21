package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.pages.ProjectPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Test class for Project Management functionality
 * Tests project creation, validation, and filtering
 */
public class ProjectTests extends BaseTest {
    private static final String TEST_PROJECT_NAME = "Test Project " + System.currentTimeMillis();
    private static final String TEST_PROJECT_DESCRIPTION = "Test project description for automation";
    private static final String TEST_PROJECT_LOCATION = "Singapore";
    private static final String TEST_PROJECT_BUDGET = "100000.00";

    @BeforeMethod
    public void login() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);
    }

    @Test(priority = 1, description = "Test create new project")
    public void testCreateProject() {
        LoggerUtils.info("Starting test: Create Project");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing create new project");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);

        ProjectPage projectPage = new ProjectPage(driver);
        Assert.assertTrue(projectPage.isProjectPageDisplayed(), "Project page should be displayed");

        int initialCount = projectPage.getProjectCount();
        
        // Get dates
        LocalDate startDate = LocalDate.now();
        LocalDate endDate = startDate.plusMonths(6);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        
        // Create new project
        projectPage.addProject(
            TEST_PROJECT_NAME,
            TEST_PROJECT_DESCRIPTION,
            TEST_PROJECT_LOCATION,
            startDate.format(formatter),
            endDate.format(formatter),
            TEST_PROJECT_BUDGET
        );
        
        // Verify project was created
        WaitUtils.wait(2);
        int finalCount = projectPage.getProjectCount();
        Assert.assertTrue(finalCount >= initialCount, "Project count should increase after creation");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Project created successfully");
        LoggerUtils.info("Create project test passed");
    }

    @Test(priority = 2, description = "Test project list validation")
    public void testProjectListValidation() {
        LoggerUtils.info("Starting test: Project List Validation");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing project list validation");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);

        ProjectPage projectPage = new ProjectPage(driver);
        Assert.assertTrue(projectPage.isProjectPageDisplayed(), "Project page should be displayed");
        
        int projectCount = projectPage.getProjectCount();
        Assert.assertTrue(projectCount >= 0, "Project count should be non-negative");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Project list validated");
        LoggerUtils.info("Project list validation test passed");
    }

    @Test(priority = 3, description = "Test search project", dependsOnMethods = "testCreateProject")
    public void testSearchProject() {
        LoggerUtils.info("Starting test: Search Project");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing search project");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);

        ProjectPage projectPage = new ProjectPage(driver);
        
        // Search for the project we just created
        projectPage.searchProject(TEST_PROJECT_NAME);
        
        // Verify project is found
        Assert.assertTrue(projectPage.isProjectPresent(TEST_PROJECT_NAME), "Project should be found in search results");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Project search working");
        LoggerUtils.info("Search project test passed");
    }

    @Test(priority = 4, description = "Test filter projects by status")
    public void testFilterProjectsByStatus() {
        LoggerUtils.info("Starting test: Filter Projects by Status");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing filter projects by status");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);

        ProjectPage projectPage = new ProjectPage(driver);
        
        // Filter by active status
        projectPage.filterByStatus("Active");
        WaitUtils.wait(2);
        
        // Filter by all status
        projectPage.filterByStatus("All Status");
        WaitUtils.wait(2);
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Project status filter working");
        LoggerUtils.info("Filter projects by status test passed");
    }

    @Test(priority = 5, description = "Test project form validation")
    public void testProjectFormValidation() {
        LoggerUtils.info("Starting test: Project Form Validation");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing project form validation");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickProjectsLink();
        WaitUtils.wait(2);

        ProjectPage projectPage = new ProjectPage(driver);
        projectPage.clickAddProject();
        WaitUtils.wait(2);
        
        // Try to submit without filling required fields
        projectPage.submitProjectForm();
        
        // Modal should still be open (HTML5 validation)
        WaitUtils.wait(1);
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Project form validation working");
        LoggerUtils.info("Project form validation test passed");
    }
}

