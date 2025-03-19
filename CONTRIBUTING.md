# Contributing to euler-nix-common

## Commit message guidelines

Follow <https://www.conventionalcommits.org/en/v1.0.0/#specification>.

### Examples of a good commit message:

```
- chore(haskell/buildAnalysis): Run a new script in `postBuildHook`
- feat(haskell/buildAnalysis): Init haskell-flake custom package setting
- chore: Update spider
- chore: Update euler-mysql-dumps
```

Keep the commit message specific to the Nix change, all the other details are unnecessary. For example, `euler-nix-common` maintainers needn't worry about internal specifics of an update to `spider`, for us it is yet another flake input. Be specific about `spider`'s change in the commit message of its respective repo, or if it is something `euler-nix-common` maintainers must know add it in the commit or PR description.

### Examples of a bad commit message:

```
- Extracting service config keys
- Bumping DB dump of merchant_gateway_payment_method_flow table cration.
- EUL-11101 Splitpayment common
```

These commit messages either provide no information about what changes they make to `euler-nix-common` or they add extra noise (in the case of second commit message).

