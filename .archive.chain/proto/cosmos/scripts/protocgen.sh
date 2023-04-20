#!/usr/bin/env bash

set -eo pipefail

protoc_gen_gocosmos() {
  if ! grep "github.com/gogo/protobuf => github.com/regen-network/protobuf" go.mod &>/dev/null ; then
    echo -e "\tPlease run this command from somewhere inside the argus folder."
    return 1
  fi

  go get github.com/regen-network/cosmos-proto/protoc-gen-gocosmos@latest 2>/dev/null
}

protoc_gen_gocosmos

cd proto/cosmos
proto_dirs=$(find ./argus -path -prune -o -name '*.proto' -print0 | xargs -0 -n1 dirname | sort | uniq)
for dir in $proto_dirs; do
  for file in $(find "${dir}" -maxdepth 2 -name '*.proto'); do
      echo "generating $file"
      buf generate --template buf.gen.gogo.yaml $file
  done
done

cd ..

# move the generated proto files (*.pb.go / *.pb.gw.go) to x/<module-name>/types/ directory
cp -r github.com/argus-labs/argus/* ../
rm -rf github.com