services:
  mongo:
    container_name: lol
    image: mongo:8.2
    restart: always
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: admin

  # mongo-express:
  #   image: mongo-express
  #   restart: always
  #   ports:
  #     - 8081:8081
  #   environment:
  #     ME_CONFIG_MONGODB_URL: mongodb://root:example@mongo:27017/
  #     ME_CONFIG_BASICAUTH_ENABLED: true
  #     ME_CONFIG_BASICAUTH_USERNAME: mongoexpressuser
  #     ME_CONFIG_BASICAUTH_PASSWORD: mongoexpresspass
## vi: set ft=yaml:
