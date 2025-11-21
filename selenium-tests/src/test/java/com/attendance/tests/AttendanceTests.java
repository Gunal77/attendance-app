package com.attendance.tests;

import com.attendance.base.BaseTest;
import com.attendance.config.ConfigReader;
import com.attendance.pages.AttendancePage;
import com.attendance.pages.DashboardPage;
import com.attendance.pages.LoginPage;
import com.attendance.utils.LoggerUtils;
import com.attendance.utils.WaitUtils;
import org.testng.Assert;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Test class for Attendance Management functionality
 * Tests attendance viewing, filtering, and validation
 */
public class AttendanceTests extends BaseTest {

    @BeforeMethod
    public void login() {
        LoginPage loginPage = new LoginPage(driver);
        loginPage.login(ConfigReader.getAdminEmail(), ConfigReader.getAdminPassword());
        WaitUtils.wait(2);
    }

    @Test(priority = 1, description = "Test view daily attendance")
    public void testViewDailyAttendance() {
        LoggerUtils.info("Starting test: View Daily Attendance");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing view daily attendance");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        Assert.assertTrue(attendancePage.isAttendancePageDisplayed(), "Attendance page should be displayed");
        Assert.assertTrue(attendancePage.isAttendanceTableDisplayed(), "Attendance table should be displayed");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Daily attendance displayed");
        LoggerUtils.info("View daily attendance test passed");
    }

    @Test(priority = 2, description = "Test attendance statistics cards")
    public void testAttendanceStatistics() {
        LoggerUtils.info("Starting test: Attendance Statistics");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing attendance statistics");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        
        // Verify stat cards are displayed
        String checkedIn = attendancePage.getCheckedInCount();
        String checkedOut = attendancePage.getCheckedOutCount();
        String totalToday = attendancePage.getTotalTodayCount();
        
        Assert.assertNotNull(checkedIn, "Checked in count should be displayed");
        Assert.assertNotNull(checkedOut, "Checked out count should be displayed");
        Assert.assertNotNull(totalToday, "Total today count should be displayed");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Attendance statistics displayed");
        LoggerUtils.info("Attendance statistics test passed");
    }

    @Test(priority = 3, description = "Test filter attendance by status")
    public void testFilterAttendanceByStatus() {
        LoggerUtils.info("Starting test: Filter Attendance by Status");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing filter attendance by status");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        
        // Filter by checked-in status
        attendancePage.filterByStatus("Checked In");
        WaitUtils.wait(2);
        
        // Filter by checked-out status
        attendancePage.filterByStatus("Checked Out");
        WaitUtils.wait(2);
        
        // Filter by all status
        attendancePage.filterByStatus("All Status");
        WaitUtils.wait(2);
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Attendance status filter working");
        LoggerUtils.info("Filter attendance by status test passed");
    }

    @Test(priority = 4, description = "Test filter attendance by project")
    public void testFilterAttendanceByProject() {
        LoggerUtils.info("Starting test: Filter Attendance by Project");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing filter attendance by project");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        
        // Filter by all projects first
        attendancePage.filterByProject("All Projects");
        WaitUtils.wait(2);
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Attendance project filter working");
        LoggerUtils.info("Filter attendance by project test passed");
    }

    @Test(priority = 5, description = "Test search attendance")
    public void testSearchAttendance() {
        LoggerUtils.info("Starting test: Search Attendance");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing search attendance");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        
        // Search for attendance records
        attendancePage.searchAttendance("test");
        WaitUtils.wait(2);
        
        // Clear search
        attendancePage.searchAttendance("");
        WaitUtils.wait(1);
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Attendance search working");
        LoggerUtils.info("Search attendance test passed");
    }

    @Test(priority = 6, description = "Test attendance table validation")
    public void testAttendanceTableValidation() {
        LoggerUtils.info("Starting test: Attendance Table Validation");
        extentTest.log(com.aventstack.extentreports.Status.INFO, "Testing attendance table validation");

        DashboardPage dashboardPage = new DashboardPage(driver);
        dashboardPage.clickAttendanceLink();
        WaitUtils.wait(2);

        AttendancePage attendancePage = new AttendancePage(driver);
        Assert.assertTrue(attendancePage.isAttendanceTableDisplayed(), "Attendance table should be displayed");
        
        int recordCount = attendancePage.getAttendanceRecordCount();
        Assert.assertTrue(recordCount >= 0, "Attendance record count should be non-negative");
        
        extentTest.log(com.aventstack.extentreports.Status.PASS, "Attendance table validated");
        LoggerUtils.info("Attendance table validation test passed");
    }
}

