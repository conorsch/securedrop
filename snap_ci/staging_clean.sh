#!/bin/bash
set -e

# Find the root of the git repository. A simpler implementation
# would be `git rev-parse --show-toplevel`, but that must be run
# from inside the git repository, whereas the solution below is
# directory agnostic. Exporting this variable doesn't work in snapci,
# so it must be rerun in each stage.
repo_root=$( dirname "$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd )" )

# Support Snap-CI cache directory, but also allow this script to be run locally.
tmp_dir="${SNAP_CACHE_DIR:-/tmp}"

# Initialize getopts for opt parsing
OPTIND=1
# Respect environment variables, but default to VirtualBox.
provider="${VAGRANT_DEFAULT_PROVIDER:-virtualbox}"
vm_reload="1"
wait_time="5s"
while getopts "c?d?x?p:?w:?" opt; do
    case "$opt" in
    c) cleanup ;;
    d) trap '[[ "$?" -eq 0 ]] && cleanup' EXIT && echo "WILL DESTROY ON CLEANUP";;
    x) trap cleanup EXIT ;;
    p) provider="$OPTARG" ;;
    w) wait_time="$OPTARG" ;;
    esac
done

# Remove short options from arg list, so $1 becomes the command to run.
shift "$((OPTIND - 1))"

function cleanup {
    # declare function for EXIT trap
    echo "Destroying VMs..."
    vagrant destroy build /staging/ -f
}

function create {
    # Create target hosts, but don't provision them yet. The shell provisioner
    # is only necessary for DigitalOcean hosts, and must run as a separate task
    # from the Ansible provisioner, otherwise it will only run on one of the two
    # hosts, due to the `ansible.limit = 'all'` setting in the Vagrantfile.
    vagrant up build /staging/ --no-provision --provider "${provider}"
}

function provision {
    # First run only the shell provisioner, to ensure the "vagrant"
    # user account exists with nopasswd sudo, then run Ansible.
    # Only matters for droplets; no-op for VirtualBox hosts.
    vagrant provision build /staging/ --provision-with shell
    vagrant provision /staging/ --provision-with ansible
}

function verify {
    # Run serverspec tests
    cd "${repo_root}/spec_tests/"
    bundle exec rake spec:build
    bundle exec rake spec:app-staging
    bundle exec rake spec:mon-staging
}

function usage {
    # Explain how to use the test suite.
    echo "Usage: $0 [options] <test|verify|create|destroy|setup>"
    echo ""
    echo "Commands:"
    echo "  create: run 'vagrant up' on target hosts, but do not provision"
    echo "  destroy: run 'vagrant destroy -f' on target hosts"
    echo "  converge: run 'vagrant provision' on target hosts"
    echo "  verify: run Serverspec tests for target hosts"
    echo "  test: alias for destroy, create, converge, verify, destroy"
    echo ""
    echo "Options:"
}

# Command names taken from test-kitchen, for consistency.
case "$1" in
destroy) cleanup && exit 0 ;;
create) create && exit 0 ;;
converge) provision && exit 0 ;;
verify) verify && exit 0 ;;
test)
    cleanup
    create
    provision
    if [[ "$vm_reload" == "1" ]]; then
        # Reload required to apply iptables rules.
        vagrant reload /staging/
        sleep "${wait_time}" # wait for servers to come back up
    fi
    verify
    exit 0
    ;;
*) usage && exit 1 ;;
esac

# Only enable auto-destroy for testing droplets
# if we're running in Snap-CI. If not running in Snap-CI,
# then executing this bash script will run all the tests
# locally.
if [[ "$SNAP_CI" == "true" ]]; then

    # Force DigitalOcean testing in Snap-CI.
    provider="digital_ocean"

    # Snap-CI does not allow large files for uploads in build stages. For local development,
    # the OSSEC packages should be built in the "ossec" repo and copied into the "build" directory.
    # Since these deb files seldom change, it's OK to pull them down for each build.
    # Certainly faster than building unchanged files repeatedly.
    wget http://apt.freedom.press/pool/main/o/ossec.net/ossec-server-2.8.2-amd64.deb \
        --continue --output-document "${repo_root}/build/ossec-server-2.8.2-amd64.deb"
    wget http://apt.freedom.press/pool/main/o/ossec.net/ossec-agent-2.8.2-amd64.deb \
        --continue --output-document "${repo_root}/build/ossec-agent-2.8.2-amd64.deb"

    # The Snap-CI nodes run CentOS, and so have an old version of rsync that doesn't support
    # --chown or --usermap, one of which is required for the build-debian-package role in staging.
    rsync_rpm="rsync-3.1.0-1.el6.rfx.x86_64.rpm"
    rsync_url="http://pkgs.repoforge.org/rsync/${rsync_rpm}"
    [[ -f "${tmp_dir}/${rsync_rpm}" ]] || wget -q "$rsync_url" -O "${tmp_dir}/${rsync_rpm}"
    sudo -E rpm -U --force -vh "${tmp_dir}/${rsync_rpm}"
fi

