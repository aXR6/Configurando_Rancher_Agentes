#!/bin/sh

# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Starting cleanup..."
echo "Removing empty directories from etcd..."

cleanup_empty_dirs () {
  if etcdctl ls "$1" >/dev/null 2>&1; then
    for subdir in $(etcdctl ls -p "$1" | grep "/$"); do
      cleanup_empty_dirs "$subdir"
    done
  else
    echo "Removing empty key $1 ..."
    etcdctl rmdir "$1"
  fi
}

cleanup_empty_dirs "/registry"
echo "Done with cleanup."
