with open("validated.txt", "r") as f:
    lines = [x.strip() for x in f.readlines() if x.strip()]

# Some values not included in the original file
hardcoded = [
        "brits",
        "agara",
        ]
skipped = []

final_lines = lines + hardcoded

for w in final_lines:
    # Cleanup some weird edge cases (e.g. 'bulv.' as a contraction)
    if not w.isalnum():
        print("Skipping", w, "because not alphanumeric")
        skipped.append(w)
        continue

    # Skip 1st declension plurals if they're present as singulars also
    if w[-1] == "i":
        candidates = [ [*w], [*w] ]
        candidates[0][-1] = "s"
        candidates[1][-1] = "š"
        candidates = [ "".join(_) for _ in candidates ]
        if candidates[0] in final_lines or candidates[1] in final_lines:
            print("Skipping", w, "because the singular alternative is present")
            skipped.append(w)

new = [w for w in final_lines if w not in skipped]
with open("validated2.txt", "w") as f:
    f.write("\n".join(new))

