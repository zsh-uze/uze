# todo list

* debian-control can either
  * install .zwc file instead of .zsh one
  * install a .zsh then compile one

# uze for impatients

uze make your zsh more perlish

download [uze](https://raw.githubusercontent.com/zsh-uze/uze/master/lib/uze.zsh)
somewhere in your local drive and add this in your `.zshenv`

  . /path/to/uze.zsh
  # or just
  . uze.zsh
  # if uze.zsh is in your path

now, the behaviors described below applies. so you can write

    uze my-lib :all

    if {which perl} {
        warn "perl is ready to run"
    } else {
        # yes! you can use yada now
        ...
    }

# uze

general informations about `uze` are available on
[the project page](https://github.com/zsh-uze). this document is the `uze.zsh`
manual.

in the current manual, we expect `uze.zsh` to be loaded.

## write and install a module

say `~lib` is a directory declared in your `$path` and the content of
`~lib/my/helpers.zsh` is (possibly `zcompile`d)

    my/helpers/greetings () {
        l "hello, ${1:-world}"
    }

    my/helpers/dont () {
        l "don't do this, ${1:-world}"
    }

    my/helpers/cheers () {
        l "cheers, ${1:-world}"
    }

you can source it the way you usually do

    .  my/helpers.zsh

    my/helpers/greetings

uze gives you the ability to "export" fonctions another namespace
(by default: no namespace, think of it as the perl `main`). so you can write

    uze my/helpers greetings
    greetings

    uze/export/my/helpers () {
        EXPORT_TAGS=( :cool 'cheers greetings' )
        EXPORT=( "$@" )
    }

### uzeless

## default behaviours

those defaults are discuted in the programming guide, they became mine after
years of zsh programming and hours of zsh debuging.

    setopt warncreateglobal nounset pipefail  # make zsh stricter
    setopt extendedglob braceccl rcquotes # make zsh more expressive
    promptsubst promptbang promptpercent  # prompt goodness available in variable substitions

those options are described in man `zshopt`

see also the "yada yada operator" from the helpers section.

## helpers

### uze

`uze` loads a module and execute the `uze/import/the/module` function. then
exports the functions declared in `EXPORT_TAGS` and `EXPORT` variables.

see the project page documentation for more details about writting modules and
dealing with namespaces.

### shush, shush1, shush2

redirect standard IOs to `/dev/null` so you can silently run a commmand

    shush  redirect both stderr and stdout
    shush1 redirect only stdout
    shush2 redirect only stderr

so

    shush grep foo bar && echo ok

is like

    grep foo bar &> /dev/null && echo ok

### warn

warn prints a message in stderr without changing the last command return (`$?`).

### die

die warns and exit.

### getlines

read multiple lines into a list of variables

    date +"%Y\n%m" | getlines year month
    echo $year

### slurp

read multiple lines in an array

    getent passwd | slurp users
    print "entry of root is" $users[1]

### typeset aliases

those are shorter, memorizable aliases for `typeset -A`
(local associative array) and `typeset -a` (local array).

    Perl                       | zsh                   | uze
    ---------------------------------------------------------------
    my %foo                    | typeset -A  foo       | my% foo
    my @bar                    | typeset -a  bar       | my@ bar
    my %foo # in global scope  | typeset -gA  foo      | our% foo
    my @bar # in global scope  | typeset -ga  bar      | our@ bar
    ref $user                  | ${(t)user}            |
    (ref $user) // 'no more'   | ${(t)user-no more}    |
    exists $user{cpan}         | (( $+user[cpan] ))    | defined user\[cpan]


`my@` is only useful inside a function to prevent the declaration
of a global array.

### the yada-yada operator (...)

warns an "unimplemented" message and returns false (255 actually).

    ...
    Unimplemented in zsh line 6

    f () {
        defined DEBUG && ...
        l 'i don''t know what to do in DEBUG mode' }

    f
    l 'see ?'
    DEBUG=msg f

    <stdout> i don't know what to do in DEBUG mode
    <stdout> see ?
    <stderr> at f line 1, warning: unimplemented

### defined

test if a variable is defined

    defined 1

is a readable way to write

    (( $+1 ))

