# Contributing to Joker 🃏

First off, thank you for considering contributing to Joker! It's people like you that make the open-source community such an amazing place. We welcome any form of contribution, from reporting bugs and suggesting features to submitting pull requests.

## How Can I Contribute?

### Reporting Bugs

If you find a bug, please make sure to:

1. **Check the existing issues** to see if someone else has already reported it.
2. If not, **create a new issue**.
3. Provide a **clear and descriptive title**.
4. Include as much information as possible:
    * Steps to reproduce the bug.
    * What you expected to happen.
    * What actually happened.
    * Code snippets, screenshots, and error messages.
    * Your Flutter/Dart version.

### Suggesting Enhancements

If you have an idea for a new feature or an improvement:

1. **Create a new issue**.
2. Provide a **clear title** and a detailed description of your suggestion.
3. Explain **why** this enhancement would be useful and what problem it solves.

### Your First Code Contribution (Pull Requests)

Here’s a quick guide on how to get started.

### 1. Fork & Clone

* Fork the repository to your own GitHub account.
* Clone your fork to your local machine:

  ```bash
  git clone https://github.com/juanvegu/joker_dart.git
  cd joker_dart
  ```

### 2. Set Up Your Environment

* We use [Melos](https://melos.invertase.dev) to manage this monorepo. First, make sure you have it installed:

  ```bash
  dart pub global activate melos
  ```

* Bootstrap the project. This will install all dependencies and link the local packages together.

  ```bash
  melos bootstrap
  ```

### 3. Create a New Branch

* Create a branch from `develop` for your changes. Please use a descriptive branch name.

  ```bash
  git checkout develop
  git checkout -b feat/add-new-matcher # For features
  # or
  git checkout -b fix/resolve-dio-bug # For bug fixes
  ```

### 4. Make Your Changes

* Write your code! Make sure to also add or update tests for your changes.

### 5. Run Local Checks

* Before pushing, make sure all tests and analysis pass. You can run these checks across all packages using our Melos scripts:

  ```bash
  melos analyze:all
  melos test:all
  ```

### 6. Commit Your Changes

* We follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification. This is important because our release process relies on it. Your commit messages should be structured like this:

  ```bash
  # Example for a new feature
  git commit -m "feat(joker_dio): add support for streaming responses"

  # Example for a bug fix
  git commit -m "fix(joker): correct handling of request headers"
  ```

### 7. Push to Your Fork

* Push your new branch to your forked repository.

  ```bash
  git push origin feat/add-new-matcher
  ```

### 8. Open a Pull Request

* Go to the original `joker_dart` repository on GitHub and open a new Pull Request.
* Set the target branch to **`develop`**.
* Fill out the PR template with a clear description of your changes.

Once you've submitted your PR, a project maintainer will review it. Thank you for your contribution!

## Styleguides

### Git Commit Messages

As mentioned, we use **Conventional Commits**. Please ensure your commit messages adhere to this format.

### Dart Style

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style). The `melos analyze:all` command will help enforce these rules.
