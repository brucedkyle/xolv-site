# Query ElasticSearch using Chat

In this tutorial, you will build a chat interface to ElasticSearch to query your data and to determine anamolies. You'll do this locally using Hugging Face models and LangChain.

## Prerequisites

You will need:

- [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) but should also work on other Linux
- [Docker](https://www.docker.com/) <!-- TODO Podman --> 
- Python

## Install Elasticsearch and Kibana

Follow the steps here to install [Elasticsearch and Kibana locally](https://github.com/elastic/start-local?tab=readme-ov-file#-try-elasticsearch-and-kibana-locally)

This script creates an `elastic-start-local` folder containing:

`docker-compose.yml`: Docker Compose configuration for Elasticsearch and Kibana
`.env`: Environment settings, including the Elasticsearch password
`uninstall.sh`: The script to uninstall Elasticsearch and Kibana

With these endpoints: 

- Elasticsearch will be running at http://localhost:9200
- Kibana will be running at http://localhost:5601

An API key for Elasticsearch is generated and stored in the `.env` file as `ES_LOCAL_API_KEY`. Use this key to connect to Elasticsearch with the Elastic SDK or REST API.

Check the connection to Elasticsearch using curl in the `elastic-start-local` folder:

```bash
cd elastic-start-local
source .env
curl $ES_LOCAL_URL -H "Authorization: ApiKey ${ES_LOCAL_API_KEY}"
```

If you need to restart or stop the service, use `docker compose`:

- Restart services: `docker compose up --wait`
- Stop services: `docker compose stop`

To troubleshoot your installation, see [Try Elasticsearch and Kibana locally](https://github.com/elastic/start-local?tab=readme-ov-file#-logging)


## References

- Elastic Search documentation [Set up Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html)