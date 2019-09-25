# LSAC JUNE 2007 Form 8LSN75
# https://www.lsac.org/sites/default/files/legacy/docs/default-source/jd-docs/sampleptjune.pdf

# Questions 1-5
using AbstractLogic

#A company employee generates a series of five-digit product
#codes in accordance with the following rules:
#The codes use the digits 0, 1, 2, 3, and 4, and no others.
logicset = logicalparse(["a, b, c, d, e  ∈  0:4"]); showfeasible(logicset)

#Each digit occurs exactly once in any code.
logicset = logicalparse(["{{i}} != {{!i}}"], logicset); showfeasible(logicset)

#The second digit has a value exactly twice that of the first digit.
logicset = logicalparse(["b == a*2"], logicset); showfeasible(logicset)

#The value of the third digit is less than the value of the fifth digit
logicset = logicalparse(["c < e"], logicset); showfeasible(logicset)

#1. If the last digit of an acceptable product code is 1...
# (which of the following has must be true N out of N cases).

#(A) first digit is 2
checkfeasible("e == 1 ==> a==2", logicset)
# Returns true: 6 of 6 possible.

#(B) second digit is 0
checkfeasible("e == 1 ==> b==0", logicset)
# False: 5 out of 6

#(C) third digit is 3
checkfeasible("e == 1 ==> c==3", logicset)
# False: 5 out of 6

#(D) fourth digit is 4
checkfeasible("d == 1 ==> d==4", logicset)
# False: 5 out of 6

#(E) fourth digit is 0
checkfeasible("d == 1 ==> d==0", logicset)
# False: 5 out of 6


#2. Which one of the following must be true about any
#acceptable product code?
range(logicset)

#(A) The digit 1 appears in some position before the digit 2.
checkfeasible("{{i}} == 1 &&& {{>i}} == 2 {{1}}", logicset, force=true)
# False: only 3 of 6

#(B) The digit 1 appears in some position before the digit 3.
checkfeasible("{{i}} == 1 &&& {{>i}} == 3 {{1}}", logicset, force=true)
# False: only 5 of 6

#(C) The digit 2 appears in some position before the digit 3.
checkfeasible("{{i}} == 2 &&& {{>i}} == 3 {{1}}", logicset, force=true)
# True! 6 of 6

#(D) The digit 3 appears in some position before the digit 0.
checkfeasible("{{i}} == 0 &&& {{>i}} == 3 {{1}}", logicset, force=true)
# False: only 5 of 6

#(E) The digit 4 appears in some position before the digit 3.
checkfeasible("{{i}} == 4 &&& {{>i}} == 3 {{1}}", logicset, force=true)
# False: only 4 of 6

#3. If the third digit of an acceptable product code is not 0, which one of the
# following must be true?

#(A) The second digit of the product code is 2.
checkfeasible("c != 0 ==> b == 2", logicset, force=true)
# False: only 5 of 6

#(B) The third digit of the product code is 3.
checkfeasible("c != 0 ==> b == 2", logicset, force=true)
# False: only 5 of 6

#(C) The fourth digit of the product code is 0.
checkfeasible("c != 0 ==> d == 0", logicset, force=true)
# True! 6 of 6

#(D) The fifth digit of the product code is 3. <true>
checkfeasible("c != 0 ==> e == 3", logicset, force=true)
# False: 5 of 6

#(E) The fifth digit of the product code is 1.
checkfeasible("c != 0 ==> e == 1", logicset, force=true)
# False: 4 of 6

#4. Any of the following pairs could be the third and fourth digits,
# respectively, of an acceptable product
#code, EXCEPT:

# (A) 0, 1
checkfeasible("c == 0 &&& d == 1", logicset)
# Possible 1 of 6

# (B) 0, 3
checkfeasible("c == 0 &&& d == 3", logicset)
# Possible 2 of 6

#(C) 1, 0
checkfeasible("c == 1 &&& d == 0", logicset)
# Possible 1 of 6

#(D) 3, 0
checkfeasible("c == 3 &&& d == 0", logicset)
# Possible 1 of 6

#(E) 3, 4
checkfeasible("c == 3 &&& d == 4", logicset)
# False! 0 of 6

#5. Which one of the following must be true about any acceptable product code?
logicset |> showfeasible

#(A) There is exactly one digit between the digit 0 and the digit 1.
checkfeasible("{{i}} == 1|0 ==> {{i+2}} == 1|0", logicset, force=true)
# False 1 of 6 outcomes

#(B) There is exactly one digit between the digit 1 and the digit 2.
checkfeasible("{{i}} == 1|2 ==> {{i+2}} == 1|2", logicset, force=true)
# False 0 of 6 outcomes

#(C) There are at most two digits between the digit 1 and the digit 3.
checkfeasible("{{i}} == 1|3 ==> {{i+4}} != 1,3", logicset, force=true)
# False 5 out of 6 outcomes true

#(D) There are at most two digits between the digit 2 and the digit 3.
checkfeasible("{{i}} == 2|3 ==> {{i+4}} != 2,3", logicset, force=true)
# False 4 out of 6 outcomes feasible

#(E) There are at most two digits between the digit 2 and the digit 4.
checkfeasible("{{i}} == 2|4 ==> {{i+4}} != 2,4", logicset, force=true)
# True 6 out of 6 outcomes feasible
