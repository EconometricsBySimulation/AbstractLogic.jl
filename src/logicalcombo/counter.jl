let
    counter = 0
    global clearcounter() = counter = 0
    global counter!() = (counter += 1; (counter > 100) && throw("Excessive Recursion Error"))
end
