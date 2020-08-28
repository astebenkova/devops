#! /usr/local/env python3

import datetime
import random

average_life_expectancy = (65, 80)

# def death_prediction(age):
#     if age < 25 :


now = datetime.datetime.now()
name = str(input("Your name is: "))
age = int(input("Your age is: "))
# sex =
death_year = random.randint(now.year+10, now.year+35)

print(f"Current year: {now.year}\nYou'll die in {death_year}")