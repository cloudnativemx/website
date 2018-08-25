#

echo "Building site with params $@"
rm -rf public && hugo "$@"  --verbose
