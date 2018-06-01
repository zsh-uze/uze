# those are tests that should be dispatched
# when cleaning ...

uze TAP :all

slurp_works_with_empty_lines () {
    if {
        (( $#them == 4 ))
        ok "number of elements looks good" || {
            l '$them looks like:' $them |
                note-
            false
        }
    } {
        [[ $them[2]$them[4] = ab
        ]]; ok "slurp knows what empty lines are" ||
            { l $them | note- }
    }
}

everything_is_fine () {

    note 'with an explicit name'
    them=()
    l '' a '' b | slurp them
    slurp_works_with_empty_lines
    note 'using $them by default'
    them=()
    l '' a '' b | slurp
    slurp_works_with_empty_lines

}

prove everything_is_fine
