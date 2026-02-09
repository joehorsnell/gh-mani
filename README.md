# gh-mani

This is a [GitHub CLI extension](https://docs.github.com/en/github-cli/github-cli/creating-github-cli-extensions#about-github-cli-extensions) to generate config for [`mani`](https://manicli.com/), a CLI repo management tool.

Once installed, run it using `gh mani ...` and it outputs Mani YAML config to stdout by default.

## Installation

```bash
gh extension install joehorsnell/gh-mani
```

To update:

```bash
gh extension upgrade mani
```

## Usage

Basic usage, outputs to stdout and uses the GitHub CLI’s default org/user context:

```bash
gh mani
```

Specify an org:

```bash
gh mani my-org
```

Write config to a file (defaults to `mani.yaml` if no file is provided):

```bash
gh mani my-org --output mani.yaml
```

Filter and limit repos (default limit is 1000). Here we exclude repos that are archived or forks ("source" only):

```bash
gh mani my-org --limit 50 --no-archived --source
```

By default, [tags](#tags) are generated in the Mani [config](https://manicli.com/config). To disable tags:

```bash
gh mani my-org --no-tags
```

By default, tags are generated for [repo topics](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/classifying-your-repository-with-topics).

To disable topics (still includes other tags):

```bash
gh mani my-org --no-topic-tags
```

Show help:

```bash
gh mani --help
```

## Output

The Mani config is printed to stdout by default, so you can pipe or redirect it anywhere:

```bash
gh mani my-org | tee mani.yaml
```
Or use `--output` to write to a file:

```bash
gh mani my-org --output mani.yaml
```

## Tags

By default, tags include:

- `defaultBranch=<name>`: eg `defaultBranch=main`
- `isArchived=true|false`
- `isFork=true|false`
- `visibility=public|private|internal` (lowercased)
- `topic=<topic>` (when topic tags are enabled)

## Options

- `--blobless-clone-size-limit-in-mb <mb>`: adds `git clone --filter=blob:none` for repos over this size (MB). Default is `500` MB if unset. Can also be set using `BLOBLESS_CLONE_SIZE_LIMIT_IN_MB` env var.
- `--limit <n>`: limit number of repos to fetch. Default is `1000`.
- `--archived` / `--no-archived`: include only archived / only non-archived repos.
- `--fork` / `--source`: include only forked repos / only non-fork ("source") repos.
- `--no-tags`: omit all tags in the output.
- `--no-topic-tags`: omit topic tags (still includes other tags).
- `--output [file]`: write the generated Mani config to a file instead of stdout (default: `mani.yaml`).
- `-h`, `--help`: show help.
