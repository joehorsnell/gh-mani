def repo_lines:
  [
    "  \(.name):",
    "    url: \(.url)",
    "    tags:",
    "      - isArchived=\(.isArchived // false)",
    "      - visibility=\(.visibility // "PUBLIC")",
    "      - defaultBranch=\(.defaultBranchRef.name // "")",
    "      - isFork=\(.isFork // false)",
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
