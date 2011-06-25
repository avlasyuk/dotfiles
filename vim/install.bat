:: Shall be executed with administrator access.
:: This is the way we can make symlinks with mklink utility.

set home=%UserProfile%

del "%home%\_vimrc"
rmdir "%home%\vimfiles"

mklink /d "%home%\vimfiles" "."
mklink "%home%\_vimrc" ".\_vimrc"
