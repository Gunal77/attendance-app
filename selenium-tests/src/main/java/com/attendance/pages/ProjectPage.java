package com.attendance.pages;

import com.attendance.utils.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Page Object Model for Project Management Page
 * Contains all locators and methods for project management
 */
public class ProjectPage {
    private WebDriver driver;

    // Locators
    private By pageTitle = By.xpath("//h1[contains(text(), 'Projects')]");
    private By addProjectButton = By.xpath("//button[contains(., 'New Project')]");
    private By searchInput = By.xpath("//input[@placeholder='Search by name, description, or location...']");
    private By projectCards = By.xpath("//div[contains(@class, 'grid')]//div[contains(@class, 'bg-white')]");
    
    // Modal locators
    private By projectNameInput = By.xpath("//label[contains(text(), 'Project Name')]/following-sibling::input | //input[@placeholder='Enter project name']");
    private By descriptionInput = By.xpath("//label[contains(text(), 'Description')]/following-sibling::textarea");
    private By locationInput = By.xpath("//label[contains(text(), 'Location')]/following-sibling::input");
    private By startDateInput = By.xpath("//label[contains(text(), 'Start Date')]/following-sibling::input[@type='date']");
    private By endDateInput = By.xpath("//label[contains(text(), 'End Date')]/following-sibling::input[@type='date']");
    private By budgetInput = By.xpath("//label[contains(text(), 'Budget')]/following-sibling::input[@type='number']");
    private By submitProjectButton = By.xpath("//button[contains(text(), 'Add Project')] | //button[@type='submit']");
    private By cancelButton = By.xpath("//button[contains(text(), 'Cancel')]");
    
    // Filter locators
    private By statusFilter = By.xpath("//select[contains(@class, 'border-gray-300')]");
    private By sortByFilter = By.xpath("//select[contains(@class, 'border-gray-300')]");

    public ProjectPage(WebDriver driver) {
        this.driver = driver;
    }

    /**
     * Check if project page is displayed
     * @return true if page is displayed
     */
    public boolean isProjectPageDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, pageTitle).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Click Add Project button
     */
    public void clickAddProject() {
        WebElement addBtn = WaitUtils.waitForElementClickable(driver, addProjectButton);
        addBtn.click();
    }

    /**
     * Enter project name
     * @param name Project name
     */
    public void enterProjectName(String name) {
        WebElement nameField = WaitUtils.waitForElementVisible(driver, projectNameInput);
        nameField.clear();
        nameField.sendKeys(name);
    }

    /**
     * Enter project description
     * @param description Project description
     */
    public void enterDescription(String description) {
        WebElement descField = WaitUtils.waitForElementVisible(driver, descriptionInput);
        descField.clear();
        descField.sendKeys(description);
    }

    /**
     * Enter project location
     * @param location Project location
     */
    public void enterLocation(String location) {
        WebElement locationField = WaitUtils.waitForElementVisible(driver, locationInput);
        locationField.clear();
        locationField.sendKeys(location);
    }

    /**
     * Enter start date
     * @param date Start date in YYYY-MM-DD format
     */
    public void enterStartDate(String date) {
        WebElement dateField = WaitUtils.waitForElementVisible(driver, startDateInput);
        dateField.clear();
        dateField.sendKeys(date);
    }

    /**
     * Enter end date
     * @param date End date in YYYY-MM-DD format
     */
    public void enterEndDate(String date) {
        WebElement dateField = WaitUtils.waitForElementVisible(driver, endDateInput);
        dateField.clear();
        dateField.sendKeys(date);
    }

    /**
     * Enter budget
     * @param budget Budget amount
     */
    public void enterBudget(String budget) {
        WebElement budgetField = WaitUtils.waitForElementVisible(driver, budgetInput);
        budgetField.clear();
        budgetField.sendKeys(budget);
    }

    /**
     * Submit project form
     */
    public void submitProjectForm() {
        WebElement submitBtn = WaitUtils.waitForElementClickable(driver, submitProjectButton);
        submitBtn.click();
    }

    /**
     * Add new project with all details
     * @param name Project name
     * @param description Project description
     * @param location Project location
     * @param startDate Start date
     * @param endDate End date
     * @param budget Budget
     */
    public void addProject(String name, String description, String location, String startDate, String endDate, String budget) {
        clickAddProject();
        WaitUtils.wait(2);
        enterProjectName(name);
        enterDescription(description);
        enterLocation(location);
        if (startDate != null && !startDate.isEmpty()) {
            enterStartDate(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            enterEndDate(endDate);
        }
        if (budget != null && !budget.isEmpty()) {
            enterBudget(budget);
        }
        submitProjectForm();
        WaitUtils.wait(2);
    }

    /**
     * Search for project
     * @param searchText Search text
     */
    public void searchProject(String searchText) {
        WebElement searchField = WaitUtils.waitForElementVisible(driver, searchInput);
        searchField.clear();
        searchField.sendKeys(searchText);
        WaitUtils.wait(1);
    }

    /**
     * Get count of project cards
     * @return Number of project cards
     */
    public int getProjectCount() {
        try {
            List<WebElement> projectCardsList = WaitUtils.waitForAllElementsVisible(driver, projectCards);
            return projectCardsList.size();
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Check if project exists in the list
     * @param projectName Project name to search
     * @return true if project exists
     */
    public boolean isProjectPresent(String projectName) {
        try {
            By projectNameLocator = By.xpath("//div[contains(text(), '" + projectName + "')]");
            return WaitUtils.waitForElementVisible(driver, projectNameLocator).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Filter projects by status
     * @param status Status filter (all, active, completed)
     */
    public void filterByStatus(String status) {
        try {
            List<WebElement> selects = driver.findElements(statusFilter);
            if (!selects.isEmpty()) {
                org.openqa.selenium.support.ui.Select select = new org.openqa.selenium.support.ui.Select(selects.get(0));
                select.selectByVisibleText(status);
                WaitUtils.wait(1);
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to filter by status: " + status, e);
        }
    }
}

