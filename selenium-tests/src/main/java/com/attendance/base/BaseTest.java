package com.attendance.base;

import com.attendance.config.ConfigReader;
import com.attendance.utils.DriverManager;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.ScreenshotUtils;
import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import org.openqa.selenium.WebDriver;
import org.testng.ITestResult;
import org.testng.annotations.*;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Base test class for all test classes
 * Handles setup, teardown, and reporting
 */
public class BaseTest {
    protected WebDriver driver;
    protected static ExtentReports extentReports;
    protected ExtentTest extentTest;

    /**
     * Setup Extent Reports before all tests
     */
    @BeforeSuite
    public void setupSuite() {
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String reportPath = "test-output/ExtentReport_" + timestamp + ".html";
        
        ExtentSparkReporter sparkReporter = new ExtentSparkReporter(reportPath);
        sparkReporter.config().setDocumentTitle("Admin Portal Test Report");
        sparkReporter.config().setReportName("Selenium Automation Test Report");
        
        extentReports = new ExtentReports();
        extentReports.attachReporter(sparkReporter);
        extentReports.setSystemInfo("Browser", ConfigReader.getBrowser());
        extentReports.setSystemInfo("Environment", "Production");
        extentReports.setSystemInfo("OS", System.getProperty("os.name"));
        
        LoggerUtils.info("Test suite started");
    }

    /**
     * Setup before each test method
     * @param result Test result
     */
    @BeforeMethod
    public void setup(ITestResult result) {
        String testName = result.getMethod().getMethodName();
        extentTest = extentReports.createTest(testName);
        
        LoggerUtils.info("Starting test: " + testName);
        driver = DriverManager.getDriver();
        driver.get(ConfigReader.getBaseUrl());
        
        extentTest.log(Status.INFO, "Navigated to: " + ConfigReader.getBaseUrl());
    }

    /**
     * Teardown after each test method
     * @param result Test result
     */
    @AfterMethod
    public void teardown(ITestResult result) {
        String testName = result.getMethod().getMethodName();
        
        if (result.getStatus() == ITestResult.FAILURE) {
            extentTest.log(Status.FAIL, "Test failed: " + result.getThrowable().getMessage());
            String screenshotPath = ScreenshotUtils.takeScreenshotOnFailure(driver, testName);
            if (screenshotPath != null) {
                extentTest.addScreenCaptureFromPath(screenshotPath);
            }
            LoggerUtils.error("Test failed: " + testName);
        } else if (result.getStatus() == ITestResult.SUCCESS) {
            extentTest.log(Status.PASS, "Test passed successfully");
            LoggerUtils.info("Test passed: " + testName);
        } else if (result.getStatus() == ITestResult.SKIP) {
            extentTest.log(Status.SKIP, "Test skipped");
            LoggerUtils.warn("Test skipped: " + testName);
        }
        
        DriverManager.quitDriver();
    }

    /**
     * Flush Extent Reports after all tests
     */
    @AfterSuite
    public void teardownSuite() {
        if (extentReports != null) {
            extentReports.flush();
        }
        LoggerUtils.closeLogger();
        LoggerUtils.info("Test suite completed");
    }
}

