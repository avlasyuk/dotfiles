set home=%UserProfile%

del "%home%\_vimrc"
rmdir "%home%\vimfiles"

mklink /d "%home%\vimfiles" "."
mklink "%home%\_vimrc" ".\_vimrc"
