function softdate(txt;
     dtstart = now()-Year(100); dtend = now(),
     splits  = [r"\n\r"],
     transformations = [(x -> x)],
     formats = [(x -> DateFormat(x, "yyyy mm dd"))],
     ranges  = [(x -> x)],
     seperators = ["\\s+through\\s+"],
     scoreparameters = [1,1,1,1],
     d2block = [(x -> x)],
     scorer  = [(x -> x)],
     dt2block = (x -> x[1]) )

    # Fill in some initial values
    scoremax = -99
    dttxtout, combset, combfull = fill([], 3)
    s0, t0, f0, r0 = fill(0,4)

    for s in 1:length(splits),
        t in 1:length(transformations),
        F in 1:length(formats) ,
        r in 1:length(ranges)

        s0=s; t0=t; f0=t, r0=r

        txt1 = split(txt, splits[s])
        txt2 = [transformations[t](x) for x in txt1]
        txt2 = txt2[txt2 .!= ""]

        dt2block(txt2, formats[F], ranges[r], seperators[s])

        txtblock = [dt2block((txt2[i], formats[F], ranges[r])) ]

        scorei = scorer(txtblock, scoreparameters, dtstart, dtend)

        if scorei > scoremax
          soremax = scorei
          dttxtout = txtblock
          combset = [si, ti, fi, ri]
          combfull = [s, t, f, r]
        end
    end

    (soremax, dttxtout, combset, combfull)
end

txt = DTtext[2]

function dt2block2(txtin; singleformat = "mm dd yyyy", rangeformat = ("mm dd yyyy", "mm dd yyyy"), seperator = "\\s+through\\s+") end
  outframe = DataFrame[]

  for (ti, i) in enumerate(txtin); println(i);

    rangeattempt = rangeformatter(i, rangeformat, seperator)

    if size(rangeattempt)[1] > 0)
        outframe= hcat(outframe, rangeattempt)
        continue
    else
        rangeattempt = singleformatter(i, singleformat)

    end
  end
end

rangeformat = ("mm dd yyyy", "mm dd yyyy")
txt = replace(txt, "/"=>" ")
seperator = "through"

function dateformat2regex(m::String)
    m = replace(m,   r"\bmm\b"=>"[0-1][0-9]")
    m = replace(m, r"\byyyy\b"=>"201[0-9]")
    m = replace(m,   r"\byy\b"=>"1[0-9]")
    m = replace(m,   r"\bdd\b"=>"[0-3][0-9]")
end

function rangeformatter(txt, rangeformat, seperator)

  left, right = dateformat2regex.(rangeformat)
  matchcheck = match(Regex("^($left)([ ]*)($seperator)([ ]*)($right)"), txt)

  (matchcheck === nothing) && (return [])
  dt1 = Date(matchcheck.captures[1], DateFormat(rangeformat[1]))
  dt3 = Date(matchcheck.captures[5], DateFormat(rangeformat[2]))
  starter = sum(length.(matchcheck.captures))+1

  txtout = strip(txt[starter:end])

  DataFrame(date=collect(dt1:Day(1):dt3), txt=fill(txtout, length(dt1:Day(1):dt3)))
end

rangeformatter("11 12 2017 through 11 15 2017 ipsum tadsf", ("mm dd yyyy", "mm dd yyyy"), "through")

function singleformat(txt; singleformat::String="mm dd yyyy")

  left = dateformat2regex.(singleformat)
  matchcheck = match(Regex("^($left)"), txt)

  (matchcheck === nothing) && (return [])
  dt1 = Date(matchcheck.captures[1], DateFormat(rangeformat[1]))
  starter = sum(length.(matchcheck.captures[1]))+1

  txtout = strip(txt[starter:end])

  DataFrame(date=dt1, txt=txtout)
end

singleformat("11 12 2017 through 11 15 2017 ipsum tadsf", singleformat="mm dd yyyy")



txt = DTtext[2]
txt = replace(DTtext[2], "/"=>" ")

a = ["a", "b", "c"];
for (index, value) in enumerate(a)
             println("$index $value")
         end
