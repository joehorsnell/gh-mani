  "projects:",
  (
    sort_by(.name)
    | map("  \(.name):\n    url: \(.url)\n" +
      (if .diskUsage and (.diskUsage > (env.BLOBLESS_CLONE_SIZE_LIMIT_IN_MB | tonumber))
       then "    clone: git clone --filter=blob:none \(.url)\n"
       else ""
       end)
    )
    | .[]
  )
