" alternate-spec.vim - Alternates between code and spec files
"Maintainer: David Elentok

function! FindAlternateFile()
  let filename = bufname('%')
  let basename = fnamemodify(filename, ':t')
  let alternate_name = s:Switch(basename)
  let alternate_file = FindFileByName(alternate_name)
  if alternate_file['result'] == 'not-found'
    let alternate_file = TryTogglingCoffee(alternate_name)
  end
  return alternate_file
endfunc

function! GotoAlternateFile()
  let alternate_file = FindAlternateFile()
  if alternate_file['result'] == 'not-found'
    echo "Cannot find file named '" . alternate_name . "'"
  elseif alternate_file['result'] == 'found-file'
    exec "e " . alternate_file['file']
  elseif alternate_file['result'] == 'found-buffer'
    if IsBufferInCurrentTab(alternate_file['buffer'])
      let win_num = bufwinnr(alternate_file['buffer'])
      exec win_num . "wincmd w"
    else
      exec "b " . alternate_file['buffer']
    end
  end
endfunc

function! SplitToAlternateFile()
  let alternate_file = FindAlternateFile()
  if alternate_file['result'] == 'not-found'
    echo "Cannot find file named '" . alternate_name . "'"
  elseif alternate_file['result'] == 'found-file'
    exec "vs " . alternate_file['file']
  elseif alternate_file['result'] == 'found-buffer'
    if IsBufferInCurrentTab(alternate_file['buffer'])
      let win_num = bufwinnr(alternate_file['buffer'])
      exec win_num . "wincmd w"
    else
      vs
      wincmd w
      exec "b " . alternate_file['buffer']
    end
  end
endfunc

function! IsBufferInCurrentTab(buffer_name)
  let buffer_num = bufnr(a:buffer_name)
  if index(tabpagebuflist(), buffer_num) >= 0
    return 1
  else
    return 0
  end
endfunc

function! FindFileByName(basename)
  let buffer_name = bufname(a:basename)
  if buffer_name == ''
    let full_path = system('find . -iname "' . a:basename . '"')
    if len(full_path) == 0
      return { 'result': 'not-found' }
    else
      return { 'result': 'found-file', 'file': full_path }
    end
  else
    return { 'result': 'found-buffer', 'buffer': buffer_name }
  end
endfunc

function! TryTogglingCoffee(basename)
  let alternate_name = ToggleCoffeeExtension(a:basename)
  if alternate_name == ''
    return { 'result': 'not-found' }
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

map `o :call GotoAlternateFile()<cr>
map `O :call SplitToAlternateFile()<cr>
