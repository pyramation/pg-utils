
up:
	docker-compose up -d

down:
	docker-compose down -v

ssh:
	docker exec -it pg-utils-postgres /bin/bash

install:
	docker exec pg-utils-postgres /sql-extensions/install.sh

  