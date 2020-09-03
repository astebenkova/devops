# The script creates a yml cloud config from a Jinja2 template based on the Google Spreadsheets data
from __future__ import print_function
import pickle
import os.path
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from jinja2 import Environment, FileSystemLoader
from netaddr import EUI, mac_unix_expanded, core


# The ID, scope and range of spreadsheets.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
SPREADSHEET_ID = '1XS_YuegNqWfK2f3QLZJe9QQIgsF_0skdg1-L_DGprJ8'
RANGE_NAME_1 = 'hw_inventory!A2:B'
RANGE_NAME_2 = 'hw_access!A2:D'
TEMPLATE_PATH = './templates'
# Path to Google Credentials (.json)
GOOGLE_CREDENTIALS = './credentials.json'


def authenticate():
    """Authenticate with Google"""
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is created
    # automatically when the authorization flow completes for the first time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(GOOGLE_CREDENTIALS, SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    return creds


def merge_lists(list1, list2):
    """
    Merges 2 lists into one by a common element
    NOTE: the first list should be the one containing more columns
    """
    return [a + [b[1]] for (a, b) in zip(list1, list2)]


def sheet_into_list(spreadsheet_id, range_name, credentials):
    """Returns a list of lists out of a Google sheet"""
    service = build('sheets', 'v4', credentials=credentials)
    sheet = service.spreadsheets()
    sheet_result = sheet.values().get(spreadsheetId=spreadsheet_id, range=range_name).execute()
    sheet_list = sheet_result.get('values', [])

    return sheet_list


def generate_file_from_template(data, template_name):
    """Generates a yml config file from a template"""
    env = Environment(loader=FileSystemLoader(TEMPLATE_PATH))
    env.globals['convert_mac'] = convert_mac
    template = env.get_template(template_name)
    output = template.render(servers=data)
    with open('inventory.yml', 'w') as f:
        print(output, file=f)


def convert_mac(mac):
    """Converts a string to MAC address in UNIX format XX:XX:XX:XX:XX"""
    try:
        addr = EUI(mac)
        addr.dialect = mac_unix_expanded
        return addr
    except core.AddrFormatError as err:
        print(f"You are ugly. Go and check the MAC address.\n{err}")


def main():
    """Main function"""
    creds = authenticate()
    hw_sheet_list = sheet_into_list(SPREADSHEET_ID, RANGE_NAME_1, creds)
    access_sheet_list = sheet_into_list(SPREADSHEET_ID, RANGE_NAME_2, creds)

    if not hw_sheet_list or not access_sheet_list:
        print('One or both of the spreadsheets are empty.')
    else:
        # Combine two sheets in one by a common column "serial"
        final_sheet = merge_lists(access_sheet_list, hw_sheet_list)
        generate_file_from_template(final_sheet, "cloud.j2")


if __name__ == '__main__':
    main()
