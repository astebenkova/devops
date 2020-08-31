#!/usr/bin/env python3

import datetime
import random
import contextlib
from contextlib import ExitStack
import os

average_life_expectancy = (65, 80)
current_year = datetime.datetime.now().year


def death_prediction(age):
    if age < average_life_expectancy[0]:
        death_age = random.choice(average_life_expectancy)
    elif age in range(*average_life_expectancy):
        death_age = random.randint(age, average_life_expectancy[1])
    else:
        print("Aren't you dead yet?")
        return

    death_year = current_year + (death_age - age)
    print(f"Current year: {current_year}\nYou'll die in {death_year}")


name = str(input("Your name is: "))
age = int(input("Your age is: "))
death_prediction(age)

permission = os.getenv("PERM_LOG", False)
if permission:
    with ExitStack() as stack:
        f = stack.enter_context(open('/tmp/death.log', 'w'))
        stack.enter_context(contextlib.redirect_stdout(f))
        print(f"You are {name} and you are {age} years old.")
        death_prediction(age)
else:
    print("You are not permitted to write a log file.")
