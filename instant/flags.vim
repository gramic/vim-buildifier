" Copyright 2016 Stanimir Mladenov. All rights reserved.
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


" Shout if maktaba is too old. Done here to ensure it's always triggered.
if !maktaba#IsAtLeastVersion('1.10.0')
  call maktaba#error#Shout('Codefmt requires maktaba version 1.10.0.')
  call maktaba#error#Shout('You have maktaba version %s.', maktaba#VERSION)
  call maktaba#error#Shout('Please update your maktaba install.')
endif


""
" The path to the buildifier executable.
call s:plugin.Flag('buildifier_executable', 'buildifier')
