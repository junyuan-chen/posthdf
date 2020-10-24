*! version 0.1.1  27sep2020
/***
{* *! version 0.1.1  27sep2020}{...}
{vieweralsosee "usehdf" "help usehdf"}{...}
{viewerjumpto "Saving HDF5 files" "posthdf##HDF5"}{...}
{viewerjumpto "Parsers" "posthdf##parsers"}{...}
Title
======

__posthdf__ {hline 2} Post estimation results from HDF5 files
Syntax
------ 

> __posthdf__ [_groupnames_] [__using__ {help filename:{it:filename}}]
[, _options_ {help usehdf:{it:usehdf_options}}]

where _groupnames_ are the groups of estimates to be posted in __e()__
and _filename_ is the path to the {help posthdf##HDF5:HDF5 file}.

__Notes:__

> __1.__ __using__ _filename_
is required unless {help usehdf:{bf:usehdf}} has been called.

> __2.__ If neither _groupnames_ nor option __i(_#_)__ is specified,
all available groups will be posted unless __with(_strlist_)__
or __without(_strlist_)__ is specified.

> __3.__ Any character invalid for being used in Stata names, such as '/',
will be replaced by '_' automatically when the data are loaded.

> __4.__ A group name should not be longer than 27 characters.
Otherwise, it will be truncated.

| _options_ | Default | Description |
|:----------------|:------------|:-------------------------------------------------|
| __**p**arser(_str_)__ | {space 1} | interpret {help fvvarlist:factor variables} and {help tsvarlist:time-series operators} from |
| {space 1} | {space 1} | coefficient names with the specified method (see {help posthdf##parsers:Parsers}) |
| {bf:i({help numlist:{it:numlist}})} | {space 1} | post the {bf:i}th group in __e()__ when the order is known from {help usehdf:{bf:usehdf}} |
| __**w**ith(_strlist_)__ | {space 1} | only post groups with at least one of the strings in the group name |
| __**witho**ut(_strlist_)__ | {space 1} | do not post groups with any of the strings in the group name |
| __**nos**tore__ | {space 1} | do not store results through {help estimates:{bf:estimates store}} |
| __b(_str_)__ | 'b' | specify key for the matrix __b__ |
| __v(_str_)__ | 'V' | specify key for the matrix __V__ |
| __y(_str_)__ | 'depvar' | specify key for the name of the dependent variable |
| __**cn**ames(_str_)__ | 'coefnames' | specify key for coefficient names |
| __**o**bs(_str_)__ | 'N' | specify key for the number of observations |
| __**d**ofr(_str_)__ | 'df_r' | specify key for the residual degrees of freedom |

__Notes:__

> __1.__ The options __with(_strlist_)__ and __without(_strlist_)__
have precedence over optional arguments _groupnames_ and option __i(_#_)__
for selecting the groups.

> __2.__ 'Key' refers to the name of the HDF5 dataset containing the relevant object.
All the data where specifying the key is allowed
are related to {help ereturn:{bf:ereturn post}}.
If the keys are misspecified, the data will still be posted.
However, they will not be posted through {help ereturn:{bf:ereturn post}}.
See {help posthdf##HDF5:Saving HDF5 files} for details.

Description
------

__posthdf__ posts scalars, macros and matrices in __e()__
using estimation results stored in {help posthdf##HDF5:HDF5 files}.
Multiple groups of results from the file can be posted in one command
and are saved in memory through {help estimates:{bf:estimates store}}
using the group name for each group.

For estimation results with coefficient vector __b__ and variance-covariance matrix __V__,
if coefficient names are provided,
they will be used to set column names and row names of these matrices.
This is done automatically as long as the dataset
containing the coefficient names are found.
Optionally, if the coefficient names indicate
levels and interactions for {help fvvarlist:factor variables}
and {help tsvarlist:time-series operators} such as leads and lags,
they can be converted into a format that Stata understands
using a parser specified by option __parser(_str_)__.
The parser is a Python function taking the list of coefficient names as the argument.
Users can provide their own parsers if desired (see {help posthdf##parsers:Parsers}).

Many Stata postestimation features require more information beyond __b__ and __V__.
If the number of observations, the residual degrees of freedom 
and the name of the dependent variable are provided,
they will be specified when posting the estimates through {help ereturn:{bf:ereturn post}}.
Other data loaded from the HDF5 file will also be posted,
if they can be classified as scalars, macros or matrices.

Whenever __using__ _filename_ is specified,
__posthdf__ calls {help usehdf:{bf:usehdf}} to load data from the HDF5 file.
See {help usehdf:{bf:usehdf}} for more details regarding to data loading.

Installation
------

The latest release can be obtained by running the following command:

> __. net install posthdf, replace from(https://raw.githubusercontent.com/junyuan-chen/posthdf/stable/)__

__Note:__

> To check the version of the current installation of __posthdf__,
use the {help which:{bf:which}} command:

> > __. which posthdf__

Since the functionality relies on the Python integration introduced in Stata 16,
a Python installation is required (Python version 3.7 or above is recommended)
and it needs to be linked to Stata (see {help python:{bf:python set exec}}).

The following Python packages are required:

> [NumPy](https://numpy.org/)  
[h5py](https://www.h5py.org/)

If you do not already have a Python installation,
a simple way to set up the Python environment
is to install [Miniconda](https://docs.conda.io/en/latest/miniconda.html),
which provides Python and a package manager called
[conda](https://docs.conda.io/projects/conda/en/latest/).

{marker HDF5}{...}
Saving HDF5 files
------

An HDF5 file organizes its content using _groups_ and _datasets_.
Each collection of estimation results should be saved
in the same HDF5 group with each item being an HDF5 dataset named appropriately.

An HDF5 _group_ is just like a folder.
Results saved in the same group
will be posted in the same collection in Stata
as if they were generated from an e-class command.
The group name will also be used to save the results
through {help estimates:{bf:estimates store}}.
Any character contained in a group name that is invalid for
being used in a Stata name
will be replaced by an underscore character '_' automatically.
A group name that is longer than 27 characters
will be truncated to satisfy
the maximum length allowed by {help estimates:{bf:estimates store}}.

An HDF5 _dataset_ holds the data as an array.
Each object such as the coefficient vector,
the variance-covariance matrix,
the number of observations, etc.,
should be saved separately in its own HDF5 dataset.
The name of each dataset will be used
when the object is posted as __e(_name_)__ in Stata.
Note that the datatype for each HDF5 dataset should have a
[NumPy equivalent](https://numpy.org/doc/stable/reference/arrays.dtypes.html).
Otherwise, they will be omitted.

Certain objects provide special information for
{help ereturn:{bf:ereturn post}}.
It is best to name the datasets containing these objects
using the default values listed in the _options_ table
so that no further specification is needed to inform their locations.

Examples
------

To post all data from an HDF5 file that has been created
using the default keys as the names for the relevant datasets:

> __. posthdf using example.h5__

If only specific groups are needed,
specify their names:

> __. posthdf A B using example.h5__

Note that options for {help usehdf:{bf:usehdf}}
can be passed to __posthdf__ when __using__ is specified.
Hence, the example below gives the same results:

> __. posthdf using example.h5, groups(A B)__

However, in this case, only data for groups __A__ and __B__
are loaded into memory;
while in the previous example, all the data are loaded
even though the remaining data are not posted in __e()__.

If the coefficient names are stored in a dataset with some name other than 'coefnames',
it can be specified as follows:

> __. posthdf using example.h5, cnames(key_for_names)__

To select a parser for interpreting the coefficient names:

> __. posthdf using example.h5, parser(iwm)__

More details on the use of parsers can be found in {help posthdf##parsers:Parsers}.

__Note:__

> Whenever any option for keys or the parser is specified,
as in the above two examples,
they are applied to all the selected groups.

For the remaining examples,
assume that data have been loaded by calling {help usehdf:{bf:usehdf}}.

If groups __A__ and __B__ are known to be the first and second groups respectively
from __r(hdfgroup_names)__ returned by {help usehdf:{bf:usehdf}},
an alternative way to only post groups __A__ and __B__ is to specify:

> __. posthdf, i(1 2)__

Note that to loop through all the groups, one can make use of
__r(n_hdfgroup)__ and __r(hdfgroup_names)__ which are returned by {help usehdf##results:{bf:usehdf}}:

> __. forvalues i = 1(1)`r(n_hdfgroup)' {c -(}__  
{space 2}2. _do something for the `i'th group_  
{space 2}3. __{c )-}__

> __. foreach g in `r(hdfgroup_names)' {c -(}__  
{space 2}2. _do something for group `g'_  
{space 2}3. __{c )-}__

{marker parsers}{...}
Parsers
------

A parser for coefficient names is a Python function
that takes a list of coefficient names as input
and return a list of processed coefficient names
with the Stata syntax for {help fvvarlist:factor variables}
and {help tsvarlist:time-series operators}.
__posthdf__ comes with a parser named __iwm__,
which has been imported when __posthdf__ is called.
Users may develop their own parsers for specific needs
and pass the function to __posthdf.py__
through {help Python:Python} interactive environment.

__List of built-in parsers:__

> __1.__ __iwm__ is a parser designed for the Julia package
[InteractionWeightedModels.jl](https://github.com/junyuan-chen/InteractionWeightedModels.jl).
It interprets interaction terms and numerical levels taken by categorical variables.
Dummy variables taking 'true' or 'false' are taken into account.
Indicators for relative time are given the name 'treat'
with appropriate time-series operators added as prefix.

> More parsers may be added in future updates.

__Using a customized parser:__

> A parser tailored to individual needs can be specified
without editing the source code of __posthdf__.
To do this, first provide the parser to __posthdf__ as below
in {help Python:Python} interactive environment:

> > __>>> from posthdf import custom_parsers__  
__>>> custom_parsers.append(my_parser)__  

> where __custom_parsers__ is an empty list defined in __posthdf.py__  and
__my_parser__ is a user-provided Python function
that has been loaded/defined in {help Python:Python} interactive environment.
The parser can then be utilized by specifying its index in the list __custom_parsers__:

> > __. posthdf A, parser(0)__

> Note that __posthdf__ cannot access any object
defined in {help Python:Python} interactive environment.
Hence, directly passing a Python function through the __parser__ option
will result in an error.

Stored results
------

__posthdf__ stores results in __e()__ for each group of estimates
depending on what exist in the data.

Matrices __b__ and __V__ are handled in a special way in Stata
through __ereturn post [b [V]]__.
Note that matrix __V__ will be stored in __e(V)__ only when matrix __b__ is provided.

All other data will be stored as __e(_name_)__
where _name_ is the name of the HDF5 dataset,
if they can be classified as scalars, macros or matrices.

Note that for each group of estimates,
the results in __e()__ are saved through {help estimates:{bf:estimates store}}
using the group name by default.
Use {help estimates:{bf:estimates dir}} to see a list of saved results.

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


program posthdf, eclass
    version 16
    syntax [namelist(name=groupnames)] [using/] ///
        [, Parser(string) i(numlist >0 int) ///
        With(string) WITHOut(string) noStore ///
        b(string) v(string) ///
        y(string) CNames(string) Obs(string) Dofr(string) ///
        Name(string) Root noRoot GRoups(string) Append]

    if "`using'" != "" {
        usehdf "`using'", n(`name') `root' gr(`groups') `append'
    }
    if "`parser'" == "" {
        local parser "None"
    }
    if "`b'" == "" {
        local b "b"
    }
    if "`v'" == "" {
        local v "V"
    }
    if "`y'" == "" {
        local y "depvar"
    }
    if "`cnames'" == "" {
        local cnames "coefnames"
    }
    if "`obs'" == "" {
        local obs "N"
    }
    if "`dofr'" == "" {
        local dofr "df_r"
    }
    python: parse_withs_withouts("`with'", "`without'")
    if "`i'" != "" {
        foreach n of numlist `i' {
            local id = `n' - 1
            python: post(`id', `parser', "`store'", "`b'", "`v'", "`y'", "`cnames'", "`obs'", "`dofr'")
        }
    }
    else if "`groupnames'" != "" {
        foreach gname in `groupnames' {
            python: post("`gname'", `parser', "`store'", "`b'", "`v'", "`y'", "`cnames'", "`obs'", "`dofr'")
        }
    }
    else {
        python: postall(`parser', "`store'", "`b'", "`v'", "`y'", "`cnames'", "`obs'", "`dofr'")
    }
end


version 16
python:
from posthdf import parse_withs_withouts, post, postall
from coefname_parsers import iwm
end