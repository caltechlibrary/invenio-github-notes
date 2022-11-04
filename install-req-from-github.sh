#!/usr/bin/env bash

if [[ -z "${VIRTUAL_ENV}" ]]; then
    echo "pyenv virtualenv not activated -- quitting"
    exit 1
fi

# The virtual env might have an older version, say version 21, and the latest
# pip might be higher, say version 22, and have fixes to dependency
# resolution or other fixes. Let's update it to be sure.

python3 -m pip install --upgrade pip

# Define some helper functions used below.

print_header() {
    printf '%.0s=' {1..80}; echo ""
    echo "========== installing $1"
    printf '%.0s=' {1..80}; echo ""
}

pip_install() {
    print_header $1
    if [[ -n "$2" ]]; then
        pip install "$2" $1
    else
        pip install $1
    fi
}

# Start by installing a closure set of all invenio modules needed.  I created
# this list iteratively, by installing invenio modules with normal pip
# dependency resolution turned on, one at a time, and watching for additional
# invenio modules that got installed, then adding them to the list below.
#
# The principle here is to install the latest versions from Github repos
# because I discovered that what invenio modules you get from PyPI are in
# some cases broken and unusuable.  The versions in the repos may also have
# many commits after the PyPI-released versions.
#
# Note that in this step, we have to be careful NOT to allow pip's automatic
# dependency resolution at this stage, because otherwise, pip will happily
# load dependent Invenio modules from PyPI, defeating the goal here.

github='git+https://github.com/inveniosoftware'

invenio=($github/invenio-access \
         $github/invenio-accounts \
         $github/invenio-admin \
         $github/invenio-administration \
         $github/invenio-app \
         $github/invenio-app-rdm \
         $github/invenio-assets \
         $github/invenio-base \
         $github/invenio-cache \
         $github/invenio-celery \
         $github/invenio-cli \
         $github/invenio-communities \
         $github/invenio-config \
         $github/invenio-db \
         $github/invenio-deposit \
         $github/invenio-drafts-resources \
         $github/invenio-files-rest \
         $github/invenio-formatter \
         $github/invenio-i18n \
         $github/invenio-indexer \
         $github/invenio-jsonschemas \
         $github/invenio-logging \
         $github/invenio-mail \
         $github/invenio-oaiserver \
         $github/invenio-oauth2server \
         $github/invenio-oauthclient \
         $github/invenio-pages \
         $github/invenio-pidstore \
#         $github/invenio-previewer \
         $github/invenio-rdm-records \
         $github/invenio-records \
         $github/invenio-records-files \
         $github/invenio-records-permissions \
         $github/invenio-records-resources \
         $github/invenio-records-rest \
         $github/invenio-records-ui \
         $github/invenio-requests \
         $github/invenio-rest \
         $github/invenio-search \
         $github/invenio-search-ui \
         $github/invenio-theme \
         $github/invenio-userprofiles \
         $github/invenio-users-resources \
         $github/invenio-userprofiles \
         $github/invenio-vocabularies \
         $github/docker-services-cli \
         $github/pytest-invenio \
         $github/Flask-Collect-Invenio.git \
         $github/Flask-Security-Invenio.git \
)

for module in ${invenio[@]}; do
    pip_install $module --no-dependencies
done

# Don't install this b/c need special version for my development:
#   pip install --no-dependencies $github/invenio-webhooks

# Now, for the final Invenio module, note that we now *do* allow dependency
# resolution.  In this step, whatever pip says is needed will be stuff that's
# not one of the essential Invenio packages (which we installed above), so
# it's okay to let pip install them from PyPI.  But, we have to take note of
# things that are flagged by pip as not being installed; those are items
# missed during the round of installations above because we turned off
# dependency resolution. We will install the missing items separately below.

print_header "invenio"
missing=$(pip install $github/invenio.git 2>&1 |\
          tee /dev/tty | grep "which is not installed" |\
          tr '<>,~=' ' ' | cut -f4 -d' ' | sort -u)

# The array $missing contains a list of the non-invenio packages that are not
# (yet) installed because we ran pip install --no-dependencies. Next, we
# install them these missing depdendencies, and track which dependencies are
# still not installed when we do so.  We have to do it this way because for
# some reason, this round of installations still results in a few more
# missing dependencies being reported.

# But first, special cases: some invenio modules need old versions of some
# python packages, and we have to install them explicitly before we let pip's
# automatic resolution grab newer versions. So:

pip_install nbconvert==6.5.4
pip_install mistune==0.8.1
pip_install docker==5.0.3
pip_install cookiecutter==1.7.3
pip_install Flask-SQLAlchemy==2.5.1
pip_install uritemplate.py==0.6.0
pip_install virtualenv==20.13.0

# OK, now let's get to it.

more_missing=()
for pkg in ${missing[@]}; do
    print_header $pkg
    more_missing+=$(pip install $pkg 2>&1 |\
                    tee /dev/stderr | grep "which is not installed" |\
                    tr '<>,~=' ' ' | cut -f4 -d' ' | sort -u)
    more_missing+=' '
done

# Uniquefy the list.

missing=($(printf "%s\n" "${more_missing[@]}" | sort -u | tr '\n' ' '))

# 3rd round: install the stuff flagged as missing in the 2nd round above.

for pkg in ${missing[@]}; do
    pip_install $pkg
done

# Finally, install other non-Invenio stuff needed for Invenio development.
# This list was created by iteratively running the test cases, watching for
# missing packages, installing them, running tests again, etc., until there
# were no more errors.
#
# WARNING: in some cases the order here matters. Don't just blindly put this
# into alphabetical order.

other=(autosemver==1.0.0 \
       isbnid_fork \
       WTForms==2.3.3 \
       Flask-Alembic \
       Flask-Menu \
       Flask-Breadcrumbs \
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
       jsmin \
       luqum \
       marshmallow_utils \
       mock \
       node-semver==0.1.1 \
       pytest \
       pytest-cov \
       pytest-pep8 \
       pyyaml \
       wand \
       webargs==5.5.2 \
       xmltodict==0.12.0 \
       Sphinx \
       check-manifest \
       isort \
       pydocstyle \
       Flask-Debugtoolbar \
)

for pkg in ${other[@]}; do
    pip_install $pkg
done
