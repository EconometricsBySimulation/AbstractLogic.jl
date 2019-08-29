# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Question 2

"""
Exactly three films—Greed, Harvest, and Limelight—are
shown during a film club’s festival held on Thursday, Friday,
and Saturday. Each film is shown at least once during the
festival but never more than once on a given day. On each day
at least one film is shown. Films are shown one at a time. The
following conditions apply:
"""

# Three films 1-Greed, 2-Harvest, and 3-Limelight as well as 0 no film
logicset = logicalparse(["t1, t2, t3, f1, f2, f3, s1, s2, s3  ∈  none, Greed, Harvest, Limelight"])

# On each day at least one film is shown.
logicset = logicalparse(["t3,f3,s3 != 'none'"], logicset)

# Let's impose the non-binding contrainst that the highest number 3 is the
# last film shown. Thus if t2|t1 != 0 => t3 != 0
# logicset = logicalparse(["t1 != 0 ==> t2 !=0"], logicset)
logicset = logicalparse(["t1 != 'none' ==> t2 != 'none'"], logicset)
logicset = logicalparse(["f1 != 'none' ==> f2 != 'none'"], logicset)
logicset = logicalparse(["s1 != 'none' ==> s2 != 'none'"], logicset)

# Each film is shown at least once during the festival
logicset = logicalparse(["{{i}} == 'Greed' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 'Harvest' {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 'Limelight' {{1,}}"], logicset)

# Never more than once on a given day. If t1 does not equal 'none' then t1 != t2.
# Since we know that t3 can't be 'none' then we can assert that t2 != t3
logicset = logicalparse(["t1 != 'none' ==> t1 != t2, t3 ; t2 != t3"], logicset)
logicset = logicalparse(["f1 != 'none' ==> f1 != f2, f3 ; f2 != f3"], logicset)
logicset = logicalparse(["s1 != 'none' ==> s1 != s2, s3 ; s2 != s3"], logicset)

showfeasible(logicset)

# On Thursday Harvest is shown, and no film is shown after it on that day
logicset = logicalparse(["t3 = 'Harvest'"], logicset)

# On Friday either Greed or Limelight, but not both, and no film is
# shown after it on that day.
logicset = logicalparse(["f3 = 'Greed'|'Limelight'; f2,f1 != 'Greed','Limelight'"], logicset);

# On Saturday either Greed or Harvest, but not both, is shown, and no film is
# shown after it on that day.
logicset = logicalparse(["s3 = 'Greed'|'Harvest'; s1,s2 != 'Greed','Harvest'"], logicset)

# Three films 1-Greed, 2-Harvest, and 3-Limelight as well as 0 no film
showfeasible(logicset)

#6. Which one of the following could be a complete and accurate description of
# the order in which the films are shown at the festival?
#(A) Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
checkfeasible("t2 = 'Limelight' ; t3 = 'Harvest' ; f3 = 'Limelight' ; s3 = 'Harvest' ; t1,f2,f1,s2,s1='none'", logicset)
# False 0 out of 64 possible combinations true

#(B) Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
checkfeasible("t3 = 'Harvest' ; f2 = 'Greed' ; f3 = 'Limelight' ; s2 = 'Limelight' ; s3 = 'Greed'", logicset)
# False 0 out of 64 possible combinations true

#(C) Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
checkfeasible("t3 = 'Harvest' ; f3 = 'Limelight' ; s2 = 'Limelight' ; s3 = 'Greed'; t1,t2,f1,f2,s1='none' ", logicset)
# true 1 out of 64 possible combinations true

#(D) Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
checkfeasible("t1 = 'Greed' ; t2 = 'Harvest' ; t3 = 'Limelight' ; f3 = 'Limelight' ; s3 = 'Greed'", logicset)
# false, 0 out of 64 possible combinations 'true'.

#(E) Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
checkfeasible("t2 = 'Greed' ; t3 = 'Harvest' ; f2 = 'Limelight' ; f3 = 'Harvest' ; s3 = 'Harvest' ", logicset)
# false, 0 out of 64 possible combinations 'true'.
