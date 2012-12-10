" alternate-spec.vim - Alternates between code and spec files
"Maintainer: David Elentok

function! FindAlternateFile()
  let filename = bufname('%')
  let basename = fnamemodify(filename, ':t')
  let alternate_name = s:Switch(basename)
  let alternate_file = FindFileByName(alternate_name)
  if len(alternate_file) == 0
    let alternate_file = TryTogglingCoffee(alternate_name)
  end

  if len(alternate_file) == 0
    echo "Cannot find file named '" . alternate_name . "'"
  else
    exec "e " . alternate_file
  end
endfunc

function! FindFileByName(basename)
  return system('find . -iname "' . a:basename . '"')
endfunc

function! TryTogglingCoffee(basename)
  let alternate_name = ToggleCoffeeExtension(a:basename)
  if alternate_name == ''
    return ''
  else
    return FindFileByName(alternate_name)
  end
endfunc

function! ToggleCoffeeExtension(basename)
  if a:basename =~ '\.coffee$'
    return substitute(a:basename, '\.coffee$', '', '')
  elseif a:basename =~ '\.js$'
    return a:basename . '.coffee'
  end
  return ''
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

command! A call FindAlternateFile()
