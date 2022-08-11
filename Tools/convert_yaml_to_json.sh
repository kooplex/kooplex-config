for i in *.yaml
	do
		cat $i | yq -o=json > $i".jsonnet"
	done
