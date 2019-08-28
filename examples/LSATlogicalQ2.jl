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
logicset = logicalparse(["t1, t2, t3, f1, f2, f3, s1, s2, s3  ∈  0:3"])

# Each film is shown at least once during the festival
logicset = logicalparse(["{{i}} == 1 {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 2 {{1,}}"], logicset)
logicset = logicalparse(["{{i}} == 3 {{1,}}"], logicset)

# Never more than once on a given day
logicset = logicalparse(["t1 > 0 ==> t1 != t2; f1 > 0 ==> f1 != f2; s1 > 0 ==> s1 != s2"], logicset)
logicset = logicalparse(["t1 > 0 ==> t1 != t3; f1 > 0 ==> f1 != f3; s1 > 0 ==> s1 != s3"], logicset)
logicset = logicalparse(["t2 > 0 ==> t2 != t3; f2 > 0 ==> f2 != f3; s2 > 0 ==> s2 != s3"], logicset)

# On each day at least one film is shown.
logicset = logicalparse(["t1|t2|t3 == 0 {0,1}; f1|f2|f3 == 0 {0,1}; s1|s2|s3 == 0 {0,1}"], logicset)

# On Thursday Harvest is shown, and no film is shown after it on that day
logicset = logicalparse(["t1 = 2 &&& t2,t3 = 0 |||| t2 = 2 &&& t3 = 0 |||| t3 == 2"], logicset)

# On Friday either Greed or Limelight, but not both, is shown, and no film is
# shown after it on that day.
logicset = logicalparse(
  ["f1 = 1|3 &&& f2,f3 = 0 |||| f2 = 1|3 &&& f1 = 0|2 &&& f3 = 0 |||| f3 = 1|3 &&& f1,f2 != 1,3"], logicset);

showfeasible(logicset)

# On Saturday either Greed or Harvest, but not both, is shown, and no film is
# shown after it on that day.
logicset = logicalparse(["s1 = 1|3 &&& s2, s3 = 0 |||| s2 == 1|3 &&& s1 != 1|3"], logicset); showfeasible(logicset)

# Three films 1-Greed, 2-Harvest, and 3-Limelight as well as 0 no film

#6. Which one of the following could be a complete and accurate description of
# the order in which the films are shown at the festival?
#(A) Thursday: Limelight, then Harvest; Friday: Limelight; Saturday: Harvest
checkfeasible("t1 = 3 &&& t2 = 2 &&& f2 = 3 &&& s2 = 2 &&& f1,s1=0", logicset)
# False 0 out of 202 possible combinations true

#(B) Thursday: Harvest; Friday: Greed, then Limelight; Saturday: Limelight, then Greed
checkfeasible("t2 = 2 &&& f1 = 1 &&& f2 = 3 &&& s1 = 3 &&& s2 = 1 &&& t1=0", logicset)
# True 1 out of 202 possible combinations true

#(C) Thursday: Harvest; Friday: Limelight; Saturday: Limelight, then Greed
checkfeasible("t2 = 2 &&& f2 = 3 &&& s1 = 3 &&& s2 = 1 &&& t1, f1 = 0", logicset)
# False 0 out of 202 possible combinations true

#(D) Thursday: Greed, then Harvest, then Limelight; Friday: Limelight; Saturday: Greed
checkfeasible("t1 = 1 &&& t2 = 2 &&& f2 = 3 &&& s1 = 3 &&& s2 = 1 &&& t1, f1 = 0", logicset)

#(E) Thursday: Greed, then Harvest; Friday: Limelight, then Harvest; Saturday: Harvest
