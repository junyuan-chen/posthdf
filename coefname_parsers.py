# version 0.1.1  27sep2020
def is_int(s):
    return s[1:].isdigit() if s[0]=='-' else s.isdigit()

def stata_operator(leadlag, level):
    """Return the prefix applied to variable names in Stata e(b), e(V) matrices
    """
    leadlag = int(leadlag)
    if leadlag == 0:
        ll=''
    elif leadlag == 1:
        ll='L'
    elif leadlag == -1:
        ll='F'
    elif leadlag > 1:
        ll='L'+str(leadlag)
    else:
        ll='F'+str(abs(leadlag))
    if int(level) < 0:
        raise ValueError('Negative factor levels are not allowed.')
    else:
        lv = str(level)
    op = lv+ll
    return op+'.' if op != '' else op

def iwm_factor(term, interact):
    factor = term.split(': ')
    if len(factor) == 2:
        if factor[0] == 'rel':
            return stata_operator(factor[1], 1)+'treat'
        elif is_int(factor[1]):
            return stata_operator(0, factor[1])+factor[0]
        elif factor[1] in ('true', 'false'):
            lev = 1 if str(factor[1]) == 'true' else 0
            return stata_operator(0, lev)+factor[0]
        else:
            print('Warning: Coeficient names contain unrecognized factor levels that are not reformatted.')
            return term
    elif len(factor) == 1 and interact:
        return 'c.'+term
    else:
        return term

def iwm(cnames):
    """Reformat coeficient names generated by InteractionWeightedModels.jl into Stata format
    """
    out = []
    for n in cnames:
        terms = n.split(' & ')
        if len(terms)>1:
            out.append('#'.join([iwm_factor(t, True) for t in terms]))
        else:
            out.append(iwm_factor(n, False))
    return out
