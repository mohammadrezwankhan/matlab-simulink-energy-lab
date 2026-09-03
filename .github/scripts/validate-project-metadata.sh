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
repository_slug="${source_url#https://github.com/}"
stars_badge="https://img.shields.io/github/stars/${repository_slug}?style=social"
forks_badge="https://img.shields.io/github/forks/${repository_slug}?style=social"
stars_badge_markdown="[![GitHub stars](${stars_badge})](${source_url}/stargazers)"
forks_badge_markdown="[![GitHub forks](${forks_badge})](${source_url}/network/members)"
reproduction_url="${source_url}/issues/new?template=reproduction_report.yml"
reproduction_template=".github/ISSUE_TEMPLATE/reproduction_report.yml"

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
grep -Fq "$stars_badge_markdown" README.md
grep -Fq "$forks_badge_markdown" README.md
grep -Fq "$reproduction_url" README.md
for file in README.md llms.txt; do
  grep -Fqi "grid-forming/grid-following" "$file"
  grep -Fqi "battery energy" "$file"
  grep -Fqi "storage system (BESS) control" "$file"
done

test -f "$reproduction_template"
for expected in \
  "name: Reproduction report" \
  "id: outcome" \
  "id: commit_sha" \
  "id: release_tag" \
  "id: entrypoint" \
  "id: command" \
  "id: environment" \
  "id: observed" \
  "id: expected" \
  "clean checkout of the stated commit" \
  "resolved 40-character SHA from git rev-parse HEAD" \
  "not hardware validation, certification evidence, or a broad compatibility claim"; do
  grep -Fq "$expected" "$reproduction_template"
done

relative_links="$(grep -nEo '\]\([^)]+\)' llms.txt | grep -vE '\]\(https://' || true)"
if test -n "$relative_links"; then
  echo "llms.txt contains non-absolute Markdown links:" >&2
  echo "$relative_links" >&2
  exit 1
fi

echo "Project metadata, live repository badges, reproduction intake, and llms.txt link policy are consistent."
