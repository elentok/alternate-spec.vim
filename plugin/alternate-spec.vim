" alternate-spec.vim - Alternates between code and spec files
"Maintainer: David Elentok

function! FindAlternateFile()
  let filename = bufname('%')
  let basename = fnamemodify(filename, ':t')
  
  let find_pattern = ''
  if ASpec_IsSpec(filename)
    let find_pattern = ASpec_GetImplPattern(filename)
  else
    let find_pattern = ASpec_GetSpecPattern(filename)
  end
  
  let alternate_file = FindFileByPattern(find_pattern)
  return alternate_file
endfunc

function! GotoAlternateFile()
  if exists('b:alternate')
    
    if IsBufferInCurrentTab(b:alternate)
      let win_num = bufwinnr(b:alternate)
      exec win_num . "wincmd w"
    else
      exec "b " . b:alternate
    end
  else

    let alternate_file = FindAlternateFile()
    if alternate_file['result'] == 'not-found'
      echo "Cannot find file alternate file"
    elseif alternate_file['result'] == 'found-file'
      let original = buffer_name('%')
      let b:alternate = ASpec_CleanBufferName(alternate_file['file'])
      exec "e " . alternate_file['file']
      let b:alternate = ASpec_CleanBufferName(original)
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

function! FindFileByPattern(pattern)
  let full_path = system('find -E . -iregex "' . a:pattern . '" | head -1')
  if len(full_path) == 0
    return { 'result': 'not-found' }
  else
    return { 'result': 'found-file', 'file': substitute(full_path, ' *$', '', '') }
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
  if ASpec_IsSpec(a:filename)
    return s:RemoveSpec(a:filename)
  else
    return s:AddSpec(a:filename)
  end
endfunc

function! ASpec_Basename(filename)
  let basename = fnamemodify(a:filename, ":t:r")
  " incase of js.coffee
  if basename =~ '\.js$'
    let basename = fnamemodify(basename, ":r")
  endif
  return basename
endfunc

function! ASpec_IsSpec(filename)
  let basename = ASpec_Basename(a:filename)
  return basename =~ '[\._-]\(spec\|test\)$' || basename =~ 'Test$'
endfunc

function! ASpec_GetSpecPattern(filename)
  let ext = fnamemodify(a:filename, ":e")
  let basename = ASpec_Basename(a:filename)
  let options = ["_spec." . ext, "_test." . ext, "Test." . ext]
  if ext == 'js' || ext == 'coffee'
    call add(options, '_spec.js.coffee')
  end
  
  let options_regex = join(options, '|')
  
  return '.*/' . basename . '(' . options_regex . ')'
endfunc

function! ASpec_GetImplPattern(filename)
  let ext = fnamemodify(a:filename, ":e")
  let basename = ASpec_Basename(a:filename)
  let basename = substitute(basename, '[\._-]\?\(spec\|test\|Test\)$', '', '')
  if ext == 'js' || ext == 'coffee'
    return '.*/(' . basename . '.js|' . basename . '.js.coffee|' . basename . '.coffee)$'
  else
    return '.*/' . basename . '.' . ext . '$'
  endif
endfunc

function! s:RemoveSpec(filename)
  return substitute(a:filename, '[\._-]spec\>', '', '')
endfunc

function! ASpec_CleanBufferName(filename)
  return substitute(a:filename, '^\.\/', '', '')
endfunc

map `o :call GotoAlternateFile()<cr>
map `O :call SplitToAlternateFile()<cr>


