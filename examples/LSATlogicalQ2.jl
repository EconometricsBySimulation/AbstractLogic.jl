# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Questions 6-10
using AbstractLogic

"""
Exactly three films—Greed, Harvest, and Limelight—are
shown during a film club’s festival held on Thursday, Friday,
and Saturday. Each film is shown at least once during the
festival but never more than once on a given day. On each day
at least one film is shown. Films are shown one at a time. The
following conditions apply:
"""

# Three films Greed, Harvest, and Limelight as well as 0 no film
# t1 is the first film, t2 the second, and t3 are the last film on Thursday
# f1, f2, f3 and s1, s2, s3 are similarly coded for friday and saturday
logicset = logicalparse("t.1, t.2, t.3, f.1, f.2, f.3, s.1, s.2, s.3  ∈  _, Greed, Harvest, Limelight")

# On each day at least one film is shown. Since 3 is last slot then .3 can't be empty.
logicset = logicalparse("{{j}}.3 != '_'", logicset)

# Let's impose the non-binding contrainst that the highest number 3 is the
# last film shown. Thus if t2|t1 != 0 => t3 != 0
# logicset = logicalparse("t1 != 0 ==> t2 !=0", logicset)
logicset = logicalparse("{{j}}.1 != '_' ==> {{j}}.2 != '_'", logicset)

# Each film is shown at least once during the festival
logicset = logicalparse("{{i}} == 'Greed' {{1,}}", logicset)
logicset = logicalparse("{{i}} == 'Harvest' {{1,}}", logicset)
logicset = logicalparse("{{i}} == 'Limelight' {{1,}}", logicset)

# Never more than once on a given day. If t1 does not equal '_' then t1 != t2.
# Since we know that t3 can't be '_' then we can assert that t2 != t3
logicset = logicalparse("{{j}}.1 != '_' ==> {{j}}.1 != {{j}}.2 &&& {{j}}.1 != {{j}}.3 &&& {{j}}.2 != {{j}}.3", logicset)

# On Thursday Harvest is shown, and no film is shown after it on that day
logicset = logicalparse("t.3 = 'Harvest'", logicset)

# On Friday either Greed or Limelight, but not both, and no film is
# shown after it on that day.
logicset = logicalparse(["f.3 = 'Greed'|'Limelight'; f.2,f.1 != 'Greed','Limelight'"], logicset);

# On Saturday either Greed or Harvest, but not both, is shown, and no film is
# shown after it on that day.
logicset = logicalparse(["s.3 = 'Greed'|'Harvest'; s.1,s.2 != 'Greed','Harvest'"], logicset)

showfeasible(logicset)

range(logicset)

#6. Which one of the following could be a complete and accurate description of
# the order in which the films are shown at the festival?
#(A) Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
checkfeasible("t.2 = 'Limelight' ; t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.3 = 'Harvest' ; t.1,f.2,f.1,s.2,s.1='_'", logicset)
# false 0 out of 72 possible combinations true

#(B) Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
checkfeasible("t.3 = 'Harvest' ; f.2 = 'Greed' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'", logicset)
# false 0 out of 72 possible combinations true

#(C) Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
checkfeasible("t.3 = 'Harvest' ; f.3 = 'Limelight' ; s.2 = 'Limelight' ; s.3 = 'Greed'; t.1, t.2, f.1, f.2, s.1='_' ", logicset)
# true 1 out of 72 possible combinations true

#(D) Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
checkfeasible("t.1 = 'Greed' ; t.2 = 'Harvest' ; t.3 = 'Limelight' ; f.3 = 'Limelight' ; s.3 = 'Greed'", logicset)
# false, 0 out of 72 possible combinations 'true'.

#(E) Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
checkfeasible("t.2 = 'Greed' ; t.3 = 'Harvest' ; f.2 = 'Limelight' ; f.3 = 'Harvest' ; s.3 = 'Harvest' ", logicset)
# false, 0 out of 72 possible combinations 'true'.


#7. Which one of the following CANNOT be true?
#(A) Harvest is the last film shown on each day of the festival.
checkfeasible("t.3,f.3,s.3 = 'Harvest'", logicset)
# false, 0 out of 64 possible combinations 'true'

# (B) Limelight is shown on each day of the festival.
checkfeasible("{{i}} == 'Limelight' {{3,}}", logicset)
# possible,  10 out of 72 possible combinations 'true'.

#(C) Greed is shown second on each day of the festival.
checkfeasible("f.1,f.2,f.3 |= 'Greed'", logicset)
# possible,  32 out of 72 possible combinations 'true'

# (D) A different film is shown first on each day of the festival.
## This will be a little trickier. Define .0 as first film
logicset2 = logicalparse("t.0, f.0, s.0 ∈ Greed, Harvest, Limelight", logicset)
logicset2 = logicalparse("{{j}}.0 == {{j}}.1 if {{j}}.1 != '_'", logicset2)
logicset2 = logicalparse("{{j}}.1 == '_' &&& {{j}}.2 != '_' ==> {{j}}.0 == {{j}}.2", logicset2)
logicset2 = logicalparse("{{j}}.0 == {{j}}.3 if {{j}}.2 == '_'", logicset2)
checkfeasible("t.0 != f.0, s.0 ; f.0 != s.0", logicset2)
# possible,  8 out of 18 possible combinations 'true'.

# (E) A different film is shown last on each day of the festival.
checkfeasible("t.3, f.3 != s.3; t.3 != f.3", logicset)
# possible,  24 out of 74 possible combinations 'true'.

# If Limelight is never shown again during the festival once Greed is shown,
logicsetreduced = logicalparse("{{i}} = 'Greed' ==> {{>i}} != 'Limelight'", logicset)

# which one of the following is the maximum number of film showings that could
# occur during the festival?
#(A) three
checkfeasible("{{i}} != '_' {{3}}", logicsetreduced, countany=true)
# true,  1 out of 20 possible combinations 'true'.

#(B) four
checkfeasible("{{i}} != '_' {{4}}", logicsetreduced, countany=true)
# true,  6 out of 20 possible combinations 'true'.

#(C) five
checkfeasible("{{i}} != '_' {{5}}", logicsetreduced, countany=true)
# true,  9 out of 20 possible combinations 'true'.

# (D) six
checkfeasible("{{i}} != '_' {{6}}", logicsetreduced, countany=true)
# true,  4 out of 20 possible combinations 'true'.
# * Answer

# (E) seven
checkfeasible("{{i}} != '_' {{7}}", logicsetreduced, countany=true)
# true, 0 out of 20 possible combinations 'true'.

# If Greed is shown exactly three times, Harvest is shown exactly twice, and
# Limelight is shown exactly once, then which one of the following must be true?
logicsetreduced = logicalparse(
  "{{i}} = 'Greed' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Limelight' {{1}}", logicset)

#(A) All three films are shown on Thursday.
checkfeasible("t.1 != '_'", logicsetreduced, force=true)
# false, 2 out of 3 possible combinations 'true'.

#(B) Exactly two films are shown on Saturday.
checkfeasible("s.1 = '_'", logicsetreduced, force=true)
# true, 3 out of 3 possible combinations 'true'.

#(C) Limelight and Harvest are both shown on Thursday.
checkfeasible("t.1,t.2,t.3 |= 'Limelight'; t.1,t.2,t.3 |= 'Harvest'", logicsetreduced, force=true)
# false, 2 out of 3 possible combinations 'true'.

#(D) Greed is the only film shown on Saturday.
checkfeasible("s.1,s.2 != '_'; s.3 = 'Greed'", logicsetreduced, force=true)
# false, 0 out of 3 possible combinations 'true'.

#(E) Harvest and Greed are both shown on Friday
checkfeasible("s.1,s.2,s.3 |= 'Harvest'; s.1,s.2,s.3 |= 'Greed'", logicsetreduced, force=true)
# false, 0 out of 3 possible combinations 'true'.



# If Limelight is shown exactly three times, Harvest is shown exactly twice, and
# Greed is shown exactly once...
logicsetreduced = logicalparse(
  "{{i}} = 'Limelight' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Greed' {{1}}", logicset)

# Reintroduce first film
logicsetreduced2 = logicalparse("t.0, f.0, s.0 ∈ Greed, Harvest, Limelight", logicsetreduced)
logicsetreduced2 = logicalparse("{{j}}.0 == {{j}}.1 if {{j}}.1 != '_'", logicsetreduced2)
logicsetreduced2 = logicalparse("{{j}}.2 == '_' ==> {{j}}.0 == {{j}}.3", logicsetreduced2)
# Order of operations helps here as the &&& block is evaluated before the if operator
logicsetreduced2 = logicalparse("{{j}}.2 != '_' &&& {{j}}.1 == '_' ==> {{j}}.0 == {{j}}.2", logicsetreduced2)

# then which one of the following is a complete and accurate list of the films
# that could be the first film shown on Thursday?
range(logicsetreduced2)[Symbol("t.0")]
# Greed, Limelight

# (A) Harvest
# (B) Limelight
# (C) Greed, Harvest
# (D) Greed, Limelight
# (E) Greed, Harvest, Limelight
