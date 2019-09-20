using ReplMaker, Markdown

function parse_to_expr(s)
   abstractlogic(s)

   if dashboard()
     println("\nCommand Lists:" * string(showsetlocation()))
     for v in showcommandlist()
         println(v)
     end

     println("\nCommand Location:" * string(showcmdlocation()))
     for v in showcommandhistory()
         println(v)
     end

     println("\nLogicSet Lists:" * string(showsetlocation()))
     for v in returnlogicset()
         println(join(collect(string(v))[1:(min(200,end))]))
     end

   end
   nothing
end

initrepl(
    parse_to_expr,
    prompt_text="abstractlogic> ",
    prompt_color = :blue,
    start_key='=',
    mode_name="Abstract Logic")
