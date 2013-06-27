if v:version < 700
  echoerr 'does not work this version of Vim(' . v:version . ')'
  finish
elseif exists('g:loaded_ruby_require')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

call gf#user#extend('gf#ruby_require#find', 1000)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_ruby_require = 1

" vim: foldmethod=marker