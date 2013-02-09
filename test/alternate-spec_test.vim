source plugin/alternate-spec.vim

function! Test_ASpec_Basename()
  call Describe("/path/to/file.js")
  call AssertEquals(ASpec_Basename('/path/to/file.js'), 'file')
  
  call Describe("/path/to/file.js.coffee")
  call AssertEquals(ASpec_Basename('/path/to/file.js.coffee'), 'file')
endfunc

function! Test_ASpec_IsSpec()
  call Describe("file.js")
  call AssertEquals(ASpec_IsSpec('file.js'), 0)
  
  call Describe("file_spec.js")
  call AssertEquals(ASpec_IsSpec('file_spec.js'), 1)
  
  call Describe("file_spec.js.coffee")
  call AssertEquals(ASpec_IsSpec('file_spec.js.coffee'), 1)
  
  call Describe("file_test.js")
  call AssertEquals(ASpec_IsSpec('file_test.js'), 1)
  
  call Describe("fileTest.js")
  call AssertEquals(ASpec_IsSpec('fileTest.js'), 1)
endfunc
  
function! Test_ASpec_GetSpecPattern()
  call Describe("file.js")
  let expected = '.*/file(_spec.js|_test.js|Test.js|_spec.js.coffee)'
  call AssertEquals(ASpec_GetSpecPattern("file.js"), expected)
endfunc

function! Test_ASpec_GetImplPattern()
  call Describe("file_spec.js")
  let expected = '.*/(file.js|file.js.coffee|file.coffee)$'
  let actual = ASpec_GetImplPattern('file_spec.js')
  call AssertEquals(actual, expected)
  
  call Describe("file_spec.rb")
  let expected = '.*/file.rb$'
  let actual = ASpec_GetImplPattern('file_spec.rb')
  call AssertEquals(actual, expected)
endfunc


