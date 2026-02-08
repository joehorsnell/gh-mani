def topic_lines:
  (.repositoryTopics // []
   | map(.name)
   | sort
   | map("      - topic=\(.)"));

def tag_lines:
  [
    "    tags:",
    "      - defaultBranch=\(.defaultBranchRef.name // "")",
    "      - isArchived=\(.isArchived // false)",
    "      - isFork=\(.isFork // false)"
  ]
  + topic_lines
  + [
    "      - visibility=\((.visibility // "public") | ascii_downcase)"
  ];

def blobless_clone_size_limit_kb:
  (env.BLOBLESS_CLONE_SIZE_LIMIT_IN_MB // "500" | tonumber) * 1024;

def repo_lines:
  [
    "  \(.name):",
    "    url: \(.url)"
  ]
  + (if (env.NO_TAGS // "false") == "true" then [] else tag_lines end)
  + (if .diskUsage and (.diskUsage > blobless_clone_size_limit_kb)
     then ["    clone: git clone --filter=blob:none \(.url)"]
     else []
     end)
  + [""];

"projects:",
(
  sort_by(.name)
  | map(repo_lines | join("\n"))
  | .[]
)
