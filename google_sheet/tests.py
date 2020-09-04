from unittest import TestCase, skip
from .spreadsheet import *


class SpreadsheetTests(TestCase):

    def setUp(self):
        self.sheet1 = [['name1', 'ip1', 'user1', 'password1'],
                       ['name2', 'ip2', 'user2', 'password2'],
                       ['name3', 'ip3', 'user3', 'password3']]
        self.sheet2 = [['name1', 'mac1'], ['name2', 'mac2'], ['name3', 'mac3']]

    @skip("Demonstrating skipping")
    def test_unique_sheets(self):
        """Tests that two sheets are different."""
        self.assertNotEqual(self.sheet1, self.sheet2)

    def test_merge_lists(self):
        merged_sheet = merge_lists(self.sheet1, self.sheet2)
        self.assertEqual(merged_sheet, [['name1', 'ip1', 'user1', 'password1', 'mac1'],
                                        ['name2', 'ip2', 'user2', 'password2', 'mac2'],
                                        ['name3', 'ip3', 'user3', 'password3', 'mac3']])

    def test_mac_convert(self):
        """Tests that MAC is being converted properly"""
        mac_1 = "94-e6-f7-63-93-b8"
        mac_2 = "94E6F76393B8"
        mac_3 = "94E6F76fghjg393B812JH"
        mac = convert_mac(mac_1)
        self.assertEqual(mac, "94:e6:f7:63:93:b8")
        mac = convert_mac(mac_2)
        self.assertEqual(mac, "94:e6:f7:63:93:b8")
        mac = convert_mac(mac_3)
        self.assertIsNone(mac)

    def check_lists_empty(self):
        """Tests that the script breaks if one of the lists is empty (or both)"""
        sheet3 = []
        with self.assertRaises(EmptyListError):
            merge_lists(sheet3, self.sheet1)

    def check_authentication(self):
        """Makes sure authentication fails without a json cred file"""
        wrong_creds = "./creds.json"
        with self.assertRaises(Exception):
            authenticate(wrong_creds)
