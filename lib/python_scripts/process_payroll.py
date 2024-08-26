# lib/python_scripts/process_payroll.py
import pandas as pd
import sys

def process_payroll(files):
    # Validate that all necessary files are present
    if len(files) < 4:
        raise ValueError("All four files (Revel data, Tips data 1, Tips data 2, Loan payments) are required.")

    # Load each Excel file using pandas
    revel_df = pd.read_excel(files[0], engine='openpyxl')
    tips_df_1 = pd.read_excel(files[1], engine='openpyxl')
    tips_df_2 = pd.read_excel(files[2], engine='openpyxl')
    loan_df = pd.read_excel(files[3], engine='openpyxl')

    # Ensure necessary columns exist in each DataFrame
    for df, file_name, required_columns in [
        (revel_df, files[0], ['first_name', 'last_name', 'hours_worked', 'overtime_hours_worked']),
        (tips_df_1, files[1], ['first_name', 'last_name', 'reported_tips']),
        (tips_df_2, files[2], ['first_name', 'last_name', 'reported_tips']),
        (loan_df, files[3], ['first_name', 'last_name', 'loan_payment'])
    ]:
        for column in required_columns:
            if column not in df.columns:
                raise ValueError(f"Required column '{column}' not found in file {file_name}")

    # Keep only necessary columns from Revel file
    revel_df = revel_df[['first_name', 'last_name', 'hours_worked', 'overtime_hours_worked']]

    # Merge tips data with Revel data based on first and last name
    merged_df = pd.merge(
        revel_df,
        tips_df_1[['first_name', 'last_name', 'reported_tips']],
        on=['first_name', 'last_name'],
        how='left'
    )
    merged_df = pd.merge(
        merged_df,
        tips_df_2[['first_name', 'last_name', 'reported_tips']],
        on=['first_name', 'last_name'],
        how='left',
        suffixes=('_tips1', '_tips2')
    )

    # Combine the reported tips from both files, fill NaN values with 0
    merged_df['total_reported_tips'] = merged_df['reported_tips_tips1'].fillna(0) + merged_df['reported_tips_tips2'].fillna(0)

    # Drop individual tips columns if only the combined total is needed
    merged_df.drop(['reported_tips_tips1', 'reported_tips_tips2'], axis=1, inplace=True)

    # Merge loan data with the combined dataframe based on first and last name
    master_df = pd.merge(
        merged_df,
        loan_df[['first_name', 'last_name', 'loan_payment']],
        on=['first_name', 'last_name'],
        how='left'
    )

    # Fill NaN values with 0 or appropriate defaults if needed
    master_df.fillna({
        'hours_worked': 0,
        'overtime_hours_worked': 0,
        'total_reported_tips': 0,
        'loan_payment': 0
    }, inplace=True)

    # Save the consolidated data to a new Excel file
    master_file_path = 'master_payroll_file.xlsx'
    master_df.to_excel(master_file_path, index=False)

    return master_file_path

if __name__ == "__main__":
    files = sys.argv[1:]  # Get file paths from command line arguments
    process_payroll(files)
