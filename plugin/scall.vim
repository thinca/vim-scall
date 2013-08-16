" Calls a script local function readily.
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_scall')
  finish
endif
let g:loaded_scall = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:scall_function_name')
  let g:scall_function_name = 'Scall'
endif

function! {g:scall_function_name}(f, ...)
  return call('scall#call', [a:f] + a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
