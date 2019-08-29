# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Questions 6-10

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
logicset = logicalparse(["t1, t2, t3, f1, f2, f3, s1, s2, s3  ∈  _, Greed, Harvest, Limelight"])

# On each day at least one film is shown.
logicset = logicalparse(["t3,f3,s3 != '_'"], logicset)

# Let's impose the non-binding contrainst that the highest number 3 is the
# last film shown. Thus if t2|t1 != 0 => t3 != 0
# logicset = logicalparse(["t1 != 0 ==> t2 !=0"], logicset)
logicset = logicalparse(["t1 != '_' ==> t2 != '_'"], logicset)
logicset = logicalparse(["f1 != '_' ==> f2 != '_'"], logicset)
logicset = logicalparse(["s1 != '_' ==> s2 != '_'"], logicset)

# Each film is shown at least once during the festival
logicset = logicalparse(["{{i}} == 'Greed' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 'Harvest' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 'Limelight' {{1,}}"], logicset)

# Never more than once on a given day. If t1 does not equal '_' then t1 != t2.
# Since we know that t3 can't be '_' then we can assert that t2 != t3
logicset = logicalparse(["t1 != '_' ==> t1 != t2, t3 ; t2 != t3"], logicset)
logicset = logicalparse(["f1 != '_' ==> f1 != f2, f3 ; f2 != f3"], logicset)
logicset = logicalparse(["s1 != '_' ==> s1 != s2, s3 ; s2 != s3"], logicset)

showfeasible(logicset)

# On Thursday Harvest is shown, and no film is shown after it on that day
logicset = logicalparse(["t3 = 'Harvest'"], logicset)

# On Friday either Greed or Limelight, but not both, and no film is
# shown after it on that day.
logicset = logicalparse(["f3 = 'Greed'|'Limelight'; f2,f1 != 'Greed','Limelight'"], logicset);

# On Saturday either Greed or Harvest, but not both, is shown, and no film is
# shown after it on that day.
logicset = logicalparse(["s3 = 'Greed'|'Harvest'; s1,s2 != 'Greed','Harvest'"], logicset)

showfeasible(logicset)

range(logicset)

#6. Which one of the following could be a complete and accurate description of
# the order in which the films are shown at the festival?
#(A) Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
checkfeasible("t2 = 'Limelight' ; t3 = 'Harvest' ; f3 = 'Limelight' ; s3 = 'Harvest' ; t1,f2,f1,s2,s1='_'", logicset)
# false 0 out of 64 possible combinations true

#(B) Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
checkfeasible("t3 = 'Harvest' ; f2 = 'Greed' ; f3 = 'Limelight' ; s2 = 'Limelight' ; s3 = 'Greed'", logicset)
# false 0 out of 64 possible combinations true

#(C) Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
checkfeasible("t3 = 'Harvest' ; f3 = 'Limelight' ; s2 = 'Limelight' ; s3 = 'Greed'; t1,t2,f1,f2,s1='_' ", logicset)
# true 1 out of 64 possible combinations true

#(D) Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
checkfeasible("t1 = 'Greed' ; t2 = 'Harvest' ; t3 = 'Limelight' ; f3 = 'Limelight' ; s3 = 'Greed'", logicset)
# false, 0 out of 64 possible combinations 'true'.

#(E) Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
checkfeasible("t2 = 'Greed' ; t3 = 'Harvest' ; f2 = 'Limelight' ; f3 = 'Harvest' ; s3 = 'Harvest' ", logicset)
# false, 0 out of 64 possible combinations 'true'.


#7. Which one of the following CANNOT be true?
#(A) Harvest is the last film shown on each day of the festival.
checkfeasible("t3,f3,s3 = 'Harvest'", logicset)
# false, 0 out of 64 possible combinations 'true'

# (B) Limelight is shown on each day of the festival.
checkfeasible("t1,t2,t3 |= 'Limelight'; f1,f2,f3 |= 'Limelight'; s1,s2,s3 |= 'Limelight'", logicset)
# possible,  10 out of 64 possible combinations 'true'.

#(C) Greed is shown second on each day of the festival.
checkfeasible("f1,f2,f3 |= 'Greed'", logicset)
# possible,  32 out of 64 possible combinations 'true'

# (D) A different film is shown first on each day of the festival.
## This will be a little trickier to code. Might need to process this one with
## Julia
feasibleset = showfeasible(logicset)
firstfilm = [feasibleset[i, 3j .+ (1:3)][findfirst(x->x!="_", feasibleset[i, 3j .+ (1:3)])]
                      for i in 1:size(feasibleset,1), j in 0:2]
sum([(firstfilm[i,:] |> unique |> length) == 3 for i in 1:size(firstfilm,1)])
# 19 different solutions

# (E) A different film is shown last on each day of the festival.
checkfeasible("t3, f3 != s3; t3 != f3", logicset)
# possible,  20 out of 64 possible combinations 'true'.

# If Limelight is never shown again during the festival once Greed is shown,
logicsetreduced = logicalparse(["{{i}} = 'Greed' ==> {{>i}} != 'Limelight'"], logicset)

# which one of the following is the maximum number of film showings that could
# occur during the festival?
#(A) three
checkfeasible("{{i}} != '_' {{3}}", logicsetreduced)
# possible,  1 out of 16 possible combinations 'true'.

#(B) four
checkfeasible("{{i}} != '_' {{4}}", logicsetreduced)
# possible,  5 out of 16 possible combinations 'true'.

#(C) five
checkfeasible("{{i}} != '_' {{5}}", logicsetreduced)
# possible,  7 out of 16 possible combinations 'true'.

# (D) six
checkfeasible("{{i}} != '_' {{6}}", logicsetreduced)
# possible,  3 out of 16 possible combinations 'true'.
# * Answer

# (E) seven
checkfeasible("{{i}} != '_' {{7}}", logicsetreduced)
# false, 0 out of 16 possible combinations 'true'.


# If Greed is shown exactly three times, Harvest is shown exactly twice, and
# Limelight is shown exactly once, then which one of the following must be true?
logicsetreduced = logicalparse(
  ["{{i}} = 'Greed' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Limelight' {{1}}"], logicset)

#(A) All three films are shown on Thursday.
checkfeasible("t1 != '_'", logicsetreduced, force=true)
# false, 2 out of 3 possible combinations 'true'.

#(B) Exactly two films are shown on Saturday.
checkfeasible("s1 = '_'", logicsetreduced, force=true)
# true, 3 out of 3 possible combinations 'true'.

#(C) Limelight and Harvest are both shown on Thursday.
checkfeasible("t1,t2,t3 |= 'Limelight'; t1,t2,t3 |= 'Harvest'", logicsetreduced, force=true)
# false, 2 out of 3 possible combinations 'true'.

#(D) Greed is the only film shown on Saturday.
checkfeasible("s1,s2 != '_'; s3 = 'Greed'", logicsetreduced, force=true)
# false, 0 out of 3 possible combinations 'true'.

#(E) Harvest and Greed are both shown on Friday
checkfeasible("s1,s2,s3 |= 'Harvest'; s1,s2,s3 |= 'Greed'", logicsetreduced, force=true)
# false, 0 out of 3 possible combinations 'true'.



# If Limelight is shown exactly three times, Harvest is shown exactly twice, and
# Greed is shown exactly once...
logicsetreduced = logicalparse(
  ["{{i}} = 'Limelight' {{3}}; {{i}} = 'Harvest' {{2}}; {{i}} = 'Greed' {{1}}"], logicset)

# then which one of the following is a complete and accurate list of the films
# that could be the first film shown on Thursday?
# (A) Harvest
checkfeasible("t1 = 'Harvest' |||| t1 = '_' &&& t2 = 'Harvest' |||| t1,t2 = '_' &&& t3 = 'Harvest'", logicsetreduced)
# false, 0 out of 3 possible combinations 'true'.

#(B) Limelight
checkfeasible("t1 = 'Limelight' |||| t1 = '_' &&& t2 = 'Limelight' |||| t1,t2 = '_' &&& t3 = 'Limelight'", logicsetreduced)
# possible,  2 out of 3 possible combinations 'true'.

#(C) Greed, Harvest
checkfeasible("t1 |= 'Greed', 'Harvest' |||| t1 = '_' &&& t2 |= 'Greed', 'Harvest' |||| t1,t2 = '_' &&& t3 |= 'Greed', 'Harvest'", logicsetreduced)
# possible,  1 out of 3 possible combinations 'true'.

#(D) Greed, Limelight
checkfeasible("t1 |= 'Limelight', 'Greed' |||| t1 = '_' &&& t2 |= 'Limelight', 'Greed' |||| t1,t2 = '_' &&& t3 |= 'Limelight', 'Greed'", logicsetreduced)
# true, 3 out of 3 possible combinations 'true'.

# (E) Greed, Harvest, Limelight
# (A) tells us that 'Harvest' cannot be the first film
