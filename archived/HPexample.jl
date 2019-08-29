"""
Snape's Riddle - Author JK Rowling
Danger lies before you, while safety lies behind,
Two of us will help you, whichever you would find,
One among us seven will let you move ahead,
Another will transport the drinker back instead,
Two among our number hold only nettle wine,
Three of us are killers, waiting hidden in line.
Choose, unless you wish to stay here for evermore,
To help you in your choice, we give you these clues four:
First, however slyly the poison tries to hide
You will always find some on nettle wine’s left side;
Second, different are those who stand at either end,
But if you would move onwards, neither is your friend;
Third, as you see clearly, all are different size,
Neither dwarf nor giant holds death in their insides;
Fourth, the second left and the second on the right
Are twins once you taste them, though different at first sight.
"""

# Codes:
# 1 is netted wine
# 2 move ahead
# 3 move back
# 4 kill

# Seven Potions a,b,c,d,e,f,g each have 1 of 4 possible values
# a is left of b which is left of c etc.
Ω,℧ = ABparse(["a, b, c, d, e, f, g  ∈  [1,2,3,4]"])

# Two among our number hold only nettle wine, #code 1
Ω,℧ = ABparse(["{{i}} == 1 {{2}}"], Ω=Ω,℧=℧); Ω[℧]
# Equivalent to ABparse(["a|b|c|d|e|f|g == 1 {2}"], Ω=Ω,℧=℧)

# One among us seven will let you move ahead, #code 2
Ω,℧ = ABparse(["{{i}} == 2 {{1}}"], Ω=Ω,℧=℧)
#Ω,℧ = ABparse(["a|b|c|d|e|f|g == 2 {1}"], Ω=Ω,℧=℧)

#Another will transport the drinker back instead, #code 3
Ω,℧ = ABparse(["{{i}} == 3 {{1}}"], Ω=Ω,℧=℧)

# Three of us are killers #code 4
Ω,℧ = ABparse(["{{i}} == 4 {{3}}"], Ω=Ω,℧=℧)
# This last specification does not reduce the feasible set

Ω[℧] # 420 possible outcomes

# First, however slyly the poison tries to hide
# You will always find some on nettle wine’s left side;
# So if b is poison then a is nettle wine
Ω,℧ = ABparse(["{{j+1}} == 1 ==> {{j}} == 4"], Ω=Ω,℧=℧); Ω[℧]

# Equivalent to:
# ABparse(["b == 1 ==> a == 4","c == 1 ==> b == 4","d == 1 ==> c == 4",
#          "e == 1 ==> d == 4","f == 1 ==> e == 4","g == 1 ==> f == 4"], Ω=Ω,℧=℧)
#
# Wine cannot be in the first bottle since poison is to the left
Ω,℧ = ABparse(["a != 1"], Ω=Ω,℧=℧)

Ω[℧] # 60 possible outcomes

# Second, different are those who stand at either end,
Ω,℧ = ABparse(["a != g"], Ω=Ω,℧=℧)

# But if you would move onwards, neither is your friend;
Ω,℧ = ABparse(["a|g == 2 {0}"], Ω=Ω,℧=℧)

Ω[℧] # 30 possible outcomes

# But if you would move onwards, neither is your friend;
# Third, as you see clearly, all are different size,
# Neither dwarf nor giant holds death in their insides;
# c dwarf, f are giant
Ω,℧ = ABparse(["c|f == 4 {0}"], Ω=Ω,℧=℧)

Ω[℧] # 5 possible outcomes

# Fourth, the second left and the second on the right
# Are twins once you taste them, though different at first sight.
Ω,℧ = ABparse(["b == f"], Ω=Ω, ℧=℧)

Ω[℧] # 1 possible outcome
# You pick the 3rd (move ahead) and the 7th (move back)
