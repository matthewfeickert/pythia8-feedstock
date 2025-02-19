#!/bin/bash

set -x

echo -e "\n# Check installed directory structure"
test -d "${PREFIX}/bin"
test -d "${PREFIX}/include"
test -d "${PREFIX}/include/Pythia8"
test -d "${PREFIX}/lib"
test -d "${PREFIX}/share"
test -d "${PREFIX}/share/Pythia8"
test -d "${PREFIX}/share/Pythia8/examples"
test -d "${PREFIX}/share/Pythia8/xmldoc"

test ! -d "${PREFIX}/share/Pythia8/htmldoc"
test ! -d "${PREFIX}/share/Pythia8/pdfdoc"

echo -e "\n# Check installed files"
test -f "${PREFIX}/bin/pythia8-config"
test -f "${PREFIX}/include/Pythia8/Pythia.h"
test -f "${PREFIX}/lib/libpythia8${SHLIB_EXT}"
test -f "${PREFIX}/lib/libpythia8lhapdf6.so"
test -f "${PREFIX}/share/Pythia8/examples/Makefile"
test -f "${PREFIX}/share/Pythia8/examples/Makefile.inc"

cat ${PREFIX}/share/Pythia8/examples/Makefile.inc

#
echo -e "\n# Check pythia8-config CLI API and flags return expected values"
pythia8-config --help

pythia8-config --cxxflags

pythia8-config --ldflags

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
_with_hepmc2=$(pythia8-config --with-hepmc2)
if [[ "${_with_hepmc2}" == "true" ]]; then
    echo -e "# pythia8-config --with-hepmc2: ${_with_hepmc2}"
else
    echo "pythia8-config --with-hepmc2 is ${_with_hepmc2} but should be true"
    exit 1
fi
unset _with_hepmc2

echo ""
_with_hepmc3=$(pythia8-config --with-hepmc3)
if [[ "${_with_hepmc3}" == "true" ]]; then
    echo -e "# pythia8-config --with-hepmc3: ${_with_hepmc3}"
else
    echo "pythia8-config --with-hepmc3 is ${_with_hepmc3} but should be true"
    exit 1
fi
unset _with_hepmc3

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
./main01 &> main01_output.txt || ./main01

# Exit early under emulation
if [[ "${build_platform}" != "${target_platform}" ]]; then
    echo -e "\n# Target platform ${target_platform} requires emulation on"\
        "${build_platform} runners and will be too slow to run the full tests,"\
        "and so is being skipped."
    exit 0
fi

echo -e "\n# Test example main81 that uses the FastJet library extension"
make clean
# avoid lots of output to stdout from download of the file
lhapdf install cteq6l1 &> /dev/null

"$CXX" main81.cc -o main81 $CXXFLAGS $LDFLAGS -lpythia8 -lfastjet
./main81 main81.cmnd w+_production_lhc_0.lhe histout81.dat &> main81_output.txt || ./main81 main81.cmnd w+_production_lhc_0.lhe histout81.dat

echo -e "\n# Test example main51 that uses the LHAPDF library extension"
make clean
# avoid lots of output to stdout from download of the file
lhapdf install NNPDF31_nnlo_as_0118_luxqed &> /dev/null

# The examples assume you built locally and didn't install, so need to patch
# the relative path (../share) to the absolute path ($PREFIX/share)
sed -i "s|../share|$(readlink -f $PREFIX/share)|g" main51.cc

"$CXX" main51.cc -o main51 $(pythia8-config --cxxflags --ldflags)
./main51 &> main51_output.txt || ./main51

echo -e "\n# Test example main72 that uses the FastJet library extension"
make clean

"$CXX" main72.cc -o main72 $CXXFLAGS $LDFLAGS -lpythia8 -lfastjet
./main72 &> main72_output.txt || ./main72

echo -e "\n# Test example that use the HepMC2 and HepMC3 extensions"
"$CXX" main41.cc -o main41 $CXXFLAGS $LDFLAGS -lpythia8 -lHepMC3
./main41 &> main41_output.txt || ./main41
test -f hepmcout41.dat

"$CXX" main42.cc -o main42 $CXXFLAGS $LDFLAGS -lpythia8 -lHepMC3
./main42 main42.cmnd hepmcout42.dat &> main42_output.txt || ./main42 main42.cmnd hepmcout42.dat
test -f hepmcout42.dat

lhapdf install PDF4LHC15_nlo_asvar &> /dev/null
"$CXX" main43.cc -o main43 $CXXFLAGS $LDFLAGS -lpythia8 -lHepMC3
./main43 main43.cmnd hepmcout43.dat &> main43_output.txt || ./main43 main43.cmnd hepmcout43.dat
test -f hepmcout43.dat

"$CXX" main44.cc -o main44 $CXXFLAGS $LDFLAGS -lpythia8 -lHepMC3
./main44 main44.cmnd hepmcout44.dat &> main44_output.txt || ./main44 main44.cmnd hepmcout44.dat
test -f hepmcout44.dat

# uses same input card as main44
"$CXX" main45.cc -o main45 $CXXFLAGS $LDFLAGS -lpythia8 -lHepMC3
./main45 main44.cmnd hepmcout45.dat &> main45_output.txt || ./main45 main44.cmnd hepmcout45.dat
test -f hepmcout45.dat
