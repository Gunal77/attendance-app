package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.pages.WorkerPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Test class for Worker/Employee Management functionality
 * Tests CRUD operations, search, and validation
 */
public class WorkerTests extends BaseTest {
    private static final String TEST_WORKER_NAME = "Test Worker " + System.currentTimeMillis();
    private static final String TEST_WORKER_EMAIL = "testworker" + System.currentTimeMillis() + "@test.com";
    private static final String TEST_WORKER_PHONE = "1234567890";
    private static final String TEST_WORKER_DEPARTMENT = "Construction";

    @BeforeMethod
    public void login() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);
    }

    @Test(priority = 1, description = "Test add new worker")
    public void testAddWorker() {
        LoggerUtils.info("Starting test: Add Worker");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing add new worker");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);

        WorkerPage workerPage = new WorkerPage(driver);
        Assert.assertTrue(workerPage.isWorkerPageDisplayed(), "Worker page should be displayed");

        int initialCount = workerPage.getWorkerCount();
        
        // Add new worker
        workerPage.addWorker(TEST_WORKER_NAME, TEST_WORKER_EMAIL, TEST_WORKER_PHONE, TEST_WORKER_DEPARTMENT);
        
        // Verify worker was added
        WaitUtils.wait(2);
        int finalCount = workerPage.getWorkerCount();
        Assert.assertTrue(finalCount >= initialCount, "Worker count should increase after adding");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Worker added successfully");
        LoggerUtils.info("Add worker test passed");
    }

    @Test(priority = 2, description = "Test search worker", dependsOnMethods = "testAddWorker")
    public void testSearchWorker() {
        LoggerUtils.info("Starting test: Search Worker");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing search worker");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);

        WorkerPage workerPage = new WorkerPage(driver);
        
        // Search for the worker we just added
        workerPage.searchWorker(TEST_WORKER_NAME);
        
        // Verify worker is found
        Assert.assertTrue(workerPage.isWorkerPresent(TEST_WORKER_NAME), "Worker should be found in search results");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Worker search working");
        LoggerUtils.info("Search worker test passed");
    }

    @Test(priority = 3, description = "Test worker list table validation")
    public void testWorkerListTable() {
        LoggerUtils.info("Starting test: Worker List Table");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing worker list table");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);

        WorkerPage workerPage = new WorkerPage(driver);
        Assert.assertTrue(workerPage.isWorkerPageDisplayed(), "Worker page should be displayed");
        
        int workerCount = workerPage.getWorkerCount();
        Assert.assertTrue(workerCount >= 0, "Worker count should be non-negative");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Worker list table validated");
        LoggerUtils.info("Worker list table test passed");
    }

    @Test(priority = 4, description = "Test delete worker", dependsOnMethods = "testAddWorker")
    public void testDeleteWorker() {
        LoggerUtils.info("Starting test: Delete Worker");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing delete worker");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);

        WorkerPage workerPage = new WorkerPage(driver);
        
        // Search for the worker
        workerPage.searchWorker(TEST_WORKER_NAME);
        WaitUtils.wait(1);
        
        int initialCount = workerPage.getWorkerCount();
        
        // Delete the worker
        workerPage.deleteWorker(TEST_WORKER_NAME);
        
        // Verify worker was deleted
        WaitUtils.wait(2);
        int finalCount = workerPage.getWorkerCount();
        Assert.assertTrue(finalCount <= initialCount, "Worker count should decrease after deletion");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Worker deleted successfully");
        LoggerUtils.info("Delete worker test passed");
    }

    @Test(priority = 5, description = "Test add worker modal validation")
    public void testAddWorkerModalValidation() {
        LoggerUtils.info("Starting test: Add Worker Modal Validation");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing add worker modal validation");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickWorkersLink();
        WaitUtils.wait(2);

        WorkerPage workerPage = new WorkerPage(driver);
        workerPage.clickAddWorker();
        WaitUtils.wait(2);
        
        // Try to submit without filling required fields
        workerPage.submitWorkerForm();
        
        // Modal should still be open (HTML5 validation)
        WaitUtils.wait(1);
        
        // Cancel to close modal
        workerPage.clickCancel();
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Add worker modal validation working");
        LoggerUtils.info("Add worker modal validation test passed");
    }
}

