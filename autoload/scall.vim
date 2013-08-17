" Calls a script local function readily.
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! scall#search(func_spec)
  let spec = a:func_spec
  let [file, func] = spec =~# ':' ? split(spec, ':') : [expand('%:p'), spec]

  if func ==# ''
    let func = s:search_buffer_func()
  endif

  let nr = 0
  if file =~# '^\d\+$'
    let nr = str2nr(file)
    let fname = s:func_name(nr, func)
    if exists('*' . fname)
      return function(fname)
    endif
    " for exception
    let target_file = file
  else
    let slist = s:redir('scriptnames')
    let filepat = '\V' . substitute(file, '\\', '/', 'g') . '\v%(\.vim)?$'
    for s in split(slist, "\n")
      let p = matchlist(s, '^\s*\(\d\+\):\s*\(.*\)$')
      if empty(p)
        continue
      endif
      let [n, sfile] = p[1 : 2]
      let sfile = fnamemodify(sfile, ':p:gs?\\?/?')
      if sfile =~# filepat
        let fname = s:func_name(n, func)
        if exists('*' . fname)
          return function(fname)
        endif
        " for exception
        let nr = n
        let target_file = fnamemodify(sfile, ':p')
      endif
    endfor
  endif

  if nr == 0
    throw 'scall: Specified file is not sourced: ' . file
  endif
  throw printf(
  \    'scall: File found, but the function is not defined: %s: %s()',
  \    target_file, func)
endfunction

function! scall#call(func_spec, ...)
  let spec = a:func_spec
  if spec =~# '('
    let [spec, args_str] = split(spec, '^.\{-}\zs\ze(')
    let args = s:eval_args(args_str)
  else
    let args = a:000
  endif

  return call(scall#search(spec), args)
endfunction

function! s:eval_args(args)
  let str = '[' . matchstr(a:args, '^\s*(\zs.*\ze)\s*$') . ']'
  return eval(str)
endfunction

function! s:search_buffer_func()
  let pat = '^\s*:\?\s*fu\%[nction]!\?\s*s:'
  let defined_line = search(pat, 'bcnW')
  if defined_line
    return matchstr(getline(defined_line), pat . '\zs[[:alnum:]_:#]\+')
  endif
  return ''
endfunction

function! s:redir(cmd)
  let oldverbosefile = &verbosefile
  set verbosefile=
  redir => res
    silent! execute a:cmd
  redir END
  let &verbosefile = oldverbosefile
  return res
endfunction

function! s:func_name(nr, name)
  return printf("\<SNR>%d_%s", a:nr, a:name)
endfunction

function! s:print_error(message)
  echohl ErrorMsg
  for m in split(a:message, "\n")
    echomsg m
  endfor
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
