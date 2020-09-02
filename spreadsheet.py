from __future__ import print_function
import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from jinja2 import Environment, FileSystemLoader
# from pprint import pprint


# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']

# The ID and range of a sample spreadsheet.
SPREADSHEET_ID = '1XS_YuegNqWfK2f3QLZJe9QQIgsF_0skdg1-L_DGprJ8'
RANGE_NAME_HW = 'hw_inventory!A2:B'
RANGE_NAME_CRED = 'hw_access!B2:D'


def main():
    """Shows basic usage of the Sheets API.
    Prints values from a sample spreadsheet.
    """
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    service = build('sheets', 'v4', credentials=creds)

    # Call the Sheets API
    sheet = service.spreadsheets()
    hw_sheet_result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range=RANGE_NAME_HW).execute()
    hw_sheet_values = hw_sheet_result.get('values', [])

    access_sheet_result = sheet.values().get(spreadsheetId=SPREADSHEET_ID, range=RANGE_NAME_CRED).execute()
    access_sheet_values = access_sheet_result.get('values', [])

    whole_info = zip(hw_sheet_values, access_sheet_values)

    if not hw_sheet_values or not access_sheet_values:
        print('No data found.')
    else:
        env = Environment(loader=FileSystemLoader('templates'))
        template = env.get_template('cloud.j2')
        output = template.render(servers=hw_sheet_values, creds=access_sheet_values, whole_info=whole_info)
        with open('inventory.yml', 'w') as f:
            print(output, file=f)


if __name__ == '__main__':
    main()
