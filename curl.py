import pycurl
# import os


def get_my_ip():
    """A curl request that returns your current external IP."""
    curl = pycurl.Curl()
    curl.setopt(curl.URL, "https://ipinfo.io/ip?")
    curl.perform()


get_my_ip()
