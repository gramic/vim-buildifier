" Copyright 2015 Stanimir Mladenov. All rights reserved.
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     http://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

let [s:plugin, s:enter] = maktaba#plugin#Enter(expand('<sfile>:p'))
if !s:enter
  finish
endif

""
" @private
" Formatter: buildifier
function! GetBuildifierFormatter() abort
  let l:formatter = {
    \ 'name': 'buildifier',
    \ 'setup_instructions': 'Install bazel buildifier from ' .
          \ ' https://github.com/bazelbuild/buildifier and ' .
          \ 'configure the buildifier_executable flag'}

  function l:formatter.IsAvailable() abort
    return executable(s:plugin.Flag('buildifier_executable'))
  endfunction

  function l:formatter.AppliesToBuffer() abort
    "return &filetype is# 'bzl'
    return 1
  endfunction

  ""
  " Run `buildifier` to format the whole file.
  "
  " We implement Format(), and not FormatRange{,s}(), because buildifier doesn't
  " provide a hook for formatting a range.
  function l:formatter.Format() abort
    let l:executable = s:plugin.Flag('buildifier_executable')
    let l:cmd = [ l:executable, '-mode=fix' ]
    let l:input = join(getline(1, line('$')), "\n")
    " Use stdout as the error message if stderr is empty.
    let l:result = maktaba#syscall#Create(l:cmd).WithStdin(l:input).Call(0)
    if !empty(l:result.stdout)
      let l:output = l:result.stdout
    else
      let l:output = l:result.stderr
    endif

    if !v:shell_error
      let l:formatted = split(l:output, "\n")
      call maktaba#buffer#Overwrite(1, line('$'), l:formatted)
    else
      let l:errors = []
      for line in split(l:output, "\n")
        let l:tokens = matchlist(line, '\C\v^.*:(\d+):(\d+):\s*(.*)')
        if !empty(l:tokens)
          call add(l:errors, {
                \ "filename": @%,
                \ "lnum": l:tokens[1],
                \ "col": l:tokens[2],
                \ "text": l:tokens[3]})
        endif
      endfor

      if empty(l:errors)
        " Couldn't parse errors; display the whole error message.
        call maktaba#error#Shout('Error formatting file: %s', l:output)
      else
        call setqflist(l:errors, 'r')
        cc 1
      endif
    endif
  endfunction

  return l:formatter
endfunction


let s:registry = maktaba#extension#GetRegistry('codefmt')
call s:registry.AddExtension(GetBuildifierFormatter())
