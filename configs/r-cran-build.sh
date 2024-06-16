# Based on https://docs.posit.co/resources/install-r-source.html

export R_VERSION="4.4.1"

wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz
tar -xzvf R-${R_VERSION}.tar.gz
cd R-${R_VERSION}

./configure --prefix="$HOME/R-${R_VERSION}" --enable-R-shlib --enable-memory-profiling

make
make install

echo "export RSTUDIO_WHICH_R=$HOME/R-${R_VERSION}/bin/R" >> $HOME/.profile
echo "export PATH=$HOME/R-${R_VERSION}/bin" >> $HOME/.profile
