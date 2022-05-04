#!/bin/python3

import os
import json

def process(word, data):
    if word in data.keys():
        new_word = data[word]
        if len(new_word) == 5:
            print("Replacing", word, "with", new_word)
            return new_word
        else:
            print("Dropping", word)
            return ""

    return word

with open("us_spellings.json", "r") as f:
    data = json.load(f)

with open("british_spellings.json", "r") as f:
    br_data = json.load(f)


with open("en_A.txt", "r") as f:
    answers = [x.strip() for x in f.readlines()]

with open("en_G.txt", "r") as f:
    guesses = [x.strip() for x in f.readlines()]


# List of 5 letter british words that don't appear in the US word lists yet
british_guesses = [br for br in br_data.keys() if len(br) == 5 and br not in guesses]

print("==> Replacing answers")
for ix in range(len(answers)):
    answers[ix] = process(answers[ix], data)

print("==> Replacing guesses")
for ix in range(len(guesses)):
    guesses[ix] = process(guesses[ix], data)

with open("en-GB_A.txt", "w") as f:
    f.writelines([f"{word}\n" for word in answers if word.strip()])
    
with open("en-GB_G.txt", "w") as f:
    f.writelines([f"{word}\n" for word in guesses + british_guesses if word.strip()])

os.system("echo \"US A\"; cat en_A.txt | wc -l")
os.system("echo \"US G\"; cat en_G.txt | wc -l")
os.system("echo \"GB A\"; cat en-GB_A.txt | wc -l")
os.system("echo \"GB G\"; cat en-GB_G.txt | wc -l")
