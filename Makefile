

test:
	mongod --smallfiles --noprealloc --nojournal &
	coffee -c tests
	laika
