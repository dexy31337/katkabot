To start container you need to:
a) Pass ENV variable TOKEN with telegram bot api token --env TOKEN=<your token>
b) Pass a persistent docker volume to store users mounted at /app/db, otherwise users will not be saved across container restarts.

Have fun
