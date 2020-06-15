#!/usr/bin/env python
import textwrap
from pprint import pprint

# -------- Utility functions --------

block_pos = (y1, x1, y2, x2) ->
    "Returns y, x, height, width"
    min(y1,y2), min(x1,x2), max(y1,y2) - min(y1,y2) + 1, max(x1,x2) - min(x1,x2) + 1

split_nl = (line) ->
    "Returns the contents of the line without the newline, and the newline if exists."
    if line.length > 0 and line[-1] == '\n'
        line[:-1], line[-1]
    else
        line, ''

expand_line = (line, width) ->
    "Ensures that line is at least `width` character long."
    line, nl = split_nl(line)
    if line.length < width
        line += ' ' * (width-line.length)
    line + nl

replace_at = (line, pos, s) ->
    "Replaces part of the line starting at `pos`."
    line = expand_line(line, pos + s.length)
    line[:pos] + s + line[pos+s.length:]

overwrite_at = (line, pos, s) ->
    "Write `s` into line at given `pos`, merging line conjunctions and skipping whitespaces."
    s = s.trimEnd()
    line = expand_line(line, pos + s.length)
    line, nl = split_nl(line)

    result = ''
    for i, c in enumerate(line)
        if pos <= i < pos+s.length
            C = s[i-pos]
            if C == ' '
                result += c
            else if (C in '-+' and c in '|+') or (C in '|+' and c in '-+')
                result += '+'
            else
                result += C
        else
            result += c
        i += 1
    result + nl

merge_block = (lines, y, x, block, merge_fn) ->
    "Merges a rectangular block on the given lines using a merge function."
    h = block.length
    w = if h>0 then max(line.length for line in block) else 0

    for l, line in enumerate(lines)
        line, nl = split_nl(line)
        if h > 0 and w > 0 and y <= l < y+h
            yield merge_fn(line, x, block[l-y]) + nl
        else
            yield line + nl

    null

replace_block = (lines, y, x, block) ->
    "Replaces a rectangular block inside the given lines."
    merge_block(lines, y, x, block, replace_at)

overwrite_block = (lines, y, x, block) ->
    "Writes a rectangular block into the given lines, except whitespaces."
    merge_block(lines, y, x, block, overwrite_at)

line = (pattern, w) ->
    "Returns pattern enlarged to fit width `w`"
    result = pattern[0] + pattern[1] * max(1, w-2) + pattern[2]
    result[:w]

align_h = (line, width, where) ->
    "Returns fixed-width, aligned text. Text is trucated if longer than width."
    line, nl = split_nl(line)
    if where == 'left'
        fmt = '{:<%ds}' % width
    else if where == 'right'
        fmt = '{:>%ds}' % width
    else
        fmt = '{:^%ds}' % width
    fmt.format(line[:width]) + nl

align_v = (lines, height, where, empty) ->
    "Adds empty lines before/after the given `lines` according to alignment."
    lines = lines[:height]
    if where == 'top'
        lines += [empty] * (height - lines.length)
    else if where == 'bottom'
        lines = [empty] * (height - lines.length) + lines
    else
        lines = [empty] * ((height - lines.length) // 2) + lines
        lines += [empty] * (height - lines.length)

    lines

char_at = (lines, y, x, default=' ') ->
    "Returns the character at the given position, or default if it is out of bounds."
    lines = list(lines)
    unless 0 <= y < lines.length
        return default
    line = lines[y]
    unless 0 <= x < line.length
        return default
    line[x]

# -------- Box drawing --------

draw_box = (lines, y1, x1, y2, x2) ->
    "Draws a box and clears its contents with spaces."
    y, x, h, w = block_pos(y1, x1, y2, x2)
    box = line([[line('+-+',w)], [line('| |',w)], [line('+-+',w)]], h)
    replace_block(lines, y, x, box)

fill_box = (lines, y1, x1, y2, x2, yalign, xalign, text) ->
    "Fills a rectangular area with text."
    y, x, h, w = block_pos(y1, x1, y2, x2)
    if h > 0 and w > 0
        text = textwrap.wrap(text, w, break_long_words=false)
        text = [align_h(l, w, xalign) for l in text]
        text = align_v(text, h, yalign, line('   ', w))
        replace_block(lines, y, x, text)
    else
        lines

draw_box_with_label = (lines, y1, x1, y2, x2, yalign, xalign, text) ->
    "Draws a box and fills it with text."
    y1, y2 = min(y1,y2), max(y1,y2)
    x1, x2 = min(x1,x2), max(x1,x2)

    lines = draw_box(lines, y1, x1, y2, x2)
    if x2-x1 > 2
        lines = fill_box(lines, y1+1, x1+2, y2-1, x2-2, yalign, xalign, text)
    lines

# -------- Line drawing --------

arrow_reverse = (arrow) ->
    "Returns the reverse of an arrow: +-> becomes <-+"
    arrow[2].replace('>','<').replace('^','v') + arrow[1] + arrow[0].replace('<','>').replace('v','^')

arrow_h2v = (arrow) ->
    "Converts an arrow to vertical. Returns a block that can be merged into lines."
    arrow = arrow.replace('-', '|').replace('<','^').replace('>','v')
    [[a] for a in arrow]

arrow_start = (lines, y1, x1, arrow) ->
    "Replaces the beginning of an arrow with '+' if necessary."
    c = char_at(lines, y1, x1)
    if c in '+|-'
        '+' + arrow[1:]
    else
        arrow

draw_line_hv = (lines, y1, x1, y2, x2, arrow) ->
    "Draws an arrow between two points, always starting with the horizontal line."
    y, x, h, w = block_pos(y1, x1, y2, x2)
    arrow = arrow_start(lines, y1, x1, arrow)
    if w > 1
        a = if x2 > x1 then arrow else arrow_reverse(arrow)
        lines = overwrite_block(lines, y1, x, [line(a, w)])
    if h > 1
        if w > 1 
            arrow = '+' + arrow[1:]
        a = arrow_h2v( if y2 > y1 thenarrow else arrow_reverse(arrow))
        lines = overwrite_block(lines, y, x2, line(a, h))
    lines

draw_line_vh = (lines, y1, x1, y2, x2, arrow) ->
    "Draws an arrow between two points, always starting with the vertical line."
    y, x, h, w = block_pos(y1, x1, y2, x2)
    arrow = arrow_start(lines, y1, x1, arrow)
    if h > 1
        a = arrow_h2v( if y2 > y1 thenarrow else arrow_reverse(arrow))
        lines = overwrite_block(lines, y, x1, line(a, h))
    if w > 1
        if h > 1
            arrow = '+' + arrow[1:]
        a = if x2 > x1 then arrow else arrow_reverse(arrow)
        lines = overwrite_block(lines, y2, x, [line(a, w)])
    lines

# -------- Selection --------

find_box = (lines, y1, x1, y2, x2) ->
    lines = list(lines)

    # Select left |
    sx = min(x1,x2)
    while char_at(lines, y1, sx, '\n') not in '|+\n'
        sx -= 1

    # Select right |
    ex = max(x1,x2)
    while char_at(lines, y2, ex, '\n') not in '|+\n'
        ex += 1

    # Select top -
    sy = min(y1,y2)
    while char_at(lines, sy, sx, '\n') not in '-+\n'
        sy -= 1

    # Select bottom -
    ey = max(y1,y2)
    while char_at(lines, ey, ex, '\n') not in '-+\n'
        ey += 1

    sy, sx, ey, ex

select_outer_box = (lines, y1, x1, y2, x2) ->
    ["%d,%d,%d,%d" % find_box(lines, y1, x1, y2, x2)]

select_inner_box = (lines, y1, x1, y2, x2) ->
    sy, sx, ey, ex = find_box(lines, y1, x1, y2, x2)
    ["%d,%d,%d,%d" % (min(sy+1,ey), min(sx+1,ex), max(ey-1,sy), max(ex-1,sx))]

# -------- Vim commands --------

CMDS = {
    # Box drawing
    '+o': [draw_box],
    '+O': [draw_box_with_label, 'middle', 'center'],
    '+[O': [draw_box_with_label, 'middle', 'left'],
    '+]O': [draw_box_with_label, 'middle', 'right'],
    '+{O': [draw_box_with_label, 'top', 'middle'],
    '+}O': [draw_box_with_label, 'bottom', 'middle'],
    '+{[O': [draw_box_with_label, 'top', 'left'],
    '+{]O': [draw_box_with_label, 'top', 'right'],
    '+}[O': [draw_box_with_label, 'bottom', 'left'],
    '+}]O': [draw_box_with_label, 'bottom', 'right'],

    # Label drawing
    '+c': [fill_box, 'middle', 'center'],
    '+[c': [fill_box, 'middle', 'left'],
    '+]c': [fill_box, 'middle', 'right'],
    '+{c': [fill_box, 'top', 'center'],
    '+}c': [fill_box, 'bottom', 'center'],
    '+{[c': [fill_box, 'top', 'left'],
    '+{]c': [fill_box, 'top', 'right'],
    '+}[c': [fill_box, 'bottom', 'left'],
    '+}]c': [fill_box, 'bottom', 'right'],

    # Line drawing
    '+>': [draw_line_vh, '-->'],
    '+<': [draw_line_vh, '-->'],
    '+V': [draw_line_hv, '-->'],
    '+v': [draw_line_hv, '-->'],
    '+^': [draw_line_hv, '-->'],

    '++>': [draw_line_vh, '<->'],
    '++<': [draw_line_vh, '<->'],
    '++V': [draw_line_hv, '<->'],
    '++v': [draw_line_hv, '<->'],
    '++^': [draw_line_hv, '<->'],

    '+-': [draw_line_vh, '---'],
    '+_': [draw_line_vh, '---'],
    '+|': [draw_line_hv, '---'],

    # Selection
    'ao': [select_outer_box],
    'io': [select_inner_box],
}

run_command = (cmd, lines, y1, x1, y2, x2, ...args) ->
    f = CMDS[cmd][0]
    args = CMDS[cmd][1:] + list(args)
    f(lines, y1, x1, y2, x2, *args)

# -------- Main --------

if __name__ == '__main__'
    import sys

    cmd, y1, x1, y2, x2 = sys.argv[1:6]
    y1, x1, y2, x2 = parseInt(y1), parseInt(x1), parseInt(y2), parseInt(x2)

    lines = sys.stdin.readlines()
    for line in run_command(cmd, lines, y1, x1, y2, x2, *sys.argv[6:])
        sys.stdout.write(line)

