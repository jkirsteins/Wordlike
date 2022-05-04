import spacy


def should_include(word):
    return word.isalnum() and len(word) == 5


nlp = spacy.load('fr_core_news_md')

with open("fr_full.txt") as f:
    fr_full = [_.strip() for _ in f.readlines()]

lemmas = set()
incr = 0
for w in fr_full:
    if incr % 5000 == 0:
        print("Progress:", incr, "/", len(fr_full), "{:.0%}".format(incr / len(fr_full)))
    incr += 1
    doc = nlp(w)
    for token in doc:
        # expand oe before we filter for length
        lemmas.add(token.lemma_.replace("œ", "oe").replace("æ", "ae"))


with open("fr_lemmas_5.txt", "w") as f:
    f.write("\n".join([_ for _ in lemmas if should_include(_)]))

# doc = nlp(u"Apples and oranges are similar. Boots and hippos aren't.")
#
#for token in doc:
#        print(token, token.lemma, token.lemma_)
