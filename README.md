# POSTHDF: Post estimation results from HDF5 files

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/junyuan-chen/posthdf)](https://github.com/junyuan-chen/posthdf/releases)
[![view changelog](https://img.shields.io/badge/view-changelog-informational.svg)](https://github.com/junyuan-chen/posthdf/blob/master/CHANGELOG.md)
[![stata version](https://img.shields.io/badge/Stata%20version-≥%2016-informational)](https://www.stata.com/)
[![made-with-python](https://img.shields.io/badge/made%20with-Python-informational.svg)](https://www.python.org/)

`posthdf` is a [Stata](https://www.stata.com/) module
that posts scalars, macros and matrices in `e()`
using estimation results stored in [HDF5](https://www.hdfgroup.org/solutions/hdf5/) files.

## Why `posthdf`?
`posthdf` makes it easy to load estimation results
obtained from any statistical software into Stata
for producing tables and plots.

- Use the widely supported [HDF5](https://www.hdfgroup.org/solutions/hdf5/) file format to collect results generated from virtually any tool.

- Load groups of results into Stata with a simple one-line command.

- Access results in Stata with  [`estimates restore`](https://www.stata.com/help.cgi?estimates) and group names.

- Optionally specify and transform coefficient names with flexible customization.

- Streamline the editing process with [`estout`](http://repec.sowi.unibe.ch/stata/estout/index.html)
and [`coefplot`](http://repec.sowi.unibe.ch/stata/coefplot/index.html).

## Installation
The latest release is on the `stable` branch of this repository
and can be obtained by running the following command in Stata:

    net install posthdf, replace from(https://raw.githubusercontent.com/junyuan-chen/posthdf/stable/)

The `master` branch contains the latest development
that might have not been tagged for release.

**Note:**
To check the version of the current installation of `posthdf`,
run `which posthdf` in Stata.

Since the functionality relies on Python integration introduced in Stata 16,
a Python installation is required (Python version 3.7 or above is recommended)
and it needs to be linked to Stata with
[`python set exec`](https://www.stata.com/help.cgi?python).

The following Python packages are required:
- [NumPy](https://numpy.org/)  
- [h5py](https://www.h5py.org/)

If you do not already have a Python installation,
a simple way to set up the Python environment
is to install [Miniconda](https://docs.conda.io/en/latest/miniconda.html),
which provides Python and a package manager called
[conda](https://docs.conda.io/projects/conda/en/latest/).

## Usage
Once estimation results are saved in an HDF5 file,
posting them in Stata is very simple with `posthdf`.

#### Saving estimation results in an HDF5 file
An HDF5 file consists of `groups` and `datasets`.
Each collection of estimation results should be saved
in the same HDF5 group with each item being an HDF5 dataset named appropriately.

- An HDF5 `group` is just like a folder.
Results saved in the same group
will be posted in the same collection in Stata
as if they were generated from an e-class command.
The group name will also be used to save the results
through [`estimates store`](https://www.stata.com/help.cgi?estimates).
A group name that is invalid for being used as a Stata name
will be converted automatically.

- An HDF5 `dataset` holds the data as an array.
Each object such as the coefficient vector,
the variance-covariance matrix,
the number of observations, etc.,
should be saved separately in its own HDF5 dataset.
The name of each dataset will be used
when the object is posted as `e(name)` in Stata.

- Certain objects provide special information for
[`ereturn post`](https://www.stata.com/help.cgi?ereturn).
It is best to name the datasets containing these objects
using the default values listed in the help file (run `help posthdf` in Stata)
so that no further specification is needed to inform their locations.

#### Posting the estimation results in Stata
To post all the groups of estimation results in Stata, simply run

    posthdf using file_name

Each group of results are now saved under the group name (with any `/` replaced by `_`).

Note that `posthdf` also provides the following features:

- If an array of coefficient names are found,
they will be used to specify the column names and row names
for coefficient vector `b` and variance-covariance matrix `V`.

- If the coefficient names indicate
levels and interactions for [`factor variables`](https://www.stata.com/help.cgi?fvvarlist)
and [`time-series operators`](https://www.stata.com/help.cgi?tsvarlist)
such as leads and lags,
they can be converted into a format that Stata understands
using a parser specified by option `parser`.
Users can provide their own parsers if desired.

Please see the help files for details on syntax and more examples.

## Contributing

Contributors are welcome.
If you find any bug or have suggestions for improvement,
please open an issue or make a pull request.
