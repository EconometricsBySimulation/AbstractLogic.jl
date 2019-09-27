using ReplMaker, Markdown

initrepl(
    parse_to_expr,
    prompt_text="abstractlogic> ",
    prompt_color = :blue,
    start_key='=',
    mode_name="Abstract Logic")
