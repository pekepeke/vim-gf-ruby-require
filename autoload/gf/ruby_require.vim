let s:save_cpo = &cpo
set cpo&vim

let s:lib_dir = expand('<sfile>:p:h:h:h') . '/lib'
let s:helper_rb = s:lib_dir . '/ruby_require_helper.rb'

function! gf#ruby_require#find()
  if &filetype !~? 'ruby\.\?'
    return 0
  endif

  let line = getline('.')
  let [lib, is_relative] = s:parse_line(line)

  if empty(lib)
    return 0
  endif

  let path = ""
  if is_relative
    " File.expand_path(lib, File.dirname(__FILE__))
    let path = expand('%:p:h') . '/' . lib . '.rb'
  else
    let output = system(printf("ruby %s %s", s:helper_rb, lib))
    let lines = split(output, "\n")
    if len(lines) > 0
      let path = lines[0]
    endif
  endif

  return !empty(path) ? {
        \ 'path' : path,
        \ 'line' : 0,
        \ 'col' : 0,
        \ } : 0
endfunction

function! s:parse_line(line)
  let matches = matchlist(a:line, 'require\(_relative\)\?\s\+[' . "'" . '"]\(.\+\)[' . "'" . '"]')

  if empty(matches)
    return ["", 0]
  endif

  let require = matches[1]
  let lib = matches[2]
  let is_relative = require == 'require_relative'
  return [substitute(lib, '\.rb$', '', ''), is_relative]
endfunction

let &cpo = s:save_cpo
