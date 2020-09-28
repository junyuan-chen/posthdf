{smcl}
{* *! version 0.1.1  27sep2020}{...}
{vieweralsosee "usehdf" "help usehdf"}{...}
{viewerjumpto "Saving HDF5 files" "posthdf##HDF5"}{...}
{viewerjumpto "Parsers" "posthdf##parsers"}{...}

{title:Title}

{p 4 4 2}
{bf:posthdf} {hline 2} Post estimation results from HDF5 files

{title:Syntax}

{p 8 8 2} {bf:posthdf} [{it:groupnames}] [{bf:using} {help filename:{it:filename}}]
[, {it:options} {help usehdf:{it:usehdf_options}}]

{p 4 4 2}
where {it:groupnames} are the groups of estimates to be posted in {bf:e()}
and {it:filename} is the path to the {help posthdf##HDF5:HDF5 file}.

{p 4 4 2}
{bf:Notes:}

{p 8 8 2} {bf:1.} {bf:using} {it:filename}
is required unless {help usehdf:{bf:usehdf}} has been called.

{p 8 8 2} {bf:2.} If neither {it:groupnames} nor option {bf:i({it:#})} is specified,
all available groups will be posted.

{p 8 8 2} {bf:3.} The {c 39}/{c 39} contained in group names is not allowed in Stata names.
Hence, any {c 39}/{c 39} will be replaced by {c 39}_{c 39} automatically when the data are loaded.

{col 5}{it:options}{col 22}Default{col 35}Description
{space 4}{hline}
{col 5}{bf:{ul:p}arser({it:str})}{col 22}{space 1}{col 35}interpret {help fvvarlist:factor variables} and {help tsvarlist:time-series operators} from
{col 5}{space 1}{col 22}{space 1}{col 35}coefficient names with the specified method (see {help posthdf##parsers:Parsers})
{col 5}{bf:i({help numlist:{it:numlist}})}{col 22}{space 1}{col 35}post the {bf:i}th group in {bf:e()} when the order is known from {help usehdf:{bf:usehdf}}
{col 5}{bf:{ul:nos}tore}{col 22}{space 1}{col 35}do not store results through {help estimates:{bf:estimates store}}
{col 5}{bf:b({it:str})}{col 22}{c 39}b{c 39}{col 35}specify key for the matrix {bf:b}
{col 5}{bf:v({it:str})}{col 22}{c 39}V{c 39}{col 35}specify key for the matrix {bf:V}
{col 5}{bf:y({it:str})}{col 22}{c 39}depvar{c 39}{col 35}specify key for the name of the dependent variable
{col 5}{bf:{ul:cn}ames({it:str})}{col 22}{c 39}coefnames{c 39}{col 35}specify key for coefficient names
{col 5}{bf:{ul:o}bs({it:str})}{col 22}{c 39}N{c 39}{col 35}specify key for the number of observations
{col 5}{bf:{ul:d}ofr({it:str})}{col 22}{c 39}df_r{c 39}{col 35}specify key for the residual degrees of freedom
{space 4}{hline}
{p 4 4 2}
{bf:Note:}
{c 39}Key{c 39} refers to the name of the HDF5 dataset containing the relevant object.
All the data where specifying the key is allowed
are related to {help ereturn:{bf:ereturn post}}.
If the keys are misspecified, the data will still be posted.
However, they will not be posted through {help ereturn:{bf:ereturn post}}.
See {help posthdf##HDF5:Saving HDF5 files} for details.


{title:Description}

{p 4 4 2}
{bf:posthdf} posts scalars, macros and matrices in {bf:e()}
using estimation results stored in {help posthdf##HDF5:HDF5 files}.
Multiple groups of results from the file can be posted in one command
and are saved in memory through {help estimates:{bf:estimates store}}
using the group name for each group.

{p 4 4 2}
For estimation results with coefficient vector {bf:b} and variance-covariance matrix {bf:V},
if coefficient names are provided,
they will be used to set column names and row names of these matrices.
This is done automatically as long as the dataset
containing the coefficient names are found.
Optionally, if the coefficient names indicate
levels and interactions for {help fvvarlist:factor variables}
and {help tsvarlist:time-series operators} such as leads and lags,
they can be converted into a format that Stata understands
using a parser specified by option {bf:parser({it:str})}.
The parser is a Python function taking the list of coefficient names as the argument.
Users can provide their own parsers if desired (see {help posthdf##parsers:Parsers}).

{p 4 4 2}
Many Stata postestimation features require more information beyond {bf:b} and {bf:V}.
If the number of observations, the residual degrees of freedom 
and the name of the dependent variable are provided,
they will be specified when posting the estimates through {help ereturn:{bf:ereturn post}}.
Other data loaded from the HDF5 file will also be posted,
if they can be classified as scalars, macros or matrices.

{p 4 4 2}
Whenever {bf:using} {it:filename} is specified,
{bf:posthdf} calls {help usehdf:{bf:usehdf}} to load data from the HDF5 file.
See {help usehdf:{bf:usehdf}} for more details regarding to data loading.


{title:Installation}

{p 4 4 2}
The latest release can be obtained by running the following command:

{p 8 8 2} {bf:. net install posthdf, replace from(https://raw.githubusercontent.com/junyuan-chen/posthdf/stable/)}

{p 4 4 2}
{bf:Note:}

{p 8 8 2} To check the version of the current installation of {bf:posthdf},
use the {help which:{bf:which}} command:

{p 16 16 2} {bf:. which posthdf}

{p 4 4 2}
Since the functionality relies on the Python integration introduced in Stata 16,
a Python installation is required (Python version 3.7 or above is recommended)
and it needs to be linked to Stata (see {help python:{bf:python set exec}}).

{p 4 4 2}
The following Python packages are required:

{p 8 8 2}  {browse "https://numpy.org/":NumPy}    {break}
{browse "https://www.h5py.org/":h5py}

{p 4 4 2}
If you do not already have a Python installation,
a simple way to set up the Python environment
is to install  {browse "https://docs.conda.io/en/latest/miniconda.html":Miniconda},
which provides Python and a package manager called
{browse "https://docs.conda.io/projects/conda/en/latest/":conda}.

{marker HDF5}{...}

{title:Saving HDF5 files}

{p 4 4 2}
An HDF5 file organizes its content using {it:groups} and {it:datasets}.
Each collection of estimation results should be saved
in the same HDF5 group with each item being an HDF5 dataset named appropriately.

{p 4 4 2}
An HDF5 {it:group} is just like a folder.
Results saved in the same group
will be posted in the same collection in Stata
as if they were generated from an e-class command.
The group name will also be used to save the results
through {help estimates:{bf:estimates store}}.
A group name that is invalid for being used as a Stata name
will be converted automatically.

{p 4 4 2}
An HDF5 {it:dataset} holds the data as an array.
Each object such as the coefficient vector,
the variance-covariance matrix,
the number of observations, etc.,
should be saved separately in its own HDF5 dataset.
The name of each dataset will be used
when the object is posted as {bf:e({it:name})} in Stata.
Note that the datatype for each HDF5 dataset should have a
{browse "https://numpy.org/doc/stable/reference/arrays.dtypes.html":NumPy equivalent}.
Otherwise, they will be omitted.

{p 4 4 2}
Certain objects provide special information for
{help ereturn:{bf:ereturn post}}.
It is best to name the datasets containing these objects
using the default values listed in the {it:options} table
so that no further specification is needed to inform their locations.


{title:Examples}

{p 4 4 2}
To post all data from an HDF5 file that has been created
using the default keys as the names for the relevant datasets:

{p 8 8 2} {bf:. posthdf using example.h5}

{p 4 4 2}
If only specific groups are needed,
specify their names:

{p 8 8 2} {bf:. posthdf A B using example.h5}

{p 4 4 2}
Note that options for {help usehdf:{bf:usehdf}}
can be passed to {bf:posthdf} when {bf:using} is specified.
Hence, the example below gives the same results:

{p 8 8 2} {bf:. posthdf using example.h5, groups(A B)}

{p 4 4 2}
However, in this case, only data for groups {bf:A} and {bf:B}
are loaded into memory;
while in the previous example, all the data are loaded
even though the remaining data are not posted in {bf:e()}.

{p 4 4 2}
If the coefficient names are stored in a dataset with some name other than {c 39}coefnames{c 39},
it can be specified as follows:

{p 8 8 2} {bf:. posthdf using example.h5, cnames(key_for_names)}

{p 4 4 2}
To select a parser for interpreting the coefficient names:

{p 8 8 2} {bf:. posthdf using example.h5, parser(iwm)}

{p 4 4 2}
More details on the use of parsers can be found in {help posthdf##parsers:Parsers}.

{p 4 4 2}
{bf:Note:}

{p 8 8 2} Whenever any option for keys or the parser is specified,
as in the above two examples,
they are applied to all the selected groups.

{p 4 4 2}
For the remaining examples,
assume that data have been loaded by calling {help usehdf:{bf:usehdf}}.

{p 4 4 2}
If groups {bf:A} and {bf:B} are known to be the first and second groups respectively
from {bf:r(hdfgroup_names)} returned by {help usehdf:{bf:usehdf}},
an alternative way to only post groups {bf:A} and {bf:B} is to specify:

{p 8 8 2} {bf:. posthdf, i(1 2)}

{p 4 4 2}
Note that to loop through all the groups, one can make use of
{bf:r(n_hdfgroup)} and {bf:r(hdfgroup_names)} which are returned by {help usehdf##results:{bf:usehdf}}:

{p 8 8 2} {bf:. forvalues i = 1(1){c 96}r(n_hdfgroup){c 39} {c -(}}    {break}
{space 2}2. {it:do something for the {c 96}i{c 39}th group}    {break}
{space 2}3. {bf:{c )-}}

{p 8 8 2} {bf:. foreach g in {c 96}r(hdfgroup_names){c 39} {c -(}}    {break}
{space 2}2. {it:do something for group {c 96}g{c 39}}    {break}
{space 2}3. {bf:{c )-}}

{marker parsers}{...}

{title:Parsers}

{p 4 4 2}
A parser for coefficient names is a Python function
that takes a list of coefficient names as input
and return a list of processed coefficient names
with the Stata syntax for {help fvvarlist:factor variables}
and {help tsvarlist:time-series operators}.
{bf:posthdf} comes with a parser named {bf:iwm},
which has been imported when {bf:posthdf} is called.
Users may develop their own parsers for specific needs
and pass the function to {bf:posthdf.py}
through {help Python:Python} interactive environment.

{p 4 4 2}
{bf:List of built-in parsers:}

{p 8 8 2} {bf:1.} {bf:iwm} is a parser designed for the Julia package
{browse "https://github.com/junyuan-chen/InteractionWeightedModels.jl":InteractionWeightedModels.jl}.
It interprets interaction terms and numerical levels taken by categorical variables.
Dummy variables taking {c 39}true{c 39} or {c 39}false{c 39} are taken into account.
Indicators for relative time are given the name {c 39}treat{c 39}
with appropriate time-series operators added as prefix.

{p 8 8 2} More parsers may be added in future updates.

{p 4 4 2}
{bf:Using a customized parser:}

{p 8 8 2} A parser tailored to individual needs can be specified
without editing the source code of {bf:posthdf}.
To do this, first provide the parser to {bf:posthdf} as below
in {help Python:Python} interactive environment:

{p 16 16 2} {bf:>>> from posthdf import custom_parsers}    {break}
{bf:>>> custom_parsers.append(my_parser)}    {break}

{p 8 8 2} where {bf:custom_parsers} is an empty list defined in {bf:posthdf.py}  and
{bf:my_parser} is a user-provided Python function
that has been loaded/defined in {help Python:Python} interactive environment.
The parser can then be utilized by specifying its index in the list {bf:custom_parsers}:

{p 16 16 2} {bf:. posthdf A, parser(0)}

{p 8 8 2} Note that {bf:posthdf} cannot access any object
defined in {help Python:Python} interactive environment.
Hence, directly passing a Python function through the {bf:parser} option
will result in an error.


{title:Stored results}

{p 4 4 2}
{bf:posthdf} stores results in {bf:e()} for each group of estimates
depending on what exist in the data.

{p 4 4 2}
Matrices {bf:b} and {bf:V} are handled in a special way in Stata
through {bf:ereturn post [b [V]]}.
Note that matrix {bf:V} will be stored in {bf:e(V)} only when matrix {bf:b} is provided.

{p 4 4 2}
All other data will be stored as {bf:e({it:name})}
where {it:name} is the name of the HDF5 dataset,
if they can be classified as scalars, macros or matrices.

{p 4 4 2}
Note that for each group of estimates,
the results in {bf:e()} are saved through {help estimates:{bf:estimates store}}
using the group name by default.
Use {help estimates:{bf:estimates dir}} to see a list of saved results.


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


