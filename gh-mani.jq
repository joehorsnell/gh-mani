  "projects:",
  (
    sort_by(.name)
    | map("  \(.name):\n    url: \(.url)\n    tags:\n      - isArchived=\(.isArchived // false)\n      - visibility=\(.visibility // "PUBLIC")\n      - defaultBranch=\(.defaultBranchRef.name // "")\n      - isFork=\(.isFork // false)\n" +
      (if .diskUsage and (.diskUsage > ((env.BLOBLESS_CLONE_SIZE_LIMIT_IN_MB // "100" | tonumber) * 1024))
       then "    clone: git clone --filter=blob:none \(.url)\n"
       else ""
       end)
    )
    | .[]
  )
