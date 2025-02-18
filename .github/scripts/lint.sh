#!/bin/bash

echo ''
echo '#######################################################################'
echo '#                Running linters inside Docker container              #'
echo '#######################################################################'

clean_pyc () { echo 'cleaning .pyc files'; find . -name "*.pyc" -exec rm -f {} \; ; }
trap clean_pyc EXIT

LINTERS_FAILED=0

echo ''
echo '#######################################################################'
echo '#                            Running black                            #'
echo '#######################################################################'
black --check $PROJECT_DIR

BLACK_STATUS=$?
if [[ ("$BLACK_STATUS" == 0) ]]; then
  echo '#######################################################################'
  echo '#                            Black succeded                           #'
  echo '#######################################################################'
else
  echo ''
  echo '#######################################################################'
  echo '#                            Black failed    !                        #'
  echo '#######################################################################'
  LINTERS_FAILED=1
fi

echo ''
echo '#######################################################################'
echo '#                             Running MyPy                            #'
echo '#######################################################################'
mypy $PROJECT_DIR

MYPY_STATUS=$?
if [[ ("$MYPY_STATUS" == 0) ]]; then
  echo '#######################################################################'
  echo '#                             MyPy succeded                           #'
  echo '#######################################################################'
else
  echo ''
  echo '#######################################################################'
  echo '#                             MyPy failed    !                        #'
  echo '#######################################################################'
  LINTERS_FAILED=1
fi

echo ''
echo '#######################################################################'
echo '#                             Running PyType                          #'
echo '#######################################################################'
# pytype pyi-error disabled due to https://github.com/google/pytype/issues/355
# pytype import error disabled because some packages (e.g. pyvoronoi) don't have any
# type hinting available.
pytype $PROJECT_DIR --disable=pyi-error,import-error

PYTYPE_STATUS=$?
if [[ ("$PYTYPE_STATUS" == 0) ]]; then
  echo '#######################################################################'
  echo '#                             PyType succeded                         #'
  echo '#######################################################################'
else
  echo ''
  echo '#######################################################################'
  echo '#                             PyType failed    !                      #'
  echo '#######################################################################'
  LINTERS_FAILED=1
fi


echo ''
echo '#######################################################################'
echo '#                         Running pycodestyle                         #'
echo '#######################################################################'
pycodestyle $PROJECT_DIR --config $PROJECT_DIR/pycodestyle.cfg

PYCODESTYLE_STATUS=$?
if [[ ("$PYCODESTYLE_STATUS" == 0) ]]; then
  echo '#######################################################################'
  echo '#                         pycodestyle succeded                        #'
  echo '#######################################################################'
else
  echo ''
  echo '#######################################################################'
  echo '#                         pycodestyle failed    !                     #'
  echo '#######################################################################'
  LINTERS_FAILED=1
fi

echo ''
echo '#######################################################################'
echo '#                    Removing type checking caches                    #'
echo '#######################################################################'
rm -rf $PROJECT_DIR/.mypy_cache
rm -rf $PROJECT_DIR/.pytype

if [[ ("$LINTERS_FAILED" == 0) ]]; then
  echo '#######################################################################'
  echo '#                    Linters finished with success                    #'
  echo '#######################################################################'
  exit 0
else
  echo ''
  echo '#######################################################################'
  echo '#                           Linters failed!                           #'
  echo '#######################################################################'
  exit 1
fi
