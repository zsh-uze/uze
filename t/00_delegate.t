path+=( t/bin )
uze TAP :all

honor_delegation () {
    plan 3

    uze/export/delegation1 () { delegate=false }
    uze delegation1 foo

    shush which delegation1/foo ; ok "delegation/foo loaded"
    ! shush which foo           ; ok "no delegation"

    uze/export/delegation1 () {:}
    uze delegation1 foo

    shush which foo             ; ok "delegation"

}

TAP/prove honor_delegation
