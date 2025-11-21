package com.attendance.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Utility class for reading test data from JSON and CSV files
 * Supports data-driven testing
 */
public class TestDataReader {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Read JSON test data from file
     * @param filePath Path to JSON file
     * @return JsonNode containing test data
     */
    public static JsonNode readJsonData(String filePath) {
        try {
            return objectMapper.readTree(new java.io.File(filePath));
        } catch (IOException e) {
            LoggerUtils.error("Failed to read JSON file: " + filePath + " - " + e.getMessage());
            throw new RuntimeException("Failed to read JSON file: " + filePath, e);
        }
    }

    /**
     * Read CSV test data from file
     * @param filePath Path to CSV file
     * @return List of Maps containing test data
     */
    public static List<Map<String, String>> readCsvData(String filePath) {
        List<Map<String, String>> records = new ArrayList<>();
        try (Reader reader = new FileReader(filePath);
             CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT.withFirstRecordAsHeader())) {

            for (CSVRecord record : csvParser) {
                Map<String, String> recordMap = new HashMap<>();
                for (String header : csvParser.getHeaderMap().keySet()) {
                    recordMap.put(header, record.get(header));
                }
                records.add(recordMap);
            }
        } catch (IOException e) {
            LoggerUtils.error("Failed to read CSV file: " + filePath + " - " + e.getMessage());
            throw new RuntimeException("Failed to read CSV file: " + filePath, e);
        }
        return records;
    }

    /**
     * Get test data for a specific test case from JSON
     * @param filePath Path to JSON file
     * @param testCaseName Name of the test case
     * @return JsonNode containing test case data
     */
    public static JsonNode getTestCaseData(String filePath, String testCaseName) {
        JsonNode rootNode = readJsonData(filePath);
        return rootNode.get(testCaseName);
    }

    /**
     * Get value from JSON node by key
     * @param node JsonNode
     * @param key Key to search for
     * @return String value
     */
    public static String getValue(JsonNode node, String key) {
        if (node != null && node.has(key)) {
            return node.get(key).asText();
        }
        return null;
    }
}

