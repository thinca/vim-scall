" Calls a script local function readily.
" Version: 1.1
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

function! s:print_error(message)
  echohl ErrorMsg
  for m in split(a:message, "\n")
    echomsg m
  endfor
  echohl None
endfunction

function! {g:scall_function_name}(f, ...)
  try
    return call('scall#call', [a:f] + a:000)
  catch /^scall:/
    call s:print_error(v:exception)
  endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
