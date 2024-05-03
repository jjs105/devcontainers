## Description

Provides the PHPUnit tool(s) allowing unit and code coverage testing of PHP code
and applications.

## Sources

There are many existing examples of similar, simple features. These
implementations use different approaches, both of which are as described in the
main README.md file of this repository.

## Tests

The tests associated with this feature checks that PHPUnit:

1) Is installed in the correct location
1) Can be run with the `--version` flag without error

The tests are run against the following scenarios:

* Latest Ubuntu base image with no options set (auto-generated)
* Latest Ubuntu base image with php 'cli' only and 'full' installation options
* Standard Alpine base image with php 'cli' only and 'full' installation options
* Standard PHP 7 and PHP 8 base images with no additional PHP installation
* Alpine PHP 7 and PHP 8 base images with no additional PHP installation

Note:
* The main automated test will fail as the feature does not install/include an
underlying PHP installation.
* The tests utilising PHP 7 images specify PHPUnit version 9 for compatibility
purposes.
