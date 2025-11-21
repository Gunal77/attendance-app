package com.attendance.pages;

import com.attendance.utils.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Page Object Model for Dashboard Page
 * Contains all locators and methods for dashboard interactions
 */
public class DashboardPage {
    private WebDriver driver;

    // Locators
    private By dashboardTitle = By.xpath("//h1[contains(text(), 'Dashboard')]");
    private By workersCard = By.xpath("//div[contains(text(), 'Workers')]/ancestor::div[contains(@class, 'bg-white')]");
    private By supervisorsCard = By.xpath("//div[contains(text(), 'Supervisors')]/ancestor::div[contains(@class, 'bg-white')]");
    private By completedProjectsCard = By.xpath("//div[contains(text(), 'Completed Projects')]/ancestor::div[contains(@class, 'bg-white')]");
    private By sidebar = By.xpath("//nav[contains(@class, 'space-y-1')]");
    private By workersLink = By.xpath("//a[contains(@href, '/workers')]");
    private By projectsLink = By.xpath("//a[contains(@href, '/projects')]");
    private By attendanceLink = By.xpath("//a[contains(@href, '/attendance')]");
    private By dashboardLink = By.xpath("//a[contains(@href, '/dashboard')]");
    private By logoutButton = By.xpath("//button[contains(text(), 'Sign Out')]");

    public DashboardPage(WebDriver driver) {
        this.driver = driver;
    }

    /**
     * Check if dashboard is displayed
     * @return true if dashboard is displayed
     */
    public boolean isDashboardDisplayed() {
        try {
            WaitUtils.waitForElementVisible(driver, dashboardTitle);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get dashboard title text
     * @return Dashboard title
     */
    public String getDashboardTitle() {
        WebElement titleElement = WaitUtils.waitForElementVisible(driver, dashboardTitle);
        return titleElement.getText();
    }

    /**
     * Get workers count from card
     * @return Workers count
     */
    public String getWorkersCount() {
        try {
            WebElement workersCardElement = WaitUtils.waitForElementVisible(driver, workersCard);
            // Extract count from the card (implementation depends on actual structure)
            return workersCardElement.getText();
        } catch (Exception e) {
            return "0";
        }
    }

    /**
     * Click on Workers link in sidebar
     */
    public void clickWorkersLink() {
        WebElement workersLinkElement = WaitUtils.waitForElementClickable(driver, workersLink);
        workersLinkElement.click();
    }

    /**
     * Click on Projects link in sidebar
     */
    public void clickProjectsLink() {
        WebElement projectsLinkElement = WaitUtils.waitForElementClickable(driver, projectsLink);
        projectsLinkElement.click();
    }

    /**
     * Click on Attendance link in sidebar
     */
    public void clickAttendanceLink() {
        WebElement attendanceLinkElement = WaitUtils.waitForElementClickable(driver, attendanceLink);
        attendanceLinkElement.click();
    }

    /**
     * Click on Dashboard link in sidebar
     */
    public void clickDashboardLink() {
        WebElement dashboardLinkElement = WaitUtils.waitForElementClickable(driver, dashboardLink);
        dashboardLinkElement.click();
    }

    /**
     * Click logout button
     */
    public void clickLogout() {
        WebElement logoutBtn = WaitUtils.waitForElementClickable(driver, logoutButton);
        logoutBtn.click();
    }

    /**
     * Verify sidebar is displayed
     * @return true if sidebar is displayed
     */
    public boolean isSidebarDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, sidebar).isDisplayed();
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

