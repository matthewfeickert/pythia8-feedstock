#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Linux" ]; then
    PYTHIA_ARCH=LINUX
else
    PYTHIA_ARCH=DARWIN
fi

if [ "${ARCH}" == "64" ]; then
    EXTRAS="--enable-64bit"
else
    EXTRAS=""
fi

./configure \
    --with-python-include="$(python -c "from sysconfig import get_paths; info = get_paths(); print(info['include'])")" \
    --with-python-bin="${PREFIX}/bin/" \
    --arch=${PYTHIA_ARCH} \
    --enable-shared \
    --prefix=${PREFIX} \
    ${EXTRAS}

make install -j${CPU_COUNT}

# Make links so conda can find the bindings
ln -s "${PREFIX}/lib/pythia8.so" "${SP_DIR}/"

# Add the post activate/deactivate scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-pythia8.sh"
cp "${RECIPE_DIR}/activate.csh" "${PREFIX}/etc/conda/activate.d/activate-pythia8.csh"
cp "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/activate-pythia8.fish"

mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.sh"
cp "${RECIPE_DIR}/deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.csh"
cp "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/deactivate-pythia8.fish"
