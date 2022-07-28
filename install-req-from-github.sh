#!/usr/bin/env bash

# The virtual env might have an older version, say version 21, and
# the latest pip might be higher, say version 22, and have fixes to
# dependency resolution or other fixes. Let's update it to be sure.

python3 -m pip install --upgrade pip

# The principle here is to install the latest versions from the code repo
# because I discovered that what you get from PyPI is in some cases broken
# and unusuable. (Specifically, a file in invenio-webhooks contains an import
# for something that doesn't exist.) The versions in the repos have many
# commits done after the released versions.  We have to be careful not to
# allow pip dependency resolution at this stage, because otherwise, pip
# will happily load something from PyPI, defeating the goal here.

github='git+https://github.com/inveniosoftware'

# This list is longer, based on what invenio-cli installs.

pip3 install --no-dependencies $github/invenio-access
pip3 install --no-dependencies $github/invenio-accounts
pip3 install --no-dependencies $github/invenio-admin
pip3 install --no-dependencies $github/invenio-app
pip3 install --no-dependencies $github/invenio-app-rdm
pip3 install --no-dependencies $github/invenio-assets
pip3 install --no-dependencies $github/invenio-base
pip3 install --no-dependencies $github/invenio-cache
pip3 install --no-dependencies $github/invenio-celery
pip3 install --no-dependencies $github/invenio-cli
pip3 install --no-dependencies $github/invenio-communities
pip3 install --no-dependencies $github/invenio-config
pip3 install --no-dependencies $github/invenio-db
pip3 install --no-dependencies $github/invenio-deposit
pip3 install --no-dependencies $github/invenio-drafts-resources
pip3 install --no-dependencies $github/invenio-files-rest
pip3 install --no-dependencies $github/invenio-formatter
pip3 install --no-dependencies $github/invenio-i18n
pip3 install --no-dependencies $github/invenio-indexer
pip3 install --no-dependencies $github/invenio-jsonschemas
pip3 install --no-dependencies $github/invenio-logging
pip3 install --no-dependencies $github/invenio-mail
pip3 install --no-dependencies $github/invenio-oaiserver
pip3 install --no-dependencies $github/invenio-oauth2server
pip3 install --no-dependencies $github/invenio-oauthclient
pip3 install --no-dependencies $github/invenio-pidstore
pip3 install --no-dependencies $github/invenio-previewer
pip3 install --no-dependencies $github/invenio-rdm-records
pip3 install --no-dependencies $github/invenio-records
pip3 install --no-dependencies $github/invenio-records-files
pip3 install --no-dependencies $github/invenio-records-permissions
pip3 install --no-dependencies $github/invenio-records-resources
pip3 install --no-dependencies $github/invenio-records-rest
pip3 install --no-dependencies $github/invenio-records-ui
pip3 install --no-dependencies $github/invenio-requests
pip3 install --no-dependencies $github/invenio-rest
pip3 install --no-dependencies $github/invenio-search
pip3 install --no-dependencies $github/invenio-search-ui
pip3 install --no-dependencies $github/invenio-theme
pip3 install --no-dependencies $github/invenio-userprofiles
pip3 install --no-dependencies $github/invenio-users-resources
pip3 install --no-dependencies $github/invenio-vocabularies
pip3 install --no-dependencies $github/invenio-webhooks

# For the final one, note that we now *do* allow dependency resolution.
# Whatever is needed will be stuff that's not one of the essential Invenio
# packages, so it's okay.  But, we have to capture the errors from pip about
# things not installed: those are items missed because we turned off
# dependency resolution for the items above.

missing=$(pip3 install $github/invenio.git 2>&1 | grep "which is not installed" | tr '<>' ' ' | cut -f4 -d' ' | sort -u)

# Now install the items reported by pip as missing.  We have to do this twice
# because for some reason, this step also resultsf in a few more missing
# dependencies being reported.

more_missing=$(pip3 install ${missing[@]} 2>&1 | grep "which is not installed" | tr '<>' ' ' | cut -f4 -d' ' | sort -u)

pip3 install ${missing[@]}

# Finally, install other non-Invenio stuff that Invenio needs.  This list was
# created by iteratively running the test cases, watching for missing
# packages, installing them, running tests again, etc., until there were no
# more errors

other=(WTForms==2.3.3 \
       Flask-Alembic \
       SQLAlchemy-Continuum \
       arrow \
       bleach \
       click-default-group \
       dictdiffer \
       elasticsearch \
       elasticsearch-dsl \
       flask-resources \
       fs \
       "ftfy<5.0.0" \
       github3.py \
       httpretty \
       humanize \
       jsonpatch \
       jsonref \
       jsonresolver \
       jsonschema \
       luqum \
       marshmallow_utils \
       mistune \
       mock \
       pytest \
       pytest-cov \
       pytest-pep8 \
       pyyaml \
       wand \
       xmltodict==0.12.0 \
)

pip3 install ${other[@]}

# Additional things needed for other parts, like the documentaion build chain.

pip3 install Sphinx check-manifest isort pydocstyle
