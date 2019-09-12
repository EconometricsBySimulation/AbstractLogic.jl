# Word Problems Logical Reasoning Tests
# http://www.graduatewings.co.uk/word-problems-logical-tests
using AbstractLogic

# Question 1
# Sam is shorter than Hannah. William is shorter than Michael who is shorter than
# Hannah. Hannah and William are shorter than Fiona. Who is the tallest?
logicset = logicalparse(["Sam, Hannah, William, Michael, Fiona ∈ 1:5"])
logicset = logicalparse(["Sam < Hannah; William < Michael; Michael < Hannah"], logicset)
logicset = logicalparse(["Hannah < Fiona; William < Fiona"], logicset)

# A) Sam    B) Hannah    C) William    D) Fiona    E) Cannot Say
search("{{i}} > {{!i}}", logicset)
# :Fiona is a match with 13 feasible combinations out of 13.
# Therefore we choose D) Fiona


# Question 2
# Ben is taller than Sharon who is taller than Ralph. Ben is also taller than Mike.
logicset = logicalparse(["Ben, Sharon, Ralph, Mike ∈ 1:4"])
logicset = logicalparse(["Ben > Sharon; Sharon > Ralph; Ben > Mike"], logicset)

# Who is the shortest?
# A) Ben    B) Sharon    C) Ralph    D) Mike    E) Cannot Say
search("{{i}} < {{!i}}", logicset)
# :Ralph is a possible match with 6 feasible combinations out of 11.
# :Mike is a possible match with 1 feasible combinations out of 11.
# Therefore we choose E) Cannot Say
