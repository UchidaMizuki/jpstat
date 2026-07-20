## Test environments

* Windows 11 Pro, R 4.6.0 (local)
* Windows Server, R-devel (win-builder)

## R CMD check results

0 errors | 0 warnings | 0 notes

Checked against the dev version (0.4.0.9000); the only NOTE seen locally
("Version contains large components") is an artifact of the dev version
number and will not appear once the version is bumped to 0.5.0 for
submission.

## Notes

* `urlchecker::url_check()` flags `https://www.mlit-data.jp/` (in
  `man/resas.Rd`) with a 403 for requests without browser-like headers. The
  URL loads fine in a real browser and with a standard `User-Agent`; this
  appears to be bot-blocking on the site's end rather than a broken link.
