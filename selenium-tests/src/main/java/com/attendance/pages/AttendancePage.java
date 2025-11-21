package com.attendance.pages;

import com.attendance.utils.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Page Object Model for Attendance Management Page
 * Contains all locators and methods for attendance management
 */
public class AttendancePage {
    private WebDriver driver;

    // Locators
    private By pageTitle = By.xpath("//h1[contains(text(), 'Attendance')]");
    private By addManualButton = By.xpath("//button[contains(., 'Add Manual')]");
    private By searchInput = By.xpath("//input[@placeholder='Search by worker name, email, or project...']");
    private By statusFilter = By.xpath("//select[contains(@class, 'border-gray-300')][1]");
    private By projectFilter = By.xpath("//select[contains(@class, 'border-gray-300')][2]");
    private By attendanceTable = By.xpath("//table | //div[contains(@class, 'table')]");
    private By tableRows = By.xpath("//tbody//tr | //div[contains(@class, 'table')]//div[contains(@class, 'row')]");
    
    // Stat cards
    private By checkedInCard = By.xpath("//div[contains(text(), 'Checked In')]/ancestor::div[contains(@class, 'bg-white')]");
    private By checkedOutCard = By.xpath("//div[contains(text(), 'Checked Out')]/ancestor::div[contains(@class, 'bg-white')]");
    private By totalTodayCard = By.xpath("//div[contains(text(), 'Total Today')]/ancestor::div[contains(@class, 'bg-white')]");
    
    // Modal locators
    private By workerSelect = By.xpath("//select[contains(@class, 'border-gray-300')]");
    private By checkInTimeInput = By.xpath("//label[contains(text(), 'Check In Time')]/following-sibling::input[@type='datetime-local']");
    private By checkOutTimeInput = By.xpath("//label[contains(text(), 'Check Out Time')]/following-sibling::input[@type='datetime-local']");
    private By submitAttendanceButton = By.xpath("//button[contains(text(), 'Add Attendance')] | //button[@type='submit']");

    public AttendancePage(WebDriver driver) {
        this.driver = driver;
    }

    /**
     * Check if attendance page is displayed
     * @return true if page is displayed
     */
    public boolean isAttendancePageDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, pageTitle).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Click Add Manual button
     */
    public void clickAddManual() {
        WebElement addBtn = WaitUtils.waitForElementClickable(driver, addManualButton);
        addBtn.click();
    }

    /**
     * Search for attendance records
     * @param searchText Search text
     */
    public void searchAttendance(String searchText) {
        WebElement searchField = WaitUtils.waitForElementVisible(driver, searchInput);
        searchField.clear();
        searchField.sendKeys(searchText);
        WaitUtils.wait(1);
    }

    /**
     * Filter by status
     * @param status Status filter (all, checked-in, checked-out)
     */
    public void filterByStatus(String status) {
        try {
            WebElement statusSelect = WaitUtils.waitForElementClickable(driver, statusFilter);
            org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(statusSelect);
            select.selectByVisibleText(status);
            WaitUtils.wait(1);
        } catch (Exception e) {
            throw new RuntimeException("Failed to filter by status: " + status, e);
        }
    }

    /**
     * Filter by project
     * @param projectName Project name
     */
    public void filterByProject(String projectName) {
        try {
            WebElement projectSelect = WaitUtils.waitForElementClickable(driver, projectFilter);
            org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(projectSelect);
            select.selectByVisibleText(projectName);
            WaitUtils.wait(1);
        } catch (Exception e) {
            throw new RuntimeException("Failed to filter by project: " + projectName, e);
        }
    }

    /**
     * Get count of attendance records in table
     * @return Number of records
     */
    public int getAttendanceRecordCount() {
        try {
            List<WebElement> rows = WaitUtils.waitForAllElementsVisible(driver, tableRows);
            return rows.size();
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Get checked in count from stat card
     * @return Checked in count
     */
    public String getCheckedInCount() {
        try {
            WebElement card = WaitUtils.waitForElementVisible(driver, checkedInCard);
            return card.getText();
        } catch (Exception e) {
            return "0";
        }
    }

    /**
     * Get checked out count from stat card
     * @return Checked out count
     */
    public String getCheckedOutCount() {
        try {
            WebElement card = WaitUtils.waitForElementVisible(driver, checkedOutCard);
            return card.getText();
        } catch (Exception e) {
            return "0";
        }
    }

    /**
     * Get total today count from stat card
     * @return Total today count
     */
    public String getTotalTodayCount() {
        try {
            WebElement card = WaitUtils.waitForElementVisible(driver, totalTodayCard);
            return card.getText();
        } catch (Exception e) {
            return "0";
        }
    }

    /**
     * Add manual attendance record
     * @param workerName Worker name
     * @param checkInTime Check in time (datetime-local format)
     * @param checkOutTime Check out time (optional)
     */
    public void addManualAttendance(String workerName, String checkInTime, String checkOutTime) {
        clickAddManual();
        WaitUtils.wait(2);
        
        // Select worker
        WebElement workerSelectElement = WaitUtils.waitForElementClickable(driver, workerSelect);
        org.openqa.selenium.support.ui.Select workerSelectDropdown = new org.openqa.selenium.support.ui.Select(workerSelectElement);
        workerSelectDropdown.selectByVisibleText(workerName);
        
        // Enter check in time
        WebElement checkInField = WaitUtils.waitForElementVisible(driver, checkInTimeInput);
        checkInField.clear();
        checkInField.sendKeys(checkInTime);
        
        // Enter check out time if provided
        if (checkOutTime != null && !checkOutTime.isEmpty()) {
            WebElement checkOutField = WaitUtils.waitForElementVisible(driver, checkOutTimeInput);
            checkOutField.clear();
            checkOutField.sendKeys(checkOutTime);
        }
        
        // Submit
        WebElement submitBtn = WaitUtils.waitForElementClickable(driver, submitAttendanceButton);
        submitBtn.click();
        WaitUtils.wait(2);
    }

    /**
     * Verify attendance table is displayed
     * @return true if table is displayed
     */
    public boolean isAttendanceTableDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, attendanceTable).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }
}

