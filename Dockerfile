FROM java:8-jre

# grab gosu for easy step-down from root
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4

ENV ELASTICSEARCH_VERSION 1.5.2

RUN echo "deb http://packages.elasticsearch.org/elasticsearch/${ELASTICSEARCH_VERSION%.*}/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN apt-get update \
	&& apt-get install elasticsearch=$ELASTICSEARCH_VERSION \
	&& rm -rf /var/lib/apt/lists/* && \
	/bin/sh /usr/share/elasticsearch/bin/plugin -install river-jdbc -url http://dl.bintray.com/jprante/elasticsearch-plugins/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/2.3.1/#elasticsearch-river-jdbc-2.3.1.zip && \
	curl -o mysql-connector-java-5.1.28.zip -L 'http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.28.zip/from/http://cdn.mysql.com/' && \
	unzip mysql-connector-java-5.1.28.zip && \
	rm -f mysql-connector-java-5.1.28.zip && \
	mv mysql-connector-java-5.1.28/mysql-connector-java-5.1.28-bin.jar /usr/share/elasticsearch/plugins/river-jdbc/mysql-connector-java-5.1.28-bin.jar

ENV PATH /usr/share/elasticsearch/bin:$PATH
COPY config /usr/share/elasticsearch/config

VOLUME /usr/share/elasticsearch/data

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
RUN chmod +x /docker-entrypoint.sh

EXPOSE 9200 9300

CMD ["elasticsearch"]
