#!/bin/bash

#
echo -e "\n# Check installed directory structure"
echo "# test -d ${PREFIX}/bin"
test -d "${PREFIX}/bin"
echo "# test -d ${PREFIX}/include"
test -d "${PREFIX}/include"
echo "# test -d ${PREFIX}/include/Pythia8"
test -d "${PREFIX}/include/Pythia8"
echo "# test -d ${PREFIX}/lib"
test -d "${PREFIX}/lib"
echo "# test -d ${PREFIX}/share"
test -d "${PREFIX}/share"
echo "# test -d ${PREFIX}/share/Pythia8"
test -d "${PREFIX}/share/Pythia8"
echo "# test -d ${PREFIX}/share/Pythia8/examples"
test -d "${PREFIX}/share/Pythia8/examples"
echo "# test -d ${PREFIX}/share/Pythia8/xmldoc"
test -d "${PREFIX}/share/Pythia8/xmldoc"

echo "# test ! -d ${PREFIX}/share/Pythia8/htmldoc"
test ! -d "${PREFIX}/share/Pythia8/htmldoc"
echo "# test ! -d ${PREFIX}/share/Pythia8/pdfdoc"
test ! -d "${PREFIX}/share/Pythia8/pdfdoc"

echo -e "\n# Check installed files"
echo "# test -f ${PREFIX}/bin/pythia8-config"
test -f "${PREFIX}/bin/pythia8-config"
echo "# test -f ${PREFIX}/include/Pythia8/Pythia.h"
test -f "${PREFIX}/include/Pythia8/Pythia.h"
if [[ "${target_platform}" == linux-* ]]; then
    echo "# test -f ${PREFIX}/lib/libpythia8.so"
    test -f "${PREFIX}/lib/libpythia8.so"
else
    # macOS
    echo "# test -f ${PREFIX}/lib/libpythia8.dylib"
    test -f "${PREFIX}/lib/libpythia8.dylib"
fi
echo "# test -f ${PREFIX}/lib/libpythia8lhapdf6.so"
test -f "${PREFIX}/lib/libpythia8lhapdf6.so"
echo "# test -f ${PREFIX}/share/Pythia8/examples/Makefile.inc"
test -f "${PREFIX}/share/Pythia8/examples/Makefile.inc"

#
echo -e "\n# Check pythia8-config CLI API and flags return expected values"
echo -e "# pythia8-config --help\n"
pythia8-config --help

echo -e "\n# pythia8-config --cxxflags: $(pythia8-config --cxxflags)"

echo -e "\n# pythia8-config --ldflags: $(pythia8-config --ldflags)"

echo ""
_with_lhapdf6=$(pythia8-config --with-lhapdf6)
if [[ "${_with_lhapdf6}" == "true" ]]; then
    echo -e "# pythia8-config --with-lhapdf6: ${_with_lhapdf6}"
else
    echo "pythia8-config --with-lhapdf6 is ${_with_lhapdf6} but should be true"
    exit 1
fi
unset _with_lhapdf6

echo ""
_with_fastjet3=$(pythia8-config --with-fastjet3)
if [[ "${_with_fastjet3}" == "true" ]]; then
    echo -e "# pythia8-config --with-fastjet3: ${_with_fastjet3}"
else
    echo "pythia8-config --with-fastjet3 is ${_with_fastjet3} but should be true"
    exit 1
fi
unset _with_fastjet3

echo ""
_with_gzip=$(pythia8-config --with-gzip)
if [[ "${_with_gzip}" == "true" ]]; then
    echo -e "# pythia8-config --with-gzip: ${_with_gzip}"
else
    echo "pythia8-config --with-gzip is ${_with_gzip} but should be true"
    exit 1
fi
unset _with_gzip

echo ""
_with_python=$(pythia8-config --with-python)
if [[ "${_with_python}" == "true" ]]; then
    echo -e "# pythia8-config --with-python: ${_with_python}"
else
    echo "pythia8-config --with-python is ${_with_python} but should be true"
    exit 1
fi
unset _with_python

echo ""
_with_mg5mes=$(pythia8-config --with-mg5mes)
if [[ "${_with_mg5mes}" == "true" ]]; then
    echo -e "# pythia8-config --with-mg5mes: ${_with_mg5mes}"
else
    echo "pythia8-config --with-mg5mes is ${_with_mg5mes} but should be true"
    exit 1
fi
unset _with_mg5mes

#
echo -e "\n# Test example main01"
cd examples/
make clean

"$CXX" main01.cc -o main01 $(pythia8-config --cxxflags --ldflags)
./main01 &> main01_output.txt

echo -e "\n# Test example main81 that uses the FastJet library extension"
make clean
# avoid lots of output to stdout from download of the file
lhapdf install cteq6l1 &> /dev/null

"$CXX" main81.cc -o main81 $CXXFLAGS $LDFLAGS -lpythia8 -lfastjet
./main81 main81.cmnd w+_production_lhc_0.lhe histout81.dat &> main81_output.txt

echo -e "\n# Test example main51 that uses LHAPDF library extension"
make clean
# avoid lots of output to stdout from download of the file
lhapdf install NNPDF31_nnlo_as_0118_luxqed &> /dev/null

# The examples assume you built locally and didn't install, so need to patch
# the relative path (../share) to the absolute path ($PREFIX/share)
sed -i "s|../share|$(readlink -f $PREFIX/share)|g" main51.cc

"$CXX" main51.cc -o main51 $(pythia8-config --cxxflags --ldflags)
./main51 &> main51_output.txt

echo -e "\n# Test example main72 that uses the FastJet library extension"
make clean

"$CXX" main72.cc -o main72 $CXXFLAGS $LDFLAGS -lpythia8 -lfastjet
./main72 &> main72_output.txt
