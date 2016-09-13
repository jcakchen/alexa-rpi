#!/bin/sh
#
# Copyright (c) Sensory, Inc. 2016.  All Rights Reserved.
# http://sensory.com/
#
# You may not use these files except in compliance with the license.
# A copy of the license is located the "LICENSE.txt" file accompanying
# this source. This file is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Build the SensoryWakeWordEngine plug-in for WakeWordAgent Raspberry Pi project.
#
# Author: Jacques H. de Villiers

set -e

# Verify that we're in the expected location.
d=$(realpath $0)
d=${d%/*}
if [ "${d##*/}" != "sensory" ]; then
 echo "ERROR: SensoryWakeWordEngine is in $d, not the sensory subdirectory." >&2
 exit 1
fi

# Verify that CMakeLists.txt in .. is as expected.
grep -q WITH_SENSORY ${d%/*}/CMakeLists.txt || (
 echo "ERROR: This plug-in must be installed in a subdirectory of WakeWordEngine." >&2
 exit 2
)

# Check whether the LICENSE.txt has been accepted.
${d}/bin/license.sh

# Create the build/ subdirectory, configure and make.
b=${d%/*}/build
set -x
mkdir -p $b
cd $b
cmake -DWITH_SENSORY=ON ..
make -j4
ln -sf $d/models/spot-alexa-rpi-31000.snsr spot-alexa-rpi.snsr

set +x
# Report success
echo "SUCCESS: Run ./WakeWordAgent in $b to start."
