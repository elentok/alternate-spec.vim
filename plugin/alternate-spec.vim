" alternate-spec.vim - Alternates between code and spec files

function! FindAlternateFile()
  let filename = bufname('%')
  let basename = fnamemodify(filename, ':t')
  let alternate_name = s:Switch(basename)
  let alternate_file = system('find . -iname "' . alternate_name . '"')
  if len(alternate_file) == 0
    echo "Cannot find file named '" . alternate_name . "'"
  else
    exec "e " . alternate_file
  end
endfunc

function! s:Switch(filename)
  if s:IsSpec(a:filename)
    return s:RemoveSpec(a:filename)
  else
    return s:AddSpec(a:filename)
  end
endfunc

function! s:IsSpec(filename)
  return a:filename =~ '[\._-]spec\>'
endfunc

function! s:RemoveSpec(filename)
  return substitute(a:filename, '[\._-]spec\>', '', '')
endfunc

function! s:AddSpec(filename)
  return substitute(a:filename, '\.', '_spec.', '')
endfunc
