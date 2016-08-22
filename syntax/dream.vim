" Bail if our syntax is already loaded.
if exists('b:current_syntax') && b:current_syntax == 'dream'
  finish
endif

" Highlight long strings.
syntax sync fromstart

" These are `matches` instead of `keywords` because vim's highlighting
" priority for keywords is higher than matches. This causes keywords to be
" highlighted inside matches, even if a match says it shouldn't contain them --
" like with dreamAssign and dreamDot.
syn match dreamStatement /\<\%(return\|break\|continue\|throw\)\>/ display
hi def link dreamStatement Statement

syn match dreamRepeat /\<\%(for\|while\|until\|loop\)\>/ display
hi def link dreamRepeat Repeat

syn match dreamConditional /\<\%(if\|else\|unless\|switch\|when\|then\)\>/
\                           display
hi def link dreamConditional Conditional

syn match dreamException /\<\%(try\|catch\|finally\)\>/ display
hi def link dreamException Exception

syn match dreamKeyword /\<\%(fn\|new\|in\|of\|by\|and\|or\|not\|is\|isnt\|class\|extends\|super\|do\|yield\)\>/
\                       display
" The `own` keyword is only a keyword after `for`.
syn match dreamKeyword /\<for\s\+own\>/ contained containedin=dreamRepeat
\                       display
hi def link dreamKeyword Keyword

syn match dreamOperator /\<\%(instanceof\|typeof\|delete\)\>/ display
hi def link dreamOperator Operator

" The first case matches symbol operators only if they have an operand before.
syn match dreamExtendedOp /\%(\S\s*\)\@<=[+\-*/%&|\^=!<>?.]\{-1,}\|[-=]>\|--\|++\|:/
\                          display
syn match dreamExtendedOp /\<\%(and\|or\)=/ display
hi def link dreamExtendedOp dreamOperator

" This is separate from `dreamExtendedOp` to help differentiate commas from
" dots.
syn match dreamSpecialOp /[,;]/ display
hi def link dreamSpecialOp SpecialChar

syn match dreamBoolean /\<\%(nil\|true\|on\|yes\|false\|off\|no\)\>/ display
hi def link dreamBoolean Boolean

syn match dreamGlobal /\<\%(null\|undefined\)\>/ display
hi def link dreamGlobal Type

" A special variable
syn match dreamSpecialVar /\<\%(this\|prototype\|arguments\)\>/ display
hi def link dreamSpecialVar Special

" An @-variable
syn match dreamSpecialIdent /@\%(\%(\I\|\$\)\%(\i\|\$\)*\)\?/ display
hi def link dreamSpecialIdent Identifier

" A class-like name that starts with a capital letter
syn match dreamObject /\<\u\w*\>/ display
hi def link dreamObject Structure

" A constant-like name in SCREAMING_CAPS
syn match dreamConstant /\<\u[A-Z0-9_]\+\>/ display
hi def link dreamConstant Constant

" A variable name
syn cluster dreamIdentifier contains=dreamSpecialVar,dreamSpecialIdent,
\                                     dreamObject,dreamConstant

" A non-interpolated string
syn cluster dreamBasicString contains=@Spell,dreamEscape
" An interpolated string
syn cluster dreamInterpString contains=@dreamBasicString,dreamInterp

" Regular strings
syn region dreamString start=/"/ skip=/\\\\\|\\"/ end=/"/
\                       contains=@dreamInterpString
"syn region dreamString start=/'/ skip=/\\\\\|\\'/ end=/'/
"\                       contains=@dreamBasicString
hi def link dreamString String

" A integer, including a leading plus or minus
syn match dreamNumber /\%(\i\|\$\)\@<![-+]\?\d\+\%(e[+-]\?\d\+\)\?/ display
" A hex, binary, or octal number
syn match dreamNumber /\<0[xX]\x\+\>/ display
syn match dreamNumber /\<0[bB][01]\+\>/ display
syn match dreamNumber /\<0[oO][0-7]\+\>/ display
syn match dreamNumber /\<\%(Infinity\|NaN\)\>/ display
hi def link dreamNumber Number

" A floating-point number, including a leading plus or minus
syn match dreamFloat /\%(\i\|\$\)\@<![-+]\?\d*\.\@<!\.\d\+\%([eE][+-]\?\d\+\)\?/
\                     display
hi def link dreamFloat Float

" An error for reserved keywords, taken from the RESERVED array:
" http://dreamscript.org/documentation/docs/lexer.html#section-67
"syn match dreamReservedError /\<\%(case\|default\|function\|var\|void\|with\|const\|let\|enum\|export\|import\|native\|__hasProp\|__extends\|__slice\|__bind\|__indexOf\|implements\|interface\|package\|private\|protected\|public\|static\)\>/
syn match dreamReservedError /\<\%(case\|default\|function\|var\|void\|with\|const\|let\|enum\|export\|import\|native\|__hasProp\|__extends\|__slice\|__bind\|__indexOf\|implements\|interface\|package\|protected\|public\|static\)\>/
\                             display
hi def link dreamReservedError Error

" A normal object assignment
syn match dreamObjAssign /@\?\%(\I\|\$\)\%(\i\|\$\)*\s*\ze::\@!/ contains=@dreamIdentifier display
hi def link dreamObjAssign Identifier

syn keyword dreamTodo TODO FIXME XXX contained
hi def link dreamTodo Todo

syn match dreamComment /# .*/ contains=@Spell,dreamTodo
"syn match dreamComment /#!.*/ contains=@Spell,dreamTodo
syn match dreamComment /\( *\)#!.*\n\(\1 .*\n\)*/ contains=@Spell,dreamTodo
"syn match dreamComment /\( *\) #!\_.*\n\ze\1\(\S\)\@!/
hi def link dreamComment Comment

"syn region dreamBlockComment start=/#!/ end=/\n\n/
syn region dreamBlockComment start=/####\@!/ end=/###/
\                             contains=@Spell,dreamTodo
hi def link dreamBlockComment dreamComment

" A comment in a heregex
syn region dreamHeregexComment start=/#/ end=/\ze\/\/\/\|$/ contained
\                               contains=@Spell,dreamTodo
hi def link dreamHeregexComment dreamComment

" Embedded JavaScript
syn region dreamEmbed matchgroup=dreamEmbedDelim
\                      start=/`/ skip=/\\\\\|\\`/ end=/`/ keepend
\                      contains=@dreamJS
hi def link dreamEmbedDelim Delimiter

syn region dreamInterp matchgroup=dreamInterpDelim start=/#{/ end=/}/ contained
\                       contains=@dreamAll
hi def link dreamInterpDelim PreProc

" A string escape sequence
syn match dreamEscape /\\\d\d\d\|\\x\x\{2\}\|\\u\x\{4\}\|\\./ contained display
hi def link dreamEscape SpecialChar

" A regex -- must not follow a parenthesis, number, or identifier, and must not
" be followed by a number
syn region dreamRegex start=#\%(\%()\|\%(\i\|\$\)\@<!\d\)\s*\|\i\)\@<!/=\@!\s\@!#
\                      end=#/[gimy]\{,4}\d\@!#
\                      oneline contains=@dreamBasicString,dreamRegexCharSet
syn region dreamRegexCharSet start=/\[/ end=/]/ contained
\                             contains=@dreamBasicString
hi def link dreamRegex String
hi def link dreamRegexCharSet dreamRegex

" A heregex
syn region dreamHeregex start=#///# end=#///[gimy]\{,4}#
\                        contains=@dreamInterpString,dreamHeregexComment,
\                                  dreamHeregexCharSet
\                        fold
syn region dreamHeregexCharSet start=/\[/ end=/]/ contained
\                               contains=@dreamInterpString
hi def link dreamHeregex dreamRegex
hi def link dreamHeregexCharSet dreamHeregex

" Heredoc strings
syn region dreamHeredoc start=/"""/ end=/"""/ contains=@dreamInterpString
\                        fold
"syn region dreamHeredoc start=/'''/ end=/'''/ contains=@dreamBasicString
"                        fold
hi def link dreamHeredoc String

" An error for trailing whitespace, as long as the line isn't just whitespace
syn match dreamSpaceError /\S\@<=\s\+$/ display
hi def link dreamSpaceError Error

" An error for trailing semicolons, for help transitioning from JavaScript
syn match dreamSemicolonError /;$/ display
hi def link dreamSemicolonError Error

" Ignore reserved words in dot accesses.
syn match dreamDotAccess /\.\@<!\.\s*\%(\I\|\$\)\%(\i\|\$\)*/he=s+1 contains=@dreamIdentifier
hi def link dreamDotAccess dreamExtendedOp

" Ignore reserved words in prototype accesses.
syn match dreamProtoAccess /::\s*\%(\I\|\$\)\%(\i\|\$\)*/he=s+2 contains=@dreamIdentifier
hi def link dreamProtoAccess dreamExtendedOp

" This is required for interpolations to work.
syn region dreamCurlies matchgroup=dreamCurly start=/{/ end=/}/
\                        contains=@dreamAll
syn region dreamBrackets matchgroup=dreamBracket start=/\[/ end=/\]/
\                         contains=@dreamAll
syn region dreamParens matchgroup=dreamParen start=/(/ end=/)/
\                       contains=@dreamAll

" These are highlighted the same as commas since they tend to go together.
hi def link dreamBlock dreamSpecialOp
hi def link dreamBracket dreamBlock
hi def link dreamCurly dreamBlock
hi def link dreamParen dreamBlock

" This is used instead of TOP to keep things dream-specific for good
" embedding. `contained` groups aren't included.
syn cluster dreamAll contains=dreamStatement,dreamRepeat,dreamConditional,
\                              dreamException,dreamKeyword,dreamOperator,
\                              dreamExtendedOp,dreamSpecialOp,dreamBoolean,
\                              dreamGlobal,dreamSpecialVar,dreamSpecialIdent,
\                              dreamObject,dreamConstant,dreamString,
\                              dreamNumber,dreamFloat,dreamReservedError,
\                              dreamObjAssign,dreamComment,dreamBlockComment,
\                              dreamEmbed,dreamRegex,dreamHeregex,
\                              dreamHeredoc,dreamSpaceError,
\                              dreamSemicolonError,dreamDotAccess,
\                              dreamProtoAccess,dreamCurlies,dreamBrackets,
\                              dreamParens

if !exists('b:current_syntax')
  let b:current_syntax = 'dream'
endif
