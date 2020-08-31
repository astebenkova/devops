#!/usr/bin/env python3

import datetime
import random
import contextlib
from contextlib import ExitStack
import os
import pdb

average_life_expectancy = (65, 80)
current_time = datetime.datetime.now()
current_year = current_time.year


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

permission = os.getenv("PERM_LOG", True)
if permission:
    try:
        pdb.set_trace()
        with ExitStack() as stack:
            filename = "/tmp/death.log"
            f = stack.enter_context(open(filename, 'x'))
            stack.enter_context(contextlib.redirect_stdout(f))
            print(f'{current_time.strftime("%m/%d/%Y, %H:%M:%S")}: You are {name} and you are {age} years old.')
            death_prediction(age)
    except FileExistsError:
        print("[!] File already exists.")
    finally:
        print("[*] Execution completed.")

else:
    print("You are not permitted to write a log file.")
