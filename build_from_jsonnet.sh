#!/bin/bash

MODULE=$1
mkdir -p _build
BUILDDIR="_build/raw_${MODULE}"
MANIFEST="_build/manifest_${MODULE}"

if [[ -z "${MODULE}" ]]; then
	echo ERROR: MODULE is not set
	echo "Usage: build_from_jsonnet.sh <module>"
	exit
else
	echo "Build ${MODULE} module"
fi

if [[ -z "${KOOPLEX_REPO}" ]]; then
	echo "Using local directory ($PWD) to populate config files"
	KOOPLEX_REPO=$PWD
else
	echo "Using ${KOOPLEX_REPO} to populate config files"
fi

mkdir -p ${BUILDDIR} ${MANIFEST} 

cd ${BUILDDIR}

for f in `ls ${KOOPLEX_REPO}/${MODULE}/*.jsonnet`
do
	sf=$(echo $f | tr "." " " | awk '{print $1}')
	jsonnet -m . $f ; 
done

for f in `ls *-raw`
do
	sf=$(echo $f | tr "-" " " | awk '{print $1}')
	cat ${f} | gojsontoyaml > ${KOOPLEX_REPO}/${MANIFEST}/${sf}
done

#cd _build


# export r=`jsonnet -e "std.manifestYamlStream(
#  ['a', 1, []],
#  indent_array_in_object=true,
#  c_document_end=false)"`

# python -c "print('${r}')"
