SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # directory where script lives

cd $SCRIPT_DIR

docker-compose -f docker-compose.test.yml down -v
docker-compose -f docker-compose.test.yml up --abort-on-container-exit --build