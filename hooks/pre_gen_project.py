#!/usr/bin/env python
"""
NOTE:
    the below code is to be maintained Python 2.x-compatible
    as the whole Cookiecutter Django project initialization
    can potentially be run in Python 2.x environment.

TODO: restrict Cookiecutter Django project initialization
      to Python 3.x environments only
"""

from __future__ import print_function

TERMINATOR = "\x1b[0m"
WARNING = "\x1b[1;33m [WARNING]: "
INFO = "\x1b[1;33m [INFO]: "
HINT = "\x1b[3;33m"
SUCCESS = "\x1b[1;32m [SUCCESS]: "

chart_name = "{! cookiecutter.chart_name !}"
if hasattr(chart_name, "isidentifier"):
    assert chart_name.isidentifier(), "'{}' chart name is not a valid Python identifier.".format(chart_name)

assert chart_name == chart_name.lower(), "'{}' chart name should be all lowercase".format(chart_name)

assert "\\" not in "{! cookiecutter.author_name !}", "Don't include backslashes in author name."
