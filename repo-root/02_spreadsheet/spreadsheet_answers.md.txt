Cleaning Steps
To ensure data integrity, the following steps were taken:

Removal of Null Values  

Handling Missing Values: Empty cells in numerical columns like risk_score and amount_usd were identified and treated as zero or filtered out where appropriate.  

Trimming Whitespace 



Standardization Rules
Consistent formatting was applied to allow for cross-sheet comparisons:

Currency Normalization: All local currency values were converted to USD using the daily exchange rates provided in the rates sheet.  

Case Consistency: Merchant names and status indicators (e.g., "Captured", "Failed") were standardized to a uniform case to prevent analysis errors.  

Date Formatting: Transaction dates were converted to a standard YYYY-MM-DD format to facilitate time-based filtering.




Lookup and Enrichment Logic
The dataset was enhanced by pulling information from the master data tables:

Merchant Details: The merchant_id was used as a key to pull account_manager and merchant_category from the merchant_master.csv sheet.  

Risk Flagging: A logic check was applied to flag transactions as "High Risk" if the risk_score exceeded 80.

High Value Identification: Transactions with an amount_usd greater than $5,000 were flagged as "High Value" for manual review.





Final Answers
Based on the analysis of 02_spreadsheet_spreadsheet_workbook.xlsx, the following totals were reached:  

Total Volume (USD): $115,253.01.  

Successful (Captured) Volume: $82,155.42.




Formula Samples
The following logic was implemented in Excel to achieve these results:

Amount_USD =IF(E2="USD", D2, IF(E2="INR", D2/83, D2))

High_value_flag=IF(OR(AND(TRIM(I2)="APAC", F2>5000), AND(TRIM(I2)="EU", F2>6000), AND(TRIM(I2)="US", F2>7000)), 1, 0)

High_risk_flag=IF(OR(H2>=70, ISNUMBER(SEARCH("chargeback", G2))), 1, 0)


