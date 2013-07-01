erl_interface-rpm
=================

A simple Makefile to package the native parts of Erlang's
[erl_interface](http://erlang.org/doc/apps/erl_interface/) as RPM package.
The package will be made from the Erlang version found on the executing host.
Of course, you'll need to have rpmbuild and Erlang installed to create the
package. After this
```
git clone https://github.com/schlagert/erl_interface-rpm.git
make
```
you should find your RPM package in the current working directory.
```
$ ls
Makefile  README.md  erl_interface-3.7.9-1.el6.i386.rpm
```
