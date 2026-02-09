# gh-mani

`gh-mani` is a [GitHub CLI extension](https://docs.github.com/en/github-cli/github-cli/creating-github-cli-extensions#about-github-cli-extensions) to generate config for [`mani`](https://manicli.com/), a CLI repo management tool.

Once installed, run it using `gh mani ...` and it outputs `mani` YAML config to stdout by default.

## What is `mani`?

[`mani`](https://manicli.com/) is a CLI tool for managing multiple source code repositories, allowing you to clone, fetch and perform other tasks across a set of configured "projects" (eg repos). This can be useful in a microservices setup, or in any situation where you have a group of repos that you want to operate on collectively.

`mani` requires a YAML [config](https://manicli.com/config) file to describe the projects, tasks, etc. that you want to manage. If you have an existing directory of repositories, `mani` can generate a basic config file for you, using its [`mani init`](https://manicli.com/commands#init) command, which will write out a `mani.yaml` file containing a project for each repo discovered.

But what if you don't already have a directory of repos to init the `mani` config from, maybe if you are starting on a new project.

This is where `gh-mani` can help, by generating `mani` config for all the repos in a given GitHub org. Let's use the GitHub [`cli`](https://github.com/cli) org as an example.

Once [installed](#installation), run it using `gh mani [org_name] [options]` and it outputs `mani` YAML config to stdout by default. We will pass in the `cli` org and use `--output mani.yaml` to write to a file. PLEASE NOTE: This will overwrite any existing `mani.yaml` in the current directory, so make sure to take a copy if you have one and its not backed-up.

```
gh mani cli --output mani.yaml
```

Note: Your `gh` CLI must already by authenticated (check using `gh auth status` to check and `gh auth login` to authenticate)

Now we can use `mani` with the generated config file, for example to show the sync status:

```
mani sync --status

 Project                 | Synced
-------------------------+--------
 browser                 | ✕
 cli                     | ✕
 gh-extension-precompile | ✕
 gh-webhook              | ✕
 go-gh                   | ✕
 go-internal             | ✕
 oauth                   | ✕
 safeexec                | ✕
 scoop-gh                | ✕
 shurcooL-graphql        | ✕

```

And if we want to clone all the repos, we can use []`mani sync`](https://manicli.com/commands#sync). Most times operations in `mani` can be run sequentially (the default) or in parallel, by passing the `--parallel` flag:

```
❯ mani sync --parallel
gh-webhook              | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/gh-webhook'...
browser                 | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/browser'...
cli                     | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/cli'...
gh-extension-precompile | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/gh-extension-precompile'...
go-gh                   | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/go-gh'...
go-internal             | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/go-internal'...
oauth                   | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/oauth'...
safeexec                | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/safeexec'...
scoop-gh                | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/scoop-gh'...
shurcooL-graphql        | Cloning into '/Users/joe/code/gh/joehorsnell/gh-mani/tmp/e2e/shurcooL-graphql'...


 Project                 | Synced
-------------------------+--------
 browser                 | ✓
 cli                     | ✓
 gh-extension-precompile | ✓
 gh-webhook              | ✓
 go-gh                   | ✓
 go-internal             | ✓
 oauth                   | ✓
 safeexec                | ✓
 scoop-gh                | ✓
 shurcooL-graphql        | ✓

```

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

Write config to a file:

```bash
gh mani my-org --output mani.yaml
```

Filter and limit repos (default limit is 1000). Here we exclude repos that are archived or forks ("source" only):

```bash
gh mani my-org --limit 50 --no-archived --source
```

By default, [tags](#tags) are generated in the `mani` [config](https://manicli.com/config). To disable tags:

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

The `mani` config is printed to stdout by default, so you can pipe or redirect it anywhere:

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
- `--output <file>`: write the generated `mani` config to a file instead of stdout.
- `-h`, `--help`: show help.
