# browse.nvim
**An experimental minimalistic browser for Neovim.**

*Currently in early development. This repository is public so that the plugin can be shared.*

## Goal
In the same way that you can `gf` to a file, doing `gf` on a url will open it.

The webpage is converted from html to markdown using [pandoc](https://en.wikipedia.org/wiki/Pandoc) and saved to the download directory. This serves as an offline browsing history. Markdown (without svg) does not take much space. The directory structure of the download directory will be the same as the website.

### Example usage

1. User: Puts cursor on `https://example.com` and then press `gf`.
2. Nvim: A markdown version of the page is opened in either a new pane or the current one.
3. User: Finds link `example.com/blog/post-123.html` and puts cursor on it and presses `gf`.
4. Nvim: A markdown version of the page is opened in either a new pane or the current one.

This will result in the following directories and files being created in the download directory:
```bash
- ~/.browse/
    - example.com/
        - index.md
        - blog/
            - post-123.md

```
## Demo
[![asciicast](https://asciinema.org/a/EhIEwv3qPtXUJaUKcjr1x77l6.svg)](https://asciinema.org/a/EhIEwv3qPtXUJaUKcjr1x77l6)

## Installation
Just add this to your [Lazy.nvim](https://lazy.folke.io) plugins:
```lua
{ "ridulfo/browse.nvim", opts = {} },
```

### Default options
```lua
{
	download_path = "~/.browse",
}
```

### Options
#### `download_path`
1. left empty, will get the default value
1. set to a path
1. set to `false`, this will disable saving of pages

## Required dependencies
- `wget`      - fetch html page
- `pandoc`    - convert html to markdown

### MacOS
```bash
brew install wget pandoc
```

### Debian/Ubuntu
```bash
sudo apt install wget pandoc

```
