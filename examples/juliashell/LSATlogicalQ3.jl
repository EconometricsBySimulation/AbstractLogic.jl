# Word Problems Logical Reasoning Tests
# http://www.graduatewings.co.uk/word-problems-logical-tests

# Questions 11-17
using AbstractLogic

"""
A cruise line is scheduling seven week-long voyages for the ship Freedom. Each
voyage will occur in exactly one of the first seven weeks of the season:
weeks 1 through 7. Each voyage will be to exactly one of four destinations:
Guadeloupe, Jamaica, Martinique, or Trinidad. Each destination will be scheduled
for at least one of the weeks. The following conditions apply to Freedom’s schedule:
"""

# exactly one of four destinations: Guadeloupe, Jamaica, Martinique, or Trinidad
logicset = logicalparse(
  ["w1, w2, w3, w4, w5, w6, w7  ∈ Guadeloupe, Jamaica, Martinique, Trinidad"])

# Each destination will be scheduled for at least one of the weeks.
logicset = logicalparse(["{{i}} = 'Guadeloupe' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} = 'Jamaica' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} = 'Martinique' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} = 'Trinidad' {{1,}}"], logicset)

# Jamaica will not be its destination in week 4.
logicset = logicalparse(["w4 != 'Jamaica'"], logicset)

# Trinidad will be its destination in week 7.
logicset = logicalparse(["w7 = 'Trinidad'"], logicset)

# Freedom will make exactly two voyages to Martinique,
logicset = logicalparse(["{{i}} = 'Martinique' {{2}}"], logicset)

# and at least one voyage to Guadeloupe will occur in some week between those two voyages.
# Unfortunately this can be a bit tedious.
logicset = logicalparse(["w1,w7 = 'Martinique' ==> w2,w3,w4,w5,w6 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w2,w7 = 'Martinique' ==> w3,w4,w5,w6 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w3,w7 = 'Martinique' ==> w4,w5,w6 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w4,w7 = 'Martinique' ==> w5,w6 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w5,w7 = 'Martinique' ==> w6 |= 'Guadeloupe'"], logicset)

logicset = logicalparse(["w1,w6 = 'Martinique' ==> w2,w3,w4,w5 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w2,w6 = 'Martinique' ==> w3,w4,w5 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w3,w6 = 'Martinique' ==> w4,w5 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w4,w6 = 'Martinique' ==> w5 |= 'Guadeloupe'"], logicset)

logicset = logicalparse(["w1,w5 = 'Martinique' ==> w2,w3,w4 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w2,w5 = 'Martinique' ==> w3,w4 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w3,w5 = 'Martinique' ==> w4 |= 'Guadeloupe'"], logicset)

logicset = logicalparse(["w1,w4 = 'Martinique' ==> w2,w3 |= 'Guadeloupe'"], logicset)
logicset = logicalparse(["w2,w4 = 'Martinique' ==> w3 |= 'Guadeloupe'"], logicset)

logicset = logicalparse(["w1,w3 = 'Martinique' ==> w2 |= 'Guadeloupe'"], logicset)

# Guadeloupe will be its destination in the week preceding any voyage it makes to Jamaica.
logicset = logicalparse(["{{i}} = 'Jamaica' ==> {{i-1}} = 'Guadeloupe'"], logicset)
logicset = logicalparse(["w1 != 'Jamaica'"], logicset)

# No destination will be scheduled for consecutive weeks.
logicset = logicalparse(["{{i}} != {{i+1}}"], logicset)

######
# 11. Which one of the following is an acceptable schedule of destinations for
# Freedom, in order from week 1 through week 7?

# (A) Guadeloupe, Jamaica, Martinique, Trinidad, Guadeloupe, Martinique, Trinidad
# I'll just check the first 4 weeks at first
checkfeasible(
  "w1 = 'Guadeloupe'; w2 = 'Jamaica'; w3 = 'Martinique'; w4 = 'Trinidad';
   w5 = 'Guadeloupe'; w6 = 'Martinique'; w7 = 'Trinidad'", logicset)
# true, 1 out of 50 possible combinations 'true'.

# (B) Guadeloupe, Martinique, Trinidad, Martinique, Guadeloupe, Jamaica, Trinidad
checkfeasible("w1 = 'Guadeloupe'; w2 = 'Martinique'; w3 = 'Trinidad'; w4 = 'Martinique';
 w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'", logicset)
# false, 0 out of 50 possible combinations 'true'.

# (C) Jamaica, Martinique, Guadeloupe, Martinique, Guadeloupe, Jamaica, Trinidad
checkfeasible("w1 = 'Jamaica'; w2 = 'Martinique'; w3 = 'Guadeloupe'; w4 = 'Martinique';
 w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'", logicset)
# false, 0 out of 50 possible combinations 'true'.

# (D) Martinique, Trinidad, Guadeloupe, Jamaica, Martinique, Guadeloupe, Trinidad
checkfeasible("w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Jamaica';
 w5 = 'Martinique'; w6 = 'Guadeloupe'; w7 = 'Trinidad'", logicset)
# false, 0 out of 50 possible combinations 'true'.

# (E) Martinique, Trinidad, Guadeloupe, Trinidad, Guadeloupe, Jamaica, Martinique
checkfeasible("w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Trinidad';
 w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Martinique'", logicset)
# false, 0 out of 50 possible combinations 'true'.


######
# 12. Which one of the following CANNOT be true about Freedom’s schedule of voyages?
# (A) Freedom makes a voyage to Trinidad in week 6
checkfeasible("w6 = 'Trinidad'", logicset)
# false, 0 out of 50 possible combinations 'true'.  - Answer

# (B) Freedom makes a voyage to Martinique in week 5.
checkfeasible("w5 = 'Martinique'", logicset)
# possible,  11 out of 25 possible combinations 'true'.

# (C) Freedom makes a voyage to Jamaica in week 6.
checkfeasible("w6 = 'Jamaica'", logicset)
# possible,  3 out of 25 possible combinations 'true'.

# (D) Freedom makes a voyage to Jamaica in week 3.
checkfeasible("w3 = 'Jamaica'", logicset)
# possible,  8 out of 25 possible combinations 'true'.

# (E) Freedom makes a voyage to Guadeloupe in week 3
checkfeasible("w3 = 'Guadeloupe'", logicset)
# possible,  4 out of 25 possible combinations 'true'.


######
# 13. If Freedom makes a voyage to Trinidad in week 5, which one of the following
# could be true?
logicsetreduced = logicalparse(["w5 = 'Trinidad'"], logicset)

#  (A) Freedom makes a voyage to Trinidad in week 1.
checkfeasible("w1 = 'Trinidad'", logicsetreduced)[2]
#false, 0 out of 3 possible combinations 'true'.

# (B) Freedom makes a voyage to Martinique in week 2.
checkfeasible("w2 = 'Martinique'", logicsetreduced)
# false, 0 out of 3 possible combinations 'true'.

# (C) Freedom makes a voyage to Guadeloupe in week 3.
checkfeasible("w3 = 'Guadeloupe'", logicsetreduced)
# false, 0 out of 3 possible combinations 'true'.

# (D) Freedom makes a voyage to Martinique in week 4.
checkfeasible("w4 = 'Martinique'", logicsetreduced)
# possible,  1 out of 3 possible combinations 'true'.

# (E) Freedom makes a voyage to Jamaica in week 6.
checkfeasible("w6 = 'Jamaica'", logicsetreduced)
# false, 0 out of 3 possible combinations 'true'.


######
# 14. If Freedom makes a voyage to Guadeloupe in week 1 and a voyage to Jamaica in
# week 5, which one of the following must be true?
logicsetreduced = logicalparse(["w1 = 'Guadeloupe'; w5 = 'Jamaica'"], logicset)

# (A) Freedom makes a voyage to Jamaica in week 2.
checkfeasible("w2 = 'Jamaica'", logicsetreduced)
# possible,  1 out of 3 possible combinations 'true'.

# (B) Freedom makes a voyage to Trinidad in week 2.
checkfeasible("w2 = 'Trinidad'", logicsetreduced)
# possible,  1 out of 3 possible combinations 'true'.

# (C) Freedom makes a voyage to Martinique in week 3.
checkfeasible("w3 = 'Martinique'", logicsetreduced)
# possible,  2 out of 3 possible combinations 'true'.

# (D) Freedom makes a voyage to Guadeloupe in week 6.
checkfeasible("w6 = 'Guadeloupe'", logicsetreduced)
# false, 0 out of 3 possible combinations 'true'.

# (E) Freedom makes a voyage to Martinique in week 6.
checkfeasible("w6 = 'Martinique'", logicsetreduced)
#true, 3 out of 3 possible combinations 'true'.


######
# 15. If Freedom makes a voyage to Guadeloupe in week 1 and to Trinidad in
# week 2, which one of the following must be true?
logicsetreduced = logicalparse(["w1 = 'Guadeloupe'; w2 = 'Trinidad'"], logicset)

# (A) Freedom makes a voyage to Martinique in week 3.
checkfeasible("w3 = 'Martinique'", logicsetreduced, force=true)
# true, 1 out of 1 possible combinations 'true'.

# (B) Freedom makes a voyage to Martinique in week 4.
checkfeasible("w4 = 'Martinique'", logicsetreduced, force=true)
# false, 0 out of 1 possible combinations 'true'.

# (C) Freedom makes a voyage to Martinique in week 5.
checkfeasible("w5 = 'Martinique'", logicsetreduced, force=true)
# false, 0 out of 1 possible combinations 'true'.

# (D) Freedom makes a voyage to Guadeloupe in week 3.
checkfeasible("w3 = 'Guadeloupe'", logicsetreduced, force=true)
# false, 0 out of 1 possible combinations 'true'.

# (E) Freedom makes a voyage to Guadeloupe in week 5
checkfeasible("w5 = 'Guadeloupe'", logicsetreduced, force=true)
# false, 0 out of 1 possible combinations 'true'.

######
# 16. If Freedom makes a voyage to Martinique in week 3, which one of the
# following could be an accurate list of Freedom’s destinations in week 4
# and week 5,respectively?
logicsetreduced = logicalparse(["w3 = 'Martinique'"], logicset)

# (A) Guadeloupe, Trinidad
checkfeasible("w4 = 'Guadeloupe'; w5 = 'Trinidad'", logicsetreduced, any=true)
# true,  1 out of 8 possible combinations 'true'.

# (B) Jamaica, Guadeloupe
checkfeasible("w4 = 'Jamaica'; w5 = 'Guadeloupe'", logicsetreduced, any=true)
# false, 0 out of 8 possible combinations 'true'.

# (C) Martinique, Trinidad
checkfeasible("w4 = 'Martinique'; w5 = 'Trinidad'", logicsetreduced, any=true)
# false, 0 out of 8 possible combinations 'true'.

# (D) Trinidad, Jamaica
checkfeasible("w4 = 'Trinidad'; w5 = 'Jamaica'", logicsetreduced, any=true)
# false, 0 out of 8 possible combinations 'true'.

# (E) Trinidad, Martinique
checkfeasible("w4 = 'Trinidad'; w5 = 'Martinique'", logicsetreduced, any=true)
# false, 0 out of 8 possible combinations 'true'.

######
# 17. Which one of the following must be true about Freedom’s schedule of voyages?

# (A) Freedom makes a voyage to Guadeloupe either in week 1 or else in week 2.
checkfeasible("w1|w2 = 'Guadeloupe'", logicset, force=true)
# false, 22 out of 25 possible combinations 'true'.
logicalparse(["w1,w2 != 'Guadeloupe'"], logicset)

# (B) Freedom makes a voyage to Martinique either in week 2 or else in week 3.
checkfeasible("w2|w3 = 'Martinique'", logicset, force=true)
# false, 12 out of 25 possible combinations 'true'.

# (C) Freedom makes at most two voyages to Guadeloupe.
checkfeasible("{{i}} = 'Guadeloupe' {{,2}}", logicset, force=true)
# false, 20 out of 25 possible combinations 'true'.

# (D) Freedom makes at most two voyages to Jamaica.
checkfeasible("{{i}} = 'Jamaica' {{,2}}", logicset, force=true)
# true, 25 out of 25 possible combinations 'true'.

# (E) Freedom makes at most two voyages to Trinidad.
checkfeasible("{{i}} = 'Trinidad' {{,2}}", logicset, force=true)
# false, 24 out of 25 possible combinations 'true'.
