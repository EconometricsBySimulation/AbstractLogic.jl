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
using AbstractLogic

# Codes:
# 1 is netted wine - NW
# 2 move ahead     - MA
# 3 move back      - MB
# 4 poison         - PO

# Seven Potions a,b,c,d,e,f,g each have 1 of 4 possible values
# a is left of b which is left of c etc.
hpset = logicalparse("a, b, c, d, e, f, g  ∈  NW, MA, MB, PO")

# Two among our number hold only nettle wine, #code 1
hpset = logicalparse("{{i}} == 'NW' {{2}}", logicset=hpset); showfeasible(hpset)
# Equivalent to logicalparse(["a|b|c|d|e|f|g == 1 {2}"], logicset=hpset)

# One among us seven will let you move ahead, #code 2
hpset = logicalparse("{{i}} == 'MA' {{1}}", logicset=hpset); showfeasible(hpset)
#hpset = logicalparse(["a|b|c|d|e|f|g == 2 {1}"], logicset=hpset)

#Another will transport the drinker back instead, #code 3
hpset = logicalparse("{{i}} == 'MB' {{1}}", logicset=hpset); showfeasible(hpset)

# Three of us are killers #code 4
hpset = logicalparse("{{i}} == 'PO' {{3}}", logicset=hpset); showfeasible(hpset)
# This last specification does not reduce the feasible set

# First, however slyly the poison tries to hide
# You will always find some on nettle wine’s left side;
# So if b is poison then a is nettle wine
# The i-1! indicates that outofbounds matches are considered "false"
hpset = logicalparse("{{i}} == 'NW' ==> {{i-1!}} == 'PO'", logicset=hpset); showfeasible(hpset)
# 60 possible outcomes

# Second, different are those who stand at either end,
hpset = logicalparse("a != g", logicset=hpset)

# But if you would move onwards, neither is your friend;
hpset = logicalparse("a,g != 'MA'", logicset=hpset); showfeasible(hpset)
# 30 possible outcomes

# Third, as you see clearly, all are different size,
# Neither dwarf nor giant holds death in their insides;
# c dwarf, f are giant
hpset = logicalparse("c,f != 'PO'", logicset=hpset); showfeasible(hpset)

# Fourth, the second left and the second on the right
# Are twins once you taste them, though different at first sight.
hpset = logicalparse("b == f", logicset=hpset)

search("='MA'", hpset) # c is a match, for the third bottle
search("='MB'", hpset) # g is a match, for the last bottle
