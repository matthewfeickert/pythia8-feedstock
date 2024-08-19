#!/usr/bin/env bash
set -e

if [[ "${target_platform}" == linux-* ]]; then
    PYTHIA_ARCH=LINUX
else
    PYTHIA_ARCH=DARWIN
fi

# Use pybind11 from conda-forge
sed -i 's@overload_caster_t@override_caster_t@g' plugins/python/src/*.cpp
rm -rf plugins/python/include/pybind11
ln -s "${PREFIX}/include/pybind11" "${PWD}/plugins/python/include/pybind11"

# Have the compiler look for crypt.h in the conda include directory
# for Python 3.8 builds
# c.f. https://github.com/conda-forge/linux-sysroot-feedstock/issues/52
if [[ "${target_platform}" == linux-* ]]; then
    if [[ $(python -c "import sys; print(sys.version_info[:2] < (3, 9))") == "True" ]]; then
        export CPATH="${PREFIX}/include:${CPATH}"
    fi
fi

# debug information for logs
./configure --help

# highfive is a header-only library, so just need the include directory
./configure \
    --with-python-include="$(python -c "from sysconfig import get_paths; info = get_paths(); print(info['include'])")" \
    --with-python-bin="${PREFIX}/bin/" \
    --arch="${PYTHIA_ARCH}" \
    --prefix="${PREFIX}" \
    --with-lhapdf6="${PREFIX}" \
    --with-gzip="${PREFIX}" \
    --with-mg5mes \
    --with-hdf5="${PREFIX}" \
    --with-highfive-include="${PREFIX}/include/highfive"

make install --jobs="${CPU_COUNT}"

# Make links so conda can find the bindings
if [[ "${target_platform}" == linux-* ]]; then
    # Use relative symlink to avoid conda-build having to patch it
    # ('Making absolute symlink relative')
    ln --symbolic --relative "${PREFIX}/lib/pythia8.so" "${SP_DIR}/"
else
    # macOS doesn't support relative symlinks
    ln -s "${PREFIX}/lib/pythia8.so" "${SP_DIR}/"
fi

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-pythia8.sh"
cp "${RECIPE_DIR}/activate.csh" "${PREFIX}/etc/conda/activate.d/activate-pythia8.csh"
cp "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/activate-pythia8.fish"

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.sh"
cp "${RECIPE_DIR}/deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.csh"
cp "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.fish"
