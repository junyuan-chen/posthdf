# version 0.1.1  27sep2020
from sfi import Scalar, Macro, Matrix, SFIToolkit
from numbers import Number
from collections import OrderedDict
from pathlib import Path
import numpy as np
import h5py
sn = SFIToolkit.strToName
st = SFIToolkit.stata

# Container for loaded data
ests = OrderedDict()

# Container for user-provided parsers
custom_parsers = []

def get_scalar(x):
    """Handle iterable object read from HDF5 when scalar is expected
    """
    return x if x.ndim==0 else x[0]

def decode(x):
    """Decode in case input is bytes-like
    """
    try:
        x = x.decode()
        return x
    except:
        return x

def is_num(x):
    return isinstance(x, Number)

def get_parents(n, o):
    """Obtain parents of all datasets
    """
    if isinstance(o, h5py.Dataset):
        load.parents.append(o.parent.name)

def coef(v, cnames):
    b = v.reshape(1,len(v))
    bname = SFIToolkit.getTempName()
    Matrix.store(bname, b)
    if cnames:
        Matrix.setColNames(bname, cnames)
    return bname

def vcov(v, cnames):
    V = np.diag(v) if v.ndim == 1 else v
    vname = SFIToolkit.getTempName()
    Matrix.store(vname, V)
    if cnames:
        Matrix.setColNames(vname, cnames)
        Matrix.setRowNames(vname, cnames)
    return vname

def generic(k, v):
    if v.ndim == 0:
        if is_num(v):
            Scalar.setValue(sn(k), v)
            st('ereturn scalar '+sn(k)+'='+sn(k))
        else:
            Macro.setLocal(sn(k), decode(v))
            st('ereturn local '+sn(k)+' `'+sn(k)+"'")
    elif v.ndim == 1:
        if all(is_num(n) for n in v):
            tname = SFIToolkit.getTempName()
            Matrix.store(tname, v.reshape(1,len(v)))
            st('ereturn matrix '+sn(k)+'='+tname)
        else:
            v = ' '.join([str(s) for s in v])
            Macro.setLocal(sn(k), v)
            st('ereturn local '+sn(k)+' `'+sn(k)+"'")
    elif v.ndim == 2:
        if all(is_num(n) for n in v):
            tname = SFIToolkit.getTempName()
            Matrix.store(tname, v)
            st('ereturn matrix '+sn(k)+'='+tname)

def load(path, rootname, root, groups, append):
    global ests
    if append == '':
        ests = OrderedDict()
    load.parents = []
    p = Path(path)
    gs = ['/'] if root=='root' else groups.split()
    empty_groups = [] # Record empty groups
    typeunknown = [] # Record datasets with unknown dtype
    # Store all data in ests
    with h5py.File(p, 'r') as h:
        # Collect all unique parents by default
        if len(gs) == 0:
            h.visititems(get_parents)
            gs = [g if g == '/' else g[1:] for g in set(load.parents)]
        if root == 'noroot':
            gs = [g for g in gs if g != '/']
        if len(gs) == 0:
            SFIToolkit.errprintln('No group is found.')
            SFIToolkit.exit(7103)
        for g in gs:
            # Stata name does not allow '/'
            e = sn(rootname) if g == '/' else g
            # Ensure group name is not too long for est store
            if len(e)>27:
                SFIToolkit.errprintln('Warning: The following group name is too long for Stata:')
                SFIToolkit.errprintln(e)
                SFIToolkit.errprintln('Try truncating the name to 27 characters.')
                e = e[:27]
            e = sn(g)
            if g in h:
                d = {}
                for k, v in h[g].items():
                    if isinstance(v, h5py.Dataset):
                        try:
                            d[k] = v[()]
                        except TypeError:
                            typeunknown.append(g+'/'+k)
                if len(d):
                    if e in ests:
                        print("Warning: Existing data of group '"+e+"' are overwritten.")
                    ests[e] = d
                else:
                    empty_groups.append(g)
            else:
                SFIToolkit.errprintln('A non-existing group name is passed to option groups().')
                SFIToolkit.exit(7103)
    if len(empty_groups):
        print('Groups do not contain any dataset are omitted:')
        print('  '+' '.join(empty_groups))
    if len(typeunknown):
        SFIToolkit.errprintln('Warning: The following datasets have datatypes not recognized by NumPy and are omitted:')
        for tu in typeunknown:
            SFIToolkit.errprintln('  '+tu)
    if len(ests) == 0:
        SFIToolkit.errprintln('No data found.')
        SFIToolkit.exit(7103)
    n_est = str(len(ests))
    est_keys = ' '.join(ests.keys())
    f = str(p)
    st('return scalar n_hdfgroup='+n_est)
    st('return local hdfgroup_names '+est_keys)
    st('return local hdf_file '+f)

def post(gname, parser, nostore, key_b, key_V, key_y, key_cnames, key_N, key_dofr, check=True):
    if check:
        if len(ests) == 0:
            SFIToolkit.errprintln('Specify using or run usehdf first.')
            SFIToolkit.exit(7103)
        # Select est based on gname
        if isinstance(gname, int):
            if not 0<=gname<len(ests):
                SFIToolkit.errprintln('Value passed to option i() is out of range.')
                SFIToolkit.exit(7103)
            est = list(ests.values())[gname]
            gname = list(ests.keys())[gname]
        elif gname in ests:
            est = ests[gname]
        else:
            SFIToolkit.errprintln('Specified group name is not in memory.')
            SFIToolkit.exit(7103)
    else:
        est = ests[gname]
    cnames = None
    if key_cnames in est:
        cnames = list(est[key_cnames])
        if callable(parser):
            cnames = parser(cnames)
        elif isinstance(parser, int) and 0<=parser<len(custom_parsers):
            cnames = custom_parsers[parser](cnames)
        elif parser is not None:
            SFIToolkit.errprintln('Invalid specification of parser.')
            SFIToolkit.exit(7103)
    # Generate options for ereturn post
    y = ''
    if key_y in est:
        y = ' dep('+sn(decode(get_scalar(est[key_y])))+')'
    obs = ''
    if key_N in est:
        obs = ' obs('+str(int(get_scalar(est[key_N])))+')'
    dof = ''
    if key_dofr in est:
        dof = ' dof('+str(int(get_scalar(est[key_dofr])))+')'
    if key_b in est:
        bname = ' '+coef(est[key_b], cnames)
        if key_V in est:
            vname = ' '+vcov(est[key_V], cnames)
            st('ereturn post'+bname+vname+','+y+obs+dof)
        else:
            st('ereturn post'+bname+','+y+obs+dof)
    # Classify and format the remaining objects and then post in e-class
    for k, v in est.items():
        if not k in (key_b, key_V, key_cnames, key_y, key_N, key_dofr):
            generic(k, v)
    # est store only works if e(cmd) exists
    if 'cmd' not in est:
        st('ereturn local cmd posthdf')
    if nostore == "":
        st('est store '+gname)

def postall(parser, nostore, key_b, key_V, key_y, key_cnames, key_N, key_dofr):
    if len(ests) == 0:
        SFIToolkit.errprintln('Specify using or run usehdf first.')
        SFIToolkit.exit(7103)
    for g in ests.keys():
        post(g, parser, nostore, key_b, key_V, key_y, key_cnames, key_N, key_dofr, check=False)
