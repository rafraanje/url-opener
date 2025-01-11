# URL Opener

A command-line tool that opens URLs based on pattern matching. It's particularly useful for quickly opening issue trackers, tickets, or other pattern-based URLs.

## Features

- Open URLs based on configurable patterns
- GUI mode with text entry dialog
- Grab selected text from any window
- Configurable URL patterns via config file
- Support for regex capture groups

## Installation

### Dependencies

The script requires the following dependencies:

For basic functionality:

    bash

For GUI support (--gui option):

    # Debian/Ubuntu
    sudo apt-get install zenity

    # RedHat/CentOS
    sudo yum install zenity

For text selection grabbing (--grab option):

    # Debian/Ubuntu
    sudo apt-get install xclip

    # RedHat/CentOS
    sudo yum install xclip

## Usage

### Basic Usage

    ./open_urls.sh [options] [identifier]

### Options

- `--gui`: Opens a GUI dialog for entering/editing the identifier
- `--grab`: Uses currently selected text as the identifier
- Both options can be combined: `--gui --grab`

### Examples

    # Basic usage
    ./open_urls.sh PROJECT-1234

    # Open GUI dialog
    ./open_urls.sh --gui

    # Open GUI with pre-filled text
    ./open_urls.sh --gui PROJECT-1234

    # Use selected text
    ./open_urls.sh --grab

    # Open GUI with selected text pre-filled
    ./open_urls.sh --gui --grab

## Configuration

The script uses a configuration file `url_patterns.conf` to define URL patterns. Each line in the file contains a pattern and URL template, separated by `|`:

    # Format: pattern|url_template
    ^(PROJECT-[0-9]+)$|https://company.atlassian.net/browse/{match}
    ^([A-Za-z0-9_-]+)#([0-9]+)$|https://github.com/{group1}/issues/{group2}
    ^(PROJECT-[A-Z0-9]+)$|https://company.sentry.io/issues/{match}

### Pattern Format

- Use regular expressions for patterns
- Patterns are anchored (must match entire input)
- Use capture groups `()` if needed
- Available replacements in URL template:
  - `{match}`: The entire matched text
  - `{group1}`, `{group2}`, etc.: Captured groups

### Example Patterns

    # Jira tickets
    ^(PROJECT-[0-9]+)$|https://company.atlassian.net/browse/{match}

    # GitHub issues
    ^([A-Za-z0-9_-]+)#([0-9]+)$|https://github.com/{group1}/issues/{group2}

    # Sentry issues
    ^(PROJECT-[A-Z0-9]+)$|https://company.sentry.io/issues/{match}


