" Calls a script local function readily.
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

function! scall#call(f, ...)
  let [file, func] = a:f =~# ':' ?  split(a:f, ':') : [expand('%:p'), a:f]

  if func ==# ''
    let pat = '^\s*:\?\s*fu\%[nction]!\?\s*s:'
    let defined_line = search(pat, 'bcnW')
    if defined_line
      let func = matchstr(getline(defined_line), pat . '\zs[[:alnum:]_:#]\+')
    endif
  endif

  let fname = matchstr(func, '^\w*')

  " Get sourced scripts.
  let slist = s:redir('scriptnames')

  if file =~# '^\d\+$'
    let nr = str2nr(file)
    let cfunc = printf("\<SNR>%d_%s", nr, func)
  else
    let filepat = '\V' . substitute(file, '\\', '/', 'g') . '\v%(\.vim)?$'
    for s in split(slist, "\n")
      let p = matchlist(s, '^\s*\(\d\+\):\s*\(.*\)$')
      if empty(p)
        continue
      endif
      let [nr, sfile] = p[1 : 2]
      let sfile = fnamemodify(sfile, ':p:gs?\\?/?')
      if sfile =~# filepat &&
      \    exists(printf("*\<SNR>%d_%s", nr, fname))
        let cfunc = printf("\<SNR>%d_%s", nr, func)
        break
      endif
    endfor
  endif

  if !exists('nr')
    call s:print_error('scall: Specified file is not sourced: ' . file)
    return
  elseif !exists('cfunc')
    let file = fnamemodify(file, ':p')
    call s:print_error(printf(
    \    'scall: File found, but the function is not defined: %s: %s()',
    \    file, fname))
    return
  endif

  return 0 <= match(func, '^\w*\s*(.*)\s*$')
  \      ? eval(cfunc) : call(cfunc, a:000)
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

function! s:print_error(message)
  echohl ErrorMsg
  for m in split(a:message, "\n")
    echomsg m
  endfor
  echohl None
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
