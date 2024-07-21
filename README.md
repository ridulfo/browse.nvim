# browse.nvim
**A experimental browser for [Neovim](https://github.com/neovim/neovim).**

*Currently in early development. This repository is public so that the plugin can be shared.*

## Goal
In the same way that you can `gf` to a file, doing `gf` over a url will open it.

The webpage is converted from html to markdown using [pandoc](https://en.wikipedia.org/wiki/Pandoc) and saved to the download path. This is in order to have access to the pages offline too. Markdown (without svg) does not take much space. The directory structure of the download directory will be the same as the website.

**Example: (not implemented yet)**
Going to `example.com` and then to `example.com/blog/post-123` will result in the following directories and files being created:
```
- ~/.browse/
    - example.com/
        - index.md
        - blog/
            - post-123.md
```

## Installation
Add this to your `Lazy.nvim`:
```lua
{ "ridulfo/browse.nvim" }
```

### Default options
```lua
{
	download_path = "~/.browse",
}
```

## Required dependencies
- `wget`      - fetch html page
- `pandoc`    - convert html to markdown
