# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal portfolio website built with Zola static site generator.
The site features a clean, minimalist design with dark/light theme support and is deployed to https://erazemk.com/.

## Development Commands

- `zola build` - Build the static site (output goes to `public/`)
- `zola serve` - Start development server with hot reloading (usually at http://127.0.0.1:1111)
- `zola check` - Validate site structure and check for broken links
- Playwright MCP server: Test after each change

## Architecture

### Site Structure

- `config.toml` - Main Zola configuration with site metadata, social links, and feature flags
- `content/` - Markdown content organized by sections:
  - `content/_index.md` - Homepage content
  - `content/posts/` - Blog posts (currently disabled via `show_posts = false`)
  - `content/projects/` - Project showcase (currently disabled via `show_projects = false`)
- `templates/` - Tera template files:
  - `base.html` - Base template with SEO meta tags, social media cards, analytics
  - `index.html` - Landing page template with conditional content blocks
  - `list.html` - Template for listing pages
  - `single.html` - Template for individual content pages
- `static/` - Static assets:
  - `css/` - Stylesheets with CSS custom properties for theming
  - `res/` - Source images (processed images go to `processed_images/`)
  - `favicons/` - Various favicon formats

### Key Features

- Responsive design with CSS custom properties for consistent theming
- Automatic dark/light theme based on system preference
- Image processing with automatic resizing and optimization
- SEO optimized with Open Graph and Twitter Card meta tags
- GoatCounter analytics integration
- Atom feed generation for content sections
- Boxicons for social media icons

### Configuration Notes

- Posts and projects sections are currently disabled but can be enabled by setting `show_posts = true` and `show_projects = true` in `config.toml`
- Social links are configured in `config.toml` under `[[extra.social]]` sections
- Profile image and description are configured in the `[extra]` section
