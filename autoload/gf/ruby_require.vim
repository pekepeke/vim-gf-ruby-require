let s:save_cpo = &cpo
set cpo&vim

let s:lib_dir = expand('<sfile>:p:h:h:h') . '/lib'
let s:helper_rb = s:lib_dir . '/ruby_require_helper.rb'

function! gf#ruby_require#find()
  if &filetype !~? 'ruby\.\?'
    call s:log("[abort] filetype=%s", &filetype)
    return 0
  endif

  let line = getline('.')
  let [lib, is_relative] = s:parse_line(line)
  call s:log("lib=%s, is_relative=%d", lib, is_relative)
  if empty(lib)
    return 0
  endif

  let path = ""
  if is_relative
    " File.expand_path(lib, File.dirname(__FILE__))
    let path = expand('%:p:h') . '/' . lib . '.rb'
  else
    let cmd = printf("ruby %s %s", s:helper_rb, lib)
    let output = system(cmd)
    call s:log("cmd = %s", cmd)
    call s:log("cwd = %s", getcwd())
    let lines = split(output, "\n")
    if len(lines) > 0
      let path = lines[0]
    endif
  endif
  call s:log("path = %s", path)

  return !empty(path) ? {
        \ 'path' : path,
        \ 'line' : 0,
        \ 'col' : 0,
        \ } : 0
endfunction

function! s:parse_line(line)
  let matches = matchlist(a:line, 'require\(_relative\)\?\s\+[' . "'" . '"]\(.\+\)[' . "'" . '"]')

  if empty(matches)
    call s:log("matchlist not found : %s", a:line)
    return ["", 0]
  endif

  let require = matches[1]
  let lib = matches[2]
  let is_relative = require == 'require_relative'
  call s:log("matchlist found : %s[%s]", require, lib)
  return [substitute(lib, '\.rb$', '', ''), is_relative]
endfunction

function! s:log(...)
  if !g:gf_ruby_require_debug
    return
  endif
  if exists(':NeoBundle') && !neobundle#is_sourced('vimconsole.vim')
    NeoBundleSource vimconsole.vim
  endif
  let args = copy(a:000)
  if empty(args)
    vimconsole#log('gf/ruby_require')
    return
  endif
  let args[0] = strftime("%Y/%m/%d %T") . "> gf/ruby_require : " . args[0]
  call call('vimconsole#log', args)
endfunction

let &cpo = s:save_cpo
