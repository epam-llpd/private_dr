FROM registry

ENV DOCKER_REGISTRY_CONFIG /registry/conf/config.yml
ENV SETTINGS_FLAVOR prod

ENV SEARCH_BACKEND sqlalchemy
ENV SQLALCHEMY_INDEX_DATABASE sqlite:////registry/sqlitedb/reg.db

ENV STORAGE_PATH /registry/data

EXPOSE 5000

CMD exec docker-registry
