*! version 0.1.1  27sep2020
/***
{* *! version 0.1.1  27sep2020}{...}
{vieweralsosee "posthdf" "help posthdf"}{...}
{viewerjumpto "Stored results" "usehdf##results"}{...}
Title
====== 

__usehdf__ {hline 2} Load data from HDF5 files for __posthdf__
Syntax
------ 

> __usehdf__ {help filename:{it:filename}} [, _options_]

where _filename_ is the path to the {help posthdf##HDF5:HDF5 file}.

| _options_          |  Description          |
|:------------------|:-------------------------------------------------------------|
| __**n**ame(_str_)__ | specify group name for datasets in the root group ('/') |
| [{bf:{ul:no}}]{bf:{ul:r}oot} | do not/only read datasets directly attached to the root group ('/') |
| __**gr**oups(_list_)__ | only read datasets directly attached to the specified groups |
| __**a**ppend__ | append datasets to existing datasets in memory |

__Note:__
'Dataset' refers to an HDF5 dataset.  
{space 7}'Group' refers to an HDF5 group, which are containers for datasets.

__Default behavior:__

> If no option is specified, __usehdf__ loads all data
and organizes them by the groups that they are directly attached to.
Data directly attached to the root group ('/') are collected under the name 'root'.
(Stata name does not allow '/'.)
Existing data in memory from a previous call of __usehdf__ are removed.

Description
------

__usehdf__ is an auxiliary command for {help posthdf:{bf:posthdf}}.
It loads data from an HDF5 file and organizes them by group name.

In a typical use case, there is no need to call __usehdf__ separately.
{help posthdf:{bf:posthdf}} calls __usehdf__
whenever __using__ _filename_ is specified.
All options for __usehdf__ can be specified in the same way
for {help posthdf:{bf:posthdf}}.

Examples
------

To load all datasets from an HDF5 file:

> __. usehdf example.h5__

To specify a name for datasets directly attached to the root group
and only load these datasets:

> __. usehdf example.h5, name(base) root__

To ignore any dataset directly attached to the root group:

> __. usehdf example.h5, noroot__

To only load datasets from certain groups and keep the existing data in memory:

> __. usehdf example.h5, groups(A B C) append__

{marker results}{...}
Stored results
------

__usehdf__ stores the following in __r()__:

{synoptset 24 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(n_hdfgroup)}}number of groups loaded into memory{p_end}

{syntab:Macros}
{synopt:{cmd:r(hdf_file)}}path of HDF5 file{p_end}
{synopt:{cmd:r(hdfgroup_names)}}list of group names{p_end}

__Remarks:__

> __1.__ Stata name does not allow '/'.
Hence, if a group name has to contain '/'
(which is the case whenever the group is below the root group by two or more levels),
any '/' is replaced by '_'.

> __2.__ A group name that is longer than 27 characters
will be truncated to satisfy
the maximum length allowed by {help estimates:{bf:estimates store}}.

> __3.__ The loaded data are stored in Python dictionaries.
To access these data in Python,
enter {help python:Python} interactive environment and import __ests__:

> > __>>> from posthdf import ests__

> __ests__ is an ordered dictionary holding all the loaded data
using group names as keys.
Each value of __ests__ is again a dictionary for the specific group,
where the names of datasets are used as keys and 
the values are data to be posted.

Author
------

Junyuan Chen  
Department of Economics  
University of California San Diego  
Support: [https://github.com/junyuan-chen/posthdf](https://github.com/junyuan-chen/posthdf)

License
------

[MIT License](https://github.com/junyuan-chen/posthdf/blob/master/LICENSE.md)

- - -

This help file was dynamically produced by 
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/) 
***/


program usehdf, rclass
    version 16
    gettoken filename : 0, parse(" ,")
    syntax anything [, Name(string) Root noRoot GRoups(string) Append]

    if "`name'" == "" {
        local name "root"
    }

    python: load("`filename'", "`name'", "`root'", "`groups'", "`append'")
end


version 16
python: from posthdf import load