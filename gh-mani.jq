  "projects:",
  (
    sort_by(.name)
    | map("  \(.name):\n    url: \(.url)\n")
    | .[]
  )
