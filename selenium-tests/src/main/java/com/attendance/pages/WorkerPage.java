package com.attendance.pages;

import com.attendance.utils.WaitUtils;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.Select;

import java.util.List;

/**
 * Page Object Model for Worker/Employee Management Page
 * Contains all locators and methods for worker management
 */
public class WorkerPage {
    private WebDriver driver;

    // Locators
    private By pageTitle = By.xpath("//h1[contains(text(), 'Workers')]");
    private By addWorkerButton = By.xpath("//button[contains(., 'Add Worker')]");
    private By searchInput = By.xpath("//input[@placeholder='Search by name, email, or phone...']");
    private By workerCards = By.xpath("//div[contains(@class, 'grid')]//div[contains(@class, 'bg-white')]");
    
    // Modal locators
    private By modalTitle = By.xpath("//div[contains(@class, 'modal')]//h2 | //div[contains(@class, 'modal')]//div[contains(text(), 'Add Worker')]");
    private By nameInput = By.xpath("//label[contains(text(), 'Name')]/following-sibling::input | //input[@placeholder='Enter worker name']");
    private By emailInput = By.xpath("//label[contains(text(), 'Email')]/following-sibling::input | //input[@type='email']");
    private By phoneInput = By.xpath("//label[contains(text(), 'Phone')]/following-sibling::input | //input[@type='tel']");
    private By departmentInput = By.xpath("//label[contains(text(), 'Department')]/following-sibling::input");
    private By submitButton = By.xpath("//button[contains(text(), 'Add Worker')] | //button[@type='submit']");
    private By cancelButton = By.xpath("//button[contains(text(), 'Cancel')]");
    private By closeModalButton = By.xpath("//button[contains(@aria-label, 'close')] | //button[contains(@class, 'close')]");
    
    // Delete modal locators
    private By deleteButton = By.xpath("//button[contains(@title, 'Delete')] | //button[contains(., 'Delete')]");
    private By confirmDeleteButton = By.xpath("//button[contains(text(), 'Delete') and contains(@class, 'bg-red-600')]");
    private By cancelDeleteButton = By.xpath("//button[contains(text(), 'Cancel')]");

    public WorkerPage(WebDriver driver) {
        this.driver = driver;
    }

    /**
     * Check if worker page is displayed
     * @return true if page is displayed
     */
    public boolean isWorkerPageDisplayed() {
        try {
            return WaitUtils.waitForElementVisible(driver, pageTitle).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Click Add Worker button
     */
    public void clickAddWorker() {
        WebElement addBtn = WaitUtils.waitForElementClickable(driver, addWorkerButton);
        addBtn.click();
    }

    /**
     * Enter worker name in modal
     * @param name Worker name
     */
    public void enterWorkerName(String name) {
        WebElement nameField = WaitUtils.waitForElementVisible(driver, nameInput);
        nameField.clear();
        nameField.sendKeys(name);
    }

    /**
     * Enter worker email in modal
     * @param email Worker email
     */
    public void enterWorkerEmail(String email) {
        WebElement emailField = WaitUtils.waitForElementVisible(driver, emailInput);
        emailField.clear();
        emailField.sendKeys(email);
    }

    /**
     * Enter worker phone in modal
     * @param phone Worker phone
     */
    public void enterWorkerPhone(String phone) {
        WebElement phoneField = WaitUtils.waitForElementVisible(driver, phoneInput);
        phoneField.clear();
        phoneField.sendKeys(phone);
    }

    /**
     * Enter worker department in modal
     * @param department Worker department
     */
    public void enterWorkerDepartment(String department) {
        WebElement deptField = WaitUtils.waitForElementVisible(driver, departmentInput);
        deptField.clear();
        deptField.sendKeys(department);
    }

    /**
     * Submit worker form
     */
    public void submitWorkerForm() {
        WebElement submitBtn = WaitUtils.waitForElementClickable(driver, submitButton);
        submitBtn.click();
    }

    /**
     * Add new worker with all details
     * @param name Worker name
     * @param email Worker email
     * @param phone Worker phone
     * @param department Worker department
     */
    public void addWorker(String name, String email, String phone, String department) {
        clickAddWorker();
        WaitUtils.wait(2); // Wait for modal to open
        enterWorkerName(name);
        enterWorkerEmail(email);
        enterWorkerPhone(phone);
        enterWorkerDepartment(department);
        submitWorkerForm();
        WaitUtils.wait(2); // Wait for form submission
    }

    /**
     * Search for worker
     * @param searchText Search text
     */
    public void searchWorker(String searchText) {
        WebElement searchField = WaitUtils.waitForElementVisible(driver, searchInput);
        searchField.clear();
        searchField.sendKeys(searchText);
        WaitUtils.wait(1); // Wait for search results
    }

    /**
     * Get count of worker cards
     * @return Number of worker cards
     */
    public int getWorkerCount() {
        try {
            List<WebElement> workerCardsList = WaitUtils.waitForAllElementsVisible(driver, workerCards);
            return workerCardsList.size();
        } catch (Exception e) {
            return 0;
        }
    }

    /**
     * Check if worker exists in the list
     * @param workerName Worker name to search
     * @return true if worker exists
     */
    public boolean isWorkerPresent(String workerName) {
        try {
            By workerNameLocator = By.xpath("//div[contains(text(), '" + workerName + "')]");
            return WaitUtils.waitForElementVisible(driver, workerNameLocator).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Delete worker by name
     * @param workerName Worker name to delete
     */
    public void deleteWorker(String workerName) {
        try {
            // Find delete button for specific worker
            By deleteBtnLocator = By.xpath("//div[contains(text(), '" + workerName + "')]/ancestor::div[contains(@class, 'bg-white')]//button[contains(@title, 'Delete')]");
            WebElement deleteBtn = WaitUtils.waitForElementClickable(driver, deleteBtnLocator);
            deleteBtn.click();
            
            // Confirm deletion
            WaitUtils.wait(1);
            WebElement confirmBtn = WaitUtils.waitForElementClickable(driver, confirmDeleteButton);
            confirmBtn.click();
            WaitUtils.wait(2); // Wait for deletion to complete
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete worker: " + workerName, e);
        }
    }

    /**
     * Click cancel button in modal
     */
    public void clickCancel() {
        try {
            WebElement cancelBtn = WaitUtils.waitForElementClickable(driver, cancelButton);
            cancelBtn.click();
        } catch (Exception e) {
            // Modal might already be closed
        }
    }
}

