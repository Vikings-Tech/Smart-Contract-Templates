Contributing to Smart Contract Templates
=======

We really appreciate and value contributions. Please take 5' to review the items listed below to make sure that your contributions are merged as soon as possible.

## Contribution guidelines

- Please ensure that you are following the [Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html) as suggested by solidity in their docs while creating your contracts.
- Add Comments to improve the readability of your contract. You can refer to the following [article](https://jeancvllr.medium.com/solidity-tutorial-all-about-comments-bc31c729975a)
## Creating Pull Requests (PRs)

As a contributor, you are expected to fork this repository, work on your own fork and then submit pull requests. The pull requests will be reviewed and eventually merged into the main repo. See ["Fork-a-Repo"](https://help.github.com/articles/fork-a-repo/) for how this works.

## A typical workflow

1) Make sure your fork is up to date with the main repository:

```
cd Smart-Contract-Templates
git remote add upstream https://github.com/Vikings-Tech/Smart-Contract-Templates.git
git fetch upstream
git pull --rebase upstream master
```
NOTE: The directory `Smart-Contract-Templates` represents your fork's local copy.

2) Branch out from `master` into `fix/some-bug-#123`:
(Postfixing #123 will associate your PR with the issue #123 and make everyone's life easier =D)
```
git checkout -b fix/some-bug-#123
```

3) Make your changes, add your files, commit, and push to your fork.

```
git add SomeFile.js
git commit "Fix some bug #123"
git push origin fix/some-bug-#123
```


5) Go to [github.com/Vikings-Tech/Smart-Contract-Templates](https://github.com/Vikings-Tech/Smart-Contract-Templates) in your web browser and issue a new pull request.

6) Maintainers will review your code and possibly ask for changes before your code is pulled in to the main repository. We'll review the coding style, and check for general code correctness. If everything is OK, we'll merge your pull request and your code will be part of the repository!
