Misc. scripts used when preparing the Latvian wordlist.

This is not an exhaustive list, nor meant to facilitate recreation of the list. There
were manual steps involved. These scripts are simply here to illustrate (approximately)
what went into preparing the word list.

Order of operations:
- unmunch Latvian hunspell dictionary, and filter for 5 letter words
- split entire 5 word list (incl. all possible forms) into chunks of 10k lines
- apply `process_raw_list.sh` on these chunks
- apply `assemble.sh` to recombine the chunks into a single file (and validate 
  words against <https://tezaurs.lv>. Some of the output words were invalid, so
  they were dropped at this step.
- perform some simple deduplication (so e.g. both plural/singular of the same word
  are not present) using `remove_plurals.py`
    - this script also does some extra validation, and might introduce hardcoded words
      that were not picked up until this step
- finally `sort -u` and call it a day.

The desired output is to have mostly the word lemma in the list (to facilitate
guessing).

This is not explicitly spelled out anywhere, the player must conclude this themselves.
