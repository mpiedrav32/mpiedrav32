# https://docs.posit.co/resources/install-r-source.html

export R_VERSION=4.4.1

wget https://cran.r-project.org/src/base/R-4/R-${R_VERSION}.tar.gz
tar -xzvf R-${R_VERSION}.tar.gz
cd R-${R_VERSION}

./configure \
  --prefix=/opt/R/${R_VERSION} \
  --enable-R-shlib \
  --enable-memory-profiling \
  --with-blas \
  --with-lapack

make
sudo make install

/opt/R/${R_VERSION}/bin/R --version

sudo ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
sudo ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

echo "export RSTUDIO_WHICH_R=/opt/R/${R_VERSION}/bin/R" >> $HOME/.profile
