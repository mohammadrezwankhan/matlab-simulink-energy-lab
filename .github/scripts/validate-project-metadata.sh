#!/usr/bin/env bash
set -euo pipefail

metadata_value() {
  sed -n "s/^$1: \"\(.*\)\"$/\1/p" project-metadata.yml
}

name="$(metadata_value name)"
source_url="$(metadata_value source_of_record_url)"
landing_url="$(metadata_value landing_page_url)"
version="$(metadata_value version)"
terminology="$(metadata_value core_terminology)"

for value in "$name" "$source_url" "$landing_url" "$version" "$terminology"; do
  test -n "$value"
done

test "$(jq -r '.name' codemeta.json)" = "$name"
test "$(jq -r '.codeRepository' codemeta.json)" = "$source_url"
test "$(jq -r '.sameAs' codemeta.json)" = "$source_url"
test "$(jq -r '.url' codemeta.json)" = "$landing_url"
test "$(jq -r '.version' codemeta.json)" = "$version"

grep -Fq "title: \"$name\"" CITATION.cff
grep -Fq "version: \"$version\"" CITATION.cff
grep -Fq "repository-code: \"$source_url\"" CITATION.cff
grep -Fq "$source_url" README.md
grep -Fq "$landing_url" README.md
grep -Fq "$source_url" FAQ.md
grep -Fq "$landing_url" FAQ.md
grep -Fq "$source_url" llms.txt
grep -Fq "$landing_url" llms.txt
for file in README.md llms.txt; do
  grep -Fqi "grid-forming/grid-following" "$file"
  grep -Fqi "battery energy" "$file"
  grep -Fqi "storage system (BESS) control" "$file"
done

relative_links="$(grep -nEo '\]\([^)]+\)' llms.txt | grep -vE '\]\(https://' || true)"
if test -n "$relative_links"; then
  echo "llms.txt contains non-absolute Markdown links:" >&2
  echo "$relative_links" >&2
  exit 1
fi

echo "Project metadata and llms.txt link policy are consistent."
