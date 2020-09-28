{smcl}
{* *! version 0.1.1  27sep2020}{...}
{vieweralsosee "posthdf" "help posthdf"}{...}
{viewerjumpto "Stored results" "usehdf##results"}{...}

{title:Title}

{p 4 4 2}
{bf:usehdf} {hline 2} Load data from HDF5 files for {bf:posthdf}

{title:Syntax}

{p 8 8 2} {bf:usehdf} {help filename:{it:filename}} [, {it:options}]

{p 4 4 2}
where {it:filename} is the path to the {help posthdf##HDF5:HDF5 file}.

{col 5}{it:options}{col 24}Description
{space 4}{hline}
{col 5}{bf:{ul:n}ame({it:str})}{col 24}specify group name for datasets in the root group ({c 39}/{c 39})
{col 5}[{bf:{ul:no}}]{bf:{ul:r}oot}{col 24}do not/only read datasets directly attached to the root group ({c 39}/{c 39})
{col 5}{bf:{ul:gr}oups({it:list})}{col 24}only read datasets directly attached to the specified groups
{col 5}{bf:{ul:a}ppend}{col 24}append datasets to existing datasets in memory
{space 4}{hline}
{p 4 4 2}
{bf:Note:}
{c 39}Dataset{c 39} refers to an HDF5 dataset.    {break}
{space 7}{c 39}Group{c 39} refers to an HDF5 group, which are containers for datasets.

{p 4 4 2}
{bf:Default behavior:}

{p 8 8 2} If no option is specified, {bf:usehdf} loads all data
and organizes them by the groups that they are directly attached to.
Data directly attached to the root group ({c 39}/{c 39}) are collected under the name {c 39}root{c 39}.
(Stata name does not allow {c 39}/{c 39}.)
Existing data in memory from a previous call of {bf:usehdf} are removed.


{title:Description}

{p 4 4 2}
{bf:usehdf} is an auxiliary command for {help posthdf:{bf:posthdf}}.
It loads data from an HDF5 file and organizes them by group name.

{p 4 4 2}
In a typical use case, there is no need to call {bf:usehdf} separately.
{help posthdf:{bf:posthdf}} calls {bf:usehdf}
whenever {bf:using} {it:filename} is specified.
All options for {bf:usehdf} can be specified in the same way
for {help posthdf:{bf:posthdf}}.


{title:Examples}

{p 4 4 2}
To load all datasets from an HDF5 file:

{p 8 8 2} {bf:. usehdf example.h5}

{p 4 4 2}
To specify a name for datasets directly attached to the root group
and only load these datasets:

{p 8 8 2} {bf:. usehdf example.h5, name(base) root}

{p 4 4 2}
To ignore any dataset directly attached to the root group:

{p 8 8 2} {bf:. usehdf example.h5, noroot}

{p 4 4 2}
To only load datasets from certain groups and keep the existing data in memory:

{p 8 8 2} {bf:. usehdf example.h5, groups(A B C) append}

{marker results}{...}

{title:Stored results}

{p 4 4 2}
{bf:usehdf} stores the following in {bf:r()}:

{synoptset 24 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(n_hdfgroup)}}number of groups loaded into memory{p_end}

{syntab:Macros}
{synopt:{cmd:r(hdf_file)}}path of HDF5 file{p_end}
{synopt:{cmd:r(hdfgroup_names)}}list of group names{p_end}

{p 4 4 2}
{bf:Remarks:}

{p 8 8 2} {bf:1.} Stata name does not allow {c 39}/{c 39}.
Hence, if a group name has to contain {c 39}/{c 39}
(which is the case whenever the group is below the root group by two or more levels),
any {c 39}/{c 39} is replaced by {c 39}_{c 39}.

{p 8 8 2} {bf:2.} The loaded data are stored in Python dictionaries.
To access these data in Python,
enter {help python:Python} interactive environment and import {bf:ests}:

{p 16 16 2} {bf:>>> from posthdf import ests}

{p 8 8 2} {bf:ests} is an ordered dictionary holding all the loaded data
using group names as keys.
Each value of {bf:ests} is again a dictionary for the specific group,
where the names of datasets are used as keys and 
the values are data to be posted.


{title:Author}

{p 4 4 2}
Junyuan Chen    {break}
Department of Economics    {break}
University of California San Diego    {break}
Support:  {browse "https://github.com/junyuan-chen/posthdf":https://github.com/junyuan-chen/posthdf}


{title:License}

{p 4 4 2}
{browse "https://github.com/junyuan-chen/posthdf/blob/master/LICENSE.md":MIT License}

{space 4}{hline}

{p 4 4 2}
This help file was dynamically produced by 
{browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package} 


