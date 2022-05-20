Misc. scripts used when preparing the French wordlist.

This is not an exhaustive list, nor meant to facilitate recreation of the list. There
were manual steps involved. These scripts are simply here to illustrate (approximately)
what went into preparing the word list.

Order of operations:
- unmunch French hunspell dictionary
- use `1_to_lemma5.py` to grab each word's canonical form (lemma) if it is 
  alphanumeric and 5 letters wrong. 
  The alphanumeric test is needed to filter out some weird edge cases.
  Also convert `oe` and `ae` to two distinct characters (before length test) because
  the game does not include these symbols on the keyboard.
- use `2_normalize.sh` to prepare the answer list, and the guess list.
  
  For the answers, grab everything that is lowercase, remove diacritics, and
  filter on some hardcoded (trial-and-error) suffixes. This is not a scientific approach,
  but the idea is to err towards having less words, but with more certainty that they
  will be fun for the player. E.g. we don't want `wushu` and similar showing up.

  Also filter out some obvious wrong words, or vulgarities.

  For the guess list (allowed guesses) we want to keep everything that is alphanumeric,
  but we allow words that start with uppercase (e.g. Erica), and there are no
  filtering (everything goes, which is technically a word).
  
