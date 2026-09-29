# https://github.com/mizchi/moonbit-template
# SPDX-License-Identifier: MIT
# MoonBit Project Commands

target := "all"

default: fmt-check check test

fmt:
    moon fmt

fmt-check:
    moon fmt --check

check:
    moon check --target {{target}}

test:
    moon test --target {{target}}

test-update:
    moon test --update --target {{target}}

info:
    moon info

clean:
    moon clean

release-check: fmt-check info check test
