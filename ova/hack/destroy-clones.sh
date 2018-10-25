#!/bin/sh

# posix compliant
# verified by https://www.shellcheck.net

LINUX_DISTRO="${1:-${LINUX_DISTRO}}"
LINUX_DISTRO="${LINUX_DISTRO:-centos}"
case "${LINUX_DISTRO}" in
photon)
  GOVC_VM="${GOVC_VM:-${GOVC_FOLDER}/photon2}"
  ;;
centos)
  GOVC_VM="${GOVC_VM:-${GOVC_FOLDER}/yakity-centos}"
  ;;
*)
  echo "invalid target os: ${LINUX_DISTRO}" 1>&2; exit 1
esac

_uuids=$(govc vm.info -vm.ipath "${GOVC_VM}" -json -e | \
  jq -r '.VirtualMachines[0].Config.ExtraConfig | .[] | select(.Key == "guestinfo.yakity.CLUSTER_UUIDS") | .Value')

for _type_and_uuid in ${_uuids}; do
  _uuid="$(echo "${_type_and_uuid}" | awk -F: '{print $2}')"
  if echo "${_uuid}" | grep -iq "42301ab6-f495-1845-25ff-5190f281430a" || \
     echo "${_uuid}" | grep -iq "4230bd07-d968-0cae-5861-e93c47c19ed2"; then
    continue
  fi
  echo "destroying ${_type_and_uuid}"
  govc vm.destroy -vm.uuid "${_uuid}"
done
