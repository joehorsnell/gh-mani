def repo_lines:
  [
    "  \(.name):",
    "    url: \(.url)",
    "    tags:",
    "      - defaultBranch=\(.defaultBranchRef.name // "")",
    "      - isArchived=\(.isArchived // false)",
    "      - isFork=\(.isFork // false)",
    "      - visibility=\(.visibility // "PUBLIC")",
    ""
  ]
  + (if .diskUsage and (.diskUsage > ((env.BLOBLESS_CLONE_SIZE_LIMIT_IN_MB // "100" | tonumber) * 1024))
     then ["    clone: git clone --filter=blob:none \(.url)"]
     else []
     end);

"projects:",
(
  sort_by(.name)
  | map(repo_lines | join("\n"))
  | .[]
)
