# AET Solo

A way to deploy AET on a standalon VM without Chef Server.

## Prerequisites

1. Berkshelf

## Installation

1. `$ ./download-cookbooks.sh`
2. If needed override aet cookbook with your version (will be needed for 7.6 upgrade)
3. `$ ./provision.sh`
