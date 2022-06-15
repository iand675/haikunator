from textblob import TextBlob

f = open("basho-poems", "r")

text = f.read()

blob = TextBlob(text)
blob.tags           # [('The', 'DT'), ('titular', 'JJ'),
                    #  ('threat', 'NN'), ('of', 'IN'), ...]

nouns = set()

for tag in [x for x in blob.tags if (x[1] == "NN" or x[1] == "NNS") and x[0] not in ["/", "”", "–"]]:
    nouns.add(tag[0])


sortedNouns = list(nouns)
sortedNouns.sort()


adjectives = set()
for tag in [x for x in blob.tags if (x[1] == "JJ") and x[0] not in ["/", "”", "–"]]:
    adjectives.add(tag[0])

sortedAdjs = list(adjectives)
sortedAdjs.sort()

nf = open("nouns", "w")
nf.writelines(n + '\n' for n in sortedNouns)

af = open("adjectives", "w")
af.writelines(a + '\n' for a in sortedAdjs)

