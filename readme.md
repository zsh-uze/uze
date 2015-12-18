the current documentation was extracted from the module. 
thinks we still have to do

* better error handling for `uze/pkg/do`
* finish and review the documentation
* test uze EXPORTER system (the tag functions are boring)

# uze

general informations about `uze` are available on
[the project page](https://zsh-uze.github.com/). this document is the `uze.zsh`
manual.

in the current manual, we expect `uze.zsh` to be loaded.

## default behaviours

those defaults are discuted in the programming guide, they became mine after 
years of zsh programming and hours of zsh debuging.

    setopt warncreateglobal nounset       # make zsh stricter
    setopt extendedglob braceccl rcquotes # make zsh more expressive

see also the "yada yada operator" from the helpers section.

## namespaces and modules

for more details about the behavior of `uze`, see the project page.

## other helpers

### shush, shush1, shush2

redirect standard IOs to `/dev/null` so you can silently run a commmand

    shush  redirect both stderr and stdout
    shush1 redirect only stdout
    shush2 redirect only stderr

so

    shush grep foo bar && echo ok

is like 

    shush grep &> /dev/null && echo ok

### warn

warn prints a message in stderr without changing the last command return (`$?`).

### die

die warns and exit.

### fill

read multiple lines into a list of variables 

    date +"%Y\n%m" | fill year month
    echo $year

### slurp

read multiple lines in an array

    getent passwd | slurp users
    print "entry of root is" $users[1]

### my% and my@ aliases

those are shorter, memorizable aliases for `typeset -A`
(local associative array) and `typeset -a` (local array). 

    Perl                     | zsh                   | uze
    ------------------------------------------------------------
    my %foo                  | typeset -A  foo       | my% foo
    my @bar                  | typeset -a  bar       | my@ bar
    ref $user                | ${(t)user}            |
    (ref $user) // 'no more' | ${(t)user-no more}    |
    exists $user{cpan}       | (( $+user[cpan] ))    |

`my@` is only usefull inside a function to prevent the declaration
of a global array.

### defined

### apply

### epply

### pipify

### the yada yada operator (...)

