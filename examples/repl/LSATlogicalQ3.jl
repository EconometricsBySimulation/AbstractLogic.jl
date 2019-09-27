# Word Problems Logical Reasoning Tests
# http://www.graduatewings.co.uk/word-problems-logical-tests

# Questions 11-17

"""
A cruise line is scheduling seven week-long voyages for the ship Freedom. Each
voyage will occur in exactly one of the first seven weeks of the season:
weeks 1 through 7. Each voyage will be to exactly one of four destinations:
Guadeloupe, Jamaica, Martinique, or Trinidad. Each destination will be scheduled
for at least one of the weeks. The following conditions apply to Freedom’s schedule:
"""
julia> using AbstractLogic
Start the repl in command prompt by typing `=`.

# exactly one of four destinations: Guadeloupe, Jamaica, Martinique, or Trinidad
w1, w2, w3, w4, w5, w6, w7  ∈ Guadeloupe, Jamaica, Martinique, Trinidad [clear]

# Each destination will be scheduled for at least one of the weeks.
{{i}} = 'Guadeloupe' {{1,}}
{{i}} = 'Jamaica' {{1,}}
{{i}} = 'Martinique' {{1,}}
{{i}} = 'Trinidad' {{1,}}

# Jamaica will not be its destination in week 4.
w4 != 'Jamaica'

# Trinidad will be its destination in week 7.
w7 = 'Trinidad'

# Freedom will make exactly two voyages to Martinique,
{{i}} = 'Martinique' {{2}}

# and at least one voyage to Guadeloupe will occur in some week between those two voyages.
# Unfortunately this can be a bit tedious.
{{<i}} = 'Martinique' &&& {{>i}} = 'Martinique' &&& {{i}} = 'Guadeloupe' {{1,}}

# Guadeloupe will be its destination in the week preceding any voyage it makes to Jamaica.
{{i!}} = 'Jamaica' ==> {{i-1}} = 'Guadeloupe'

# No destination will be scheduled for consecutive weeks.
{{i}} != {{i+1}}

export lsat4

######
# 11. Which one of the following is an acceptable schedule of destinations for
# Freedom, in order from week 1 through week 7?

# (A) Guadeloupe, Jamaica, Martinique, Trinidad, Guadeloupe, Martinique, Trinidad
# I'll just check the first 4 weeks at first
check w1 = 'Guadeloupe'; w2 = 'Jamaica'; w3 = 'Martinique'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Martinique'; w7 = 'Trinidad'
# true, 1 out of 50 possible combinations 'true'.

# (B) Guadeloupe, Martinique, Trinidad, Martinique, Guadeloupe, Jamaica, Trinidad
check w1 = 'Guadeloupe'; w2 = 'Martinique'; w3 = 'Trinidad'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
# false, 0 out of 50 possible combinations 'true'.

# (C) Jamaica, Martinique, Guadeloupe, Martinique, Guadeloupe, Jamaica, Trinidad
check w1 = 'Jamaica'; w2 = 'Martinique'; w3 = 'Guadeloupe'; w4 = 'Martinique'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Trinidad'
# false, 0 out of 50 possible combinations 'true'.

# (D) Martinique, Trinidad, Guadeloupe, Jamaica, Martinique, Guadeloupe, Trinidad
check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Jamaica'; w5 = 'Martinique'; w6 = 'Guadeloupe'; w7 = 'Trinidad'
# false, 0 out of 50 possible combinations 'true'.

# (E) Martinique, Trinidad, Guadeloupe, Trinidad, Guadeloupe, Jamaica, Martinique
check w1 = 'Martinique'; w2 = 'Trinidad'; w3 = 'Guadeloupe'; w4 = 'Trinidad'; w5 = 'Guadeloupe'; w6 = 'Jamaica'; w7 = 'Martinique'
# false, 0 out of 50 possible combinations 'true'.


######
# 12. Which one of the following CANNOT be true about Freedom’s schedule of voyages?
# (A) Freedom makes a voyage to Trinidad in week 6
check w6 = 'Trinidad'
# false, 0 out of 50 possible combinations 'true'.  - Answer

# (B) Freedom makes a voyage to Martinique in week 5.
check w5 = 'Martinique'
# possible,  11 out of 25 possible combinations 'true'.

# (C) Freedom makes a voyage to Jamaica in week 6.
check w6 = 'Jamaica'
# possible,  3 out of 25 possible combinations 'true'.

# (D) Freedom makes a voyage to Jamaica in week 3.
check w3 = 'Jamaica'
# possible,  8 out of 25 possible combinations 'true'.

# (E) Freedom makes a voyage to Guadeloupe in week 3
check w3 = 'Guadeloupe'
# possible,  4 out of 25 possible combinations 'true'.


######
# 13. If Freedom makes a voyage to Trinidad in week 5, which one of the following
# could be true?
w5 = 'Trinidad'

#  (A) Freedom makes a voyage to Trinidad in week 1.
check w1 = 'Trinidad'
#false, 0 out of 3 possible combinations 'true'.

# (B) Freedom makes a voyage to Martinique in week 2.
check w2 = 'Martinique'
# false, 0 out of 3 possible combinations 'true'.

# (C) Freedom makes a voyage to Guadeloupe in week 3.
check w3 = 'Guadeloupe'
# false, 0 out of 3 possible combinations 'true'.

# (D) Freedom makes a voyage to Martinique in week 4.
check w4 = 'Martinique'
# possible,  1 out of 3 possible combinations 'true'.

# (E) Freedom makes a voyage to Jamaica in week 6.
check w6 = 'Jamaica'
# false, 0 out of 3 possible combinations 'true'.

import lsat4

######
# 14. If Freedom makes a voyage to Guadeloupe in week 1 and a voyage to Jamaica in
# week 5, which one of the following must be true?
w1 = 'Guadeloupe'; w5 = 'Jamaica'

# (A) Freedom makes a voyage to Jamaica in week 2.
check w2 = 'Jamaica'
# possible,  1 out of 3 possible combinations 'true'.

# (B) Freedom makes a voyage to Trinidad in week 2.
check w2 = 'Trinidad'
# possible,  1 out of 3 possible combinations 'true'.

# (C) Freedom makes a voyage to Martinique in week 3.
check w3 = 'Martinique'
# possible,  2 out of 3 possible combinations 'true'.

# (D) Freedom makes a voyage to Guadeloupe in week 6.
check w6 = 'Guadeloupe'
# false, 0 out of 3 possible combinations 'true'.

# (E) Freedom makes a voyage to Martinique in week 6.
check w6 = 'Martinique'
#true, 3 out of 3 possible combinations 'true'.
import lsat4

######
# 15. If Freedom makes a voyage to Guadeloupe in week 1 and to Trinidad in
# week 2, which one of the following must be true?
w1 = 'Guadeloupe'; w2 = 'Trinidad'

# (A) Freedom makes a voyage to Martinique in week 3.
prove w3 = 'Martinique'
# true, 1 out of 1 possible combinations 'true'.

# (B) Freedom makes a voyage to Martinique in week 4.
prove w4 = 'Martinique'
# false, 0 out of 1 possible combinations 'true'.

# (C) Freedom makes a voyage to Martinique in week 5.
prove w5 = 'Martinique'
# false, 0 out of 1 possible combinations 'true'.

# (D) Freedom makes a voyage to Guadeloupe in week 3.
prove w3 = 'Guadeloupe'
# false, 0 out of 1 possible combinations 'true'.

# (E) Freedom makes a voyage to Guadeloupe in week 5
prove w5 = 'Guadeloupe'
# false, 0 out of 1 possible combinations 'true'.
import lsat4

######
# 16. If Freedom makes a voyage to Martinique in week 3, which one of the
# following could be an accurate list of Freedom’s destinations in week 4
# and week 5,respectively?
w3 = 'Martinique'

# (A) Guadeloupe, Trinidad
any w4 = 'Guadeloupe'; w5 = 'Trinidad'
# true,  1 out of 8 possible combinations 'true'.

# (B) Jamaica, Guadeloupe
any w4 = 'Jamaica'; w5 = 'Guadeloupe'
# false, 0 out of 8 possible combinations 'true'.

# (C) Martinique, Trinidad
any w4 = 'Martinique'; w5 = 'Trinidad'
# false, 0 out of 8 possible combinations 'true'.

# (D) Trinidad, Jamaica
any w4 = 'Trinidad'; w5 = 'Jamaica'
# false, 0 out of 8 possible combinations 'true'.

# (E) Trinidad, Martinique
any w4 = 'Trinidad'; w5 = 'Martinique'
# false, 0 out of 8 possible combinations 'true'.
import lsat4

######
# 17. Which one of the following must be true about Freedom’s schedule of voyages?

# (A) Freedom makes a voyage to Guadeloupe either in week 1 or else in week 2.
check w1|w2 = 'Guadeloupe'
# false, 22 out of 25 possible combinations 'true'.
w1,w2 != 'Guadeloupe'

# (B) Freedom makes a voyage to Martinique either in week 2 or else in week 3.
check w2|w3 = 'Martinique'
# false, 12 out of 25 possible combinations 'true'.

# (C) Freedom makes at most two voyages to Guadeloupe.
check {{i}} = 'Guadeloupe' {{,2}}
# false, 20 out of 25 possible combinations 'true'.

# (D) Freedom makes at most two voyages to Jamaica.
check {{i}} = 'Jamaica' {{,2}}
# true, 25 out of 25 possible combinations 'true'.

# (E) Freedom makes at most two voyages to Trinidad.
check {{i}} = 'Trinidad' {{,2}}
# false, 24 out of 25 possible combinations 'true'.
